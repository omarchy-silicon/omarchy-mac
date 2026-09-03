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
test_root="$(realpath "$test_tmp")"
fixture="$test_tmp/omarchy"
mkdir -p "$fixture/bin" "$fixture/platform/apple-silicon" "$fixture/install/hardware/apple"
cp "$command" "$fixture/bin/omarchy-hw-apple-platform-admission"
cp "$projection" "$fixture/platform/apple-silicon/board-registry-projection.json"
cp "$lock" "$fixture/platform/apple-silicon/board-registry-projection.lock.json"
chmod +x "$fixture/bin/omarchy-hw-apple-platform-admission"
compatible_input="$test_tmp/compatible"
printf 'apple,arm-platform\0apple,j313\0apple,t8103\0' >"$compatible_input"
compatible="$(realpath "$compatible_input")"

run_admission() {
  local status=0
  output=$(OMARCHY_PATH="$fixture" \
    "$fixture/bin/omarchy-hw-apple-platform-admission" --compatible "$compatible" 2>&1) || status=$?
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
  result=$(OMARCHY_PATH="$fixture" \
    "$fixture/bin/omarchy-hw-apple-platform-admission" --compatible "$compatible" 2>&1) || status=$?
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

printf 'raspberrypi,4-model-b\0' >"$compatible"
mapfile -t non_apple < <(run_admission)
[[ ${non_apple[0]} == 0 ]] || fail "valid non-Apple aarch64 identity is not blocked" "status ${non_apple[0]} output ${non_apple[*]:1}"
[[ $(jq -r '.decision' <<<"${non_apple[1]}") == NOT_APPLICABLE ]] || fail "valid non-Apple identity returns NOT_APPLICABLE"
pass "valid non-Apple identity returns NOT_APPLICABLE"

printf '%s\0' 'apple,arm-platform' >"$compatible"
assert_error "missing board selector is rejected" COMPATIBLE_MISMATCH
mkdir "$test_tmp/compatible-directory"
compatible_directory="$(realpath "$test_tmp/compatible-directory")"
assert_error_with_path() {
  local label="$1" expected="$2" path="$3" status=0 result
  result=$(OMARCHY_PATH="$fixture" "$fixture/bin/omarchy-hw-apple-platform-admission" --compatible "$path" 2>&1) || status=$?
  (( status != 0 )) || fail "$label" "checker unexpectedly passed"
  [[ $(jq -r '.error.code' <<<"$result") == "$expected" ]] || fail "$label" "expected $expected, got $result"
  pass "$label"
}
assert_error_with_path "compatible directory is rejected" COMPATIBLE_NOT_REGULAR "$compatible_directory"
mkfifo "$test_tmp/compatible-fifo"
fifo_path="$(realpath "$test_tmp/compatible-fifo")"
if timeout 2 "$fixture/bin/omarchy-hw-apple-platform-admission" --compatible "$fifo_path" >/dev/null 2>&1; then
  fail "compatible FIFO is rejected without blocking"
fi
pass "compatible FIFO is rejected without blocking"
printf 'apple,j313\0' >"$test_root/compatible-target"
ln -s "$test_root/compatible-target" "$test_root/compatible-leaf-link"
assert_error_with_path "compatible leaf symlink is rejected" COMPATIBLE_READ_FAILED "$test_root/compatible-leaf-link"
mkdir "$test_root/compatible-parent"
ln -s "$test_root/compatible-parent" "$test_root/compatible-parent-link"
assert_error_with_path "compatible parent symlink is rejected" COMPATIBLE_READ_FAILED "$test_root/compatible-parent-link/compatible"

# Exercise the installer seam with a stubbed uname, run_logged, and a command
# reached through OMARCHY_PATH.  No compatible environment override is used.
mkdir -p "$test_tmp/stub-bin"
cat >"$test_tmp/stub-bin/uname" <<'SH'
#!/bin/bash
[[ ${1:-} == "-m" ]] && printf '%s\n' "${TEST_ARCH:-aarch64}" || /usr/bin/uname "$@"
SH
chmod +x "$test_tmp/stub-bin/uname"
gate_root="$test_tmp/gate-root"
mkdir -p "$gate_root/bin"
cat >"$gate_root/bin/omarchy-hw-apple-platform-admission" <<'SH'
#!/bin/bash
printf 'admission\n' >>"$ADMISSION_CALLS"
exit "${ADMISSION_STATUS:-3}"
SH
chmod +x "$gate_root/bin/omarchy-hw-apple-platform-admission"
calls="$test_tmp/install-calls"
if PATH="$test_tmp/stub-bin:$PATH" TEST_ARCH=aarch64 OMARCHY_PATH="$gate_root" OMARCHY_INSTALL="$ROOT/install" \
  CALLS="$calls" ADMISSION_CALLS="$test_tmp/admission-calls" ADMISSION_STATUS=3 bash -eE -o pipefail -c '
    run_logged() { printf "%s\n" "$1" >>"$CALLS"; if [[ $1 == *"platform-admission.sh" ]]; then source "$1"; fi; }
    source "$1"
  ' bash "$ROOT/install/hardware/all.sh"; then
  fail "denied Apple Silicon gate aborts hardware setup"
fi
grep -q 'hardware/apple/platform-admission.sh' "$calls" || fail "Apple gate is wired into hardware setup"
[[ $(wc -l <"$test_tmp/admission-calls" | tr -d ' ') == 1 ]] || fail "denied gate invokes admission command once"
! grep -q 'hardware/vulkan.sh' "$calls" || fail "Apple admission precedes generic Vulkan mutation"
! grep -q 'hardware/apple/fix-spi-keyboard.sh' "$calls" || fail "Apple mutating leaf is behind admission gate"
pass "denied Apple Silicon gate aborts before every mutation"

: >"$calls"
: >"$test_tmp/admission-calls"
if PATH="$test_tmp/stub-bin:$PATH" TEST_ARCH=aarch64 OMARCHY_PATH="$gate_root" OMARCHY_INSTALL="$ROOT/install" \
  CALLS="$calls" ADMISSION_CALLS="$test_tmp/admission-calls" ADMISSION_STATUS=0 bash -eE -o pipefail -c '
    run_logged() { printf "%s\n" "$1" >>"$CALLS"; if [[ $1 == *"platform-admission.sh" ]]; then source "$1"; fi; }
    source "$1"
  ' bash "$ROOT/install/hardware/all.sh"; then
  :
else
  fail "passing aarch64 admission permits subsequent setup"
fi
gate_line=$(grep -n 'hardware/apple/platform-admission.sh' "$calls" | cut -d: -f1)
vulkan_line=$(grep -n 'hardware/vulkan.sh' "$calls" | cut -d: -f1)
apple_line=$(grep -n 'hardware/apple/fix-spi-keyboard.sh' "$calls" | cut -d: -f1)
(( gate_line < vulkan_line && gate_line < apple_line )) || fail "admission precedes generic and Apple mutation"
pass "aarch64 admission runs before generic Vulkan and Apple leaves"

: >"$calls"
if PATH="$test_tmp/stub-bin:$PATH" TEST_ARCH=x86_64 OMARCHY_PATH="$gate_root" OMARCHY_INSTALL="$ROOT/install" \
  CALLS="$calls" ADMISSION_CALLS="$test_tmp/admission-calls" ADMISSION_STATUS=99 bash -eE -o pipefail -c '
    run_logged() { printf "%s\n" "$1" >>"$CALLS"; if [[ $1 == *"platform-admission.sh" ]]; then source "$1"; fi; }
    source "$1"
  ' bash "$ROOT/install/hardware/all.sh"; then
  :
else
  fail "x86 hardware setup remains unchanged"
fi
! grep -q 'platform-admission.sh' "$calls" || fail "x86 hardware setup does not invoke admission"
grep -q 'hardware/vulkan.sh' "$calls" || fail "x86 hardware setup retains generic leaves"
pass "x86 hardware setup remains unchanged"

pass "Apple platform admission hostile-case suite"
