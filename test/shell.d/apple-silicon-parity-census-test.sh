#!/bin/bash
if (( BASH_VERSINFO[0] < 5 )) && [[ -x /opt/homebrew/bin/bash ]]; then exec /opt/homebrew/bin/bash "$0" "$@"; fi
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
if [[ -x /opt/homebrew/bin/bash ]] && [[ -x "$ROOT/bin/omarchy" ]]; then
  executable_count=$(git -C "$ROOT" ls-files --stage -- 'bin/omarchy-*' | awk '$1 == "100755" {count++} END {print count+0}')
  command_json=$(/opt/homebrew/bin/bash "$ROOT/bin/omarchy" commands --all --json 2>/dev/null)
  command_count=$(jq '.commands | length' <<<"$command_json")
  [[ $executable_count == 459 && $command_count == 459 ]] || fail "Git executable command census matches router JSON" "$executable_count vs $command_count"
  pass "Git executable command census matches router JSON (459)"
fi
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
fixture="$test_tmp/repo"
mkdir -p "$fixture/bin" "$fixture/install" "$fixture/applications" "$fixture/default/applications" "$fixture/platform/apple-silicon" "$fixture/tools/apple-silicon" "$fixture/test/shell.d"
printf '#!/bin/bash\n' >"$fixture/bin/omarchy-alpha"
printf '#!/bin/bash\n' >"$fixture/bin/omarchy-mac-special"
chmod +x "$fixture/bin/omarchy-alpha" "$fixture/bin/omarchy-mac-special"
printf 'demo-app\n' >"$fixture/install/omarchy-base.packages"
printf '# no packages\n' >"$fixture/install/omarchy-other.packages"
printf '[Desktop Entry]\nType=Application\nName=Battle.net\nExec=omarchy-launch-battlenet\n' >"$fixture/default/applications/battlenet.desktop"
printf '[Desktop Entry]\nType=Application\nName=Foot\nExec=foot\n' >"$fixture/applications/foot.desktop"
printf '# evidence fixture\n' >"$fixture/test/shell.d/aarch64-compat-test.sh"
chmod +x "$fixture/test/shell.d/aarch64-compat-test.sh"
cp "$ROOT/tools/apple-silicon/parity-census.py" "$fixture/tools/apple-silicon/parity-census.py"
git -C "$fixture" init -q
git -C "$fixture" add .
checker=(python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture")
manifest="$fixture/platform/apple-silicon/parity-census.json"
queue="$fixture/platform/apple-silicon/porting-queue.json"
"${checker[@]}" --update-inventory >/dev/null
baseline_manifest="$test_tmp/baseline-manifest.json"
baseline_queue="$test_tmp/baseline-queue.json"
cp "$manifest" "$baseline_manifest"
cp "$queue" "$baseline_queue"
expect_pass() { local label=$1; shift; local output; if ! output=$("$@" 2>&1); then fail "$label" "$output"; fi; pass "$label"; }
expect_fail() { local label=$1; shift; if "$@" >/dev/null 2>&1; then fail "$label" "checker unexpectedly passed"; fi; pass "$label"; }
check() { "${checker[@]}" --check; }
expect_pass "generated fixture census passes" check
mutate() {
  local operation=$1
  case $operation in
    missing) jq 'del(.entries[-1])' "$manifest" >"$manifest.tmp";;
    extra) jq '.entries += [.entries[0] + {id:"command:omarchy-extra"}]' "$manifest" >"$manifest.tmp";;
    duplicate) jq '.entries += [.entries[0]]' "$manifest" >"$manifest.tmp";;
    unsorted) jq '.entries |= reverse' "$manifest" >"$manifest.tmp";;
    disposition) jq '.entries[0].disposition = "unknown"' "$manifest" >"$manifest.tmp";;
    source) jq '.entries[0].sources[0].path = "bin/not-tracked"' "$manifest" >"$manifest.tmp";;
    traversal) jq '.entries[0].sources[0].path = "../bin/omarchy-alpha"' "$manifest" >"$manifest.tmp";;
    id) jq '.entries[0].id = "1:bad"' "$manifest" >"$manifest.tmp";;
    blocked-queue) jq '.entries[0].queue_id = null' "$manifest" >"$manifest.tmp";;
    evidence) jq '.entries[0].evidence.reference = "test/no-evidence"' "$manifest" >"$manifest.tmp";;
  esac
  mv "$manifest.tmp" "$manifest"
}
for operation in missing extra duplicate unsorted disposition source traversal id blocked-queue evidence; do
  cp "$baseline_manifest" "$manifest"
  cp "$baseline_queue" "$queue"
  mutate "$operation"
  expect_fail "hostile manifest $operation is rejected" check
done
cp "$baseline_manifest" "$manifest"
cp "$baseline_queue" "$queue"
"${checker[@]}" --update-inventory >/dev/null
jq '.items += [.items[0] + {id:"P03-orphan"}]' "$queue" >"$queue.tmp"
mv "$queue.tmp" "$queue"
expect_fail "hostile queue orphan is rejected" check
cp "$baseline_manifest" "$manifest"
cp "$baseline_queue" "$queue"
first_queue=$(jq -r '.entries[0].queue_id' "$manifest")
jq --arg id "$first_queue" '.entries[1].queue_id=$id' "$manifest" >"$manifest.tmp" && mv "$manifest.tmp" "$manifest"
expect_fail "shared queue ids are rejected" check
cp "$baseline_manifest" "$manifest"
cp "$baseline_queue" "$queue"
"${checker[@]}" --update-inventory >/dev/null
printf '#!/bin/bash\n' >"$fixture/bin/omarchy-new-tracked"
chmod +x "$fixture/bin/omarchy-new-tracked"
git -C "$fixture" add bin/omarchy-new-tracked
expect_fail "tracked executable source drift is rejected" check
"${checker[@]}" --update-inventory >/dev/null
printf '#!/bin/bash\n' >"$fixture/bin/omarchy-not-executable"
git -C "$fixture" add bin/omarchy-not-executable
expect_pass "tracked non-executable command is excluded" check
"${checker[@]}" --update-inventory >/dev/null
ln -s omarchy-alpha "$fixture/bin/omarchy-symlink"
git -C "$fixture" add bin/omarchy-symlink
expect_fail "tracked command symlink is rejected" check
git -C "$fixture" reset -q HEAD -- bin/omarchy-symlink
"${checker[@]}" --update-inventory >/dev/null
printf 'invalid package name!\n' >"$fixture/install/omarchy-base.packages"
git -C "$fixture" add install/omarchy-base.packages
expect_fail "invalid package grammar is rejected" check
printf 'demo-app\n' >"$fixture/install/omarchy-base.packages"
git -C "$fixture" add install/omarchy-base.packages
"${checker[@]}" --update-inventory >/dev/null
printf '[Desktop Entry]\nName=Broken\n' >"$fixture/applications/foot.desktop"
git -C "$fixture" add applications/foot.desktop
expect_fail "malformed desktop launcher is rejected" check
printf '[Desktop Entry]\nType=Application\nName=Foot\nExec=foot\n' >"$fixture/applications/foot.desktop"
git -C "$fixture" add applications/foot.desktop
"${checker[@]}" --update-inventory >/dev/null
jq '.entries[0].owner="reviewer" | .entries[0].notes="reviewed note"' "$manifest" >"$manifest.tmp" && mv "$manifest.tmp" "$manifest"
jq '.items[0].owner="reviewer" | .items[0].status="in-progress"' "$queue" >"$queue.tmp" && mv "$queue.tmp" "$queue"
reviewed=$(jq -c '[.entries[0].owner,.entries[0].notes]' "$manifest")
reviewed_queue=$(jq -c '[.items[0].owner,.items[0].status]' "$queue")
expect_pass "reviewed fields survive inventory update" "${checker[@]}" --update-inventory
[[ $reviewed == "$(jq -c '[.entries[0].owner,.entries[0].notes]' "$manifest")" ]] || fail "reviewed manifest fields were overwritten"
[[ $reviewed_queue == "$(jq -c '[.items[0].owner,.items[0].status]' "$queue")" ]] || fail "reviewed queue fields were overwritten"
git -C "$fixture" reset -q HEAD -- bin/omarchy-new-tracked
expect_fail "ambiguous inventory removals are rejected" "${checker[@]}" --update-inventory
cp "$baseline_manifest" "$manifest"
cp "$baseline_queue" "$queue"
entry_id=$(jq -r '.entries[0].id' "$manifest")
receipt=$(jq -r '.entries[0].evidence.reference' "$manifest")
jq --arg id "$entry_id-attacker" --arg evidence "$receipt" '.items[0].acceptance.command = "python3 tools/apple-silicon/parity-census.py accept-entry --id \($id) --evidence \($evidence)"' "$queue" >"$queue.tmp" && mv "$queue.tmp" "$queue"
expect_fail "substring entry ID in acceptance command is rejected" check
cp "$baseline_queue" "$queue"
verify=(python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" verify-entry --id "$entry_id" --evidence "$receipt")
expect_fail "absent receipt is rejected" "${verify[@]}"
python3 -c 'import hashlib,json,os,subprocess,sys; m,root,r=sys.argv[1:]; d=json.load(open(m)); e=d["entries"][0]; digest=lambda x: hashlib.sha256(subprocess.check_output(["git","-C",root,"show",":"+x])).hexdigest(); os.makedirs(os.path.dirname(os.path.join(root,r)),exist_ok=True); json.dump({"entry_id":e["id"],"disposition":e["disposition"],"architecture":"aarch64","command":"probe "+e["id"],"exit_status":1,"observed_behavior":"probe is pending","source_digests":[{"path":s["path"],"sha256":digest(s["path"])} for s in e["sources"]],"test_evidence":{"path":"test/shell.d/aarch64-compat-test.sh","sha256":digest("test/shell.d/aarch64-compat-test.sh")},"recorded_at":"2026-09-03T00:00:00Z","reviewer":"reviewer","owner":e["owner"]},open(os.path.join(root,r),"w"),indent=2); e["evidence"]={"kind":"receipt","reference":r}; json.dump(d,open(m,"w"),indent=2)' "$manifest" "$fixture" "$receipt"
git -C "$fixture" add "${receipt#"$fixture"/}" platform/apple-silicon/parity-census.json
expect_pass "bound receipt verifies" "${verify[@]}"
expect_fail "mismatched receipt path is rejected" python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" verify-entry --id "$entry_id" --evidence "platform/apple-silicon/evidence/other.json"
accept=(python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" accept-entry --id "$entry_id" --evidence "$receipt")
jq '.disposition="native" | .exit_status=1' "$fixture/$receipt" >"$fixture/$receipt.tmp" && mv "$fixture/$receipt.tmp" "$fixture/$receipt"
git -C "$fixture" add "${receipt#"$fixture"/}"
expect_fail "nonzero receipt cannot clear a blocked entry" "${accept[@]}"
jq '.disposition="native" | .exit_status=0' "$fixture/$receipt" >"$fixture/$receipt.tmp" && mv "$fixture/$receipt.tmp" "$fixture/$receipt"
git -C "$fixture" add "${receipt#"$fixture"/}"
second_entry=$(jq -c '.entries[1]' "$manifest")
second_queue=$(jq -c '.items[1]' "$queue")
expect_pass "one-item acceptance atomically clears entry and queue row" "${accept[@]}"
expect_pass "accepted fixture census passes" check
[[ $(jq -r --arg id "$entry_id" '.entries[] | select(.id==$id) | .disposition' "$manifest") == native ]] || fail "accept-entry did not update only matching disposition"
[[ $(jq -r --arg id "$entry_id" '.items[] | select(.id==$id) | .id' "$queue") == "" ]] || fail "accept-entry did not remove matching queue row"
[[ $second_entry == "$(jq -c '.entries[1]' "$manifest")" ]] || fail "accept-entry changed another manifest entry"
[[ $second_queue == "$(jq -c '.items[0]' "$queue")" ]] || fail "accept-entry changed another queue row"
expect_fail "wrong-ID clearance is rejected" python3 "$fixture/tools/apple-silicon/parity-census.py" --root "$fixture" accept-entry --id "$(jq -r '.entries[1].id' "$manifest")" --evidence "$receipt"
source_path=$(jq -r '.entries[0].sources[0].path' "$manifest")
printf '\n# stale probe mutation\n' >>"$fixture/$source_path"
git -C "$fixture" add "$source_path"
expect_fail "stale source receipt is rejected" "${verify[@]}"
pass "parity census hostile-case suite"
