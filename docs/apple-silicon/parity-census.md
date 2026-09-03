# Apple Silicon product-parity census

This document defines the P-03 product-integration parity boundary. It records whether user-facing command and application sources have an ARM implementation and provides an executable queue for items that still need porting work. It is not evidence of hardware qualification, supported devices, boot success, or a release decision.

## Authoritative inventory

`tools/apple-silicon/parity-census.py` reads only the Git index through closed pathspecs. Commands are exactly tracked regular files with Git mode `100755` whose path is `bin/omarchy-*`; non-executable regular files are not commands, and symlink/submodule modes are rejected. Applications are package names from both tracked lists (`install/omarchy-base.packages` and `install/omarchy-other.packages`) plus launchers from both tracked trees (`applications/*.desktop` and `default/applications/*.desktop`). Package and launcher sources merge only when a desktop `Exec` token exactly equals a package name; all other launcher identities remain separate and produce a deterministic collision if their normalized filename identity is ambiguous.

The scanner reads package and desktop contents from Git index blobs, never from untracked files, never executes shell, and never uses network content. Its output is stable for the same index: entries and source records are sorted. IDs use `command:<basename>`, `application:package-<package>`, or `application:launcher-<slug>` and must match the closed ID grammar.

## Manifest and receipts

`platform/apple-silicon/parity-census.json` is the checked-in machine-readable manifest with schema `omarchy.apple-silicon.product-parity/v2`. Each entry has exactly `id`, `kind`, `sources`, `disposition`, `evidence`, `owner`, `queue_id`, and `notes`. `sources` is a sorted nonempty list of `{kind,path}` records. Every initial entry is conservatively `blocked`; source presence, package listing, and launcher parsing are not ARM evidence. A disposition other than `blocked` is accepted only when `evidence` is a `receipt` that directly names the exact entry and passes digest validation. Pending blocked evidence is a deterministic path under `platform/apple-silicon/evidence/`. Spotify is treated like every other current implementation source and remains blocked until its own receipt exists; it is not classified as a web substitute by name.

Receipts use a closed schema with `entry_id`, `disposition`, `architecture`, `command`, `exit_status`, `observed_behavior`, `source_digests`, `test_evidence`, `recorded_at`, `reviewer`, and `owner`. They are tracked JSON files under `platform/apple-silicon/evidence/`; source and test evidence SHA-256 digests are checked against Git index blobs. `verify-entry --id <id> --evidence <path>` rejects absent, mismatched, malformed, or stale receipts. A blocked probe is allowed to record a nonzero exit status while the queue remains open.

## Queue and updates

`platform/apple-silicon/porting-queue.json` is a closed one-to-one queue. Each item has exactly `id`, `owner`, `dependency`, `next_action`, `acceptance`, and `status`; status is `planned`, `in-progress`, or `complete`. Every blocked entry has one queue item with a unique acceptance command containing the exact entry ID and expected receipt path. A complete queue item is invalid while its entry is blocked, and a nonblocked entry cannot retain a queue item.

Run `python3 tools/apple-silicon/parity-census.py --check` to validate the tracked inventory and manifests. `--update-inventory` is the only mutating mode. It preserves reviewed disposition, evidence, owner, notes, queue fields, and queue status byte-for-byte for retained IDs, adds new sources as blocked, rejects ambiguous removals, and writes both files through temporary files plus atomic rename. There is no destructive `--write` mode.

The shell test `test/shell.d/apple-silicon-parity-census-test.sh` runs the checker in temporary Git fixtures and covers inventory drift, malformed paths/modes/IDs, package and desktop grammar, receipts, queue invariants, and reviewed-field preservation.
