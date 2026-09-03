#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-hw-capability-outcome"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

valid_digest='sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'

run_set() {
  local payload="$1"
  printf '%s\n' "$payload" >"$test_tmp/results.json"
  set +e
  "$command" --validate-set "$test_tmp/results.json" --required-id audio --optional-id picker >"$test_tmp/result"
  outcome_status=$?
  set -e
}

run_set "{\"results\":[{\"capability_id\":\"audio\",\"required\":true,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"$valid_digest\"},{\"capability_id\":\"picker\",\"required\":false,\"observed\":false,\"code\":\"OPTIONAL_CAPABILITY_UNAVAILABLE\",\"evidence_digest\":\"$valid_digest\"}]}"
[[ $outcome_status -eq 0 ]] || fail "complete required and optional outcomes pass" "$(cat "$test_tmp/result")"
grep -Fq '"code":"CAPABILITY_VALID"' "$test_tmp/result" || fail "complete outcome set has a typed success"
pass "complete required and optional outcomes pass"

run_set "{\"results\":[{\"capability_id\":\"audio\",\"required\":true,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"$valid_digest\"}]}"
[[ $outcome_status -eq 3 ]] || fail "missing optional outcome is incomplete"
grep -Fq 'CAPABILITY_RESULT_INCOMPLETE' "$test_tmp/result" || fail "missing outcome has the typed incomplete code"
pass "missing outcome is incomplete"

run_set "{\"results\":[{\"capability_id\":\"audio\",\"required\":true,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"$valid_digest\"},{\"capability_id\":\"audio\",\"required\":true,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"$valid_digest\"},{\"capability_id\":\"picker\",\"required\":false,\"observed\":false,\"code\":\"OPTIONAL_CAPABILITY_UNAVAILABLE\",\"evidence_digest\":\"$valid_digest\"}]}"
[[ $outcome_status -eq 3 ]] || fail "duplicate capability outcomes are rejected"
grep -Fq 'CAPABILITY_RESULT_INCOMPLETE' "$test_tmp/result" || fail "duplicate outcome has the typed incomplete code"
pass "duplicate capability outcomes are rejected"

run_set "{\"results\":[{\"capability_id\":\"audio\",\"required\":true,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"$valid_digest\"},{\"capability_id\":\"other\",\"required\":false,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"$valid_digest\"},{\"capability_id\":\"picker\",\"required\":false,\"observed\":false,\"code\":\"OPTIONAL_CAPABILITY_UNAVAILABLE\",\"evidence_digest\":\"$valid_digest\"}]}"
[[ $outcome_status -eq 3 ]] || fail "unknown capability outcomes are rejected"
grep -Fq 'CAPABILITY_RESULT_INCOMPLETE' "$test_tmp/result" || fail "unknown outcome has the typed incomplete code"
pass "unknown capability outcomes are rejected"

run_set "{\"results\":[{\"capability_id\":\"picker\",\"required\":false,\"observed\":false,\"code\":\"OPTIONAL_CAPABILITY_UNAVAILABLE\",\"evidence_digest\":\"$valid_digest\"},{\"capability_id\":\"audio\",\"required\":true,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"$valid_digest\"}]}"
[[ $outcome_status -eq 3 ]] || fail "unsorted capability outcomes are rejected"
pass "unsorted capability outcomes are rejected"

run_set "{\"results\":[{\"capability_id\":\"audio\",\"required\":true,\"observed\":true,\"code\":\"CAPABILITY_VALID\",\"evidence_digest\":\"sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"},{\"capability_id\":\"picker\",\"required\":false,\"observed\":false,\"code\":\"OPTIONAL_CAPABILITY_UNAVAILABLE\",\"evidence_digest\":\"$valid_digest\"}]}"
[[ $outcome_status -eq 3 ]] || fail "sentinel evidence digests are rejected"
pass "sentinel evidence digests are rejected"

marker="$test_tmp/required-mutation"
if "$command" --capability-id audio --required true --observed false --code REQUIRED_CAPABILITY_UNAVAILABLE --evidence "missing package" >"$test_tmp/required-result"; then
  fail "required unavailable outcome is nonzero"
fi
[[ ! -e $marker ]] || fail "rejected required outcome does not mutate its target"
grep -Fq 'REQUIRED_CAPABILITY_UNAVAILABLE' "$test_tmp/required-result" || fail "required gap has the typed rejection"
pass "required unavailable outcome is nonzero and non-mutating"
