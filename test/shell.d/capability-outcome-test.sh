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

run_set "{\"results\":[{\"capability_id\":\"audio\",\"required\":true,\"observed\":false,\"code\":\"REQUIRED_CAPABILITY_UNAVAILABLE\",\"evidence_digest\":\"$valid_digest\"},{\"capability_id\":\"picker\",\"required\":false,\"observed\":false,\"code\":\"OPTIONAL_CAPABILITY_UNAVAILABLE\",\"evidence_digest\":\"$valid_digest\"}]}"
[[ $outcome_status -eq 3 ]] || fail "required unavailable outcome propagates from aggregate validation"
grep -Fq 'REQUIRED_CAPABILITY_UNAVAILABLE' "$test_tmp/result" || fail "aggregate required gap keeps its typed rejection"
pass "required unavailable outcome propagates from aggregate validation"

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

printf '%s\n' '{"results":' >"$test_tmp/results.json"
set +e
"$command" --validate-set "$test_tmp/results.json" --required-id audio >"$test_tmp/result"
outcome_status=$?
set -e
[[ $outcome_status -eq 3 ]] || fail "malformed outcome JSON is typed and nonzero"
grep -Fq 'CAPABILITY_RESULT_INCOMPLETE' "$test_tmp/result" || fail "malformed outcome JSON has the typed incomplete code"
pass "malformed outcome JSON is typed and nonzero"

set +e
"$command" --bogus >"$test_tmp/result" 2>/dev/null
outcome_status=$?
set -e
[[ $outcome_status -eq 3 ]] || fail "unknown invocation is typed and nonzero"
grep -Fq 'CAPABILITY_RESULT_INCOMPLETE' "$test_tmp/result" || fail "unknown invocation has the typed incomplete code"
pass "unknown invocation is typed and nonzero"

python3 - "$command" <<'PY'
import json
import os
import subprocess
import sys

bad_evidence = os.fsdecode(b"\xff")
completed = subprocess.run(
    [sys.argv[1], "--capability-id", "audio", "--required", "true", "--observed", "true", "--code", "CAPABILITY_VALID", "--evidence", bad_evidence],
    capture_output=True,
    text=True,
)
assert completed.returncode == 3, completed
assert completed.stderr == "", completed.stderr
parsed = json.loads(completed.stdout)
assert parsed["code"] == "CAPABILITY_RESULT_INCOMPLETE", parsed
PY
pass "unencodable evidence is typed and nonzero"

marker="$test_tmp/required-mutation"
if "$command" --capability-id audio --required true --observed false --code REQUIRED_CAPABILITY_UNAVAILABLE --evidence "missing package" >"$test_tmp/required-result"; then
  fail "required unavailable outcome is nonzero"
fi
[[ ! -e $marker ]] || fail "rejected required outcome does not mutate its target"
grep -Fq 'REQUIRED_CAPABILITY_UNAVAILABLE' "$test_tmp/required-result" || fail "required gap has the typed rejection"
pass "required unavailable outcome is nonzero and non-mutating"
