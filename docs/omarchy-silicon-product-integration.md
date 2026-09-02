# Omarchy Silicon product integration design (P-01–P-05)

Status: DESIGN NOTE only. This document does not implement a registry, change production behavior, edit `PROGRAM.md`, merge a branch, establish compatibility, or mark any slice or program DONE.

This design is for the `omarchy-mac` product/control-plane side of the Omarchy Silicon program. The canonical program baseline read for this lane is [`PROGRAM.md` at `omarchy-silicon/omarchy-apple-platform` main](https://github.com/omarchy-silicon/omarchy-apple-platform/blob/main/PROGRAM.md), resolved at `7183eb7cd25a32b092c74991c4c09dbe27018292` on 2026-09-02. The lane is based on `origin/quattro` at `95ffbc41a6d5d5356c217e503b51f3f7c3bd80f1`.

## 1. Scope, boundaries, and non-claims

The target is a narrow integration contract: `omarchy-mac` consumes signed, generated platform data, admits a platform-scoped operation before its first mutation, reports typed capability results, and exposes an update/recovery UX that cannot claim success before required verification. The canonical platform repository owns the registry, schemas, manifests, lockfiles, signing, qualification records, and release authority. The installer/recovery repository owns the macOS/Recovery/APFS transaction. This lane owns the consumer design, policy wiring, command and app parity census, diagnostics, migrations, and user-visible state.

This design does not infer support from `uname -m`, a chip family, a successful build, a VM, a booting desktop, or an existing package. Exact board identity, SoC identity, device-tree records, firmware schema, signed platform release, and qualified capability records are required inputs. An unknown or ambiguous identity is a blocking result.

The coordinator supersession fence makes `m1n1-omarchy` an opaque human-produced artifact boundary. This lane does not inspect, read, analyze, edit, test, clone further, or make claims about that repository or its contents. Any boot-component evidence required by the program must be supplied by the coordinator as an external, human-produced artifact or physical-lab record.

## 2. Authority and contract model

The platform repository is the only authority for these versioned contracts:

| Contract | Consumer use | Authority and acceptance rule |
| --- | --- | --- |
| `board-registry/v1` | Exact board, SoC, device-tree, firmware schema, lifecycle, and capability identity | Generated and signed by `omarchy-apple-platform`; consumer rejects an unknown schema, invalid signature, stale record, or ambiguous match. |
| `platform-manifest/v1` | One immutable release tuple: board record, kernel/boot artifacts, packages, apps, migrations, provenance, and rollback metadata | The manifest selects the tuple; `omarchy-mac` must not select independent component versions. |
| `installer-plan/v1` | Read-only inventory and planned mutation scopes | Plan is serializable, reviewable, and complete before mutation; execution accepts only its digest-bound plan. |
| `qualification-record/v1` | Physical board/capability evidence and release qualification | A recognized record is not a qualification claim; the record must identify the exact board, release, test set, and evidence. |
| `boot-health/v1` | First-boot attestation and update health result | The active tuple is committed only after required boot and capability checks pass. |

The consumer should receive a generated, signed bundle with a stable layout such as `platform/board-registry.v1.json`, `platform/platform-manifest.v1.json`, detached signatures, schema identifiers, a source commit, a build identifier, and a bundle digest. These names are proposed design labels, not existing files. The bundle must be installed atomically, retained with the active transaction record, and validated offline before any package, repository, boot, system, or user-state write. A generated shell-safe binding may expose typed fields to the existing Bash control plane, but it must be generated from the canonical schema rather than re-declaring the board map.

There must be one identity authority, proposed here as the `platform identity` library/command boundary. It resolves a supplied inventory into exactly one immutable identity tuple containing at least `board_id`, product/model, SoC identity, normalized device-tree compatibles, firmware schema, platform release, registry version, and capability IDs. All installers, setup commands, hardware leaves, package/app planners, diagnostics, migrations, and update commands consume that result. A caller may ask whether a capability is applicable, but it may not independently decide Apple-ness, board support, package substitution, or release compatibility.

The authority must distinguish `unknown`, `ambiguous`, `unsupported`, `stale`, `invalid`, and `qualified`. Chip family and `aarch64` are diagnostic facts only. `uname -m` may remain in diagnostics or a human-readable hint, but it cannot be a decision predicate for a platform-scoped mutation.

## 3. One pre-mutation admission chokepoint

The proposed chokepoint is `platform admit(operation, mutation_scope)`. The name is provisional; the invariant is not. It is a single implementation boundary backed by the identity authority and called by every platform-scoped entrypoint. It must produce a digest-bound `installer-plan/v1` and an admission token or equivalent transaction context. No leaf is allowed to manufacture its own “Apple” or “ARM” decision.

Admission is a two-phase protocol:

1. Collect read-only inventory, load the signed generated bundle, verify signature/schema/digest/expiry, resolve exact identity, calculate capability outcomes, and write no target state.
2. Display or serialize the complete plan, obtain the operation’s existing confirmation/authorization, then allow mutations only through the admitted transaction context. Every mutation is journaled and post-verified against the plan; a stale plan, changed identity, changed manifest, or missing authorization fails closed.

The chokepoint must run before the first mutation in all of these paths:

| Path family | Current entrypoints and required future boundary |
| --- | --- |
| Bootstrap and Mac installer | `install.sh` before `ensure_utf8_locale`, `ensure_gum`, source/package setup, temporary privilege, or any write; `bin/omarchy-mac-setup` before log/state creation, checkout replacement, user creation, fonts, keymap, hostname, config, systemd unit, or `--step`/`--resume` mutation. The current main sequence is visible at `bin/omarchy-mac-setup:1292-1325`. |
| Root system setup | `bin/omarchy-apply-system`, `bin/omarchy-apply-hardware`, `bin/omarchy-provision-owner`, and the root setup service must admit before sourcing any leaf. The current wrappers only establish path/logging and source leaves at `bin/omarchy-apply-system:83-102`, `bin/omarchy-apply-hardware:58-75`, and the install leaves are dispatched through `install/helpers/logging.sh:41-76`. |
| User setup | `bin/omarchy-provision-user` and `bin/omarchy-provision-first-run` must admit their declared scope before config, application, state, or migration-marker writes. User-only operations can use an explicit `universal-user` scope; Apple capability operations still require the exact identity. |
| Installation and package primitives | `omarchy-install-*`, `omarchy-pkg-*`, `omarchy-appimage-*`, `omarchy-webapp-*`, `omarchy-tui-*`, and `omarchy-reinstall-*` must be reached through an admitted operation. Package and app helpers must reject a missing or mismatched transaction context rather than treating an unavailable package as success. |
| Setup and hardware commands | Every mutating `omarchy-setup-*`, hardware leaf under `install/hardware/`, and platform-specific user leaf under `install/user/hardware/` must use the same authority. Read-only `hw-*` probes may report facts, but a setup command cannot re-probe and choose a different board policy. |
| Upgrade, channel, and update | `omarchy-update`, `omarchy-update-system-pkgs`, `omarchy-update-dev`, `omarchy-update-firmware`, `omarchy-channel-set`, `omarchy-reinstall-pkgs`, and `omarchy-upgrade-to-quattro-mac` must admit the complete platform tuple before package, checkout, repository, or boot selection changes. The direct pacman guard is a safety net, not the platform authority. |
| Migrations and scheduled paths | `omarchy-migrate`, login-time migration notification, systemd setup units, and any future scheduled installer/update service must carry an explicit operation scope and admission context. Direct execution of a leaf must fail closed or be limited to a declared read-only mode. |

The implementation must test both the public command route and the underlying script path. A hidden route, a direct `bash` source, a resumed systemd service, a root invocation, a user invocation, an already-installed machine, and an interrupted transaction are separate admission cases. `--abort` and recovery actions must be able to close an existing journal without silently starting a new install, but they still validate transaction identity before writing recovery state.

The platform admission result must be machine-readable and human-readable. A required failure returns nonzero, leaves no success marker, and identifies the next safe action. An optional failure may return zero only when the operation’s overall result is explicitly `completed_with_optional_gaps`; it must never be rendered as `Install complete`, `Update complete`, or equivalent. Unknown is never equivalent to not applicable.

Proposed outcome vocabulary:

| Result | Meaning | Overall operation rule |
| --- | --- | --- |
| `ready` | Required capability is present in the plan and eligible to run | May proceed to mutation. |
| `applied` | Mutation completed and post-verification passed | Counts toward required completion. |
| `not_applicable` | The signed board record explicitly excludes the capability | Valid only for a capability marked not applicable by the registry. |
| `optional_unavailable` | Optional capability could not be installed or verified | Visible gap; operation may finish with a degraded-but-honest result. |
| `required_blocked` | Required capability is unknown, unsupported, stale, unavailable, or preconditioned incorrectly | Nonzero; no success marker or reboot-as-complete. |
| `failed` | A required mutation or verification failed | Nonzero; preserve journal and recovery path. |
| `interrupted` | Power, process, network, or storage interruption left a transaction open | Nonzero until resume, rollback, or abort closes it. |

The result record should include `operation_id`, `plan_digest`, `bundle_digest`, exact identity digest, capability ID, requiredness, status, reason code, redacted evidence references, and next action. Human output is derived from that record, not from ad hoc warning strings.

## 4. P-01 — generated registry consumption

P-01 consumes only generated bindings and signed runtime data from `board-registry/v1` and `platform-manifest/v1`. It removes the current split authority between `install.sh`, Apple hardware leaves, package deny lists, app fallbacks, and update scripts. The current router itself deliberately has no command registry beyond executable files and metadata (`docs/cli-router.md:3-8`); that remains a command-discovery concern and must not be confused with the platform registry.

The consumer contract is:

- Validate the bundle’s signature against a pinned, rotated trust-root policy supplied by the platform authority; reject missing, malformed, expired, or unexpected schema versions.
- Resolve identity from the generated matching rules and record all observed inputs needed to explain the match without uploading raw sensitive identifiers.
- Select capabilities only from the signed board record and release manifest. A package name, AUR availability result, `uname -m`, `/proc/device-tree/compatible` grep, DMI string, PCI ID, or GPU vendor is evidence to the identity authority, not an independent policy source.
- Keep the active and last-known-good bundles and bind each installed state, transaction journal, support bundle, and boot-health record to a digest.
- Fail closed before mutation if the bundle cannot be validated, if more than one board record matches, if no board record matches, or if the release has no required qualification record.
- Make generated-data drift a gate: regeneration from the canonical schema must produce no uncommitted consumer artifact changes.

The current Apple decision seams that P-01 replaces include the architecture/device-tree warning in `install.sh:57-64`, the Apple package choice in `install/hardware/vulkan.sh:6-24`, the audio selection in `install/hardware/apple/audio.sh:27-40`, the ARM mirror gate in `install/preflight/arm-mirrors.sh:5-39`, the Apple-specific user leaves in `install/user/all.sh:1-16`, and the separate unavailable package map in `install/omarchy-aarch64-unavailable.packages:1-41` consumed by `install.sh:203-230`. These may remain as compatibility adapters during migration, but they cannot remain authorities.

## 5. P-02 — typed capability outcomes and fail census

The implementation must replace warning-as-policy with typed results at the operation boundary. A leaf may emit a warning as context, but it must return the result object and the orchestrator must decide whether the result blocks. Success markers are written only after all required results are `applied` or registry-authorized `not_applicable`.

### Current warning-success seams

This is the current seam census found in the authorized `omarchy-mac` tree. It is a fail census, not an acceptance claim.

| Current seam | Evidence | Risk and required correction |
| --- | --- | --- |
| Installer accepts non-confirmed Apple hardware | `install.sh:57-64` checks `aarch64` and greps Apple-compatible text, then says “continuing anyway” | Unknown hardware can reach package, source, privilege, and system mutation; replace with `required_blocked` before `ensure_gum`. |
| Installer skips package failures and still completes | `install.sh:213-243` collects failed AUR packages, warns, and returns success; `install.sh:282-297` always logs “Install complete” after the sequence | Classify every package as required/optional/not applicable from the manifest; prohibit completion when a required result is absent. |
| Unavailable ARM packages are a mutable deny list | `install.sh:188-210` prompts around `install/omarchy-aarch64-unavailable.packages` and `install.sh:229-241` warns on skipped packages | Generated capability/package records must replace the deny list; a stale or unknown record blocks required work. |
| Missing Mac setup version is only a warning | `bin/omarchy-mac-setup:693-700` logs `unknown` and warns when `version` is absent | A missing release identity must be `required_blocked` before checkout acceptance or install. |
| Missing session file does not fail setup | `bin/omarchy-mac-setup:906-921` returns success after no candidate is found; `bin/omarchy-mac-setup:939-948` leaves the greeter alone when no session is found | For encrypted installs, session/autologin is a required capability unless the manifest explicitly marks it not applicable; preserve a recoverable plan otherwise. |
| Keymap writes tolerate failure | `bin/omarchy-mac-setup:132-170` uses `loadkeys ... || true` and warns after persistence fallback | Return `applied`, `optional_unavailable`, or `required_blocked` according to the manifest; never let a required first-boot input path disappear into a green install. |
| Apple audio stack can be incomplete | `install/hardware/apple/audio.sh:35-53` warns on package or daemon failure and continues | Required audio must block; optional audio must be visible in the overall result and support bundle. |
| Optional app failure is only text | `install/post-install/optional-apps.sh:16-22` catches 1Password failure and prints a manual-install message | Use a typed optional result and an explicit capability ID; do not imply the default app set is complete. |
| ARM mirror helper reports warning completion | `install/preflight/arm-mirrors.sh:24-39` returns from missing helper/failure paths while printing warning; `install/helpers/set-arm-mirrors.sh:229-235` proceeds with the primary mirror when both tested mirrors fail | Mirror selection is part of the signed source plan; an unverified source must block required package mutation. |
| Package helper skips unavailable names with exit 0 | `bin/omarchy-pkg-add:12-21` prints “Skipping” for packages not found and exits 0 if none remain | The helper needs a typed unavailable result or admitted requiredness; filtered-empty cannot mean success for a required capability. |
| Snapshot failure continues update | `bin/omarchy-update:33-37` continues without a snapshot after failures other than the deliberate absent-tool case | Snapshot policy must be in the platform transaction plan; absence may be an explicit policy result, while an unexpected failure blocks an atomic update. |
| Update shell restart failure is ignored | `bin/omarchy-update-restart:37-42` runs `omarchy-restart-shell || true` | Record restart as a post-update capability and keep the transaction pending until the required health state is verified. |
| Security setup can print failure without a failing result | `bin/omarchy-setup-security-fingerprint:105-109` and `bin/omarchy-setup-security-fido2:129-148` print enrollment/verification failures without making every failure a nonzero operation result | Typed requiredness must distinguish “not enrolled”, “verification failed”, and “not applicable”; no success marker may be emitted for a requested required control. |
| SSH setup treats missing firewall as success | `bin/omarchy-setup-security-sshd:60-75` skips UFW with a message | The manifest declares whether firewall is required; report `not_applicable` only when authorized, otherwise block or report an optional gap. |
| Identification intentionally always succeeds | `install/preflight/identification.sh:5-18` explicitly returns success when optional name/email prompts are skipped | Keep this as a user-choice result, not a platform capability; make its optionality machine-readable so it cannot be copied as a setup pattern. |
| Leaf runner records only shell exit status | `install/helpers/logging.sh:41-76` runs each sourced leaf and labels it Completed when exit code is zero | Wrap leaves in result collection and central policy; logs are evidence, not the success contract. |
| Upgrade removes packages with warning and continues | `bin/omarchy-upgrade-to-quattro-mac:345-356` leaves retired packages installed when removal fails and allows NetworkManager to remain absent | The tuple plan must identify required retired-state and network capabilities, then stop or show an explicit incomplete upgrade state. |

### Existing positive seams to preserve and formalize

The redesign should retain the useful behavior already present while moving its authority into the typed transaction: `bin/omarchy-pkg-add:23-37` verifies packages after installation; `bin/omarchy-mac-setup:1041-1048` captures the install status and revokes temporary privilege before failing; `bin/omarchy-mac-setup:969-976` verifies the initramfs hook after a rebuild; `bin/omarchy-migrate:91-97` marks a migration only after its script succeeds; and `bin/omarchy-provision-first-run:104-108` marks first run only when all steps pass. Each becomes a required postcondition or an explicitly optional capability result rather than an implicit shell convention.

### Current duplicate-detection and drift seams

These checks prevent some repeated work, but they are not a single platform identity or transaction authority. They must be retained as lower-level idempotence while their decisions are bound to the generated plan.

| Current seam | Evidence | Required P-01/P-02 treatment |
| --- | --- | --- |
| CLI route collision detection | `bin/omarchy:149-165` records `ROUTE_COLLISIONS`; executable command discovery is performed at `bin/omarchy:313-319` | Keep command metadata as the route authority and keep `omarchy commands --check`; do not use command routes as a substitute for platform capability identity. |
| Mac install completion has four signals | `bin/omarchy-mac-setup:227-274` combines an installed marker, `@factory`, runtime version, and display-manager link | Replace implicit signal precedence with a digest-bound transaction state; a marker is valid only after required capability postconditions. |
| Staged checkout replacement | `bin/omarchy-mac-setup:644-668` reuses a matching checkout but recursively replaces a mismatched one | Bind checkout provenance to the signed manifest; never accept “some `.git`” or a mutable branch as release identity, and make replacement journaled/recoverable. |
| Session-file no-op detection | `bin/omarchy-mac-setup:896-921` returns early when `omarchy.desktop` exists and also returns success when no candidate exists | Keep idempotent install behavior but require a verified session capability before encrypted setup can complete. |
| User finalization marker | `bin/omarchy-provision-user:56-62` skips unless `--force` is supplied | Make the marker include the plan/bundle digest and required result summary; a stale marker must trigger read-only revalidation, not unconditional success. |
| First-install migration pre-marking | `bin/omarchy-provision-user:115-122` touches every migration marker on first install before marking finalization complete | Stop pre-marking future migrations; mark only migrations actually executed successfully under the admitted plan. |
| First-run retry marker | `bin/omarchy-provision-first-run:39-44,104-108` skips completed first run and marks it only when all steps pass | Preserve retry semantics, but include capability results and transaction identity so a partial run cannot be mistaken for a completed platform setup. |
| Migration pending/mark-after-success | `bin/omarchy-migrate:35-56,85-97` uses one marker per migration and marks after the script returns success | Preserve this idempotence model; add platform scope, authority version, plan digest, and an explicit blocked result for unsupported identity. |
| Package pre/post checks | `bin/omarchy-pkg-add:12-37` skips names found neither installed nor in metadata, then verifies installed state | Keep postcondition checks, but require an admission context and make filtered-empty a typed unavailable result for required packages. |
| ARM mirror append avoidance | `install/helpers/set-arm-mirrors.sh:242-256` detects an existing matching `Server` line before appending | Keep idempotent merge and backup behavior; bind the selected mirror/source to the signed manifest and fail closed when verification cannot establish a source. |
| Preinstall install/remove list duplication | `bin/omarchy-install-preinstalls:15-32` and `bin/omarchy-remove-preinstalls:20-38` carry separate package arrays; `test/shell.d/preinstalls-test.sh:48-86` checks their overlap | Generate one install/remove capability record and make the test compare generated output, including ARM substitute exclusivity and failed-removal state. |
| Split package availability authorities | `install/omarchy-base.packages:1-152`, `install/omarchy-other.packages:1-77`, and `install/omarchy-aarch64-unavailable.packages:1-41` are interpreted by different callers; `zram-generator` appears in both base and other lists | Make the platform manifest the one source for package role, architecture, provider, and requiredness; report duplicate package rows as census failures unless explicitly layered. |
| ARM app substitute duplication | `install/omarchy-aarch64-unavailable.packages:41` names `obsidian` as unavailable while `install/user/hardware/apple/obsidian.sh:7-18` selects `obsidian-appimage`, and preinstall commands carry both names | A generated capability must express primary provider, substitute, mutual exclusion, verification, and rollback; hand-maintained parallel lists are temporary adapters only. |


## 6. P-03 — command and app ARM parity census

P-03 produces a generated census before implementation changes claim parity. The source inventory is `bin/omarchy` metadata and `omarchy commands --all --json`, executable `bin/omarchy-*` files, package manifests under `install/`, optional setup/install sources, and every desktop file under `applications/` plus `default/applications/`. The census record for each command/app contains route, binary, package/provider, source URL or repository, architecture, capability IDs, requiredness, fallback/substitute, `Exec` target, verification command, and evidence status.

The generated census classifies each item as `native`, `arch-any`, `ARM substitute`, `webapp/wrapper`, `not applicable`, `blocked`, or `unknown`. `unknown` blocks a required product profile. It does not mean that every app must have an ARM-native binary: a signed, tested webapp or approved ARM substitute can satisfy a capability when the manifest says so.

Initial high-risk census observations:

| Surface | Current evidence | P-03 action |
| --- | --- | --- |
| Command metadata and routes | `docs/cli-router.md:3-8` describes executable-file discovery; `docs/cli-router.md:32-45` records collision and metadata behavior; `docs/cli-router.md:118-127` defines `omarchy commands --check` failures | Export route/binary metadata into the parity census; preserve `GROUP_DESCRIPTIONS` and first-80-line metadata rules from `AGENTS.md` and `agents/skills/command-metadata.md`. |
| Mac setup and bootstrap | `bin/omarchy-mac-setup:1-7` exposes Mac-specific setup controls; `install.sh:57-64` is an ARM/Apple probe rather than a registry consumer | Mark as platform-scoped and require P-01 admission before any install/setup mutation. |
| ARM package gaps | `install/omarchy-aarch64-unavailable.packages:1-41` names `obs-studio`, `dotnet-runtime`, `pinta`, and `obsidian`; the base package list still contains broad defaults at `install/omarchy-base.packages:48,93-94,101,109,112` | For each name, record package availability, approved substitute, requiredness, and physical/functional verification in the generated manifest; delete no list until generated parity passes. |
| Obsidian | `install/user/hardware/apple/obsidian.sh:1-23` prefers `obsidian-appimage` and falls back to AUR; `bin/omarchy-install-preinstalls:15-32` and `bin/omarchy-remove-preinstalls:20-38` separately carry `obsidian` and the ARM substitute | Collapse install/remove/refresh into one generated capability record and test exact replacement semantics, including rollback and absence. |
| Share picker and optional services | `install/user/hardware/apple/share-picker.sh:1-8` uses an ARM-only package/fallback; `install/post-install/optional-apps.sh:4-22` treats 1Password as best effort; `bin/omarchy-install-service-1password:24-45` treats the CLI as optional on ARM | Record app/service requiredness and architecture/provider in the manifest; return typed optional gaps. |
| Screen recording | `install.sh:237-238` and `bin/omarchy-upgrade-to-quattro-mac:231-242` use `wf-recorder` as an Apple GPU fallback | Keep this intentional backend divergence only as a signed, verified capability mapping, not as an ad hoc package append. |
| 1Password binary | `bin/omarchy-install-1password:8,24-35` uses a hard-coded version and an ARM tarball path; `bin/omarchy-install-1password:60-78` ignores icon-cache failure and announces installation | Add source digest/signature, version provenance, executable verification, and an explicit optional/required app result. |
| Gaming graphics | `bin/omarchy-install-gaming-gpu-lib32:14-34` maps Intel/AMD/NVIDIA but has no Apple driver mapping and skips when no supported GPU is detected | Classify Apple gaming support per capability; do not infer that x86 lib32 support is ARM parity. |
| Desktop applications | Existing entries include web wrappers (Basecamp, Discord, Google services, WhatsApp, X, YouTube, Zoom, HEY), native/system entries (Docker, Foot, Imv, MPV), and the default Battle.net launcher | Validate each `Exec` target, runtime, package/provider, architecture, MIME behavior, and post-install launch on Apple hardware; wrappers are not evidence of native-app parity. |

The census must preserve intentional Mac divergences called out by repository guidance: notch-height bar sizing, `hid_apple fnmode=1` media keys, Shift+brightness for keyboard backlight, `wf-recorder` on the Asahi GPU, Spotify as a webapp, and the Codeberg update remote. These are policy exceptions to track, not defects to “normalize”; they still need capability and regression evidence.

The exact census gate is reproducible from a clean checkout: generate command JSON, package rows, setup/install rows, and desktop `Exec` rows; normalize them; compare against the signed manifest; and fail on missing, duplicate, architecture-unknown, provider-unknown, or unverified required rows. A parity row is not accepted because the command routes or the desktop file exists.

## 7. P-04 — diagnostics, support bundles, and redaction

The support artifact should be a versioned, local-first bundle containing the operation/transaction ID, plan and platform bundle digests, redacted identity summary, capability result records, source/provider provenance, package/app versions, kernel/boot-health state, migration state, and bounded relevant logs. It must record why a capability was required, optional, or not applicable without exposing raw device or owner data.

The current debug path writes date, hostname, package identity, `inxi`, dmesg, journal warnings/errors, and installed packages to `/tmp/omarchy-debug.log` at `bin/omarchy-debug:29-61`, then offers upload to `logs.omarchy.org` at `bin/omarchy-debug:68-86`. It has no explicit allowlist/redaction contract in this source. The install logger also creates a mode-666 log when configured at `install/helpers/logging.sh:13-18`. These are diagnostic/privacy residuals, not evidence that the current path is safe for a platform support bundle.

P-04 requires:

- A stable schema with a version and bundle digest; no free-form concatenation as the primary record.
- An allowlist for fields and log sections, with redaction before persistence and again before upload.
- Removal or pseudonymization of credentials, tokens, cookies, owner email/name, hostnames where not required, serials, raw device identifiers, disk paths, encryption material, private keys, recovery secrets, and unrelated user content.
- Redaction tests containing fake secrets, URLs with credentials, LUKS/device examples, SSH material, and journal lines; tests must prove the raw fixture cannot occur in the exported bundle.
- Explicit user confirmation for upload, a local export path, bounded retention, and an upload failure that remains an upload failure rather than “support bundle ready”.
- A `--print` mode that never contacts the network and a deterministic `--validate` mode for support staff.

Diagnostics may report that the m1n1 artifact is outside this lane’s inspection boundary; they must not invent facts about it or include opaque boot artifacts in a bundle without a coordinator-supplied schema and redaction rule.

## 8. P-05 — atomic platform update and rollback UX

The current update flow is a sequence of independently mutable actions: an optional snapshot continuation at `bin/omarchy-update:28-48`, dev checkout pulling at `bin/omarchy-update-dev:7-21`, package mutation through `bin/omarchy-update-system-pkgs:21-39`, channel/package selection at `bin/omarchy-channel-set:61-99`, and hard-coded `linux-asahi` restart detection with ignored shell-restart failure at `bin/omarchy-update-restart:4-42`. The Mac upgrader also accepts a user-selected `--ref` and permits a non-Apple warning continuation at `bin/omarchy-upgrade-to-quattro-mac:71-91`. These are current seams to replace, not compatibility evidence.

The platform manifest, not a channel name, branch, package solver, or individual command, selects one release tuple. `omarchy-channel-set` can remain a user-facing policy request, but it must resolve to a signed channel manifest and cannot install a partially selected tuple. `OMARCHY_UPDATE_PACMAN=1` can continue to identify an Omarchy-owned package transaction for the ALPM guard; it is not proof that the transaction is platform-authorized. The direct-pacman bypass remains an explicit unsupported recovery path and must be visible as such.

Proposed transaction states:

```text
idle
  -> preflighted (identity, bundle, disk, power, network, authority, and plan verified)
  -> staged (all artifacts downloaded and digest/signature checked)
  -> applied (inactive system/package/config target written and verified)
  -> boot-selected (new tuple selected with a bounded retry budget)
  -> attesting (first boot health and required capabilities being checked)
  -> committed (new tuple is last-known-good)

preflighted/staged/applied/boot-selected/attesting -> rolled-back
interrupted -> recoverable (resume, rollback, or abort; no false success)
```

The backend may use snapshots, inactive slots, or another transaction mechanism selected by the installer/recovery authority. The product contract is backend-neutral: stage all required artifacts before switching, bind every write to the plan digest, preserve the last-known-good tuple, make boot selection reversible, verify required boot-health and capabilities, and commit only after attestation. Power loss, network loss, full disk, corrupt metadata, bad signature, stale identity, partial write, failed boot, and failed required capability must each produce a recoverable state.

The user UX must show the tuple and state, not a misleading package-only progress bar:

| State | User-facing result | Machine/action rule |
| --- | --- | --- |
| Preflight blocked | “Update not started: required reason” | No mutation; show remediation and preserve no success marker. |
| Staging | “Preparing Omarchy release `<redacted digest prefix>`” | Only verified artifacts may enter the transaction. |
| Applying | “Applying release; recovery is available” | Journal every scope; do not report complete. |
| Attesting | “Verifying the new boot and required capabilities” | Keep previous tuple selectable until all required checks pass. |
| Optional gap | “Updated with optional capability unavailable: `<capability>`” | Exit according to typed policy; never hide the gap. |
| Rolled back | “Update rolled back; previous release remains active” | Keep failed evidence and offer support bundle. |
| Committed | “Update complete” | Only after `boot-health/v1` and required capability verification. |

The UX must have a status command and JSON output suitable for recovery automation. A killed process, reboot, or rerun reads the journal and resumes or offers rollback; it does not start a second transaction based on a stale checkout. Independent component version flags such as `--ref`, mutable raw script fetches, and package-name substitutions must either become manifest resolution inputs or be rejected for release operations.

## 9. Migration design

Migrations must move existing state toward the single authority without turning legacy state into support evidence. The current migration runner enumerates files and markers at `bin/omarchy-migrate:35-56`, runs each script, and marks it only after success at `bin/omarchy-migrate:85-97`; this idempotent marker behavior is the baseline to preserve. The current first-install path, however, touches every migration marker at `bin/omarchy-provision-user:115-120`, which can hide migrations from a newly provisioned user and must be addressed in the migration design.

The migration sequence is:

1. Add a machine-scoped, digest-bound platform-state record only after the identity authority validates the generated bundle. No migration may convert an unknown identity into a supported identity.
2. Import legacy Mac setup markers, checkout state, channel state, package substitutions, and diagnostics state into a versioned compatibility record. Preserve raw legacy state until the new record is verified; do not delete it as part of an unverified migration.
3. Convert duplicated ARM/Apple decisions into references to generated capability IDs. Keep adapters for old paths until the generated census proves there is one authority for each capability.
4. Separate “fresh install” initialization from “migration applied”. A first install may initialize only the markers it actually ran; it must not pre-mark future migrations merely because files exist.
5. Migrate update state to the transaction journal and retain the last-known-good digest needed for rollback. A failed migration leaves its marker absent and the transaction recoverable.
6. Use the existing documented authoring rules: new `migrations/*.sh` files are 0644, have no shebang, begin with a clear echo, use `$OMARCHY_PATH`, are idempotent, do not restart the shell, and are tested against a fake `HOME` twice plus a non-legacy state. These rules are specified in `agents/skills/migrations.md` and `docs/testing.md`.

Each migration declares a platform scope and required authority version in its design metadata. Universal upstream migrations remain universal; Apple-specific state migrations require an exact Apple record; unsupported/unknown identity stops before a platform-scoped write. Pre-Quattro conversion remains a dedicated upgrade path rather than a generic migration that guesses a source generation.

## 10. Upstream Omarchy compatibility policy

This document defines a compatibility policy and gates; it does not claim that the current tree or any future release is compatible. The policy is:

| Context | Required behavior | Claim gate |
| --- | --- | --- |
| Upstream x86 or non-Apple board with no Apple record | Preserve upstream command routing, package policy, migrations, and user setup; the Apple profile is not selected | Upstream regression suite and a negative test proving Apple-only capability leaves do not mutate. |
| Exact Apple board with a signed qualified record | Select only the generated Apple profile and approved substitutions | Full generated-registry, install/update/recovery, parity, and physical evidence for that exact board/release. |
| Apple-shaped but unknown or ambiguous record | Stop before mutation with a remediation result | Negative fixture tests and physical negative identity cases. |
| Intentional Mac divergence | Track it as an explicit manifest capability and preserve it | Functional/physical evidence plus census row; no silent fork of generic policy. |
| Dev checkout or mutable ref | Treat as development/research state, not a qualified platform release | No compatibility or support claim from a dev build. |

The existing warning in `docs/upgrade-to-quattro.md:29-33` that x86 upgrade instructions must not be used on Mac is a useful compatibility boundary. It must become a signed/profiled operation rule rather than remain only prose. Command metadata remains governed by `bin/omarchy` and `agents/skills/command-metadata.md`; new generated platform metadata must not create a second user-facing command prefix registry.

## 11. Exact gates and evidence

### Automated gates for this consumer repository

The implementation gate battery must run from a clean checkout and report each command as PASS or FAIL, not just the aggregate exit code:

```bash
./test/all
./test/cli
./test/shell
bin/omarchy commands --check
for f in bin/omarchy-*; do
  if head -1 "$f" | grep -q python; then
    python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read())' "$f" || exit 1
  else
    bash -n "$f" || exit 1
  fi
done
git diff --check
```

The product-integration gate adds generated-registry schema/signature/digest fixtures, unknown/ambiguous/stale identity fixtures, required-versus-optional result fixtures, no-mutation-on-admission-failure property tests, direct-script and routed-command coverage, interrupted/resume/rollback tests, support-bundle redaction tests, generated census drift checks, and migration twice/nonlegacy tests. Markdown/link sanity must resolve every relative link in this document and reject conflict markers. A generated artifact diff or missing signature is a failure even when shell tests pass.

The command metadata gate must continue to enforce summaries, route uniqueness, valid metadata, executable binaries, and `GROUP_DESCRIPTIONS`; generated platform capability IDs do not replace command metadata. Package tests must prove no required package is silently filtered by `omarchy-pkg-add`, that ARM substitutes are mutually exclusive where required, and that install/remove/refresh use one generated record.

### Acceptance and physical gates

There is no graphical change in this design document, so a running-UI visual check is not applicable to this lane. Any future visual implementation must follow `agents/skills/visual-verification.md`. Any package or installation implementation must use a fresh ISO in the disposable VM workflow described by `agents/skills/acceptance-tests.md`; a reused base image is not evidence.

The program’s physical gate is required for each exact Apple board/profile and qualified release: clean install; read-only plan; encryption; first boot; required hardware and app capabilities; sleep/resume; update; interrupted update; rollback; uninstall/recovery; full-disk/network/power/process fault injection; stale/invalid signature and identity cases; support-bundle redaction; and a repeated install/update cycle. Evidence must identify board, firmware schema, platform manifest digest, test commit, and outcome. VM, static inspection, parser success, package availability, recognized chip, or a booting desktop cannot substitute for physical qualification.

The m1n1 component remains outside this lane’s inspection and test authority under the coordinator supersession fence. Physical or installer gates that depend on it are therefore deferred here and must be supplied as coordinator-owned evidence before any support statement.

### Gate ownership

| Gate | Owner | Required evidence before integration |
| --- | --- | --- |
| P-01 generated registry and admission | Platform authority plus `omarchy-mac` consumer | Signed fixtures, generated drift-free bindings, exact identity negative cases, zero mutation before admission. |
| P-02 typed outcomes | `omarchy-mac` | Result schema, exit/status contract, warning-success regression tests, required marker proof. |
| P-03 parity census | `omarchy-mac` with platform manifest owner | Machine-readable census, no unknown required rows, install/remove/launch verification, intentional divergence records. |
| P-04 diagnostics | `omarchy-mac` | Allowlist schema, redaction fixtures, local export and explicit upload tests, no secrets in artifact. |
| P-05 update/recovery | Installer/recovery authority plus `omarchy-mac` UX | Fault-injection journal evidence, last-known-good rollback, boot-health attestation, no false completion. |
| Physical qualification | Coordinator-owned lab process | Exact board/release evidence and signed qualification record; no claim from this design lane alone. |

## 12. Deferrals, residuals, and coordinator questions

Deferrals are intentional: all production implementation; canonical schema and key-root decisions; generated artifact format; installer/recovery transaction backend; platform repository changes; physical Apple lab runs; qualification records; m1n1-dependent evidence; command/app census generation; migration implementation; and any compatibility or support claim. This document is not DONE as a program slice; it is a design handoff for coordinator ruling.

Known residuals until implementation include the warning-success seams in the P-02 table, duplicated Apple/ARM probes, mutable source/ref selection, package and app lists with separate authorities, current debug/log redaction gaps, first-install migration pre-marking, independent update/channel mutation, and the absence of an atomic platform tuple transaction in the current consumer. No residual is waived by the design.

Coordinator questions requiring a ruling:

- What exact generated bundle layout, signing root, rotation policy, expiry policy, and offline-cache retention should `omarchy-mac` consume?
- What is the canonical capability vocabulary, and which capabilities are required versus optional for each board/profile?
- Should admission be a Bash-compatible command, a generated library binding, or a small signed-data verifier with a command adapter? What is the permitted trust boundary for each runtime context?
- Which mutation primitives must enforce the transaction context themselves, and which universal user-config operations may use an explicit non-platform scope?
- Which installer/recovery backend provides inactive targets, boot selection, health attestation, and rollback, and how should `omarchy-mac` persist the shared journal?
- What is the approved ARM substitute policy for `obsidian`, `obs-studio`, `pinta`, `dotnet-runtime`, recording, gaming, and desktop wrappers?
- What migration cutover retains legacy evidence safely, and when may duplicated fallback code and deny lists be removed?
- What exact physical board matrix and evidence location will produce `qualification-record/v1` without crossing the m1n1 opaque boundary?
