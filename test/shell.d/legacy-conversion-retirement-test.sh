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
stage_apple_source "$source_root" "$staged_root" "$test_tmp"
for entrypoint in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate; do
  [[ ! -e "$staged_root/bin/$entrypoint" ]] || fail "Apple staged package source omits $entrypoint"
done
[[ -f "$staged_root/bin/omarchy-update" ]] || fail "Apple staged package source preserves safe commands"
pass "Apple staged package source omits exactly the three legacy entrypoints"

run_stage_rejected() {
  local candidate_source="$1" candidate_destination="$2" label="$3" status

  set +e
  bash -c 'source "$1"; stage_apple_source "$2" "$3" "$4"' _ \
    "$ROOT/build-packages.sh" "$candidate_source" "$candidate_destination" "$test_tmp" \
    >"$test_tmp/$label-output" 2>&1
  status=$?
  set -e
  [[ $status -ne 0 ]] || fail "$label rejects unsafe staging input"
}

outside_root="$test_tmp/outside"
mkdir -p "$outside_root"
for entrypoint in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate; do
  printf 'outside sentinel\n' >"$outside_root/$entrypoint"
done

source_link="$test_tmp/source-root-link"
ln -s "$source_root" "$source_link"
run_stage_rejected "$source_link" "$test_tmp/source-link-staged" "source-root-symlink"
[[ -f "$source_root/bin/omarchy-update" ]] || fail "source-root symlink rejection leaves source intact"
pass "source-root symlink is rejected before copy"

bin_link_source="$test_tmp/bin-link-source"
cp -a "$source_root" "$bin_link_source"
rm -rf "$bin_link_source/bin"
ln -s "$outside_root" "$bin_link_source/bin"
run_stage_rejected "$bin_link_source" "$test_tmp/bin-link-staged" "bin-symlink"
for entrypoint in omarchy-mac-setup omarchy-system-boot-to-esp omarchy-system-btrfs-migrate; do
  [[ -f "$outside_root/$entrypoint" ]] || fail "bin symlink rejection deletes outside file"
done
pass "bin symlink is rejected before copy or removal"

entry_link_source="$test_tmp/entry-link-source"
cp -a "$source_root" "$entry_link_source"
rm -f "$entry_link_source/bin/omarchy-mac-setup"
ln -s "$outside_root/omarchy-mac-setup" "$entry_link_source/bin/omarchy-mac-setup"
run_stage_rejected "$entry_link_source" "$test_tmp/entry-link-staged" "legacy-entry-symlink"
[[ -f "$outside_root/omarchy-mac-setup" ]] || fail "legacy entry symlink rejection deletes outside file"
pass "legacy entry symlink is rejected before copy"

partial_source="$test_tmp/partial-source"
cp -a "$source_root" "$partial_source"
rm -f "$partial_source/bin/omarchy-system-btrfs-migrate"
partial_destination="$test_tmp/partial-staged"
run_stage_rejected "$partial_source" "$partial_destination" "partial-source"
[[ ! -e "$partial_destination" && ! -L "$partial_destination" ]] ||
  fail "partial source rejection leaves no staging destination"
pass "incomplete source is rejected before copy"

destination_target="$test_tmp/destination-target"
mkdir -p "$destination_target"
printf 'destination sentinel\n' >"$destination_target/sentinel"
destination_link="$test_tmp/destination-link"
ln -s "$destination_target" "$destination_link"
run_stage_rejected "$source_root" "$destination_link" "existing-destination-symlink"
[[ -f "$destination_target/sentinel" ]] || fail "existing destination symlink rejection mutates target"

dangling_destination="$test_tmp/dangling-destination"
ln -s "$test_tmp/no-such-destination" "$dangling_destination"
run_stage_rejected "$source_root" "$dangling_destination" "dangling-destination-symlink"
[[ -L "$dangling_destination" ]] || fail "dangling destination symlink was altered"
pass "existing and dangling destination symlinks are rejected"

real_parent="$test_tmp/real-parent"
mkdir -p "$real_parent"
linked_parent="$test_tmp/linked-parent"
ln -s "$real_parent" "$linked_parent"
run_stage_rejected "$source_root" "$linked_parent/linked-staged" "destination-parent-symlink"
[[ ! -e "$real_parent/linked-staged" && ! -L "$real_parent/linked-staged" ]] ||
  fail "destination parent symlink rejection writes outside staging root"
pass "destination parent symlink is rejected"

alias_destination="$source_root/aliased-staged"
run_stage_rejected "$source_root" "$alias_destination" "source-destination-alias"
[[ ! -e "$alias_destination" && ! -L "$alias_destination" ]] ||
  fail "source/destination alias rejection creates staging output"
pass "source/destination alias is rejected"
