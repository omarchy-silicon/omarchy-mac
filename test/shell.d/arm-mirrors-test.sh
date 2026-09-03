#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/install/helpers/set-arm-mirrors.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
cat >"$mock_bin/curl" <<'SH'
#!/bin/bash

printf '%s\n' "$@" >"$ARM_MIRROR_TEST_LOG"
SH
chmod +x "$mock_bin/curl"

export ARM_MIRROR_TEST_LOG="$test_tmp/curl-args"
PATH="$mock_bin:$PATH"
export PATH
VERBOSE=0
export VERBOSE

# The helper is also an executable, so source only the connectivity function
# instead of running its mirrorlist writes against the host.
eval "$(awk '/^test_mirror_connectivity\(\) \{/,/^\}/' "$helper")"

test_mirror_connectivity 'http://us.mirror.archlinuxarm.org/$arch/$repo'

if ! grep -Fxq 'http://us.mirror.archlinuxarm.org/aarch64/core' "$ARM_MIRROR_TEST_LOG"; then
  fail "mirror connectivity expands the ARM path" "curl args:\n$(cat "$ARM_MIRROR_TEST_LOG")"
fi
pass "mirror connectivity expands the ARM path"

mirrorlist="$test_tmp/mirrorlist"
sandbox_helper="$test_tmp/set-arm-mirrors.sh"
sed "s#MIRRORLIST_FILE=\"/etc/pacman.d/mirrorlist\"#MIRRORLIST_FILE=\"$mirrorlist\"#" "$helper" >"$sandbox_helper"
chmod +x "$sandbox_helper"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash

if [[ $1 == "tee" ]]; then
  exit 3
fi
exec "$@"
SH
chmod +x "$mock_bin/sudo"

set +e
PATH="$mock_bin:$PATH" "$sandbox_helper" --test --force >"$test_tmp/write-result" 2>&1
mirror_status=$?
set -e
[[ $mirror_status -eq 3 ]] || fail "mirrorlist write failure stays nonzero" "$(cat "$test_tmp/write-result")"
[[ ! -e $mirrorlist ]] || fail "failed mirrorlist write does not report success"
pass "mirrorlist write failure stays nonzero"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash

if [[ $1 == "pacman" ]]; then
  exit 3
fi
exec "$@"
SH
chmod +x "$mock_bin/sudo"

set +e
PATH="$mock_bin:$PATH" "$sandbox_helper" --test --force >"$test_tmp/refresh-result" 2>&1
mirror_status=$?
set -e
[[ $mirror_status -eq 3 ]] || fail "package database refresh failure stays nonzero" "$(cat "$test_tmp/refresh-result")"
pass "package database refresh failure stays nonzero"

cat >"$mock_bin/uname" <<'SH'
#!/bin/bash

printf '%s\n' x86_64
SH
chmod +x "$mock_bin/uname"
direct_output=$(PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_INSTALL="$ROOT/install" bash "$ROOT/install/preflight/arm-mirrors.sh")
[[ $(printf '%s\n' "$direct_output" | wc -l | tr -d ' ') -eq 1 ]] || fail "direct ARM preflight emits one terminal outcome" "$direct_output"
printf '%s\n' "$direct_output" | grep -Fq '"code":"NOT_APPLICABLE"' || fail "direct ARM preflight is typed not applicable" "$direct_output"
pass "direct ARM preflight emits one terminal outcome"
