#!/bin/bash
# Automatic ARM mirror setup for Omarchy installation
# This script automatically configures ARM mirrors if on ARM architecture

source "$OMARCHY_INSTALL/helpers/capability-outcomes.sh"

arm_mirrors_main() {
  capability_outcomes_require_emitter || return $?

  # Only run on ARM64 systems
  local arch
  arch="$(uname -m)"
  if [[ "$arch" != "aarch64" ]]; then
    if [[ "${OMARCHY_DEBUG:-}" == "1" ]]; then
      echo "[DEBUG] Not an ARM64 system (detected: $arch), skipping ARM mirror setup"
    fi
    capability_not_applicable arm-package-mirror "architecture is not aarch64"
    return $?
  fi

  # Check if we're in an Arch Linux ARM environment
  if [[ ! -f /etc/arch-release ]]; then
    if [[ "${OMARCHY_DEBUG:-}" == "1" ]]; then
      echo "[DEBUG] Not an Arch Linux system, skipping ARM mirror setup"
    fi
    capability_not_applicable arm-package-mirror "system is not Arch Linux ARM"
    return $?
  fi

  echo "[INFO] Detected ARM64 Arch Linux system, configuring optimal mirrors..."

  # Source the ARM mirror helper
  local arm_mirror_script="$OMARCHY_INSTALL/helpers/set-arm-mirrors.sh"

  if [[ ! -x "$arm_mirror_script" ]]; then
    capability_required_unavailable arm-package-mirror "ARM mirror helper is missing or not executable"
    return $?
  fi

  # Auto-detect and setup with backup by default
  # Use --test to verify connectivity, --backup for safety
  if "$arm_mirror_script" --auto --test --backup --verbose; then
    capability_valid arm-package-mirror true "ARM mirror configuration completed"
    return $?
  else
    capability_required_unavailable arm-package-mirror "ARM mirror configuration failed"
    return $?
  fi
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  arm_mirrors_main "$@"
  exit $?
else
  arm_mirrors_main "$@"
fi
