#!/bin/bash
# Sound on Apple Silicon needs three things this install would otherwise never
# get, for three different reasons.
#
# PipeWire's PulseAudio server: install/omarchy-other.packages lists
# pipewire-pulse and says why it is not in the base set -- "Utilized by ISO
# builder to ensure package availability in the ISO". x86 machines get it from
# the ISO. A Mac has no ISO, and wireplumber pulls in pipewire but not
# pipewire-pulse, so the machine ends up with a running audio server that
# nothing can talk to: pactl says "Connection refused", and every Omarchy audio
# command exits 1 -- the volume and mute keys do nothing while brightness works
# fine, because brightness never touches PulseAudio.
#
# Realtime scheduling: rtkit is only an optional dependency of pipewire, so
# nothing here would pull it in. Without it pipewire's data threads run at
# normal priority, and any load spike delays the DSP cycle long enough to
# underrun -- heard as crackling or popping that gets worse under load. The
# Asahi speaker filter chain runs several convolvers per cycle, so it is more
# exposed to this than a plain sink.
#
# Then the Apple parts: asahi-audio carries the UCM profiles and the DSP filter
# chain that makes a speaker sink exist at all, and speakersafetyd is what
# allows the speakers to play. Without the daemon the kernel keeps them muted,
# on purpose -- these drivers can be damaged by what the hardware will happily
# ask them to do.

source "$OMARCHY_INSTALL/helpers/capability-outcomes.sh"

apple_audio_main() {
  capability_outcomes_require_emitter || return $?

  compatible="/sys/firmware/devicetree/base/compatible"
  OMARCHY_ASAHI_AUDIO_PACKAGES_CHANGED=0

  # Every device-tree machine has a compatible file, so it has to name Apple --
  # otherwise a Raspberry Pi would install the Asahi stack too.
  if [[ $(uname -m) != "aarch64" ]]; then
    capability_not_applicable apple-audio-stack "architecture is not aarch64"
    return $?
  fi
  if ! grep -Faiq 'apple,' "$compatible"; then
    capability_not_applicable apple-audio-stack "device-tree identity is not Apple Silicon"
    return $?
  fi

  # pkg-missing rather than a bare pkg-add, so the migration can tell whether this
  # actually installed anything and only then ask for a reboot.
  if omarchy-pkg-missing rtkit pipewire-pulse pipewire-alsa asahi-audio speakersafetyd; then
    echo "Installing the Apple Silicon audio stack"
    omarchy-pkg-add rtkit pipewire-pulse pipewire-alsa asahi-audio speakersafetyd || true

    if omarchy-pkg-present rtkit pipewire-pulse pipewire-alsa asahi-audio speakersafetyd; then
      OMARCHY_ASAHI_AUDIO_PACKAGES_CHANGED=1
    else
      capability_required_unavailable apple-audio-stack "required Asahi audio packages are unavailable" || return $?
    fi
  fi

  # The daemon has to be running before the speakers will produce anything.
  if sudo systemctl enable --now speakersafetyd >/dev/null 2>&1; then
    capability_valid apple-audio-stack true "Asahi audio packages are installed and speakersafetyd is running"
  else
    capability_required_unavailable apple-audio-stack "speakersafetyd could not be enabled" || return $?
  fi
}

# pipewire-pulse is socket-activated per user, so enabling it system-wide is not
# the job; the user units are enabled at first run.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  apple_audio_main "$@"
  exit $?
else
  apple_audio_main "$@"
fi
