# hyprland-preview-share-picker in omarchy-base.packages has no aarch64 build, so
# xdg-desktop-portal-hyprland shows no source chooser and browser sharing silently
# degrades to tab-only. The -git package builds on aarch64, and only as the user.
source "$OMARCHY_INSTALL/helpers/capability-outcomes.sh"
capability_outcomes_require_emitter || return $?

if [[ $(uname -m) != "aarch64" ]]; then
  capability_not_applicable apple-share-picker "architecture is not aarch64"
elif omarchy-cmd-missing hyprland-preview-share-picker; then
  echo "Installing the browser screen-share picker for Apple Silicon."

  if omarchy-pkg-aur-add hyprland-preview-share-picker-git && ! omarchy-cmd-missing hyprland-preview-share-picker; then
    capability_valid apple-share-picker false "screen-share picker is installed"
  else
    capability_optional_unavailable apple-share-picker "screen-share picker is unavailable"
  fi
else
  capability_valid apple-share-picker false "screen-share picker is already installed"
fi
