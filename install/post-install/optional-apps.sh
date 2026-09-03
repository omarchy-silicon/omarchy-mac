#!/bin/bash
# Install optional proprietary/AUR apps (1Password, etc.)

source "$OMARCHY_INSTALL/helpers/capability-outcomes.sh"

optional_apps_main() {
  capability_outcomes_require_emitter || return $?

  # Only run on aarch64
  if [ "$(uname -m)" != "aarch64" ]; then
    capability_not_applicable optional-proprietary-apps "architecture is not aarch64"
    return $?
  fi

  # This leaf runs from omarchy-apply-system, which puts the checkout's bin/
  # directory on PATH but does not define the old OMARCHY_BIN variable. Resolve
  # the command from the active checkout so the default 1Password install is not
  # silently skipped on every fresh Apple Silicon install.
  OMARCHY_BIN="${OMARCHY_PATH:-/usr/share/omarchy}/bin"

  # Install 1Password if the installer script exists
  if [ -x "$OMARCHY_BIN/omarchy-install-1password" ]; then
    echo "Installing 1Password..."
    if "$OMARCHY_BIN/omarchy-install-1password"; then
      capability_valid optional-proprietary-apps false "1Password installer completed"
    else
      capability_optional_unavailable optional-proprietary-apps "1Password installer failed"
    fi
  else
    capability_optional_unavailable optional-proprietary-apps "1Password installer is not shipped"
  fi
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  optional_apps_main "$@"
  exit $?
else
  optional_apps_main "$@"
fi
