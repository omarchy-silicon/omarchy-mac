#!/usr/bin/python3
"""Validate and (deliberately) regenerate the Apple Silicon product census.

The inventory is intentionally derived from git's index.  This keeps editor
files and generated/untracked files out of the product-parity boundary.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from collections import Counter
from pathlib import Path
from typing import Any


SCHEMA = "omarchy.apple-silicon.product-parity/v1"
DISPOSITIONS = {"native", "ported", "web-substitute", "optional", "blocked"}
EVIDENCE_KINDS = {"source", "package-list", "desktop-entry", "test"}
QUEUE_STATUSES = {"planned", "in-progress", "blocked", "complete"}
ENTRY_KEYS = {"id", "kind", "source", "disposition", "evidence", "owner", "queue_id", "notes"}
QUEUE_KEYS = {"id", "owner", "dependency", "next_action", "acceptance", "status"}
ACCEPTANCE_KEYS = {"command", "evidence"}


def git_files(root: Path) -> list[str]:
    result = subprocess.run(
        [
            "git",
            "-C",
            str(root),
            "ls-files",
            "-z",
            "--",
            "bin/omarchy-*",
            "install/omarchy-base.packages",
            "install/omarchy-other.packages",
            "default/applications/*.desktop",
            "test/shell.d/*.sh",
        ],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return [path for path in result.stdout.decode("utf-8").split("\0") if path]


def git_blob(root: Path, source: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), "show", f":{source}"],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout.decode("utf-8")


def package_names(root: Path, tracked: set[str]) -> list[tuple[str, str]]:
    found: dict[str, str] = {}
    for source in ("install/omarchy-base.packages", "install/omarchy-other.packages"):
        if source not in tracked:
            continue
        for raw in git_blob(root, source).splitlines():
            value = raw.split("#", 1)[0].strip()
            if value and value not in found:
                found[value] = source
    return sorted(found.items())


def desktop_apps(root: Path, tracked: set[str]) -> list[tuple[str, str]]:
    apps: list[tuple[str, str]] = []
    for source in sorted(tracked):
        if not source.startswith("default/applications/") or not source.endswith(".desktop"):
            continue
        text = git_blob(root, source)
        name = next((line.split("=", 1)[1].strip() for line in text.splitlines() if line.startswith("Name=")), "")
        if not name:
            name = Path(source).stem
        apps.append((name.lower().replace(" ", "-"), source))
    return apps


def command_disposition(name: str) -> tuple[str, str]:
    # These are explicit, source-backed Mac divergences in AGENTS.md.  Keeping
    # them in the census makes the intended product behavior visible.
    if name in {"omarchy-launch-spotify", "omarchy-install-service-spotify"}:
        return "web-substitute", "Intentional Spotify webapp divergence for Mac."
    if any(token in name for token in ("-mac-", "-apple")) or name in {"omarchy-brightness-keyboard"}:
        return "ported", "Mac-specific implementation is present in the tracked source."
    if name.startswith("omarchy-remove-") or name.startswith("omarchy-install-"):
        return "optional", "Optional application/service integration; validate on ARM when selected."
    return "blocked", "ARM dependency and runtime parity still require an owned executable check."


def discover(root: Path) -> list[dict[str, Any]]:
    tracked_list = git_files(root)
    tracked = set(tracked_list)
    entries: list[dict[str, Any]] = []

    for source in sorted(tracked):
        path = Path(source)
        if len(path.parts) == 2 and path.parts[0] == "bin" and path.name.startswith("omarchy-"):
            disposition, notes = command_disposition(path.name)
            evidence_kind = "test" if disposition == "ported" else "source"
            evidence_ref = "test/shell.d/aarch64-compat-test.sh" if evidence_kind == "test" else source
            queue_id = f"P03-{path.name}" if disposition == "blocked" else None
            entries.append(
                {
                    "id": f"command:{path.name}",
                    "kind": "command",
                    "source": source,
                    "disposition": disposition,
                    "evidence": {"kind": evidence_kind, "reference": evidence_ref},
                    "owner": "platform-team",
                    "queue_id": queue_id,
                    "notes": notes,
                }
            )

    for package, source in package_names(root, tracked):
        queue_id = f"P03-application-{package}"  # package names are queue-safe
        entries.append(
            {
                "id": f"application:{package}",
                "kind": "application",
                "source": source,
                "disposition": "blocked",
                "evidence": {"kind": "package-list", "reference": source},
                "owner": "platform-team",
                "queue_id": queue_id,
                "notes": "Default package source; ARM package/runtime parity is not assumed from listing alone.",
            }
        )

    for app, source in desktop_apps(root, tracked):
        entries.append(
            {
                "id": f"application:{app}",
                "kind": "application",
                "source": source,
                "disposition": "blocked",
                "evidence": {"kind": "desktop-entry", "reference": source},
                "owner": "platform-team",
                "queue_id": f"P03-application-{app}",
                "notes": "Tracked desktop launcher; ARM launch/runtime parity requires an executable check.",
            }
        )

    # If a package and desktop launcher share a normalized id, prefer the
    # package source (the package is the install authority) while retaining an
    # exact one-entry census.
    unique: dict[str, dict[str, Any]] = {}
    for entry in entries:
        unique.setdefault(entry["id"], entry)
    return [unique[key] for key in sorted(unique)]


def queue_for(entries: list[dict[str, Any]]) -> list[dict[str, Any]]:
    result = []
    for entry in entries:
        if entry["disposition"] != "blocked":
            continue
        result.append(
            {
                "id": entry["queue_id"],
                "owner": entry["owner"],
                "dependency": "ARM package/runtime and user-facing behavior evidence",
                "next_action": f"Run an aarch64 parity probe for {entry['id']} and record the result.",
                "acceptance": {
                    "command": "python3 tools/apple-silicon/parity-census.py",
                    "evidence": entry["source"],
                },
                "status": "planned",
            }
        )
    return sorted(result, key=lambda item: item["id"])


def load_json(path: Path, label: str) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read {label}: {error}") from error


def require_string(value: Any, label: str, errors: list[str]) -> None:
    if not isinstance(value, str) or not value:
        errors.append(f"{label} must be a non-empty string")


def validate(root: Path, manifest_path: Path, queue_path: Path) -> tuple[list[str], Counter[str], int]:
    errors: list[str] = []
    try:
        tracked = set(git_files(root))
        expected = discover(root)
        manifest = load_json(manifest_path, "manifest")
        queue = load_json(queue_path, "queue")
    except (ValueError, subprocess.CalledProcessError) as error:
        return [str(error)], Counter(), 0

    if not isinstance(manifest, dict) or set(manifest) != {"schema", "entries"}:
        errors.append("manifest must have exactly schema and entries")
        manifest_entries: list[Any] = []
    else:
        if manifest.get("schema") != SCHEMA:
            errors.append(f"manifest schema must be {SCHEMA}")
        manifest_entries = manifest.get("entries", [])
        if not isinstance(manifest_entries, list):
            errors.append("manifest entries must be an array")
            manifest_entries = []

    expected_by_id = {entry["id"]: entry for entry in expected}
    actual_ids = [entry.get("id") if isinstance(entry, dict) else None for entry in manifest_entries]
    if actual_ids != sorted(actual_ids, key=lambda value: "" if value is None else value):
        errors.append("manifest entries must be sorted by id")
    if len(actual_ids) != len(set(actual_ids)):
        errors.append("manifest entries contain duplicate ids")
    actual_by_id = {entry.get("id"): entry for entry in manifest_entries if isinstance(entry, dict)}
    missing = sorted(set(expected_by_id) - set(actual_by_id))
    extra = sorted(set(actual_by_id) - set(expected_by_id))
    errors.extend(f"missing census entry: {item}" for item in missing)
    errors.extend(f"extra census entry: {item}" for item in extra)

    for index, entry in enumerate(manifest_entries):
        if not isinstance(entry, dict):
            errors.append(f"entry {index} must be an object")
            continue
        label = f"entry {entry.get('id', index)}"
        if set(entry) != ENTRY_KEYS:
            errors.append(f"{label} has wrong fields")
        require_string(entry.get("id"), f"{label}.id", errors)
        if entry.get("kind") not in {"command", "application"}:
            errors.append(f"{label}.kind is invalid")
        require_string(entry.get("source"), f"{label}.source", errors)
        source = entry.get("source")
        if isinstance(source, str) and (source not in tracked or not (root / source).is_file()):
            errors.append(f"{label}.source is not an existing tracked file: {source}")
        if entry.get("disposition") not in DISPOSITIONS:
            errors.append(f"{label}.disposition is invalid")
        evidence = entry.get("evidence")
        if not isinstance(evidence, dict) or set(evidence) != {"kind", "reference"}:
            errors.append(f"{label}.evidence has wrong fields")
        elif evidence.get("kind") not in EVIDENCE_KINDS:
            errors.append(f"{label}.evidence.kind is invalid")
        if isinstance(evidence, dict):
            reference = evidence.get("reference")
            require_string(reference, f"{label}.evidence.reference", errors)
            if isinstance(reference, str) and (reference not in tracked or not (root / reference).is_file()):
                errors.append(f"{label}.evidence.reference is not an existing tracked file: {reference}")
        expected_entry = expected_by_id.get(entry.get("id"))
        if expected_entry is not None:
            if entry.get("kind") != expected_entry["kind"]:
                errors.append(f"{label}.kind does not match the discovered source")
            if entry.get("source") != expected_entry["source"]:
                errors.append(f"{label}.source does not match the discovered source")
        require_string(entry.get("owner"), f"{label}.owner", errors)
        if not isinstance(entry.get("notes"), str):
            errors.append(f"{label}.notes must be a string")
        disposition = entry.get("disposition")
        queue_id = entry.get("queue_id")
        if disposition == "blocked":
            require_string(queue_id, f"{label}.queue_id", errors)
        elif queue_id is not None:
            errors.append(f"{label} non-blocked entries must have queue_id null")

    if not isinstance(queue, dict) or set(queue) != {"schema", "items"}:
        errors.append("queue must have exactly schema and items")
        queue_items: list[Any] = []
    else:
        if queue.get("schema") != SCHEMA:
            errors.append(f"queue schema must be {SCHEMA}")
        queue_items = queue.get("items", [])
        if not isinstance(queue_items, list):
            errors.append("queue items must be an array")
            queue_items = []

    queue_ids = [item.get("id") if isinstance(item, dict) else None for item in queue_items]
    if queue_ids != sorted(queue_ids, key=lambda value: "" if value is None else value):
        errors.append("queue items must be sorted by id")
    if len(queue_ids) != len(set(queue_ids)):
        errors.append("queue items contain duplicate ids")
    queue_by_id = {item.get("id"): item for item in queue_items if isinstance(item, dict)}
    blocked_ids = {entry.get("queue_id") for entry in manifest_entries if isinstance(entry, dict) and entry.get("disposition") == "blocked"}
    for queue_id in sorted(blocked_ids - set(queue_by_id)):
        errors.append(f"blocked entry has no queue item: {queue_id}")
    for queue_id in sorted(set(queue_by_id) - blocked_ids):
        errors.append(f"orphan queue item: {queue_id}")
    for index, item in enumerate(queue_items):
        if not isinstance(item, dict):
            errors.append(f"queue item {index} must be an object")
            continue
        label = f"queue item {item.get('id', index)}"
        if set(item) != QUEUE_KEYS:
            errors.append(f"{label} has wrong fields")
        require_string(item.get("id"), f"{label}.id", errors)
        for field in ("owner", "dependency", "next_action"):
            require_string(item.get(field), f"{label}.{field}", errors)
        if item.get("status") not in QUEUE_STATUSES:
            errors.append(f"{label}.status is invalid")
        matching_entries = [entry for entry in manifest_entries if isinstance(entry, dict) and entry.get("queue_id") == item.get("id")]
        if len(matching_entries) == 1 and item.get("owner") != matching_entries[0].get("owner"):
            errors.append(f"{label}.owner must match its blocked census entry owner")
        acceptance = item.get("acceptance")
        if not isinstance(acceptance, dict) or set(acceptance) != ACCEPTANCE_KEYS:
            errors.append(f"{label}.acceptance has wrong fields")
        elif not isinstance(acceptance.get("command"), str) or not acceptance["command"]:
            errors.append(f"{label}.acceptance.command must be a non-empty string")
        if isinstance(acceptance, dict):
            evidence = acceptance.get("evidence")
            require_string(evidence, f"{label}.acceptance.evidence", errors)
            if isinstance(evidence, str) and (evidence not in tracked or not (root / evidence).is_file()):
                errors.append(f"{label}.acceptance.evidence is not an existing tracked file: {evidence}")

    summary = Counter(f"{entry.get('kind')}:{entry.get('disposition')}" for entry in manifest_entries if isinstance(entry, dict))
    return errors, summary, len(expected)


def write_manifests(root: Path, manifest_path: Path, queue_path: Path) -> None:
    entries = discover(root)
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    queue_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps({"schema": SCHEMA, "entries": entries}, indent=2) + "\n", encoding="utf-8")
    queue_path.write_text(json.dumps({"schema": SCHEMA, "items": queue_for(entries)}, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--queue", type=Path)
    parser.add_argument("--write", action="store_true", help="regenerate checked-in manifests from tracked sources")
    args = parser.parse_args()
    root = args.root.resolve()
    manifest = (args.manifest or root / "platform/apple-silicon/parity-census.json").resolve()
    queue = (args.queue or root / "platform/apple-silicon/porting-queue.json").resolve()
    if args.write:
        write_manifests(root, manifest, queue)
    errors, summary, discovered_count = validate(root, manifest, queue)
    print(f"DISCOVERED: {discovered_count}")
    print(f"MANIFEST: {sum(summary.values()) if summary else 0}")
    for key in sorted(summary):
        print(f"{key}: {summary[key]}")
    if errors:
        print("FAIL_CENSUS:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
