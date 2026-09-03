#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fixture="$test_tmp/repo"
mkdir -p "$fixture/bin" "$fixture/install" "$fixture/default/applications" \
  "$fixture/platform/apple-silicon" "$fixture/tools/apple-silicon" "$fixture/test/shell.d"
printf '#!/bin/bash\n' >"$fixture/bin/omarchy-alpha"
printf '#!/bin/bash\n' >"$fixture/bin/omarchy-mac-special"
chmod +x "$fixture/bin/omarchy-alpha" "$fixture/bin/omarchy-mac-special"
printf 'demo-app\n' >"$fixture/install/omarchy-base.packages"
printf '# no packages\n' >"$fixture/install/omarchy-other.packages"
printf '[Desktop Entry]\nName=Battle.net\nExec=omarchy-launch-battlenet\n' >"$fixture/default/applications/battlenet.desktop"
printf 'evidence\n' >"$fixture/test/shell.d/aarch64-compat-test.sh"
cp "$ROOT/tools/apple-silicon/parity-census.py" "$fixture/tools/apple-silicon/parity-census.py"

git -C "$fixture" init -q
git -C "$fixture" add .
python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" --write >/dev/null

expect_pass() {
  local label=$1
  shift
  "$@" >/dev/null || fail "$label"
  pass "$label"
}

expect_fail() {
  local label=$1
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label" "checker unexpectedly passed"
  fi
  pass "$label"
}

check() {
  python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture"
}

manifest="$fixture/platform/apple-silicon/parity-census.json"
queue="$fixture/platform/apple-silicon/porting-queue.json"
expect_pass "generated fixture census passes" check

mutate_manifest() {
  python3 - "$manifest" "$1" <<'PY'
import json
import sys
path, operation = sys.argv[1:]
data = json.load(open(path, encoding="utf-8"))
entries = data["entries"]
if operation == "missing":
    entries.pop()
elif operation == "extra":
    entries.append(dict(entries[0], id="command:omarchy-extra"))
elif operation == "duplicate":
    entries.append(dict(entries[0]))
elif operation == "unsorted":
    entries.reverse()
elif operation == "disposition":
    entries[0]["disposition"] = "unknown"
elif operation == "source":
    entries[0]["source"] = "bin/not-tracked"
elif operation == "blocked-queue":
    next(item for item in entries if item["disposition"] == "blocked")["queue_id"] = None
elif operation == "evidence":
    entries[0]["evidence"]["reference"] = "test/no-evidence"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2)
PY
}

for operation in missing extra duplicate unsorted disposition source blocked-queue evidence; do
  python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" --write >/dev/null
  mutate_manifest "$operation"
  expect_fail "hostile manifest $operation is rejected" check
done

python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" --write >/dev/null
python3 - "$queue" <<'PY'
import json
import sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["items"].append(dict(data["items"][0], id="P03-orphan"))
json.dump(data, open(path, "w", encoding="utf-8"), indent=2)
PY
expect_fail "hostile queue orphan is rejected" check

python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" --write >/dev/null
printf '#!/bin/bash\n' >"$fixture/bin/omarchy-new-tracked"
git -C "$fixture" add bin/omarchy-new-tracked
expect_fail "tracked source-tree drift is rejected" check

pass "parity census hostile-case suite"
