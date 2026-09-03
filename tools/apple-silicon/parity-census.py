#!/usr/bin/python3
"""Validate the tracked Apple Silicon product-parity census."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
from collections import Counter
from pathlib import Path, PurePosixPath
from typing import Any

SCHEMA = "omarchy.apple-silicon.product-parity/v2"
DISPOSITIONS = {"native", "ported", "web-substitute", "optional", "blocked"}
SOURCE_KINDS = {"command", "package-list", "launcher"}
RECEIPT_KINDS = {"pending", "receipt"}
QUEUE_STATUSES = {"planned", "in-progress", "complete"}
ENTRY_KEYS = {"id", "kind", "sources", "disposition", "evidence", "owner", "queue_id", "notes"}
SOURCE_KEYS = {"kind", "path"}
EVIDENCE_KEYS = {"kind", "reference"}
QUEUE_KEYS = {"id", "owner", "dependency", "next_action", "acceptance", "status"}
ACCEPTANCE_KEYS = {"command", "evidence"}
RECEIPT_KEYS = {"entry_id", "disposition", "architecture", "command", "exit_status", "observed_behavior", "source_digests", "test_evidence", "recorded_at", "reviewer", "owner"}
RECEIPT_DIGEST_KEYS = {"path", "sha256"}
ID_RE = re.compile(r"^[a-z][a-z0-9._-]*:[a-z0-9][a-z0-9._-]*$")
QUEUE_ID_RE = re.compile(r"^P03-[a-z0-9._-]+$")
PACKAGE_RE = re.compile(r"^[a-zA-Z0-9][a-zA-Z0-9@._+:-]*$")
SLUG_RE = re.compile(r"[^a-z0-9._-]+")


class CensusError(Exception):
    """A structured inventory or manifest error."""


def run_git(root: Path, *args: str) -> bytes:
    try:
        result = subprocess.run(["git", "-C", str(root), *args], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except (OSError, subprocess.CalledProcessError) as error:
        raise CensusError(f"git operation failed: {error}") from error
    return result.stdout


def tracked_index(root: Path) -> dict[str, str]:
    """Return relevant tracked paths and Git index modes without broad traversal."""
    pathspecs = ("bin/omarchy-*", "install/omarchy-base.packages", "install/omarchy-other.packages", "applications/*.desktop", "default/applications/*.desktop", "test/shell.d/*.sh", "platform/apple-silicon/evidence/*.json")
    raw = run_git(root, "ls-files", "--stage", "-z", "--", *pathspecs)
    tracked: dict[str, str] = {}
    try:
        records = raw.decode("utf-8").split("\0")
    except UnicodeDecodeError as error:
        raise CensusError("Git index output is not UTF-8") from error
    for record in records:
        if not record:
            continue
        header, separator, path = record.partition("\t")
        fields = header.split()
        if not separator or len(fields) != 3:
            raise CensusError(f"malformed Git index record for {path}")
        tracked[path] = fields[0]
    return tracked


def git_blob(root: Path, path: str) -> bytes:
    return run_git(root, "show", f":{path}")


def safe_repo_path(root: Path, path: Any, tracked: dict[str, str], label: str, modes: set[str] | None = None) -> Path:
    if not isinstance(path, str) or not path or "\\" in path:
        raise CensusError(f"{label} must be a repository-relative POSIX path")
    pure = PurePosixPath(path)
    if pure.is_absolute() or ".." in pure.parts or "." in pure.parts:
        raise CensusError(f"{label} escapes the repository: {path}")
    mode = tracked.get(path)
    if mode is None:
        raise CensusError(f"{label} is not tracked: {path}")
    if modes is not None and mode not in modes:
        raise CensusError(f"{label} has invalid Git mode {mode}: {path}")
    candidate = (root / Path(*pure.parts)).resolve()
    try:
        candidate.relative_to(root.resolve())
    except ValueError as error:
        raise CensusError(f"{label} escapes the repository: {path}") from error
    if not candidate.is_file():
        raise CensusError(f"{label} is not an existing regular file: {path}")
    return candidate


def parse_packages(root: Path, tracked: dict[str, str]) -> dict[str, list[dict[str, str]]]:
    packages: dict[str, list[dict[str, str]]] = {}
    for path in ("install/omarchy-base.packages", "install/omarchy-other.packages"):
        safe_repo_path(root, path, tracked, "package list", {"100644"})
        try:
            text = git_blob(root, path).decode("utf-8")
        except UnicodeDecodeError as error:
            raise CensusError(f"package list is not UTF-8: {path}") from error
        for line_number, raw in enumerate(text.splitlines(), 1):
            value = raw.strip()
            if not value or value.startswith("#"):
                continue
            if "#" in value or not PACKAGE_RE.fullmatch(value):
                raise CensusError(f"invalid package line {path}:{line_number}")
            packages.setdefault(value, []).append({"kind": "package-list", "path": path})
    return packages


def desktop_records(root: Path, tracked: dict[str, str], packages: dict[str, list[dict[str, str]]]) -> list[tuple[str, str, str | None]]:
    records: list[tuple[str, str, str | None]] = []
    seen_slugs: dict[str, str] = {}
    for path in sorted(tracked):
        if not ((path.startswith("applications/") or path.startswith("default/applications/")) and path.endswith(".desktop")):
            continue
        safe_repo_path(root, path, tracked, "desktop launcher", {"100644"})
        try:
            text = git_blob(root, path).decode("utf-8")
        except UnicodeDecodeError as error:
            raise CensusError(f"desktop launcher is not UTF-8: {path}") from error
        if "\x00" in text:
            raise CensusError(f"desktop launcher contains NUL: {path}")
        group = False
        seen_entry = False
        values: dict[str, str] = {}
        for line_number, raw in enumerate(text.splitlines(), 1):
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if line == "[Desktop Entry]":
                group = True
                seen_entry = True
                continue
            if line.startswith("["):
                group = False
                continue
            if group:
                if "=" not in line:
                    raise CensusError(f"malformed desktop line {path}:{line_number}")
                key, value = line.split("=", 1)
                if not key or " " in key:
                    raise CensusError(f"malformed desktop key {path}:{line_number}")
                values.setdefault(key, value)
        if not seen_entry or values.get("Type") != "Application" or not values.get("Name") or not values.get("Exec"):
            raise CensusError(f"desktop launcher lacks Type=Application, Name, or Exec: {path}")
        try:
            command = shlex.split(values["Exec"])[0]
        except (IndexError, ValueError) as error:
            raise CensusError(f"invalid desktop Exec in {path}") from error
        stem = Path(path).stem.lower()
        slug = SLUG_RE.sub("-", stem).strip("-")
        if not slug or not re.fullmatch(r"[a-z0-9][a-z0-9._-]*", slug):
            raise CensusError(f"desktop launcher identity is invalid: {path}")
        previous = seen_slugs.get(slug)
        if previous and previous != path:
            raise CensusError(f"ambiguous normalized launcher identity {slug}: {previous}, {path}")
        seen_slugs[slug] = path
        # Merge only when the launcher identity and the package identity are
        # exact. Generic wrappers (for example xdg-terminal-exec) are shared
        # plumbing, not proof that two unrelated launchers are one product.
        package = command if command in packages and slug == command.lower() else None
        records.append((slug, path, package))
    return records


def evidence_path(entry_id: str) -> str:
    return f"platform/apple-silicon/evidence/{re.sub(r'[^a-zA-Z0-9._-]+', '__', entry_id)}.json"


def queue_id(entry_id: str) -> str:
    return "P03-" + re.sub(r"[^a-zA-Z0-9._-]+", "-", entry_id).strip("-")


def discover(root: Path) -> list[dict[str, Any]]:
    tracked = tracked_index(root)
    command_candidates = [path for path in tracked if Path(path).parent == Path("bin") and Path(path).name.startswith("omarchy-")]
    for path in command_candidates:
        if tracked[path] not in {"100644", "100755"}:
            raise CensusError(f"command source has non-regular Git mode {tracked[path]}: {path}")
    command_paths = sorted(path for path in command_candidates if tracked[path] == "100755")
    for path in command_paths:
        safe_repo_path(root, path, tracked, "command source", {"100755"})
    packages = parse_packages(root, tracked)
    launchers = desktop_records(root, tracked, packages)
    entries: dict[str, dict[str, Any]] = {}
    for path in command_paths:
        entry_id = f"command:{Path(path).name}"
        entries[entry_id] = {"id": entry_id, "kind": "command", "sources": [{"kind": "command", "path": path}], "disposition": "blocked", "evidence": {"kind": "pending", "reference": evidence_path(entry_id)}, "owner": "platform-team", "queue_id": queue_id(entry_id), "notes": "ARM parity receipt is pending; source presence is not evidence of parity."}
    for package, sources in packages.items():
        entry_id = f"application:package-{package}"
        entries[entry_id] = {"id": entry_id, "kind": "application", "sources": sorted(sources, key=lambda item: (item["kind"], item["path"])), "disposition": "blocked", "evidence": {"kind": "pending", "reference": evidence_path(entry_id)}, "owner": "platform-team", "queue_id": queue_id(entry_id), "notes": "ARM package/runtime parity receipt is pending; package listing is not evidence of parity."}
    for slug, path, package in launchers:
        entry_id = f"application:package-{package}" if package else f"application:launcher-{slug}"
        if entry_id not in entries:
            entries[entry_id] = {"id": entry_id, "kind": "application", "sources": [], "disposition": "blocked", "evidence": {"kind": "pending", "reference": evidence_path(entry_id)}, "owner": "platform-team", "queue_id": queue_id(entry_id), "notes": "ARM launcher/runtime parity receipt is pending; desktop source is not evidence of parity."}
        entries[entry_id]["sources"].append({"kind": "launcher", "path": path})
        entries[entry_id]["sources"] = sorted(entries[entry_id]["sources"], key=lambda item: (item["kind"], item["path"]))
    return [entries[key] for key in sorted(entries)]


def acceptance_command(entry_id: str, evidence: str) -> str:
    return f"python3 tools/apple-silicon/parity-census.py accept-entry --id {shlex.quote(entry_id)} --evidence {shlex.quote(evidence)}"


def queue_for(entries: list[dict[str, Any]]) -> list[dict[str, Any]]:
    items = []
    for entry in entries:
        if entry["disposition"] != "blocked":
            continue
        expected = entry["evidence"]["reference"]
        items.append({"id": entry["queue_id"], "owner": entry["owner"], "dependency": "ARM package/runtime behavior and a reviewed receipt", "next_action": f"Run the exact ARM probe for {entry['id']} and save its receipt.", "acceptance": {"command": acceptance_command(entry["id"], expected), "evidence": expected}, "status": "planned"})
    return sorted(items, key=lambda item: item["id"])


def load_json(path: Path, label: str) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise CensusError(f"cannot read {label}: {error}") from error


def require_string(value: Any, label: str) -> None:
    if not isinstance(value, str) or not value:
        raise CensusError(f"{label} must be a non-empty string")


def sha256_git(root: Path, path: str) -> str:
    return hashlib.sha256(git_blob(root, path)).hexdigest()


def validate_receipt(root: Path, tracked: dict[str, str], entry: dict[str, Any], receipt_path: str, transition: bool = False) -> dict[str, Any]:
    safe_repo_path(root, receipt_path, tracked, "receipt", {"100644"})
    receipt = load_json(root / receipt_path, "receipt")
    if not isinstance(receipt, dict) or set(receipt) != RECEIPT_KEYS:
        raise CensusError(f"receipt has wrong fields: {receipt_path}")
    if receipt["entry_id"] != entry["id"] or (not transition and receipt["disposition"] != entry["disposition"]):
        raise CensusError(f"receipt binding mismatch: {receipt_path}")
    if receipt["disposition"] not in DISPOSITIONS:
        raise CensusError(f"receipt disposition is invalid: {receipt_path}")
    if transition and (entry["disposition"] != "blocked" or receipt["disposition"] == "blocked"):
        raise CensusError(f"acceptance must transition blocked entry to a non-blocked disposition: {receipt_path}")
    if receipt["architecture"] != "aarch64":
        raise CensusError(f"receipt architecture must be aarch64: {receipt_path}")
    require_string(receipt["command"], "receipt.command")
    if entry["id"] not in receipt["command"]:
        raise CensusError(f"receipt command must name exact entry: {receipt_path}")
    if not isinstance(receipt["exit_status"], int) or isinstance(receipt["exit_status"], bool):
        raise CensusError(f"receipt.exit_status must be an integer: {receipt_path}")
    for field in ("observed_behavior", "recorded_at", "reviewer", "owner"):
        require_string(receipt[field], f"receipt.{field}")
    if receipt["owner"] != entry["owner"]:
        raise CensusError(f"receipt owner mismatch: {receipt_path}")
    digests = receipt["source_digests"]
    if not isinstance(digests, list) or [item.get("path") for item in digests if isinstance(item, dict)] != [item["path"] for item in entry["sources"]]:
        raise CensusError(f"receipt source_digests do not bind exact sources: {receipt_path}")
    for item, source in zip(digests, entry["sources"]):
        if not isinstance(item, dict) or set(item) != RECEIPT_DIGEST_KEYS or item["path"] != source["path"] or item["sha256"] != sha256_git(root, source["path"]):
            raise CensusError(f"stale or malformed source digest: {receipt_path}")
    test_evidence = receipt["test_evidence"]
    if not isinstance(test_evidence, dict) or set(test_evidence) != RECEIPT_DIGEST_KEYS:
        raise CensusError(f"receipt.test_evidence is malformed: {receipt_path}")
    if not test_evidence["path"].startswith("test/"):
        raise CensusError(f"receipt test evidence must be under test/: {receipt_path}")
    safe_repo_path(root, test_evidence["path"], tracked, "receipt test evidence", {"100755"})
    if test_evidence["sha256"] != sha256_git(root, test_evidence["path"]):
        raise CensusError(f"stale test evidence digest: {receipt_path}")
    if entry["disposition"] != "blocked" and receipt["exit_status"] != 0:
        raise CensusError(f"non-blocked receipt must have exit_status 0: {receipt_path}")
    if transition and receipt["exit_status"] != 0:
        raise CensusError(f"accepted receipt must have exit_status 0: {receipt_path}")
    return receipt


def validate(root: Path, manifest_path: Path, queue_path: Path) -> tuple[list[str], Counter[str], int, int]:
    try:
        tracked = tracked_index(root)
        expected = discover(root)
        manifest = load_json(manifest_path, "manifest")
        queue = load_json(queue_path, "queue")
    except CensusError as error:
        return [str(error)], Counter(), 0, 0
    errors: list[str] = []
    expected_by_id = {entry["id"]: entry for entry in expected}
    if not isinstance(manifest, dict) or set(manifest) != {"schema", "entries"} or manifest.get("schema") != SCHEMA:
        errors.append(f"manifest must use schema {SCHEMA} with exactly schema and entries")
        manifest_entries: list[Any] = []
    else:
        manifest_entries = manifest.get("entries", [])
        if not isinstance(manifest_entries, list):
            errors.append("manifest entries must be an array")
            manifest_entries = []
    actual_ids = [entry.get("id") if isinstance(entry, dict) else None for entry in manifest_entries]
    if actual_ids != sorted(actual_ids, key=lambda value: "" if value is None else value):
        errors.append("manifest entries must be sorted by id")
    if len(actual_ids) != len(set(actual_ids)):
        errors.append("manifest entries contain duplicate ids")
    actual_by_id = {entry.get("id"): entry for entry in manifest_entries if isinstance(entry, dict)}
    errors.extend(f"missing census entry: {item}" for item in sorted(set(expected_by_id) - set(actual_by_id)))
    errors.extend(f"extra census entry: {item}" for item in sorted(set(actual_by_id) - set(expected_by_id)))
    for index, entry in enumerate(manifest_entries):
        if not isinstance(entry, dict):
            errors.append(f"entry {index} must be an object")
            continue
        label = f"entry {entry.get('id', index)}"
        if set(entry) != ENTRY_KEYS:
            errors.append(f"{label} has wrong fields")
        if not isinstance(entry.get("id"), str) or not ID_RE.fullmatch(entry["id"]):
            errors.append(f"{label}.id is malformed")
        expected_entry = expected_by_id.get(entry.get("id"))
        if expected_entry is not None and (entry.get("kind") != expected_entry["kind"] or entry.get("sources") != expected_entry["sources"]):
            errors.append(f"{label} does not exactly match discovered source inventory")
        sources = entry.get("sources")
        if not isinstance(sources, list) or not sources:
            errors.append(f"{label}.sources must be a non-empty array")
        elif any(not isinstance(item, dict) or set(item) != SOURCE_KEYS for item in sources):
            errors.append(f"{label}.sources contain malformed records")
        else:
            if sources != sorted(sources, key=lambda item: (item["kind"], item["path"])):
                errors.append(f"{label}.sources must be sorted")
            for item in sources:
                if item["kind"] not in SOURCE_KINDS:
                    errors.append(f"{label}.sources kind is invalid")
                try:
                    safe_repo_path(root, item["path"], tracked, f"{label}.source", {"100644", "100755"})
                except CensusError as error:
                    errors.append(str(error))
        if entry.get("kind") not in {"command", "application"}:
            errors.append(f"{label}.kind is invalid")
        if entry.get("disposition") not in DISPOSITIONS:
            errors.append(f"{label}.disposition is invalid")
        for field in ("owner", "notes"):
            if not isinstance(entry.get(field), str) or not entry[field]:
                errors.append(f"{label}.{field} must be a non-empty string")
        evidence = entry.get("evidence")
        if not isinstance(evidence, dict) or set(evidence) != EVIDENCE_KEYS or evidence.get("kind") not in RECEIPT_KINDS or not isinstance(evidence.get("reference"), str):
            errors.append(f"{label}.evidence is malformed")
        elif evidence["kind"] == "pending":
            if evidence["reference"] != evidence_path(entry["id"]):
                errors.append(f"{label}.pending evidence path is not deterministic")
            if evidence["reference"] in tracked:
                errors.append(f"{label}.pending receipt unexpectedly exists")
        else:
            try:
                validate_receipt(root, tracked, entry, evidence["reference"])
            except CensusError as error:
                errors.append(str(error))
        queue_ref = entry.get("queue_id")
        if entry.get("disposition") == "blocked":
            if queue_ref != queue_id(entry["id"]):
                errors.append(f"{label} blocked entry has invalid queue_id")
        elif queue_ref is not None:
            errors.append(f"{label} non-blocked entries must have queue_id null")
        if entry.get("disposition") != "blocked" and (not isinstance(evidence, dict) or evidence.get("kind") != "receipt"):
            errors.append(f"{label} non-blocked disposition requires a receipt")
    if not isinstance(queue, dict) or set(queue) != {"schema", "items"} or queue.get("schema") != SCHEMA:
        errors.append(f"queue must use schema {SCHEMA} with exactly schema and items")
        queue_items: list[Any] = []
    else:
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
    blocked = {entry.get("queue_id") for entry in manifest_entries if isinstance(entry, dict) and entry.get("disposition") == "blocked"}
    errors.extend(f"blocked entry has no queue item: {item_id}" for item_id in sorted(blocked - set(queue_by_id)))
    errors.extend(f"orphan queue item: {item_id}" for item_id in sorted(set(queue_by_id) - blocked))
    for item_id in sorted(blocked & set(queue_by_id)):
        matching_count = sum(1 for entry in manifest_entries if isinstance(entry, dict) and entry.get("queue_id") == item_id)
        if matching_count != 1:
            errors.append(f"queue id is not one-to-one: {item_id} ({matching_count} entries)")
    for index, item in enumerate(queue_items):
        if not isinstance(item, dict):
            errors.append(f"queue item {index} must be an object")
            continue
        label = f"queue item {item.get('id', index)}"
        if set(item) != QUEUE_KEYS:
            errors.append(f"{label} has wrong fields")
        for field in ("id", "owner", "dependency", "next_action"):
            if not isinstance(item.get(field), str) or not item[field]:
                errors.append(f"{label}.{field} must be a non-empty string")
        if not isinstance(item.get("id"), str) or not QUEUE_ID_RE.fullmatch(item["id"]):
            errors.append(f"{label}.id is malformed")
        if item.get("status") not in QUEUE_STATUSES:
            errors.append(f"{label}.status is invalid")
        matching = [entry for entry in manifest_entries if isinstance(entry, dict) and entry.get("queue_id") == item.get("id")]
        if len(matching) == 1:
            entry = matching[0]
            if item.get("owner") != entry.get("owner"):
                errors.append(f"{label}.owner does not match census owner")
            if item.get("status") == "complete" and entry.get("disposition") == "blocked":
                errors.append(f"{label} cannot be complete while entry is blocked")
            acceptance = item.get("acceptance")
            expected_command = acceptance_command(entry["id"], entry.get("evidence", {}).get("reference", ""))
            if not isinstance(acceptance, dict) or set(acceptance) != ACCEPTANCE_KEYS or acceptance.get("command") != expected_command:
                errors.append(f"{label}.acceptance.command must name exact entry")
            if isinstance(acceptance, dict) and acceptance.get("evidence") != entry.get("evidence", {}).get("reference"):
                errors.append(f"{label}.acceptance.evidence must match entry receipt path")
        acceptance = item.get("acceptance")
        if isinstance(acceptance, dict) and set(acceptance) == ACCEPTANCE_KEYS:
            evidence = acceptance.get("evidence")
            if not isinstance(evidence, str) or not evidence.startswith("platform/apple-silicon/evidence/") or ".." in PurePosixPath(evidence).parts:
                errors.append(f"{label}.acceptance.evidence is malformed")
            elif evidence in tracked and tracked[evidence] != "100644":
                errors.append(f"{label}.acceptance.evidence has invalid mode")
    summary = Counter(f"{entry.get('kind')}:{entry.get('disposition')}" for entry in manifest_entries if isinstance(entry, dict))
    return errors, summary, len(expected), len(manifest_entries)


def atomic_write(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    handle = tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, prefix=f".{path.name}.", delete=False)
    try:
        with handle:
            json.dump(data, handle, indent=2, ensure_ascii=False)
            handle.write("\n")
        os.replace(handle.name, path)
    except OSError as error:
        try:
            os.unlink(handle.name)
        except OSError:
            pass
        raise CensusError(f"atomic write failed for {path}: {error}") from error


def preserve_inventory(root: Path, manifest_path: Path, queue_path: Path) -> None:
    entries = discover(root)
    old_manifest = load_json(manifest_path, "manifest") if manifest_path.exists() else None
    old_queue = load_json(queue_path, "queue") if queue_path.exists() else None
    legacy_manifest = isinstance(old_manifest, dict) and old_manifest.get("schema") != SCHEMA
    legacy_queue = isinstance(old_queue, dict) and old_queue.get("schema") != SCHEMA
    old_entries = {item["id"]: item for item in old_manifest.get("entries", [])} if not legacy_manifest and isinstance(old_manifest, dict) and isinstance(old_manifest.get("entries"), list) else {}
    old_queue_items = {item["id"]: item for item in old_queue.get("items", [])} if not legacy_queue and isinstance(old_queue, dict) and isinstance(old_queue.get("items"), list) else {}
    current_ids = {entry["id"] for entry in entries}
    removed = sorted(set(old_entries) - current_ids)
    if removed:
        raise CensusError("ambiguous inventory removal; review explicitly before updating: " + ", ".join(removed))
    updated: list[dict[str, Any]] = []
    for entry in entries:
        prior = old_entries.get(entry["id"])
        if prior is not None:
            for field in ("disposition", "evidence", "owner", "queue_id", "notes"):
                if field in prior:
                    entry[field] = copy.deepcopy(prior[field])
        updated.append(entry)
    generated_queue = queue_for(updated)
    old_orphans = sorted(set(old_queue_items) - {item["id"] for item in generated_queue})
    if old_orphans:
        raise CensusError("ambiguous queue removal; review explicitly before updating: " + ", ".join(old_orphans))
    for item in generated_queue:
        prior = old_queue_items.get(item["id"])
        if prior is not None:
            generated_acceptance = copy.deepcopy(item["acceptance"])
            item.clear()
            item.update(copy.deepcopy(prior))
            # The acceptance protocol is an executable contract, not a
            # reviewed disposition field; migrate old verify-entry commands
            # to the fail-closed clearance command.
            item["acceptance"] = generated_acceptance
    atomic_write(manifest_path, {"schema": SCHEMA, "entries": updated})
    atomic_write(queue_path, {"schema": SCHEMA, "items": sorted(generated_queue, key=lambda item: item["id"])})


def verify_entry(root: Path, manifest_path: Path, entry_id: str, receipt_path: str) -> int:
    tracked = tracked_index(root)
    manifest = load_json(manifest_path, "manifest")
    entries = manifest.get("entries", []) if isinstance(manifest, dict) else []
    entry = next((item for item in entries if isinstance(item, dict) and item.get("id") == entry_id), None)
    if entry is None:
        raise CensusError(f"unknown entry: {entry_id}")
    if receipt_path != entry.get("evidence", {}).get("reference"):
        raise CensusError("receipt path does not exactly match manifest evidence path")
    validate_receipt(root, tracked, entry, receipt_path)
    print(f"VERIFIED: {entry_id}")
    return 0


def accept_entry(root: Path, manifest_path: Path, queue_path: Path, entry_id: str, receipt_path: str) -> int:
    tracked = tracked_index(root)
    manifest = load_json(manifest_path, "manifest")
    queue = load_json(queue_path, "queue")
    entries = manifest.get("entries", []) if isinstance(manifest, dict) else []
    items = queue.get("items", []) if isinstance(queue, dict) else []
    matching_entries = [entry for entry in entries if isinstance(entry, dict) and entry.get("id") == entry_id]
    if len(matching_entries) != 1:
        raise CensusError(f"accept-entry requires exactly one manifest entry: {entry_id}")
    entry = matching_entries[0]
    if entry.get("disposition") != "blocked" or entry.get("evidence", {}).get("reference") != receipt_path:
        raise CensusError("accept-entry receipt does not exactly match the blocked manifest item")
    matching_items = [item for item in items if isinstance(item, dict) and item.get("id") == entry.get("queue_id")]
    if len(matching_items) != 1:
        raise CensusError(f"accept-entry requires exactly one queue row: {entry_id}")
    item = matching_items[0]
    acceptance = item.get("acceptance", {})
    if not isinstance(acceptance, dict) or acceptance.get("command") != acceptance_command(entry_id, receipt_path) or acceptance.get("evidence") != receipt_path:
        raise CensusError("accept-entry queue acceptance does not bind the exact receipt")
    receipt = validate_receipt(root, tracked, entry, receipt_path, transition=True)
    updated_manifest = copy.deepcopy(manifest)
    updated_queue = copy.deepcopy(queue)
    updated_entry = next(item for item in updated_manifest["entries"] if item["id"] == entry_id)
    updated_entry["disposition"] = receipt["disposition"]
    updated_entry["evidence"] = {"kind": "receipt", "reference": receipt_path}
    updated_entry["queue_id"] = None
    updated_queue["items"] = [item for item in updated_queue["items"] if item.get("id") != entry["queue_id"]]
    manifest_tmp = tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=manifest_path.parent, prefix=f".{manifest_path.name}.", delete=False)
    queue_tmp = tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=queue_path.parent, prefix=f".{queue_path.name}.", delete=False)
    try:
        with manifest_tmp:
            json.dump(updated_manifest, manifest_tmp, indent=2, ensure_ascii=False)
            manifest_tmp.write("\n")
        with queue_tmp:
            json.dump(updated_queue, queue_tmp, indent=2, ensure_ascii=False)
            queue_tmp.write("\n")
        errors, _, _, _ = validate(root, Path(manifest_tmp.name), Path(queue_tmp.name))
        if errors:
            raise CensusError("accept-entry postcondition failed: " + "; ".join(errors))
        os.replace(manifest_tmp.name, manifest_path)
        os.replace(queue_tmp.name, queue_path)
    except OSError as error:
        raise CensusError(f"accept-entry atomic update failed: {error}") from error
    finally:
        for temporary in (manifest_tmp.name, queue_tmp.name):
            try:
                os.unlink(temporary)
            except OSError:
                pass
    print(f"ACCEPTED: {entry_id}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--queue", type=Path)
    parser.add_argument("--update-inventory", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("subcommand", nargs="?")
    parser.add_argument("--id", dest="entry_id")
    parser.add_argument("--evidence", dest="evidence")
    args = parser.parse_args()
    root = args.root.resolve()
    manifest = (args.manifest or root / "platform/apple-silicon/parity-census.json").resolve()
    queue = (args.queue or root / "platform/apple-silicon/porting-queue.json").resolve()
    try:
        if args.subcommand == "verify-entry":
            if not args.entry_id or not args.evidence:
                raise CensusError("verify-entry requires --id and --evidence")
            return verify_entry(root, manifest, args.entry_id, args.evidence)
        if args.subcommand == "accept-entry":
            if not args.entry_id or not args.evidence:
                raise CensusError("accept-entry requires --id and --evidence")
            return accept_entry(root, manifest, queue, args.entry_id, args.evidence)
        if args.update_inventory:
            preserve_inventory(root, manifest, queue)
        errors, summary, discovered, manifest_count = validate(root, manifest, queue)
    except (CensusError, TypeError, KeyError, UnicodeError, ValueError) as error:
        print("FAIL_CENSUS:")
        print(f"- {error}")
        return 1
    print(f"DISCOVERED: {discovered}")
    print(f"MANIFEST: {manifest_count}")
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
