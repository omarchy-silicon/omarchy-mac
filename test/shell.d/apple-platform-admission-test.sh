#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-hw-apple-platform-admission"
projection="$ROOT/platform/apple-silicon/board-registry-projection.json"
lock="$ROOT/platform/apple-silicon/board-registry-projection.lock.json"
[[ -x $command ]] || fail "Apple platform admission command is executable"
[[ -f $projection && -f $lock ]] || fail "Q-00 projection and lock are shipped"
pass "Q-00 projection and closed lock are shipped"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
fixture="$test_tmp/omarchy"
mkdir -p "$fixture/bin" "$fixture/platform/apple-silicon" "$fixture/install/hardware/apple"
cp "$command" "$fixture/bin/omarchy-hw-apple-platform-admission"
cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
cp "$lock" "$fixture/platform/apple-silicon/board-registry-projection.lock.json"
chmod +x "$fixture/bin/omarchy-hw-apple-platform-admission"
compatible="$test_tmp/compatible"
printf 'apple,arm-platform\0apple,j313\0apple,t8103\0' >"$compatible"

run_admission() {
  local status=0
  output=$(OMARCHY_PATH="$fixture" OMARCHY_APPLE_COMPATIBLE="$compatible" \
    "$fixture/bin/omarchy-hw-apple-platform-admission" 2>&1) || status=$?
  printf '%s\n' "$status" "$output"
}

mapfile -t valid < <(run_admission)
[[ ${valid[0]} == 3 ]] || fail "matching J313 is denied by explicit NOT_ADMISSIBLE" "status ${valid[0]} output ${valid[*]:1}"
[[ $(jq -r '.decision' <<<"${valid[1]}") == DENY ]] || fail "admission emits a deny decision"
[[ $(jq -r '.reason' <<<"${valid[1]}") == NOT_ADMISSIBLE ]] || fail "admission reports NOT_ADMISSIBLE"
[[ $(jq -r '.selector' <<<"${valid[1]}") == j313 ]] || fail "admission reports exact board selector"
pass "matching J313 is structurally validated then denied"

baseline_projection=$(sha256sum "$fixture/platform/apple-silicon/board-registry-projection.json")
baseline_lock=$(sha256sum "$fixture/platform/apple-silicon/board-registry-projection.lock.json")
assert_error() {
  local label="$1" expected="$2"
  shift 2
  local status=0 result
  result=$(OMARCHY_PATH="$fixture" OMARCHY_APPLE_COMPATIBLE="$compatible" \
    "$fixture/bin/omarchy-hw-apple-platform-admission" 2>&1) || status=$?
  (( status != 0 )) || fail "$label" "checker unexpectedly passed"
  [[ $(jq -r '.error.code' <<<"$result") == "$expected" ]] || fail "$label" "expected $expected, got $result"
  [[ $(jq -c '.' <<<"$result" | wc -l | tr -d ' ') == 1 ]] || fail "$label" "more than one JSON result"
  pass "$label"
}
mutate_projection() {
  local operation="$1"
  case "$operation" in
    unknown) jq '.payload.unexpected=true' "$projection" >"$fixture/platform/apple-silicon/board-registry-projection.json" ;;
    missing) jq 'del(.payload.soc_id)' "$projection" >"$fixture/platform/apple-silicon/board-registry-projection.json" ;;
    float) jq '.payload.admissible=1.0' "$projection" >"$fixture/platform/apple-silicon/board-registry-projection.json" ;;
    bool_as_int) jq '.payload.admissible=0' "$projection" >"$fixture/platform/apple-silicon/board-registry-projection.json" ;;
    sentinel) jq '.record_digest="sha256\u003a" + ("1" * 64)' "$projection" >"$fixture/platform/apple-silicon/board-registry-projection.json" ;;
    ambiguous) jq '.payload.identity_match.linux_compatible="apple,j313-extra"' "$projection" >"$fixture/platform/apple-silicon/board-registry-projection.json" ;;
  esac
}
for operation in unknown missing float bool_as_int sentinel ambiguous; do
  cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
  mutate_projection "$operation"
  case "$operation" in
    unknown) expected=UNKNOWN_FIELD ;;
    missing) expected=MISSING_FIELD ;;
    float) expected=FLOAT_FORBIDDEN ;;
    bool_as_int) expected=TYPE_MISMATCH ;;
    sentinel) expected=SENTINEL_DIGEST ;;
    ambiguous) expected=INVALID_VALUE ;;
  esac
  assert_error "hostile projection $operation is rejected" "$expected"
done
cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
cp "$lock" "$fixture/platform/apple-silicon/board-registry-projection.lock.json"
printf ' ' >>"$fixture/platform/apple-silicon/board-registry-projection.json"
printf '{"x":1}' >>"$fixture/platform/apple-silicon/board-registry-projection.json"
assert_error "trailing JSON data is rejected" TRAILING_DATA
cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
python3 - "$fixture/platform/apple-silicon/board-registry-projection.json" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
path.write_bytes(b'{"x":' + b'[' * 20 + b'0' + b']' * 20 + b'}')
PY
assert_error "deep JSON is rejected" DEPTH_LIMIT
cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
python3 - "$fixture/platform/apple-silicon/board-registry-projection.json" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
path.write_bytes(path.read_bytes() + b' ' * (64 * 1024))
PY
assert_error "oversize JSON is rejected" SIZE_LIMIT
cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
printf '%s\n' '{"projection_id":"apple:j313","projection_id":"apple:j313"}' >"$fixture/platform/apple-silicon/board-registry-projection.json"
assert_error "duplicate JSON keys are rejected" DUPLICATE_KEY
cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
jq '.source.commit="0000000000000000000000000000000000000000000000000000000000000000"' "$lock" >"$fixture/platform/apple-silicon/board-registry-projection.lock.json"
assert_error "provenance lock mismatch is rejected" PROVENANCE_MISMATCH
cp "$lock" "$fixture/platform/apple-silicon/board-registry-projection.lock.json"

printf 'apple,arm-platform\0apple,j313-extra\0' >"$compatible"
assert_error "substring compatible is not accepted" COMPATIBLE_MISMATCH
printf 'apple,arm-platform\0apple,j313\0apple,j313\0' >"$compatible"
assert_error "duplicate compatible records are rejected" COMPATIBLE_AMBIGUOUS
printf 'apple,arm-platform\0apple,j274\0' >"$compatible"
assert_error "different board compatible is rejected" COMPATIBLE_MISMATCH
printf 'apple,arm-platform\0apple,j313\0' >"$compatible"
[[ $(sha256sum "$fixture/platform/apple-silicon/board-registry-projection.json") == "$baseline_projection" ]] || fail "admission does not mutate projection"
[[ $(sha256sum "$fixture/platform/apple-silicon/board-registry-projection.lock.json") == "$baseline_lock" ]] || fail "admission does not mutate lock"
pass "hostile inputs fail without artifact mutation"

# Exercise the installer seam with a stubbed uname and run_logged.  The denied
# gate must prevent the first Apple mutating leaf from being reached.
mkdir -p "$test_tmp/stub-bin"
cat >"$test_tmp/stub-bin/uname" <<'SH'
#!/bin/bash
[[ ${1:-} == "-m" ]] && printf '%s\n' "aarch64" || /usr/bin/uname "$@"
SH
chmod +x "$test_tmp/stub-bin/uname"
calls="$test_tmp/install-calls"
if PATH="$test_tmp/stub-bin:$PATH" OMARCHY_PATH="$fixture" OMARCHY_INSTALL="$ROOT/install" OMARCHY_APPLE_COMPATIBLE="$compatible" \
  CALLS="$calls" bash -eE -o pipefail -c '
    run_logged() { printf "%s\n" "$1" >>"$CALLS"; if [[ $1 == *"platform-admission.sh" ]]; then source "$1"; fi; }
    source "$1"
  ' bash "$ROOT/install/hardware/all.sh"; then
  fail "denied Apple Silicon gate aborts hardware setup"
fi
grep -q 'hardware/apple/platform-admission.sh' "$calls" || fail "Apple gate is wired into hardware setup"
! grep -q 'hardware/apple/fix-spi-keyboard.sh' "$calls" || fail "Apple mutating leaf is behind admission gate"
pass "denied Apple Silicon gate aborts before Apple mutation"

pass "Apple platform admission hostile-case suite"
