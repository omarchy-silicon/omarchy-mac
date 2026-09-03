# Common typed capability-result seam for install leaves.
#
# Every result is emitted by the checked-in command so JSON escaping, field
# order, and evidence digests stay deterministic. A required unavailable
# result returns status 3; optional gaps and not-applicable results return 0.

capability_outcome() {
  local capability_id="$1" required="$2" observed="$3" code="$4" evidence="$5"
  local command="${OMARCHY_PATH:?OMARCHY_PATH is required}/bin/omarchy-hw-capability-outcome"

  "$command" \
    --capability-id "$capability_id" \
    --required "$required" \
    --observed "$observed" \
    --code "$code" \
    --evidence "$evidence"
}

capability_valid() {
  capability_outcome "$1" "$2" true CAPABILITY_VALID "$3"
}

capability_required_unavailable() {
  capability_outcome "$1" true false REQUIRED_CAPABILITY_UNAVAILABLE "$2"
}

capability_optional_unavailable() {
  capability_outcome "$1" false false OPTIONAL_CAPABILITY_UNAVAILABLE "$2"
}

capability_not_applicable() {
  capability_outcome "$1" false false NOT_APPLICABLE "$2"
}
