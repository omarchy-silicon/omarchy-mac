#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-update-platform"
[[ -x $command ]] || fail "platform update command is executable"
grep -q '# omarchy:group=update' "$command" || fail "platform update command has update metadata"
pass "platform update command is executable and grouped"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

copy_with_arch() {
  local source="$1" destination="$2" architecture="$3"
  sed "s|/usr/bin/uname -m|printf '%s\\n' '$architecture'|g" "$source" >"$destination"
  chmod +x "$destination"
}

copy_with_probe() {
  local source="$1" destination="$2" probe="$3"
  sed "s|/usr/bin/uname -m|$probe|g" "$source" >"$destination"
  chmod +x "$destination"
}

copy_with_trusted_arch() {
  local source="$1" destination="$2" architecture="$3" trusted_root="$4"
  sed -e "s|/usr/share/omarchy|$trusted_root|g" -e "s|/usr/bin/uname -m|printf '%s\\n' '$architecture'|g" "$source" >"$destination"
  chmod +x "$destination"
}

run_expect_status() {
  local expected="$1"
  shift
  local status=0
  "$@" >/dev/null 2>&1 || status=$?
  (( status == expected )) || fail "command returns expected status $expected" "got $status: $*"
}

json_code() {
  python3 -c 'import json,sys; print(json.load(sys.stdin)["code"])'
}

platform_aarch64="$test_tmp/platform-aarch64"
platform_x86="$test_tmp/platform-x86"
copy_with_arch "$command" "$platform_aarch64" aarch64
copy_with_arch "$command" "$platform_x86" x86_64

output=$($platform_aarch64 status 2>/dev/null) && fail "aarch64 status does not silently succeed without authority"
[[ $(json_code <<<"$output") == UPDATE_AUTHORITY_UNAVAILABLE ]] || fail "aarch64 status reports the authority hold" "$output"
pass "aarch64 status is a typed authority hold"

output=$($platform_aarch64 apply 2>/dev/null) && fail "aarch64 apply does not fail closed"
[[ $(json_code <<<"$output") == UPDATE_AUTHORITY_UNAVAILABLE ]] || fail "aarch64 apply reports the authority hold" "$output"
pass "aarch64 apply is a typed fail-closed hold"

output=$($platform_x86 status 2>/dev/null) || fail "x86 status is not not-applicable"
[[ $(json_code <<<"$output") == NOT_APPLICABLE ]] || fail "x86 status is not-applicable" "$output"
pass "x86 status remains not-applicable"

run_expect_status 2 "$platform_aarch64" stable
output=$($platform_aarch64 --version 2>/dev/null) && fail "selector-like option is accepted"
[[ $(json_code <<<"$output") == UPDATE_INVALID_ARGUMENT ]] || fail "selector-like option is typed as invalid" "$output"
pass "version/channel/candidate selectors are closed"
output=$($platform_aarch64 'x"}' 2>/dev/null) && fail "hostile selector is accepted"
[[ $(json_code <<<"$output") == UPDATE_INVALID_ARGUMENT ]] || fail "hostile selector remains typed" "$output"
pass "hostile selectors cannot corrupt the JSON result"

for probe in 'false' "printf ''" "printf 'mystery\\n'"; do
  identity_copy="$test_tmp/identity-${#probe}"
  copy_with_probe "$command" "$identity_copy" "$probe"
  output=$($identity_copy status 2>/dev/null) && fail "identity probe unexpectedly succeeds: $probe"
  [[ $(json_code <<<"$output") == PLATFORM_IDENTITY_* ]] || fail "identity failure is typed: $probe" "$output"
  pass "identity failure is fail-closed: $probe"
done

fake_omarchy="$test_tmp/fake-omarchy"
trusted_omarchy="$test_tmp/trusted-omarchy"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$fake_omarchy/bin" "$trusted_omarchy/bin" "$stub_bin"
cat >"$trusted_omarchy/bin/omarchy-update-platform" <<'SH'
#!/bin/bash
printf 'platform-update-platform\n' >>"$CALLS"
printf '%s\n' '{"schema":"omarchy.platform-update/v1","operation":"apply","decision":"HOLD","code":"UPDATE_AUTHORITY_UNAVAILABLE","process_status":3}'
exit 3
SH
chmod +x "$trusted_omarchy/bin/omarchy-update-platform"
cat >"$fake_omarchy/bin/omarchy-update-platform" <<'SH'
#!/bin/bash
printf 'untrusted-platform-update-platform\n' >>"$CALLS"
printf '%s\n' '{"schema":"omarchy.platform-update/v1","operation":"apply","decision":"ALLOW","code":"SENTINEL_AUTHORITY","process_status":0}'
exit 0
SH
chmod +x "$fake_omarchy/bin/omarchy-update-platform"
for helper in script omarchy-update-lock omarchy-update-pkg-prune sudo pacman; do
  cat >"$stub_bin/$helper" <<'SH'
#!/bin/bash
printf '%s\n' "${0##*/}" >>"$CALLS"
exit 0
SH
  chmod +x "$stub_bin/$helper"
done
update_aarch64="$test_tmp/update-aarch64"
copy_with_trusted_arch "$ROOT/bin/omarchy-update" "$update_aarch64" aarch64 "$trusted_omarchy"
set +e
OMARCHY_PATH="$trusted_omarchy" CALLS="$calls" PATH="$stub_bin:$PATH" "$update_aarch64" -y >"$test_tmp/update.out" 2>&1
status=$?
set -e
(( status == 3 )) || fail "aarch64 update propagates the platform hold" "status $status"
grep -qx 'platform-update-platform' "$calls" || fail "aarch64 update invokes the platform entrypoint"
[[ $(grep -c . "$calls") == 1 ]] || fail "aarch64 update reaches no legacy helper" "$(cat "$calls")"
pass "aarch64 update gates before logging and mutation"

set +e
output=$(env -u OMARCHY_PATH PATH="$stub_bin:$PATH" "$update_aarch64" -y 2>&1)
status=$?
set -e
(( status == 3 )) || fail "aarch64 update rejects an unset product path" "status $status"
[[ $(json_code <<<"$output") == UPDATE_ENTRYPOINT_UNAVAILABLE ]] || fail "unset product path is typed" "$output"
pass "aarch64 update rejects an unset product path without shell errors"
linked_path="$test_tmp/omarchy-link"
ln -s "$trusted_omarchy" "$linked_path"
set +e
output=$(OMARCHY_PATH="$linked_path" PATH="$stub_bin:$PATH" "$update_aarch64" -y 2>&1)
status=$?
set -e
(( status == 3 )) || fail "aarch64 update rejects a substituted product path"
[[ $(json_code <<<"$output") == UPDATE_ENTRYPOINT_UNAVAILABLE ]] || fail "substituted product path is typed" "$output"
pass "aarch64 update rejects a product-path symlink"
: >"$calls"
set +e
output=$(OMARCHY_PATH="$fake_omarchy" CALLS="$calls" PATH="$stub_bin:$PATH" "$update_aarch64" -y 2>&1)
status=$?
set -e
(( status == 3 )) || fail "aarch64 update rejects an untrusted normal product path"
[[ $(json_code <<<"$output") == UPDATE_ENTRYPOINT_UNAVAILABLE ]] || fail "untrusted product path is typed" "$output"
[[ ! -s $calls ]] || fail "untrusted broker was executed" "$(cat "$calls")"
pass "aarch64 update rejects an untrusted fake broker"
symlink_root="$test_tmp/symlink-root"
mkdir -p "$symlink_root/bin"
ln -s "$trusted_omarchy/bin/omarchy-update-platform" "$symlink_root/bin/omarchy-update-platform"
symlink_update="$test_tmp/update-symlink-root"
copy_with_trusted_arch "$ROOT/bin/omarchy-update" "$symlink_update" aarch64 "$symlink_root"
: >"$calls"
run_expect_status 3 env OMARCHY_PATH="$symlink_root" CALLS="$calls" PATH="$stub_bin:$PATH" "$symlink_update" -y
[[ ! -s $calls ]] || fail "symlinked installed broker was executed"
pass "aarch64 update rejects a symlinked installed broker"
run_expect_status 2 "$update_aarch64" -y extra

leaves=(omarchy-update-system-pkgs omarchy-update-firmware omarchy-refresh-pacman omarchy-refresh-pacman-mirrorlist omarchy-reinstall-pkgs omarchy-reinstall omarchy-update-system-pkgs-when-conflicted omarchy-update-keyring omarchy-update-pkg-prune omarchy-update-restart omarchy-update-dev omarchy-snapshot omarchy-update-aur-pkgs omarchy-update-mise omarchy-update-orphan-pkgs)
for leaf in "${leaves[@]}"; do
  leaf_copy="$test_tmp/$leaf"
  copy_with_arch "$ROOT/bin/$leaf" "$leaf_copy" aarch64
  : >"$calls"
  run_expect_status 3 env CALLS="$calls" PATH="$stub_bin:$PATH" OMARCHY_PATH="$fake_omarchy" "$leaf_copy" stable
  [[ ! -s $calls ]] || fail "$leaf refuses before mutators" "$(cat "$calls")"
  pass "$leaf is closed on aarch64 before mutation"
done

for source in "$ROOT/bin/omarchy-refresh-pacman" "$ROOT/bin/omarchy-snapshot"; do
  source_copy="$test_tmp/$(basename "$source")-extra"
  copy_with_arch "$source" "$source_copy" x86_64
  run_expect_status 1 "$source_copy" stable extra
  pass "$(basename "$source") rejects extra arguments before I/O"
done

for leaf in "${leaves[@]}"; do
  leaf_copy="$test_tmp/$leaf"
  : >"$calls"
  run_expect_status 3 env CALLS="$calls" PATH="$stub_bin:$PATH" OMARCHY_PATH="$fake_omarchy" bash -c 'source "$1"' bash "$leaf_copy"
  [[ ! -s $calls ]] || fail "sourcing $leaf reaches no mutator" "$(cat "$calls")"
  pass "sourcing $leaf remains closed on aarch64"
done

channel_copy="$test_tmp/channel-set"
copy_with_arch "$ROOT/bin/omarchy-channel-set" "$channel_copy" aarch64
for selector in stable rc edge dev; do
  : >"$calls"
  run_expect_status 1 env HOME="$test_tmp/home" CALLS="$calls" PATH="$stub_bin:$PATH" OMARCHY_PATH="$fake_omarchy" "$channel_copy" "$selector"
  [[ ! -s $calls ]] || fail "channel selector $selector reaches no mutator"
  pass "channel selector $selector is closed on aarch64"
done
run_expect_status 1 "$channel_copy" stable extra
pass "channel-set rejects extra arguments before I/O"

guard_copy="$test_tmp/update-pacman-guard"
copy_with_arch "$ROOT/bin/omarchy-update-pacman-guard" "$guard_copy" aarch64
for command_line in 'pacman -Syu --noconfirm' 'pacman -S firefox' 'not-an-upgrade'; do
  output=$(OMARCHY_PACMAN_CMDLINE="$command_line" OMARCHY_UPDATE_PACMAN=1 OMARCHY_ALLOW_DIRECT_PACMAN=1 "$guard_copy" 2>&1) && fail "aarch64 pacman guard accepts input: $command_line"
  grep -q 'omarchy update' <<<"$output" || fail "aarch64 pacman guard explains the closed update path" "$output"
  pass "aarch64 pacman guard ignores command-line evidence: $command_line"
done
args_line=$(grep -n 'pacman_args=()' "$guard_copy" | cut -d: -f1)
deny_line=$(grep -n '^  aarch64)' "$guard_copy" | cut -d: -f1)
(( deny_line < args_line )) || fail "aarch64 pacman denial precedes command-line and proc reads"
pass "aarch64 pacman denial precedes command-line and proc reads"
guard_x86="$test_tmp/update-pacman-guard-x86"
copy_with_arch "$ROOT/bin/omarchy-update-pacman-guard" "$guard_x86" x86_64
OMARCHY_PACMAN_CMDLINE='pacman -Syu --noconfirm' OMARCHY_UPDATE_PACMAN=1 "$guard_x86" || fail "x86 pacman update context changed"
pass "x86 pacman update context remains allowed"

for helper in omarchy-update-lock omarchy-update-requires-free-space omarchy-update-confirm omarchy-update-pkg-prune omarchy-snapshot omarchy-update-stay-awake omarchy-update-dev omarchy-update-keyring omarchy-update-system-pkgs omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-mise omarchy-update-orphan-pkgs omarchy-update-analyze-logs omarchy-update-status omarchy-update-restart; do
  cat >"$stub_bin/$helper" <<'SH'
#!/bin/bash
printf '%s\n' "${0##*/}" >>"$CALLS"
exit 0
SH
  chmod +x "$stub_bin/$helper"
done
update_x86="$test_tmp/update-x86"
copy_with_arch "$ROOT/bin/omarchy-update" "$update_x86" x86_64
: >"$calls"
CALLS="$calls" PATH="$stub_bin:$PATH" OMARCHY_UPDATE_LOGGED=1 "$update_x86" -y >/dev/null 2>&1 || fail "x86 update legacy path changed"
grep -qx 'omarchy-update-system-pkgs' "$calls" || fail "x86 update still reaches system package update"
pass "x86 update preserves the legacy sequence"

pass "platform update hostile routing suite"
