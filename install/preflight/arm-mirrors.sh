#!/bin/bash
# Automatic ARM mirror setup for Omarchy installation
# This script automatically configures ARM mirrors if on ARM architecture

source "$OMARCHY_INSTALL/helpers/capability-outcomes.sh"

# Only run on ARM64 systems
ARCH="$(uname -m)"
if [[ "$ARCH" != "aarch64" ]]; then
  if [[ "${OMARCHY_DEBUG:-}" == "1" ]]; then
    echo "[DEBUG] Not an ARM64 system (detected: $ARCH), skipping ARM mirror setup"
  fi
  capability_not_applicable arm-package-mirror "architecture is not aarch64"
  return 0
fi

# Check if we're in an Arch Linux ARM environment
if [[ ! -f /etc/arch-release ]]; then
  if [[ "${OMARCHY_DEBUG:-}" == "1" ]]; then
    echo "[DEBUG] Not an Arch Linux system, skipping ARM mirror setup"
  fi
  capability_not_applicable arm-package-mirror "system is not Arch Linux ARM"
  return 0
fi

echo "[INFO] Detected ARM64 Arch Linux system, configuring optimal mirrors..."

# Source the ARM mirror helper
ARM_MIRROR_SCRIPT="$OMARCHY_INSTALL/helpers/set-arm-mirrors.sh"

if [[ ! -x "$ARM_MIRROR_SCRIPT" ]]; then
  capability_required_unavailable arm-package-mirror "ARM mirror helper is missing or not executable" || return $?
fi

# Auto-detect and setup with backup by default
# Use --test to verify connectivity, --backup for safety
if "$ARM_MIRROR_SCRIPT" --auto --test --backup --verbose; then
  capability_valid arm-package-mirror true "ARM mirror configuration completed"
else
  capability_required_unavailable arm-package-mirror "ARM mirror configuration failed" || return $?
fi
