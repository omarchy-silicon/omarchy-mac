#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-debug-platform"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

valid_digest='sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
python3 - "$test_tmp/valid.json" "$valid_digest" <<'PY'
import hashlib
import json
import sys

results = [{"capability_id": "audio", "required": True, "observed": True, "code": "CAPABILITY_VALID", "evidence_digest": sys.argv[2]}]
payload = {"code": "CAPABILITY_VALID", "results": results}
payload["evidence_digest"] = "sha256:" + hashlib.sha256(json.dumps(results, ensure_ascii=True, sort_keys=True, separators=(",", ":")).encode("ascii")).hexdigest()
with open(sys.argv[1], "w", encoding="utf-8") as stream:
    json.dump(payload, stream, ensure_ascii=True, separators=(",", ":"))
PY

set +e
"$command" --input "$test_tmp/valid.json" >"$test_tmp/valid-output" 2>"$test_tmp/valid-error"
outcome_status=$?
set -e
[[ $outcome_status -eq 0 ]] || fail "valid aggregate emits a successful bundle" "$(cat "$test_tmp/valid-error")"
[[ ! -s $test_tmp/valid-error ]] || fail "valid bundle emits no stderr" "$(cat "$test_tmp/valid-error")"
python3 - "$test_tmp/valid-output" <<'PY'
import hashlib
import json
import sys

raw = open(sys.argv[1], "rb").read()
assert raw.endswith(b"\n")
bundle = json.loads(raw)
assert set(bundle) == {"result_schema", "adapter", "operation", "scope", "route", "aggregate", "capabilities", "content_digest"}
assert bundle["result_schema"] == "omarchy.platform-support-bundle/v1"
assert bundle["adapter"] == "omarchy-hw-capability-outcome"
assert bundle["operation"] == "platform-support"
assert bundle["scope"] == "apple-silicon"
assert bundle["route"] == "omarchy debug platform"
assert bundle["aggregate"] == {"code": "CAPABILITY_VALID", "process_status": 0, "decision": "allow"}
assert bundle["capabilities"] == [{"id": "audio", "status": "valid", "code": "CAPABILITY_VALID", "evidence_digest": "sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}]
without_digest = dict(bundle)
del without_digest["content_digest"]
canonical = json.dumps(without_digest, ensure_ascii=True, sort_keys=True, separators=(",", ":")).encode("ascii")
assert bundle["content_digest"] == "sha256:" + hashlib.sha256(canonical).hexdigest()
for forbidden in ("hostname", "serial", "mac", "password", "credential", "raw", "detail", "path"):
    assert forbidden not in raw.decode("ascii").lower()
PY
pass "valid aggregate emits the exact redacted deterministic bundle"

export_dir="$test_tmp/export"
mkdir -p "$export_dir"
(cd "$export_dir" && "$command" --input "$test_tmp/valid.json" --output support.json >stdout)
[[ -f "$export_dir/support.json" ]] || fail "local export creates the requested file"
cmp -s "$export_dir/support.json" "$export_dir/stdout" || fail "local export bytes match stdout"
if ! python3 - "$export_dir/support.json" <<'PY'
import os
import stat
import sys

assert stat.S_IMODE(os.stat(sys.argv[1]).st_mode) == 0o600
PY
then
  fail "local export is mode 0600"
fi
cp "$export_dir/support.json" "$test_tmp/export-before"
set +e
(cd "$export_dir" && "$command" --input "$test_tmp/valid.json" --output support.json >second-output)
outcome_status=$?
set -e
[[ $outcome_status -eq 3 ]] || fail "local export never overwrites"
grep -Fq 'LOCAL_BUNDLE_WRITE_FAILURE' "$export_dir/second-output" || fail "overwrite failure is typed"
cmp -s "$export_dir/support.json" "$test_tmp/export-before" || fail "overwrite failure leaves the original unchanged"
pass "local export is mode 0600, atomic, and no-overwrite"

run_rejected() {
  local payload="$1" label="$2" output status
  output="$test_tmp/$label-output"
  printf '%s\n' "$payload" >"$test_tmp/hostile.json"
  set +e
  "$command" --input "$test_tmp/hostile.json" >"$output" 2>"$test_tmp/$label-error"
  status=$?
  set -e
  [[ $status -ne 0 ]] || fail "$label is rejected"
  [[ ! -s "$test_tmp/$label-error" ]] || fail "$label emits no traceback" "$(cat "$test_tmp/$label-error")"
  python3 - "$output" <<'PY'
import json
import sys

rows = [line for line in open(sys.argv[1], encoding="ascii") if line.strip()]
assert len(rows) == 1
value = json.loads(rows[0])
assert value["code"] in {"SUPPORT_BUNDLE_REDACTION_FAILED", "PRIVACY_FIELD_FORBIDDEN"}
assert set(value) == {"result_schema", "code", "process_status", "decision"}
PY
}

run_rejected '{"code":"CAPABILITY_VALID","results":[],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}' "empty-results"
run_rejected '{"code":"CAPABILITY_VALID","results":[{"capability_id":"audio","required":true,"observed":true,"code":"CAPABILITY_VALID","evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","secret":"do-not-export"}' "unknown-field"
run_rejected '{"code":"CAPABILITY_VALID","code":"CAPABILITY_VALID","results":[],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}' "duplicate-field"
run_rejected '{"code":"CAPABILITY_VALID","results":[{"capability_id":"audio","required":1.0,"observed":true,"code":"CAPABILITY_VALID","evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}' "float"
run_rejected '{"code":"CAPABILITY_VALID","results":[{"capability_id":"audio","required":true,"observed":true,"code":"CAPABILITY_VALID","evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}],"evidence_digest":NaN}' "nonfinite"
run_rejected '{"code":"CAPABILITY_VALID","results":[{"capability_id":"picker","required":false,"observed":false,"code":"NOT_APPLICABLE","evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"},{"capability_id":"audio","required":true,"observed":true,"code":"CAPABILITY_VALID","evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}' "unsorted"
run_rejected '{"code":"CAPABILITY_VALID","results":[{"capability_id":"audio","required":true,"observed":true,"code":"CAPABILITY_VALID","evidence_digest":"sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}' "sentinel-digest"
run_rejected '{"code":"CAPABILITY_VALID","results":[{"capability_id":"audio","required":true,"observed":true,"code":"CAPABILITY_VALID","evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"} trailing' "trailing"
run_rejected '{"code":"CAPABILITY_VALID","results":[{"capability_id":"audio","required":true,"observed":true,"code":"CAPABILITY_VALID","evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"}],"evidence_digest":"sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","hostname":"secret"}' "secret-field"
python3 - "$test_tmp/deep.json" <<'PY'
import sys

with open(sys.argv[1], "w", encoding="ascii") as stream:
    stream.write("[" * 10000 + "0" + "]" * 10000)
PY
run_rejected "$(cat "$test_tmp/deep.json")" "deep"
python3 - "$test_tmp/oversize.json" <<'PY'
import sys

with open(sys.argv[1], "w", encoding="ascii") as stream:
    stream.write("x" * (64 * 1024 + 1))
PY
set +e
"$command" --input "$test_tmp/oversize.json" >"$test_tmp/oversize-output" 2>/dev/null
outcome_status=$?
set -e
[[ $outcome_status -ne 0 ]] || fail "oversize input is rejected"
pass "strict hostile aggregate inputs are typed and non-persistent"

mkfifo "$test_tmp/input-fifo"
set +e
timeout 2 "$command" --input "$test_tmp/input-fifo" >"$test_tmp/fifo-output" 2>"$test_tmp/fifo-error"
outcome_status=$?
set -e
[[ $outcome_status -ne 0 && $outcome_status -ne 124 ]] || fail "FIFO input is rejected without blocking"
grep -Fq 'SUPPORT_BUNDLE_REDACTION_FAILED' "$test_tmp/fifo-output" || fail "FIFO input has the typed rejection"
set +e
(cd "$test_tmp" && timeout 2 "$command" --input "$test_tmp/missing-input" --output missing-bundle.json >"$test_tmp/missing-output" 2>/dev/null)
outcome_status=$?
set -e
[[ $outcome_status -ne 0 && $outcome_status -ne 124 ]] || fail "missing input path is rejected without blocking"
[[ ! -e "$test_tmp/missing-bundle.json" ]] || fail "missing input creates no output bundle"
pass "FIFO and missing input paths fail closed without blocking"

for unsafe in ../escape absolute/name .; do
  set +e
  "$command" --input "$test_tmp/valid.json" --output "$unsafe" >"$test_tmp/unsafe-output" 2>/dev/null
  outcome_status=$?
  set -e
  [[ $outcome_status -eq 3 ]] || fail "unsafe output path is rejected: $unsafe"
done
mkdir "$export_dir/dir"
mkfifo "$export_dir/fifo"
ln -s "$export_dir/missing" "$export_dir/dangling"
for unsafe in dir fifo dangling; do
  set +e
  (cd "$export_dir" && "$command" --input "$test_tmp/valid.json" --output "$unsafe" >"$test_tmp/$unsafe-output" 2>/dev/null)
  outcome_status=$?
  set -e
  [[ $outcome_status -eq 3 ]] || fail "existing special output is rejected: $unsafe"
done
pass "output traversal, directory, FIFO, symlink, and dangling targets are rejected"

python3 - "$command" "$test_tmp/fault-export" <<'PY'
import importlib.util
from importlib.machinery import SourceFileLoader
import os
import pathlib
import sys

loader = SourceFileLoader("platform_diagnostics", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)
os.makedirs(sys.argv[2], exist_ok=True)
os.chdir(sys.argv[2])
real_unlink = module.os.unlink
failures = 0

def flaky_unlink(path, *args, **kwargs):
    global failures
    if pathlib.Path(path).name.startswith(".omarchy-debug-platform.") and failures < 2:
        failures += 1
        raise OSError("injected cleanup failure")
    return real_unlink(path, *args, **kwargs)

module.os.unlink = flaky_unlink
module.export_once(b"{}\n", "fault.json")
assert pathlib.Path("fault.json").read_bytes() == b"{}\n"
assert not list(pathlib.Path(".").glob(".omarchy-debug-platform.*"))
PY
pass "local export retries temporary cleanup without hidden residue"

cat >"$test_tmp/curl" <<'SH'
#!/bin/bash
touch "$OMARCHY_DIAGNOSTICS_MARKER"
exit 99
SH
chmod +x "$test_tmp/curl"
set +e
PATH="$test_tmp:$PATH" OMARCHY_DIAGNOSTICS_MARKER="$test_tmp/network-marker" "$command" --upload >"$test_tmp/upload-output" 2>/dev/null
outcome_status=$?
set -e
[[ $outcome_status -eq 4 ]] || fail "upload request is held without consent"
grep -Fq 'UPLOAD_CONSENT_MISSING' "$test_tmp/upload-output" || fail "upload request has the typed hold"
[[ ! -e $test_tmp/network-marker ]] || fail "upload request performs no network action"
pass "upload is held without network or local action"

grep -Fq '/usr/bin/uname -m' "$ROOT/bin/omarchy-debug" || fail "legacy debug uses fixed system identity"
grep -Fq '/usr/bin/uname -m' "$ROOT/bin/omarchy-upload-log" || fail "legacy upload uses fixed system identity"
for mutator in sudo cat dmesg pacman inxi journalctl hostname date expac ping gum curl less cp fastfetch; do
  cat >"$test_tmp/$mutator" <<'SH'
#!/bin/bash
touch "$OMARCHY_DIAGNOSTICS_MARKER"
exit 99
SH
  chmod +x "$test_tmp/$mutator"
done
for legacy in "$ROOT/bin/omarchy-debug" "$ROOT/bin/omarchy-upload-log"; do
  simulated="$test_tmp/$(basename "$legacy")"
  python3 - "$legacy" "$simulated" <<'PY'
import os
import sys

source, destination = sys.argv[1:]
text = open(source, encoding="utf-8").read()
text = text.replace("$(/usr/bin/uname -m 2>/dev/null)", "$(printf 'aarch64\\n')")
with open(destination, "w", encoding="utf-8") as stream:
    stream.write(text)
os.chmod(destination, 0o755)
PY
  set +e
  PATH="$test_tmp:$PATH" OMARCHY_DIAGNOSTICS_MARKER="$test_tmp/simulated-marker" "$simulated" --print >"$test_tmp/simulated-output" 2>&1
  outcome_status=$?
  set -e
  [[ $outcome_status -eq 3 ]] || fail "simulated aarch64 legacy route is blocked: $legacy"
  [[ ! -e $test_tmp/simulated-marker ]] || fail "simulated aarch64 legacy route reaches a mutator"
done
pass "fixed aarch64 identity blocks both legacy routes before side effects"

for hostile_arch in failed false empty unknown; do
  for legacy in "$ROOT/bin/omarchy-debug" "$ROOT/bin/omarchy-upload-log"; do
    simulated="$test_tmp/$(basename "$legacy")-$hostile_arch"
    python3 - "$legacy" "$simulated" "$hostile_arch" <<'PY'
import os
import sys

source, destination, architecture = sys.argv[1:]
replacement = {"failed": "$(exit 19)", "false": "false", "empty": "", "unknown": "mystery"}[architecture]
text = open(source, encoding="utf-8").read()
if architecture == "failed":
    text = text.replace("$(/usr/bin/uname -m 2>/dev/null)", replacement)
else:
    text = text.replace("$(/usr/bin/uname -m 2>/dev/null)", "$(printf '%s\\n' '" + replacement + "')")
with open(destination, "w", encoding="utf-8") as stream:
    stream.write(text)
os.chmod(destination, 0o755)
PY
    set +e
    PATH="$test_tmp:$PATH" OMARCHY_DIAGNOSTICS_MARKER="$test_tmp/hostile-marker" "$simulated" --print >"$test_tmp/hostile-output" 2>&1
    outcome_status=$?
    set -e
    [[ $outcome_status -eq 3 ]] || fail "hostile architecture is blocked: $legacy/$hostile_arch"
    [[ ! -e $test_tmp/hostile-marker ]] || fail "hostile architecture reaches a mutator: $legacy/$hostile_arch"
  done
done
pass "false, empty, and unknown architecture identities fail closed"

cat >"$test_tmp/uname" <<'SH'
#!/bin/bash
printf '%s\n' aarch64
SH
cat >"$test_tmp/sudo" <<'SH'
#!/bin/bash
touch "$OMARCHY_DIAGNOSTICS_MARKER"
exit 99
SH
chmod +x "$test_tmp/uname" "$test_tmp/sudo"
if [[ $(/usr/bin/uname -m) == "aarch64" ]]; then
  for legacy in "$ROOT/bin/omarchy-debug" "$ROOT/bin/omarchy-upload-log"; do
    set +e
    PATH="$test_tmp:$PATH" OMARCHY_DIAGNOSTICS_MARKER="$test_tmp/legacy-marker" "$legacy" --print >"$test_tmp/legacy-output" 2>&1
    outcome_status=$?
    set -e
    [[ $outcome_status -eq 3 ]] || fail "aarch64 legacy debug route is blocked: $legacy"
    grep -Fq 'omarchy debug platform' "$test_tmp/legacy-output" || fail "legacy debug route directs to the redacted command"
    [[ ! -e $test_tmp/legacy-marker ]] || fail "aarch64 legacy debug route mutates nothing"
  done
  pass "aarch64 legacy debug and upload routes fail closed before mutation"
else
  set +e
  PATH="$test_tmp:$PATH" "$ROOT/bin/omarchy-debug" --not-a-real-option >"$test_tmp/fake-uname-output" 2>&1
  outcome_status=$?
  set -e
  if [[ $(/usr/bin/uname -m) == "x86_64" ]]; then
    [[ $outcome_status -eq 1 ]] || fail "PATH fake uname cannot re-enable the aarch64 guard"
    grep -Fq 'Unknown option' "$test_tmp/fake-uname-output" || fail "fixed system identity controls the legacy debug guard"
  else
    [[ $outcome_status -eq 3 ]] || fail "unrecognized host identity remains fail closed"
    grep -Fq 'recognized safe non-Apple' "$test_tmp/fake-uname-output" || fail "unknown host identity has the typed guard"
  fi
  pass "PATH fake uname cannot bypass the fixed system identity guard"
fi

if [[ $(/usr/bin/uname -m) == "x86_64" ]]; then
  cat >"$test_tmp/x86-uname" <<'SH'
#!/bin/bash
printf '%s\n' x86_64
SH
  chmod +x "$test_tmp/x86-uname"
  ln -sf "$test_tmp/x86-uname" "$test_tmp/uname"
  set +e
  PATH="$test_tmp:$PATH" "$ROOT/bin/omarchy-debug" --not-a-real-option >"$test_tmp/x86-output" 2>&1
  outcome_status=$?
  set -e
  [[ $outcome_status -eq 1 ]] || fail "x86 debug route retains its existing argument behavior"
  grep -Fq 'Unknown option' "$test_tmp/x86-output" || fail "x86 debug route remains structurally unchanged"
  pass "x86 debug behavior remains unchanged"
fi

pass "platform diagnostics hostile-case suite"
