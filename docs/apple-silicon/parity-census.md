# Apple Silicon product-parity census

This document defines the P-03 product-integration parity boundary. It records whether the user-facing command and application sources in this tree have an ARM implementation, and provides an executable queue for the items that still need porting work. It is not evidence of hardware qualification, supported devices, boot success, or a release decision.

## Authoritative inventory

`tools/apple-silicon/parity-census.py` asks Git for the tracked tree with `git ls-files`. Commands are every tracked regular file whose path matches `bin/omarchy-*`. Applications are package-backed desktop programs named by the tracked package lists (`install/omarchy-base.packages` and `install/omarchy-other.packages`) together with tracked desktop launchers under `default/applications/*.desktop`. Package list comments and blank lines are ignored. A package that is both listed and named by a launcher is one manifest entry, not two. These selectors are deliberately closed and are part of the checker contract: adding a source that matches a selector requires regenerating the manifest in the same change.

The scanner never walks untracked files and does not execute shell, parse network content, or inspect any boot-boundary source. Its output is stable for the same Git tree: entries are sorted by `id`, and IDs are `command:<basename>` for commands and `application:<name>` for package/application names.

## Manifest format

`platform/apple-silicon/parity-census.json` is the checked-in machine-readable manifest. Its top-level `schema` is `omarchy.apple-silicon.product-parity/v1`, and `entries` is the complete sorted census. Each entry has exactly these fields: `id`, `kind`, `source`, `disposition`, `evidence`, `owner`, `queue_id`, and `notes`. `kind` is `command` or `application`; `disposition` is one of `native`, `ported`, `web-substitute`, `optional`, or `blocked`. `evidence` has `kind` (`source`, `package-list`, `desktop-entry`, or `test`) and a repository `reference` path. A disposition other than `blocked` has `queue_id: null`. Blocked entries must point to one queue item.

`platform/apple-silicon/porting-queue.json` is the closed queue. Each item has `id`, `owner`, `dependency`, `next_action`, `acceptance`, and `status`. The `acceptance` object contains an executable `command` and an evidence path. Queue IDs are unique, every blocked entry references exactly one item, and no queue item may be orphaned. The initial census uses conservative dispositions: uncertain native availability is blocked, while an explicitly optional or web application path is recorded as such. The intentional Mac divergences listed in `AGENTS.md` remain truthful product distinctions and are not treated as failures by this census.

## Verification

Run `python3 tools/apple-silicon/parity-census.py`. It prints the discovered and manifest counts and a summary by kind/disposition, then exits nonzero for missing, extra, duplicate, unsorted, malformed, stale, or unqueued entries. Use `--write` only when intentionally regenerating both manifests from the current tracked tree; generated entries still require human disposition and queue review before they can be accepted. The shell test `test/shell.d/apple-silicon-parity-census-test.sh` copies manifests into temporary Git fixtures and exercises hostile drift cases without mutating this checkout.
