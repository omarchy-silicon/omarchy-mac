#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
marker="$test_tmp/mutated"
mkdir -p "$mock_bin"
for command_name in pacman cryptsetup btrfs mount umount reboot systemctl; do
  cat >"$mock_bin/$command_name" <<'SH'
#!/bin/bash

touch "$OMARCHY_RETIREMENT_MARKER"
SH
  chmod +x "$mock_bin/$command_name"
done

set +e
PATH="$mock_bin:$PATH" OMARCHY_RETIREMENT_MARKER="$marker" \
  "$ROOT/bin/omarchy-mac-setup" --encrypt --repo '../../../../target' --step mutate >"$test_tmp/tombstone-output" 2>&1
tombstone_status=$?
set -e
[[ $tombstone_status -ne 0 ]] || fail "retired guided setup rejects hostile options"
grep -Fq 'signed Omarchy Silicon native clean installer is not yet shipped' "$test_tmp/tombstone-output" ||
  fail "retired guided setup explains the fail-closed status"
[[ ! -e $marker ]] || fail "retired guided setup reaches no mutator"
pass "retired guided setup rejects hostile options before mutation"

for forbidden in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate cryptsetup mkfs.btrfs btrfs-convert; do
  if grep -Fq "$forbidden" "$ROOT/install.sh"; then
    fail "clean install does not contain retired conversion primitive" "$forbidden"
  fi
done
pass "clean install contains no retired conversion invocation or primitive"

for forbidden in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate; do
  if grep -Fxq "$forbidden" "$ROOT/install/omarchy-base.packages"; then
    fail "base package list omits conversion-only command references" "$forbidden"
  fi
done
pass "base package list omits conversion-only command references"

for entrypoint in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate; do
  [[ -f "$ROOT/bin/$entrypoint" ]] || fail "standalone source remains for P-07" "$entrypoint"
done
pass "standalone legacy source remains for P-07"

source_root="$test_tmp/source"
staged_root="$test_tmp/staged"
mkdir -p "$source_root/bin"
for entrypoint in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate; do
  printf '#!/bin/bash\n' >"$source_root/bin/$entrypoint"
done
printf '#!/bin/bash\necho safe\n' >"$source_root/bin/omarchy-update"

source "$ROOT/build-packages.sh"
stage_apple_source "$source_root" "$staged_root"
for entrypoint in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate; do
  [[ ! -e "$staged_root/bin/$entrypoint" ]] || fail "Apple staged package source omits $entrypoint"
done
[[ -f "$staged_root/bin/omarchy-update" ]] || fail "Apple staged package source preserves safe commands"
pass "Apple staged package source omits exactly the three legacy entrypoints"
