#!/bin/bash

# Build the Omarchy packages for Apple Silicon from this checkout.
#
# omarchy, omarchy-settings, omarchy-keyring, and ttf-jetbrains-mono-nerd-basic
# are all arch=any, so they need no architecture-specific build. The only Apple
# Silicon delta is the limine bootloader stack, patched out below.
#
# OMARCHY_PKGREL bumps pkgrel on omarchy and omarchy-settings only, so a Mac
# hotfix can ship as 4.0.1-2 without waiting for an upstream 4.0.2 tag. Leave
# it unset to keep the PKGBUILD values.

set -euo pipefail

readonly checkout="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly output_dir="${OMARCHY_PACKAGE_OUTPUT:-$checkout/build-output}"
readonly source_cache="${OMARCHY_PACKAGE_SRCDEST:-${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-build/sources}"

# Macs boot m1n1 -> u-boot -> GRUB, so limine is wrong here. Two of these have
# no aarch64 build at all, and installing limine itself would make
# install/login/alt-bootloaders.sh skip the GRUB plymouth setup it guards.
readonly limine_dependencies=(
  limine
  limine-mkinitcpio-hook
  limine-snapper-sync
)

# These utilities remain in the checkout for P-07's retirement/hardening work,
# but an Apple clean-install package must not ship the legacy conversion graph.
readonly legacy_conversion_entrypoints=(
  omarchy-mac-setup
  omarchy-system-boot-to-esp
  omarchy-system-btrfs-migrate
)

readonly packages=(
  omarchy-keyring
  ttf-jetbrains-mono-nerd-basic
  omarchy-settings
  omarchy
)

log() {
  printf '\033[32m==>\033[0m %s\n' "$*"
}

fail() {
  printf '\033[31mError:\033[0m %s\n' "$*" >&2
  exit 1
}

remove_build_dir() {
  [[ -n ${build_dir:-} ]] || return 0
  rm -rf "$build_dir"
}

find_omarchy_pkgs() {
  local candidate
  for candidate in \
    "${OMARCHY_PKGS_PATH:-}/pkgbuilds" \
    "${OMARCHY_PKGS_PATH:-}" \
    "$checkout/../omarchy-pkgs/pkgbuilds" \
    "$HOME/code/omarchy-pkgs/pkgbuilds" \
    "${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-build/omarchy-pkgs/pkgbuilds"; do
    [[ -n $candidate && -d $candidate ]] || continue
    (cd -- "$candidate" && pwd)
    return 0
  done
  return 1
}

set_pkgrel() {
  local pkgbuild="$1" rel=${OMARCHY_PKGREL:-}

  # Mac hotfixes repackage the same upstream pkgver between tags, so they bump
  # pkgrel rather than pkgver to stay upgradeable without stealing the next
  # upstream tag. Unset OMARCHY_PKGREL to keep the PKGBUILD values.
  [[ -n $rel ]] || return 0
  [[ $rel =~ ^[1-9][0-9]*$ ]] || fail "OMARCHY_PKGREL must be a positive whole number, got: $rel"
  grep -qE '^pkgrel=' "$pkgbuild" || fail "no pkgrel= in $pkgbuild"
  sed -i "s/^pkgrel=.*/pkgrel=$rel/" "$pkgbuild"
  grep -qx "pkgrel=$rel" "$pkgbuild" || fail "could not set pkgrel=$rel in $pkgbuild"
}

# Drop the limine entries from depends=() without forking the PKGBUILD, so it
# keeps tracking upstream and only this delta is ours.
strip_limine_dependencies() {
  local pkgbuild="$1" dependency

  for dependency in "${limine_dependencies[@]}"; do
    sed -i "/^[[:space:]]*'${dependency}'[[:space:]]*$/d" "$pkgbuild"
  done

  for dependency in "${limine_dependencies[@]}"; do
    if grep -qE "^[[:space:]]*'${dependency}'[[:space:]]*$" "$pkgbuild"; then
      fail "could not remove '$dependency' from $pkgbuild"
    fi
  done
}

stage_apple_source() {
  local source_root="$1" staged_root="$2" allowed_root="${3:-}" entry source_bin staged_bin
  local source_real allowed_real staged_parent staged_parent_real staged_real staged_name component cursor
  local -a parent_components=()

  [[ -n $allowed_root ]] || fail "Apple source staging requires a trusted build directory"
  [[ -d "$allowed_root" && ! -L "$allowed_root" ]] ||
    fail "Apple source staging build directory must be a real directory"
  [[ -d "$source_root" && ! -L "$source_root" ]] ||
    fail "Apple source root must be a real directory"
  source_bin="$source_root/bin"
  [[ -d "$source_bin" && ! -L "$source_bin" ]] ||
    fail "Apple source bin must be a real directory"
  source_real=$(cd -- "$source_root" && pwd -P) || fail "could not resolve Apple source root"
  allowed_real=$(cd -- "$allowed_root" && pwd -P) || fail "could not resolve Apple build directory"
  staged_parent="${staged_root%/*}"
  staged_name="${staged_root##*/}"
  [[ $staged_parent != "$staged_root" && -n $staged_name ]] ||
    fail "Apple source staging destination must name a directory"
  [[ -d "$staged_parent" && ! -L "$staged_parent" ]] ||
    fail "Apple source staging parent must be a real directory"
  case "$staged_parent/" in
    "$allowed_root/"*) ;;
    *) fail "Apple source staging destination is outside the trusted build directory" ;;
  esac
  IFS=/ read -r -a parent_components <<< "${staged_parent#"$allowed_root"}"
  cursor="$allowed_root"
  for component in "${parent_components[@]}"; do
    [[ -n $component ]] || continue
    cursor="$cursor/$component"
    [[ ! -L "$cursor" ]] || fail "Apple source staging parent contains a symlink"
  done
  staged_parent_real=$(cd -- "$staged_parent" && pwd -P) || fail "could not resolve Apple staging parent"
  staged_real="$staged_parent_real/$staged_name"
  case "$staged_real/" in
    "$allowed_real/"*) ;;
    *) fail "Apple source staging destination escapes the trusted build directory" ;;
  esac
  case "$staged_real/" in
    "$source_real/"*) fail "Apple source staging destination aliases the source" ;;
  esac
  [[ ! -e "$staged_root" && ! -L "$staged_root" ]] ||
    fail "refusing to overwrite existing Apple source staging destination: $staged_root"
  for entry in "${legacy_conversion_entrypoints[@]}"; do
    [[ -f "$source_bin/$entry" && ! -L "$source_bin/$entry" ]] ||
      fail "Apple source legacy entrypoint must be a regular non-symlink file: bin/$entry"
  done
  cp -a "$source_root" "$staged_root"
  [[ -d "$staged_root" && ! -L "$staged_root" ]] ||
    fail "Apple staged source root must be a real directory"
  staged_bin="$staged_root/bin"
  [[ -d "$staged_bin" && ! -L "$staged_bin" ]] ||
    fail "Apple staged source bin must be a real directory"
  for entry in "${legacy_conversion_entrypoints[@]}"; do
    [[ -f "$staged_bin/$entry" && ! -L "$staged_bin/$entry" ]] ||
      fail "Apple source is missing legacy entrypoint bin/$entry"
    rm -f -- "$staged_bin/$entry"
    [[ ! -e "$staged_bin/$entry" && ! -L "$staged_bin/$entry" ]] ||
      fail "could not omit legacy entrypoint bin/$entry from staged source"
  done
}

# makepkg runs with --nodeps because the runtime dependencies include packages
# built here, so pacman cannot resolve them yet. That skips makedepends too,
# leaving the build tools to be installed up front.
install_build_dependencies() {
  local pkgbuild_source="$1" package
  local -a build_dependencies=()

  for package in "${packages[@]}"; do
    while read -r dependency; do
      [[ -n $dependency ]] || continue
      build_dependencies+=("$dependency")
    done < <(sed -n '/^makedepends=(/,/^)/p' "$pkgbuild_source/$package/PKGBUILD" |
      sed '1d;$d' | tr -d "'\"" | tr -d ' ')
  done

  (( ${#build_dependencies[@]} )) || return 0

  # pacman -T reports only what is missing, so an already-equipped machine
  # needs no sudo at all, and repeated makedepends collapse.
  local -a missing=()
  mapfile -t missing < <(pacman -T "${build_dependencies[@]}" || true)
  (( ${#missing[@]} )) || return 0

  log "Installing build dependencies: ${missing[*]}"
  sudo pacman -S --needed --noconfirm "${missing[@]}"
}

remove_old_packages() {
  local artifact

  # This directory is the installer hand-off, not a package cache. A retry
  # after PKGBUILDs changed must not mix the previous build with this one.
  for artifact in "$output_dir"/*.pkg.tar.*; do
    [[ -f $artifact ]] || continue
    rm -f -- "$artifact"
  done
}

build_package() {
  local package="$1" pkgbuild_source="$2" build_dir="$3"
  local artifact package_source="$checkout"
  local -a built=()

  log "Building $package"
  rm -rf "$build_dir/$package"
  cp -r "$pkgbuild_source/$package" "$build_dir/$package"

  if [[ $package == "omarchy" ]]; then
    strip_limine_dependencies "$build_dir/$package/PKGBUILD"
    package_source="$build_dir/omarchy-source"
    stage_apple_source "$checkout" "$package_source" "$build_dir"
  fi
  if [[ $package == "omarchy" || $package == "omarchy-settings" ]]; then
    set_pkgrel "$build_dir/$package/PKGBUILD"
  fi

  # SRCDEST caches downloaded sources outside the throwaway build directory, so
  # a rebuild does not re-fetch the 125 MB font archive.
  (
    cd "$build_dir/$package"
    SRCDEST="$source_cache" OMARCHY_SRC="$package_source" \
      makepkg --force --noconfirm --nodeps --skipinteg
  )

  # A configured makepkg signer leaves detached .sig files beside the archive;
  # pacman -U accepts package archives, not those signatures.
  for artifact in "$build_dir/$package"/*.pkg.tar.*; do
    [[ -f $artifact && $artifact != *.sig ]] || continue
    built+=("$artifact")
  done
  (( ${#built[@]} )) || fail "$package produced no package archive"
  mv -- "${built[@]}" "$output_dir/"
}

main() {
  [[ $(uname -m) == "aarch64" ]] || fail "This builds the Apple Silicon packages; run it on aarch64."
  command -v makepkg >/dev/null || fail "makepkg is required (install base-devel)."
  (( EUID != 0 )) || fail "Run this as your regular user, not as root."

  local pkgbuild_source package
  pkgbuild_source="$(find_omarchy_pkgs)" ||
    fail "No omarchy-pkgs checkout found. Set OMARCHY_PKGS_PATH or clone it beside this repo."
  log "Using PKGBUILDs from $pkgbuild_source"

  for package in "${packages[@]}"; do
    [[ -d "$pkgbuild_source/$package" ]] || fail "$pkgbuild_source/$package is missing."
  done

  install_build_dependencies "$pkgbuild_source"

  # build_dir stays global: an EXIT trap runs after main's locals are gone, and
  # under set -u a local would abort the trap instead of cleaning up.
  build_dir="$(mktemp -d)"
  trap remove_build_dir EXIT

  mkdir -p "$output_dir" "$source_cache"
  remove_old_packages
  for package in "${packages[@]}"; do
    build_package "$package" "$pkgbuild_source" "$build_dir"
  done

  log "Built packages in $output_dir"
  ls -1 "$output_dir"/*.pkg.tar.*
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  main "$@"
fi
