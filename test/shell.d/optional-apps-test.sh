#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
fake_omarchy="$test_tmp/omarchy"
install_log="$test_tmp/1password.log"
aur_log="$test_tmp/aur.log"
mkdir -p "$mock_bin" "$fake_omarchy/bin"
cp "$ROOT/bin/omarchy-hw-capability-outcome" "$fake_omarchy/bin/"

cat >"$mock_bin/uname" <<'SH'
#!/bin/bash
echo aarch64
SH

cat >"$fake_omarchy/bin/omarchy-install-1password" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_INSTALL_LOG"
SH

cat >"$mock_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_AUR_LOG"
SH

chmod +x "$mock_bin/uname" "$fake_omarchy/bin/omarchy-install-1password" "$mock_bin/omarchy-pkg-aur-add"

(
  unset OMARCHY_BIN
  PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_PATH="$fake_omarchy" \
    OMARCHY_INSTALL="$ROOT/install" \
    OMARCHY_TEST_INSTALL_LOG="$install_log" \
    OMARCHY_TEST_AUR_LOG="$aur_log" \
    bash -eE -c 'source "$1"' bash "$ROOT/install/post-install/optional-apps.sh"
)

[[ -f $install_log ]] ||
  fail "aarch64 post-install finds the 1Password installer through OMARCHY_PATH"
pass "aarch64 post-install finds the 1Password installer through OMARCHY_PATH"

[[ ! -e $aur_log ]] ||
  fail "root post-install does not try to build the user-owned screen-share picker"
pass "root post-install does not try to build the user-owned screen-share picker"

missing_emitter_root="$test_tmp/missing-emitter"
mkdir -p "$missing_emitter_root/bin"
cp "$fake_omarchy/bin/omarchy-install-1password" "$missing_emitter_root/bin/"
rm -f "$install_log"
set +e
PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_PATH="$missing_emitter_root" \
  OMARCHY_INSTALL="$ROOT/install" \
  OMARCHY_TEST_INSTALL_LOG="$install_log" \
  OMARCHY_TEST_AUR_LOG="$aur_log" \
  bash "$ROOT/install/post-install/optional-apps.sh" >"$test_tmp/missing-emitter-output" 2>&1
status=$?
set -e
[[ $status -ne 0 ]] || fail "missing capability emitter rejects optional apps before mutation"
[[ ! -e $install_log ]] || fail "missing capability emitter blocks the 1Password mutator"
pass "missing capability emitter blocks optional apps before mutation"
