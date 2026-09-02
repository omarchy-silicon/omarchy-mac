# Omarchy Silicon product integration design (P-01–P-05)

Status: DESIGN NOTE only, correction round 1. This document does not implement a registry, change production behavior, edit `PROGRAM.md`, merge a branch, establish compatibility, or mark any slice or program DONE.

This design is for the `omarchy-mac` product/control-plane side of the Omarchy Silicon program. The ratified program baseline for this lane is [`PROGRAM.md` at `omarchy-silicon/omarchy-apple-platform` commit `58302d148f0e8b855578f9aa518ff1c5eb48c515`](https://github.com/omarchy-silicon/omarchy-apple-platform/blob/58302d148f0e8b855578f9aa518ff1c5eb48c515/PROGRAM.md), the main commit that merged the hardened program. Every ledger, dependency, and authority statement below is read from that exact commit; a later `PROGRAM.md` change is a new coordinator ruling and does not silently update this note. The lane is based on `origin/quattro` at `95ffbc41a6d5d5356c217e503b51f3f7c3bd80f1`.

The F-02 platform schema contract is consumed here only as the correction candidate [`docs/design/platform-schema.md` at `c315c7e79928d0041deb582bed79a61074361b21`](https://github.com/omarchy-silicon/omarchy-apple-platform/blob/c315c7e79928d0041deb582bed79a61074361b21/docs/design/platform-schema.md). That tip is REJECTED and not ratified; `PROGRAM.md` section 16 at `58302d1` records it as frozen unless the owner grants an exception. Every dependency on F-02 field grammar in this document is therefore PROVISIONAL, PENDING COORDINATOR APPROVAL, and is marked as such. This document copies no schema, invents no alternate vocabulary, and treats the ratified `PROGRAM.md` "Frozen cross-repository contracts" section as the only currently binding statement of the payload set.

## 1. Scope, boundaries, and non-claims

The target is a narrow integration contract: `omarchy-mac` consumes signed, generated platform data, admits a platform-scoped operation before its first mutation, reports typed capability results, and exposes an update/recovery UX that cannot claim success before required verification. The canonical platform repository owns the registry, schemas, manifests, lockfiles, signing, qualification records, and release authority. The installer/recovery repository owns the macOS/Recovery/APFS transaction. This lane owns the consumer design, policy wiring, command and app parity census, diagnostics, migrations, and user-visible state.

This design does not infer support from `uname -m`, a chip family, a successful build, a VM, a booting desktop, or an existing package. Exact board identity, SoC identity, device-tree records, firmware schema, signed platform release, and qualified capability records are required inputs. An unknown or ambiguous identity is a blocking result.

The coordinator supersession fence makes `m1n1-omarchy` an opaque human-produced artifact boundary. This lane does not inspect, read, analyze, edit, test, clone further, or make claims about that repository or its contents. Any external boot-component evidence required by the program may be described here only as a coordinator-supplied signed opaque envelope.

Stable-channel promotion is outside this lane entirely. `F-07` in `omarchy-apple-platform` is the sole stable promotion writer per `PROGRAM.md` sections 11, 12.1, 13, and 17 at `58302d1`. Nothing in `omarchy-mac` publishes, copies, tags, or selects a stable candidate; the product produces machine-local transaction state and evidence only (section 9).

## 2. Authority and contract model

### 2.1 The eight authenticated payloads

`PROGRAM.md` at `58302d1` freezes exactly eight authenticated payload types owned by F-02 and published only by `omarchy-apple-platform`. The product consumes exactly these eight and no local ninth type:

| Payload type | Product use | Authority the product never takes |
| --- | --- | --- |
| `board-registry/v1` | Exact board, SoC, device-tree, firmware schema, lifecycle, and required qualification profile for identity resolution | Cannot qualify a board or select a component version |
| `platform-manifest/v1` | One immutable release tuple: typed component records, locks, constraints, channel, boot-health policy, rollback compatibility, and the required consumer binding set | Product never selects independent component versions |
| `installer-plan/v1` | Read-only inventory, stable identifiers, proposed mutations, selected board record, manifest, actor/role context, and approval requirements for platform-scoped product operations | A plan is not approval and authorizes no mutation |
| `qualification-record/v1` | Physical evidence identity for the exact board, manifest, tests, failures, residuals, operator, and timestamps; consumed for admission and status display | Product never produces or edits one; parsing it grants no support |
| `boot-health/v1` | Signed health core with slot, generation, lineage, attempt counter, manifest-bound required checks, failure reason, and fallback set; consumed for update state and status | Contains no success marker; product never infers success from it |
| `owner-approval/v1` | Separate approval bound to plan/scope/registry/manifest/topology/schema-set/target/operation, actor, role, issuance, expiry, and replay identity; required before any owner-authorized platform mutation | Cannot grant release, board, or boot authority |
| `boot-success-mark/v1` | Separate authenticated success statement bound to the verified boot-health core, board, manifest, slot, generation, lineage, counter, source generation, required-check policy, and rollback set; consumed to close an update transaction locally | Cannot qualify hardware or authorize mutation |
| `dtb-mutation-envelope/v1` | Authorized device-tree mutation record; the product consumes only its verified decision and never performs DTB mutation itself | Cannot authorize a board, release, or storage operation |

The ratified program statement binds every object to canonical UTF-8 JSON under RFC 8785 JCS, the common authenticated envelope, the exact schema-set digest, and acceptance only as a verified trusted type. It states that stable document IDs are never content digests and that the envelope carries the separately computed payload digest. Those are binding today.

### 2.2 Provisional F-02 trust seam the product consumes

PENDING COORDINATOR APPROVAL. The following consumption rules read the rejected F-02 candidate at `c315c7e` and bind to it by name only. Final field grammar, digest preimages, limits, and error codes remain BLOCKED on F-02 ratification; the product implements nothing against them until the coordinator approves a schema tip and its generated bindings exist.

- The product consumes generated bindings only. Per the candidate's section 16, the Python consumer binding is generated by the locked generator from the canonical schema set and carries a `ConsumerCapabilities` identity; the product never hand-copies field lists, never keeps a consumer-local schema, and fails `BINDING_INTEGRITY_FAILURE` if its generated output does not match the manifest-required binding.
- The exact F-02 trust seam consumed by the product is the candidate's single construction path `strict_parse -> canonicalize -> verify -> admit`, producing `Trusted<T>` and then `Admitted<T>`, with authority resolved by `AuthorityRoleBinding` inside `Trusted<TrustContext>`. The product shell never parses signed metadata with ad hoc traversal and never receives a partially trusted value.
- Authority resolves only through `AuthorityRoleBinding` inside `Trusted<TrustContext>` supplied by F-03. No consumer-local owner table, role string, key ID, or account string grants authority. F-03 is not started in the ratified ledger and is a named BLOCKED dependency (section 12).
- `document_id` is a stable, immutable one-ID-to-one-payload-digest identity and is distinct from `payload_digest`, which is the digest of the canonical payload. Product journals, markers, and support bundles record both for every consumed document and never treat one as the other.
- `schema_set_digest` is required in every payload and envelope preimage and is compared byte-for-byte with the generated binding's lock; a compatible-looking schema set is rejected.
- Every verification supplies an `ExpectedContext` constructed for the exact operation and target, and the envelope's required anti-transplant binding is checked with it, so a payload transplanted between domains, contexts, projects, repositories, slices, boards, manifests, or targets fails `SIGNATURE_CONTEXT_MISMATCH` before authority resolution. The product never constructs an `ExpectedContext` from caller-supplied strings; the adapter derives it from the closed operation and scope in section 3.
- Owner authorization requires `Trusted<OwnerApproval>` plus the independently verified `Trusted<OwnerProofReceipt>` and `Trusted<TargetAccount>` supporting values named by the provisional F-02 seam; these are not additional authenticated payload types, and their final grammar remains BLOCKED on F-02/F-03 ratification. A signed approval payload alone is not approval.

### 2.3 Identity authority

There is one identity authority in the product, the admission adapter in section 3. It resolves a `Trusted<Observation>` against `Trusted<BoardRegistry>`, `Trusted<PlatformManifest>`, and the applicable `Trusted<QualificationRecord>` set through the generated `admit_board` binding into exactly one immutable identity result containing at least `board_id`, SoC identity, normalized device-tree compatibles, firmware schema, manifest `document_id` and `payload_digest`, registry `document_id` and `payload_digest`, `schema_set_digest`, lifecycle, and capability IDs. All installers, setup commands, hardware leaves, package/app planners, diagnostics, migrations, and update commands consume that result. A caller may ask whether a capability is applicable, but it may not independently decide Apple-ness, board support, package substitution, or release compatibility.

The authority distinguishes `unknown`, `ambiguous`, `unsupported`, `stale`, `invalid`, `hold`, and `qualified`. Chip family and `aarch64` are diagnostic facts only. `uname -m` may remain in diagnostics or a human-readable hint, but it cannot be a decision predicate for a platform-scoped mutation. Only the `full` lifecycle state named by the ratified contract admits a platform-scoped mutation, and only when registry, manifest, qualification record, artifact set, and policy agree on exact digests and exact board identity.

## 3. Product admission interface (normative)

This section closes the pre-mutation chokepoint as a design contract. The trust boundary is a version-pinned verifier command adapter wrapping the generated Python binding; it is not a Bash reimplementation and not a sourced library. Its name, argument set, scopes, result record, handle, return codes, and journal are closed here. Field grammar inside the signed payloads it verifies remains BLOCKED on F-02 ratification and is not restated.

### 3.1 Adapter identity and pinning

The adapter is one executable, `bin/omarchy-admission`, with the closed subcommands `open`, `check`, `close`, and `status`. The existing metadata router exposes it as the `admission` group with a `GROUP_DESCRIPTIONS` entry when implemented. The executable is a thin launcher for the pinned interpreter and generated contract binding; no admission logic lives in Bash and no second adapter is permitted.

The adapter declares `adapter_id = omarchy-admission-adapter` and `adapter_api = 1.0.0`, and embeds the exact expected generated-binding identity: `binding_id`, `binding_version`, `binding_source_digest`, `parser_id`, `parser_version`, `generated_output_path`, `generated_output_digest`, and `schema_set_digest`. At start it runs the binding's `load_consumer_capabilities` and `negotiate` against the manifest-required Python binding entry. Any mismatch is a hard `reject` before inventory, before any file other than the lock files is read, and before any journal write. The interpreter, generator, parser, and API versions are those named by the F-02 candidate's section 16 for the Python consumer and are PROVISIONAL until ratified; the product pins whatever the ratified lock names and refuses a floating interpreter or package.

### 3.2 Bounded typed inputs

`omarchy-admission open` accepts exactly these inputs. Each is a bounded token or a path; the adapter reads path contents only through the generated strict parser or a fixed-size source adapter.

| Input | Type and bound | Rule |
| --- | --- | --- |
| `--operation` | one member of the closed operation set in 3.3, at most 32 bytes | unknown value exits 2 |
| `--scope` | one member of the closed scope set in 3.3, at most 32 bytes | unknown value exits 2 |
| `--bundle-dir` | absolute path, at most 4096 bytes, no globs, required for platform scopes, and owned by root with mode 0755 or stricter | file names inside are exactly those named by the final ratified/generated layout binding; extra, missing, symlinked, or duplicate files exit 2; a bundle on `universal-user` is forbidden |
| `--plan` | absolute path, at most 4096 bytes, required for platform scopes, containing the generated `installer-plan/v1` input | the plan is parsed and verified through the generated binding; an absent, foreign, or mismatched plan exits 3; universal-user uses only its bounded local step declaration |
| `--trust-context` | absolute path to the F-03 `TrustContext` source record | absent or unverifiable trust context is `TRUST_FAILURE`, exit 3 |
| `--policy-source` | absolute path to the F-03 policy source record, whose final schema is PROVISIONAL and BLOCKED pending F-03 ratification | absent, downgraded, or expired policy is a policy rejection, exit 3 |
| `--steps` | absolute path to a closed step declaration listing `step_id`, `scope`, `primitive`, and declared postcondition kind, at most 256 steps | a step with an unknown primitive or a scope outside the requested scope exits 2 |
| `--resume` | existing `txn_id` UUID | unknown, closed, or foreign-uid transaction exits 8 |
| `--json` | flag | canonical result record on stdout is always emitted; the flag suppresses the human summary on stderr |

The required semantic inputs are the closed operation and scope, the adapter-owned read-only observation, the exact signed bundle and plan for platform scopes, and the F-03 trust context and policy sources. The adapter computes and records the `schema_set_digest`, registry and manifest `document_id`/`payload_digest` pairs, plan digest, identity/topology digest, policy digest, and `ExpectedContext`; callers cannot supply or override any of those digests, identities, timestamps, roles, keys, or trust decisions. The adapter has no argument for identity, board, time, actor, role, key, handle value, or trust decision. The observation is captured by the adapter's own source adapters as a `SourceEvidence`-backed `Trusted<Observation>`; the clock is a `VerifiedClock` from the adapter's attested clock source; a caller-supplied `--at`, board ID, or "assume Apple" flag does not exist and any such argument exits 2. Fixture runs inject their source adapters through the test harness's adapter registration, never through argv or environment. Environment variables cannot supply semantic admission inputs; `OMARCHY_PATH` only locates the packaged code, and `XDG_STATE_HOME`/`HOME` only select the mandated non-root journal root.

Universal user-only operations use exactly one non-platform scope, `universal-user`. It is still opened through `omarchy-admission open`, still issues a handle, and still journals, but it consults no platform bundle and admits no step whose primitive is platform-capable. A missing scope, an empty scope, or a scope not in 3.3 is a hard error; there is no "no scope means universal" default because unknown is never equivalent to not applicable.

### 3.3 Closed operation and scope vocabulary

Scopes are closed and map one-to-one to a journal root and a privilege requirement:

| Scope | Privilege | Journal root | Mutation authority granted |
| --- | --- | --- | --- |
| `platform-system` | effective uid 0 | `/var/lib/omarchy/admission/` | system packages, repositories, system configuration, systemd units, users, hostname, checkout replacement, initramfs |
| `platform-hardware` | effective uid 0 | `/var/lib/omarchy/admission/` | hardware leaves under `install/hardware/`, firmware profiles, audio profiles, kernel parameters |
| `platform-update` | effective uid 0 | `/var/lib/omarchy/admission/` | the atomic tuple update transaction: staging, applying, boot selection request, attestation consumption |
| `platform-user` | effective uid not 0, uid equals journal owner | `${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/admission/` | Apple-specific user leaves under `install/user/hardware/`, user-side substitutes, user-side capability markers |
| `platform-migration` | effective uid 0 | `/var/lib/omarchy/admission/` | one platform migration script run and its marker |
| `universal-user` | effective uid not 0, uid equals journal owner | `${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/admission/` | user configuration, themes, webapps, user-only application state; no platform-capable primitive |
| `read-only` | any | none | none; no handle is issued and no journal record is written |

Operations are closed and each maps to exactly one set of permitted scopes:

| Operation | Permitted scopes | Current entrypoints it will front |
| --- | --- | --- |
| `install` | `platform-system`, `platform-hardware` | `install.sh`, `bin/omarchy-mac-setup` main sequence |
| `setup` | `platform-system`, `platform-hardware` | `bin/omarchy-mac-setup --step`/`--resume`, mutating `omarchy-setup-*` |
| `apply-system` | `platform-system` | `bin/omarchy-apply-system`, root setup service |
| `apply-hardware` | `platform-hardware` | `bin/omarchy-apply-hardware` |
| `provision-owner` | `platform-system` | `bin/omarchy-provision-owner` |
| `provision-user` | `platform-user`, `universal-user` | `bin/omarchy-provision-user` |
| `first-run` | `platform-user`, `universal-user` | `bin/omarchy-provision-first-run` |
| `update` | `platform-update` | `omarchy-update`, `omarchy-update-system-pkgs`, `omarchy-update-dev`, `omarchy-update-firmware`, `omarchy-reinstall-pkgs` |
| `channel-set` | `platform-update` | `omarchy-channel-set` |
| `upgrade` | `platform-system`, `platform-update` | `omarchy-upgrade-to-quattro-mac` |
| `migrate` | `platform-migration`, `universal-user` | `omarchy-migrate` and login-time migration paths |
| `recover` | `platform-update`, `platform-system` | resume, rollback, and `--abort` paths |
| `inspect` | `read-only` | `hw-*` probes, `omarchy-admission status`, diagnostics |

An operation/scope pair outside this table exits 2. The product's operation names are product-local and never widen the F-02 plan operation vocabulary; where a product transaction is expressed as an `installer-plan/v1`, each journal step maps to exactly one F-02 plan operation value (PROVISIONAL: `inspect/v1`, `write/v1`, `replace/v1`, `remove/v1`, `rollback/v1` in the rejected candidate's section 8) and the mapping is generated, not hand-written. Final operation grammar is BLOCKED on F-02 ratification.

### 3.4 Result record

Every adapter subcommand writes exactly one canonical JSON adapter-result record to stdout. It is a product-local machine-readable record with no cross-repository payload type. It is not one of the eight authenticated payload types, is not signed by any platform role, is never presented to the platform verifier as a payload, and never crosses a repository boundary as authority. Its closed fields are:

`result_schema`, `adapter_id`, `adapter_api`, `binding_identity`, `schema_set_digest`, `operation_id`, `operation`, `scope`, `decision` (`admitted`, `reject`, `hold`, `valid`, `closed`, `already_applied`), `code` (an F-02 failure code carried verbatim, or one of the product codes `ADMISSION_USAGE`, `ADMISSION_PRIVILEGE_MISMATCH`, `ADMISSION_FRESHNESS_FAILURE`, `ADMISSION_JOURNAL_FAILURE`, `ADMISSION_HANDLE_INVALID`), `path`, `message` (fixed template, no input values), `txn_id`, `handle` (present only when `decision = admitted`), `board_id`, `identity_digest`, `bundle_digest`, `registry_document_id`, `registry_payload_digest`, `manifest_document_id`, `manifest_payload_digest`, `plan_digest`, `capabilities` (one record per capability with `capability_id`, `requiredness`, `status`, `reason_code`, `evidence_ref`), `next_action`, `expires_at`, `journal_ref`.

The human summary on stderr is rendered from this record. Errors contain no class C, D, or E values under the F-02 privacy classes; the record carries only class A and B fields plus pseudonymized references.

Bash callers consume the record only by fixed-path field extraction with an exit-code check, for example `jq -e -r '.handle'`, and by the adapter exit code. A caller never passes adapter output to `eval`, `source`, `bash -c`, a here-string into `read -a`, or unquoted word splitting, and never parses the human summary. A test in the implementation gate greps every consumer for those forbidden forms.

### 3.5 Admitted transaction handle

An admitted transaction is represented by an opaque handle. Its external form is the single token `omarchy-admit:v1:<txn_id>:<scope>:<expires_at>:<mac>`. The `mac` is HMAC-SHA256 under a per-journal-root key over the canonical JCS record `{txn_id, scope, operation, uid, boot_id, plan_digest, bundle_digest, identity_digest, schema_set_digest, issued_at, expires_at, nonce}`, encoded as unpadded base64url. The key is 32 random bytes created by the adapter on first use in the journal root as `handle.key` with mode 0600 owned by the journal owner. Only `omarchy-admission check` interprets a handle; every other component treats it as an opaque string and gains nothing by inspecting it.

Handle validity is decided by recomputing the MAC against the live journal record, never by the presence or shape of the string. A handle whose record is closed, expired, from another `boot_id`, from another uid, from another scope, or whose plan, bundle, or identity digests no longer match a fresh revalidation is invalid.

Transport to a mutator is by the explicit `--handle H` argument. A child hook may inherit the token only as transport alongside the mutator's already-open process, but the hook must call the adapter to validate the live journal record and key-bound MAC; an environment variable alone is never an authorization convention and an environment-only handle is rejected. No caller may choose the journal path or transaction record.

### 3.6 Replay, freshness, and journal linkage

- One open transaction per journal root. A second `open` while a transaction is open exits 7 and names `resume` or `abort` as the next action; it never starts a parallel transaction.
- Handle expiry is the earliest of six hours after issuance, the `expires_at` of the registry, manifest, policy, and trust context consumed, and the end of the current `boot_id`. A handle that outlives any of these is invalid.
- Every mutation step is reserved before it runs and completed after its postcondition: `omarchy-admission check --handle H --step S --step-digest D` records `reserved`; the primitive performs exactly that step; `omarchy-admission check --handle H --complete S --postcondition-digest P` records `applied`. A step ID not declared at `open` exits 8. A reserved step that is never completed is `interrupted` at resume time.
- Replaying a completed step with the same `step_id` and identical step digest returns `already_applied` with exit 0 and performs nothing. The same `step_id` with a different digest exits 6. A step digest covers the primitive name, its bounded arguments, and the plan step it maps to.
- Resume revalidates trust context, policy, bundle digests, identity, plan digest, and clock, then issues a new handle with a fresh nonce bound to the same `txn_id`; every earlier handle for that transaction is invalid from that moment.
- The journal is a directory per transaction containing `record.json` (canonical open record), `steps.jsonl` (each line carries the SHA-256 of the previous line), and `result.json` (written at close). The adapter creates records with exclusive creation, fsync, and atomic rename under a mode-0700 journal root owned by the required uid; it never accepts a caller-selected journal path. The journal is evidence, never authority: a missing, truncated, divergent, or unauthenticated journal permits only a fresh observation and a typed hold or recovery decision, consistent with `PROGRAM.md` section 4.2. It is bound to the plan digest and the exact document identities from 2.2.
- `omarchy-admission close --handle H --outcome O` accepts exactly `completed`, `completed_with_optional_gaps`, `failed`, `rolled_back`, or `aborted`. `completed` is refused unless every required step is `applied` and every required capability result is `applied` or registry-authorized `not_applicable`.

### 3.7 Return codes

| Exit | Meaning | Handle issued |
| --- | --- | --- |
| 0 | admitted, valid, already applied, or closed as requested | yes for `open` and `resume`; otherwise no |
| 2 | usage: unknown operation, unknown scope, malformed or over-bound argument, unexpected bundle layout, foreign environment | no |
| 3 | reject: parse, canonicalization, signature context, trust, expiry, cross-document, identity, policy, or binding failure; the F-02 code is in the record | no |
| 4 | hold: one of the F-02 HOLD codes; a typed hold or recovery decision is required | no |
| 5 | privilege mismatch between scope and effective uid | no |
| 6 | freshness or replay failure: expired handle, boot change, stale bundle, changed identity, changed plan, replayed or divergent step | no |
| 7 | journal failure: unwritable root, corrupt chain, divergent replica, or another open transaction | no |
| 8 | handle invalid: unknown transaction, MAC mismatch, wrong scope or uid, closed transaction, undeclared step | no |

Any other exit, including a crash, is treated by every caller as reject. A zero exit with a record whose `decision` is not `admitted` or `valid` is a caller bug and the enforcement seam treats it as invalid.

### 3.8 Privilege behavior

The adapter never escalates privilege and never wraps a command that manages its own elevation. Platform-system, platform-hardware, platform-update, and platform-migration require the caller to already be root; a non-root caller exits 5 with `next_action` naming the caller's own elevation path. Per `AGENTS.md` and the privilege-escalation rule in `default/agents/skills/omarchy/SKILL.md`, an interactive caller in a visible terminal uses `sudo`, and a caller without a terminal, such as the root setup service or a graphical launcher, uses `pkexec` or already runs as root under systemd. User scopes require a non-root effective uid equal to the journal owner; root opening `platform-user` or `universal-user` exits 5, because user-state writes by root are the current provisioning defect this design removes.

### 3.9 Direct leaf invocation fails closed

Leaves under `install/` remain 0644, have no shebang, and are reached only through the leaf runner in `install/helpers/logging.sh`, which will require a valid explicit handle before sourcing any leaf. A direct `bash install/<leaf>.sh`, `source install/<leaf>.sh`, copied hostile leaf, or forged environment value has no admitted handle, so every supported mutation primitive it calls exits 8 and performs nothing. Raw system mutation commands are forbidden outside the enforcing primitives and are rejected by the implementation lint and hostile-fixture gates before integration; the product provides no supported direct-script path. The read-only mode of a leaf is an explicit `--check` in the primitive, not an implicit result of missing admission. Bash cannot make a root shell incapable of raw writes, so that out-of-band root capability remains a residual rather than a false runtime guarantee (section 12).

## 4. Enforcement at the mutation seam

Every platform-scoped mutator receives the handle and validates it at the seam where the mutation happens, not by trusting an environment convention. The enforcing primitives and their rules are:

| Primitive | Enforcement | Bypass closed |
| --- | --- | --- |
| `omarchy-pkg-add`, `omarchy-pkg-drop`, `omarchy-reinstall-pkgs`, `omarchy-refresh-pacman` | Call `omarchy-admission check --step` before invoking pacman and `--complete` after the existing post-install verification; on an Apple-identified machine a missing or invalid handle exits 8 and installs nothing; filtered-empty for a required package is a typed `required_blocked` result, never exit 0 | direct leaf calls, hidden routes, and copied scripts reach the same executable and the same check |
| ALPM guard `bin/omarchy-update-pacman-guard` | For a transaction carrying a handle, verify it through `omarchy-admission check` as root inside the hook; `OMARCHY_UPDATE_PACMAN=1` is transaction metadata only and never authorizes a platform-scoped transaction; the legacy `OMARCHY_ALLOW_DIRECT_PACMAN=1` convention is rejected before pacman and cannot be used as a recovery success path | raw `pacman` by root is caught at the hook, the only seam Bash can guarantee for package writes |
| `omarchy-appimage-*`, `omarchy-webapp-*`, `omarchy-tui-*`, `omarchy-install-*`, `omarchy-install-preinstalls`, `omarchy-remove-preinstalls` | Same step reservation and completion; platform-capable variants require a platform scope, universal variants accept `universal-user` | the substitute selection is read from the admitted capability record, never re-decided |
| `omarchy-refresh-config` and template renderers writing under `~/.config` or `/etc` | Require a handle in `platform-user`, `universal-user`, or `platform-system` as appropriate; reject `..` in the relative path as part of the same change | the current path-interpolation gap named in `AGENTS.md` is closed at the same seam |
| Leaf runner in `install/helpers/logging.sh` | Validate the handle before sourcing each leaf; export nothing that a leaf can use to self-authorize; record leaf start and result as journal steps | sourced leaves inherit no authority and cannot mint one |
| `bin/omarchy-mac-setup` writes: log/state creation, checkout replacement, user creation, fonts, keymap, hostname, config, systemd units, initramfs | Each becomes a declared step under `install` or `setup`; the four-signal completion detection is replaced by the journal outcome | `--step` and `--resume` revalidate through `--resume`, never through a stale marker |
| `bin/omarchy-migrate` and migration markers | Open `platform-migration` per migration with the migration's declared privilege and scope; write the marker only after `--complete` succeeds | first-install pre-marking is removed (section 10) |
| `omarchy-update*`, `omarchy-channel-set`, `omarchy-upgrade-to-quattro-mac` | Open the closed `upgrade` operation under `platform-system` or `platform-update` as mapped in section 3.3; boot selection requests, staging, and applying are steps; no step runs on a handle from a different transaction | `--ref` and raw script fetches are rejected for release operations (section 9) |
| Systemd setup and update units | The unit invokes the public command, which opens or resumes admission itself; a unit never carries a handle in its environment file | a resumed service after reboot must resume, because the old handle died with the `boot_id` |

Unforgeability rests on two facts, both owned by the product: the per-journal-root key is readable only by the journal owner, so a non-root process cannot mint a root-scope handle, and validity is decided by the live journal record, so a copied handle stops working when its transaction closes, its boot ends, or its inputs change. A same-uid actor can already perform that uid's ordinary writes and is outside this escalation model. No privileged broker or descriptor is required for handle unforgeability; the adapter is the sole issuer and verifier, and the journal root's ownership, mode, exclusive record creation, and chain are verified at every check. A root process that performs raw writes outside the enforcing primitives remains the explicit implementation residual in section 12 and is never treated as a supported product route.

Every enforcement path is tested both as the public route and as the underlying script path: hidden route, direct `bash` source, resumed systemd service, root invocation, user invocation, already-installed machine, and interrupted transaction are separate admission cases. `--abort` and recovery actions close an existing journal without silently starting a new install, and they still validate transaction identity before writing recovery state.

### 4.1 Outcome vocabulary

The platform admission result must be machine-readable and human-readable. A required failure returns nonzero, leaves no success marker, and identifies the next safe action. An optional failure may return zero only when the operation's overall result is explicitly `completed_with_optional_gaps`; it must never be rendered as `Install complete`, `Update complete`, or equivalent. Unknown is never equivalent to not applicable.

| Result | Meaning | Overall operation rule |
| --- | --- | --- |
| `ready` | Required capability is present in the plan and eligible to run | May proceed to mutation. |
| `applied` | Mutation completed and post-verification passed | Counts toward required completion. |
| `not_applicable` | The signed board record explicitly excludes the capability | Valid only for a capability marked not applicable by the registry. |
| `optional_unavailable` | Optional capability could not be installed or verified | Visible gap; operation may finish with a degraded-but-honest result. |
| `required_blocked` | Required capability is unknown, unsupported, stale, unavailable, or preconditioned incorrectly | Nonzero; no success marker or reboot-as-complete. |
| `failed` | A required mutation or verification failed | Nonzero; preserve journal and recovery path. |
| `interrupted` | Power, process, network, or storage interruption left a transaction open | Nonzero until resume, rollback, or abort closes it. |

The result record includes `operation_id`, `plan_digest`, `bundle_digest`, exact identity digest, capability ID, requiredness, status, reason code, redacted evidence references, and next action. Human output is derived from that record, not from ad hoc warning strings.

## 5. P-01 — generated registry consumption

P-01 consumes only generated bindings and signed runtime data from `board-registry/v1` and `platform-manifest/v1`, and the `qualification-record/v1` set the manifest references by stable ID. It removes the current split authority between `install.sh`, Apple hardware leaves, package deny lists, app fallbacks, and update scripts. The current router itself deliberately has no command registry beyond executable files and metadata (`docs/cli-router.md:3-8`); that remains a command-discovery concern and must not be confused with the platform registry.

The consumer contract is:

- Validate every bundle document through the generated trust seam in 2.2 against the F-03 trust context; reject missing, malformed, expired, replayed, transplanted, or unexpected schema-set input before any file, package, repository, boot, system, or user-state write.
- Resolve identity from the generated matching rules and record all observed inputs needed to explain the match without uploading raw sensitive identifiers.
- Use the signed board record only for exact physical presence and identity inputs, and use the signed manifest for capability requiredness, provider, and substitute policy. A package name, AUR availability result, `uname -m`, `/proc/device-tree/compatible` grep, DMI string, PCI ID, or GPU vendor is evidence to the identity authority, not an independent policy source.
- Keep the active and last-known-good bundles and bind each installed state, transaction journal, support bundle, and boot-health record to the document IDs and payload digests of the documents consumed.
- Fail closed before mutation if the bundle cannot be validated, if more than one board record matches, if no board record matches, or if the release has no required qualification record.
- Make generated-data drift a gate: regeneration from the canonical schema must produce no uncommitted consumer artifact changes.

The bundle layout on disk, the trust root, rotation, expiry, and offline-cache retention are read from the ratified platform contract and its generated layout binding; they are rulings in section 12, not product choices. The current Apple decision seams that P-01 replaces include the architecture/device-tree warning in `install.sh:57-64`, the Apple package choice in `install/hardware/vulkan.sh:6-24`, the audio selection in `install/hardware/apple/audio.sh:27-40`, the ARM mirror gate in `install/preflight/arm-mirrors.sh:5-39`, the Apple-specific user leaves in `install/user/all.sh:1-16`, and the separate unavailable package map in `install/omarchy-aarch64-unavailable.packages:1-41` consumed by `install.sh:203-230`. These may remain as compatibility adapters during migration, but they cannot remain authorities.

## 6. P-02 — typed capability outcomes and fail census

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
| Keymap writes tolerate failure | `bin/omarchy-mac-setup:132-170` uses `loadkeys ... \|\| true` and warns after persistence fallback | Return `applied`, `optional_unavailable`, or `required_blocked` according to the manifest; never let a required first-boot input path disappear into a green install. |
| Apple audio stack can be incomplete | `install/hardware/apple/audio.sh:35-53` warns on package or daemon failure and continues | Required audio must block; optional audio must be visible in the overall result and support bundle. |
| Optional app failure is only text | `install/post-install/optional-apps.sh:16-22` catches 1Password failure and prints a manual-install message | Use a typed optional result and an explicit capability ID; do not imply the default app set is complete. |
| ARM mirror helper reports warning completion | `install/preflight/arm-mirrors.sh:24-39` returns from missing helper/failure paths while printing warning; `install/helpers/set-arm-mirrors.sh:229-235` proceeds with the primary mirror when both tested mirrors fail | Mirror selection is part of the signed source plan; an unverified source must block required package mutation. |
| Package helper skips unavailable names with exit 0 | `bin/omarchy-pkg-add:12-21` prints “Skipping” for packages not found and exits 0 if none remain | The helper needs a typed unavailable result or admitted requiredness; filtered-empty cannot mean success for a required capability. |
| Snapshot failure continues update | `bin/omarchy-update:33-37` continues without a snapshot after failures other than the deliberate absent-tool case | Snapshot policy must be in the platform transaction plan; absence may be an explicit policy result, while an unexpected failure blocks an atomic update. |
| Update shell restart failure is ignored | `bin/omarchy-update-restart:37-42` runs `omarchy-restart-shell \|\| true` | Record restart as a post-update capability and keep the transaction pending until the required health state is verified. |
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

## 7. P-03 — command and app ARM parity census

P-03 produces a generated census before implementation changes claim parity. The source inventory is `bin/omarchy` metadata and `omarchy commands --all --json`, executable `bin/omarchy-*` files, package manifests under `install/`, optional setup/install sources, and every desktop file under `applications/` plus `default/applications/`. The census record for each command/app contains route, binary, package/provider, source URL or repository, architecture, capability IDs, requiredness, fallback/substitute, `Exec` target, verification command, and evidence status.

The generated census classifies each item as `native`, `arch-any`, `ARM substitute`, `webapp/wrapper`, `not applicable`, `blocked`, or `unknown`. `unknown` blocks a required product profile. It does not mean that every app must have an ARM-native binary: a signed, tested webapp or approved ARM substitute can satisfy a capability when the manifest says so. Capability requiredness and substitutes come only from the signed manifest; a census row whose requiredness or substitute is not in the manifest is `unknown` and blocks.

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

The exact census gate is reproducible from a clean checkout: generate command JSON, package rows, setup/install rows, and desktop `Exec` rows; normalize them; compare against the signed manifest; and fail on missing, duplicate, architecture-unknown, provider-unknown, or unverified required rows. A parity row is not accepted because the command routes or the desktop file exists. The census output is a product evidence artifact consumed by F-07 through the handoff in section 9.3; it is never a manifest input.

## 8. P-04 — diagnostics, support bundles, and redaction

The support artifact should be a versioned, local-first bundle containing the operation/transaction ID, plan and platform bundle digests, redacted identity summary, capability result records, source/provider provenance, package/app versions, kernel/boot-health state, migration state, and bounded relevant logs. It must record why a capability was required, optional, or not applicable without exposing raw device or owner data.

The current debug path writes date, hostname, package identity, `inxi`, dmesg, journal warnings/errors, and installed packages to `/tmp/omarchy-debug.log` at `bin/omarchy-debug:29-61`, then offers upload to `logs.omarchy.org` at `bin/omarchy-debug:68-86`. It has no explicit allowlist/redaction contract in this source. The install logger also creates a mode-666 log when configured at `install/helpers/logging.sh:13-18`. These are diagnostic/privacy residuals, not evidence that the current path is safe for a platform support bundle.

P-04 requires:

- A stable schema with a version and bundle digest; no free-form concatenation as the primary record.
- An allowlist for fields and log sections, with redaction before persistence and again before upload. Platform documents enter the bundle only as the F-02 `public/v1` or `private-support/v1` projection produced by the generated projection binding (PROVISIONAL naming pending F-02 ratification); raw envelopes, signatures, key IDs, and evidence bytes never enter.
- Removal or pseudonymization of credentials, tokens, cookies, owner email/name, hostnames where not required, serials, raw device identifiers, disk paths, encryption material, private keys, recovery secrets, and unrelated user content.
- Redaction tests containing fake secrets, URLs with credentials, LUKS/device examples, SSH material, and journal lines; tests must prove the raw fixture cannot occur in the exported bundle.
- Explicit user confirmation for upload, a local export path, bounded retention, and an upload failure that remains an upload failure rather than “support bundle ready”.
- A `--print` mode that never contacts the network and a deterministic `--validate` mode for support staff.

Diagnostics may report that external boot evidence is outside this lane's inspection boundary; they must not invent facts about it or include it in a bundle. A bundle may reference such evidence only through a coordinator-supplied signed opaque envelope after its schema and redaction rule are ratified.

## 9. P-05 — atomic platform update and rollback UX

The current update flow is a sequence of independently mutable actions: an optional snapshot continuation at `bin/omarchy-update:28-48`, dev checkout pulling at `bin/omarchy-update-dev:7-21`, package mutation through `bin/omarchy-update-system-pkgs:21-39`, channel/package selection at `bin/omarchy-channel-set:61-99`, and hard-coded `linux-asahi` restart detection with ignored shell-restart failure at `bin/omarchy-update-restart:4-42`. The Mac upgrader also accepts a user-selected `--ref` and permits a non-Apple warning continuation at `bin/omarchy-upgrade-to-quattro-mac:71-91`. These are current seams to replace, not compatibility evidence.

The platform manifest, not a channel name, branch, package solver, or individual command, selects one release tuple. `omarchy-channel-set` can remain a user-facing policy request, but it must resolve to a signed channel manifest and cannot install a partially selected tuple. `OMARCHY_UPDATE_PACMAN=1` can continue to identify an Omarchy-owned package transaction for the ALPM guard; it is not proof that the transaction is platform-authorized (section 4). The legacy direct-pacman bypass is rejected before mutation; any separate unsupported recovery procedure belongs to the recovery authority, is outside the product admission path, and cannot produce a success result.

### 9.1 Local machine transaction state

The states below describe one machine's transaction under a `platform-update` handle. They are local. None of them publishes, promotes, or selects anything on a release channel.

```text
idle
  -> preflighted (identity, bundle, disk, power, network, authority, and plan verified)
  -> staged (all artifacts downloaded and digest/signature checked)
  -> applied (inactive system/package/config target written and verified)
  -> boot-selected (new tuple selected with a bounded retry budget)
  -> attesting (first boot health and required capabilities being checked)
  -> machine-committed (new tuple is this machine's last-known-good)

preflighted/staged/applied/boot-selected/attesting -> rolled-back
interrupted -> recoverable (resume, rollback, or abort; no false success)
```

`machine-committed` is reached only after the generated `evaluate_boot_health` binding returns a success decision from `Trusted<BootHealthCore>` plus `Trusted<BootSuccessMark>` for the exact board, manifest, slot, generation, lineage, and counter (PROVISIONAL API naming pending F-02 ratification), and every required capability result is `applied` or registry-authorized `not_applicable`. The product never writes a success marker itself; the bounded boot runtime produces `boot-success-mark/v1` and the product only consumes it.

The backend uses snapshots, inactive slots, or another transaction mechanism selected by the installer/recovery authority; the installer/recovery repository owns the atomic backend journal, inactive targets, boot selection, health attestation transport, and rollback mechanics under I-01, I-04, and I-06, with B-04 owning slot selection and success marking. The product owns UX, read-only status, an evidence linkage record for its `platform-update` view, and the evidence; that product record is not the installer backend journal, does not authorize a write, and cannot resume mutation without the installer/recovery journal. The product contract is backend-neutral: stage all required artifacts before switching, bind every write to the plan digest, preserve the last-known-good tuple, make boot selection reversible, verify required boot-health and capabilities, and reach `machine-committed` only after attestation. Power loss, network loss, full disk, corrupt metadata, bad signature, stale identity, partial write, failed boot, and failed required capability must each produce a recoverable state.

### 9.2 User-facing state

| State | User-facing result | Machine/action rule |
| --- | --- | --- |
| Preflight blocked | “Update not started: required reason” | No mutation; show remediation and preserve no success marker. |
| Staging | “Preparing Omarchy release `<redacted digest prefix>`” | Only verified artifacts may enter the transaction. |
| Applying | “Applying release; recovery is available” | Journal every scope; do not report complete. |
| Attesting | “Verifying the new boot and required capabilities” | Keep previous tuple selectable until all required checks pass. |
| Optional gap | “Updated with optional capability unavailable: `<capability>`” | Exit according to typed policy; never hide the gap. |
| Rolled back | “Update rolled back; previous release remains active” | Keep failed evidence and offer support bundle. |
| Machine-committed | “Update complete on this Mac” | Only after `boot-health/v1` and `boot-success-mark/v1` verification and required capability verification; says nothing about channel status. |

The UX must have a status subcommand and JSON output suitable for recovery automation; `omarchy-admission status` is that subcommand. A killed process, reboot, or rerun reads the journal and resumes or offers rollback; it does not start a second transaction based on a stale checkout. Independent component version flags such as `--ref`, mutable raw script fetches, and package-name substitutions must either become manifest resolution inputs or be rejected for release operations.

### 9.3 Evidence-only handoff to F-07

F-07 in `omarchy-apple-platform` is the sole stable promotion writer. `PROGRAM.md` at `58302d1` states that F-07 consumes F-05, P-03, P-05, I-09, B-04, and Q-04 through Q-08, recomputes the complete closure, and copies an already-built immutable candidate digest; that any alternate stable-write path is a hard rejection; and that a hostile promotion test must prove every stable-channel writer routes through F-07. The product therefore has no promotion code path, no channel write credential, no "publish" command, and no state that means "stable". Its responsibilities are exactly:

| Product evidence responsibility | Content | Identity | Consumer |
| --- | --- | --- | --- |
| P-03 parity census output | generated census rows, classification, verification results, intentional divergence records | commit SHA of the generating tree plus SHA-256 of the normalized census file | F-07 required-slice closure through F-05 assembly |
| P-05 update/rollback evidence | fault-injection journal evidence, last-known-good rollback results, PROVISIONAL F-02 boot-health and success-mark public projections, no-false-completion test results | commit SHA plus SHA-256 of each evidence file; journals reference `document_id` and `payload_digest` of every consumed platform document | F-07 required-slice closure after F-02 projection ratification |
| Product gate census | the PASS/FAIL census of section 11 from a clean checkout | commit SHA plus the runner's output digest | F-07 required-slice closure |
| Support and diagnostics projections | PROVISIONAL F-02 `public/v1` projections only, pending ratified projection binding | projection digest | Q-lab evidence store and coordinator review, never a manifest input; handoff is blocked until F-02 ratification |

The product hands these over as digest-addressed files committed in this repository or attached to the lane report; it does not wrap them in a new signed payload type, because inventing one would create a shadow authority. The intake format by which F-05 assembly and F-07 read P-03 and P-05 evidence is not ratified in any input available to this lane. The F-06 compliance handoff and the F-07 product-evidence intake are also not ratified cross-repository schemas in the permitted inputs. These are named BLOCKED dependencies in section 12, owned by the platform owners, due before any F-07 promotion attempt; until both interfaces exist the handoff stays blocked and this lane produces evidence files only.

Local `machine-committed` state, `boot-success-mark/v1` consumption, and update UX completion are never reported to a user or a ledger as channel or support status. A `qualification-record/v1` is produced only by the `qualification-lab` role; the product references it by stable ID and never copies raw lab evidence into product state.

## 10. Migration design

Migrations must move existing state toward the single authority without turning legacy state into support evidence. The current migration runner enumerates files and markers at `bin/omarchy-migrate:35-56`, runs each script, and marks it only after success at `bin/omarchy-migrate:85-97`; this idempotent marker behavior is the baseline to preserve. The current first-install path, however, touches every migration marker at `bin/omarchy-provision-user:115-120`, which can hide migrations from a newly provisioned user and must be addressed in the migration design.

The migration sequence is:

1. Add a machine-scoped, digest-bound platform-state record only after the identity authority validates the generated bundle under an admitted `platform-migration` handle. No migration may convert an unknown identity into a supported identity.
2. Dual-read legacy Mac setup markers, checkout state, channel state, package substitutions, and diagnostics state into a versioned compatibility record. Canonical state is written only after admission; raw legacy state is preserved until the new record is verified and is never deleted as part of an unverified migration.
3. Convert duplicated ARM/Apple decisions into references to generated capability IDs. Keep adapters for old paths until the generated census proves there is one authority for each capability.
4. Separate “fresh install” initialization from “migration applied”. A first install may initialize only the markers it actually ran; it must not pre-mark future migrations merely because files exist.
5. Migrate update state to the transaction journal and retain the last-known-good digest needed for rollback. A failed migration leaves its marker absent and the transaction recoverable.
6. Remove fallbacks, deny lists, and legacy readers only after parity evidence: the generated census shows one authority per capability, the twice-run and non-legacy migration tests pass, and the hostile direct-invocation fixtures show no mutation without a handle.
7. Use the existing documented authoring rules: new `migrations/*.sh` files are 0644, have no shebang, begin with a clear echo, use `$OMARCHY_PATH`, are idempotent, do not restart the shell, and are tested against a fake `HOME` twice plus a non-legacy state. These rules are specified in `agents/skills/migrations.md` and `docs/testing.md`.

Each migration declares a platform scope and required authority version in its design metadata. Universal upstream migrations declare `universal-user` and remain universal; Apple-specific state migrations declare a platform scope and require an exact Apple record; unsupported/unknown identity stops before a platform-scoped write. Pre-Quattro conversion remains a dedicated upgrade path rather than a generic migration that guesses a source generation. P-06 removal of legacy conversion commands and P-07 retirement of in-place conversion are downstream of P-02 and P-05 respectively (section 12.1) and are not designed here.

## 11. Upstream Omarchy compatibility policy

This document defines a compatibility policy and gates; it does not claim that the current tree or any future release is compatible. The policy is:

| Context | Required behavior | Claim gate |
| --- | --- | --- |
| Upstream x86 or non-Apple board with no Apple record | Preserve upstream command routing, package policy, migrations, and user setup; the Apple profile is not selected | Upstream regression suite and a negative test proving Apple-only capability leaves do not mutate. |
| Exact Apple board with a signed qualified record | Select only the generated Apple profile and approved substitutions | Full generated-registry, install/update/recovery, parity, and physical evidence for that exact board/release. |
| Apple-shaped but unknown or ambiguous record | Stop before mutation with a remediation result | Negative fixture tests and physical negative identity cases. |
| Intentional Mac divergence | Track it as an explicit manifest capability and preserve it | Functional/physical evidence plus census row; no silent fork of generic policy. |
| Dev checkout or mutable ref | Treat as development/research state, not a qualified platform release | No compatibility or support claim from a dev build. |

The existing warning in `docs/upgrade-to-quattro.md:29-33` that x86 upgrade instructions must not be used on Mac is a useful compatibility boundary. It must become a signed/profiled operation rule rather than remain only prose. Command metadata remains governed by `bin/omarchy` and `agents/skills/command-metadata.md`; new generated platform metadata must not create a second user-facing command prefix registry.

## 12. Exact gates and evidence

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

The product-integration gate adds generated-registry schema/signature/digest fixtures, unknown/ambiguous/stale identity fixtures, required-versus-optional result fixtures, no-mutation-on-admission-failure property tests, direct-script and routed-command coverage, interrupted/resume/rollback tests, support-bundle redaction tests, generated census drift checks, and migration twice/nonlegacy tests. It also adds the admission seam gates: an adapter identity and negotiation test, a forged-handle test for every enforcing primitive in section 4, a handle-without-journal test, a cross-boot handle test, a step replay test with identical and divergent digests, a privilege-mismatch test for each scope, a lint that fails any consumer passing adapter output to `eval`, `source`, or `bash -c`, and a lint that fails any leaf or command invoking `pacman`, `useradd`, `systemctl enable`, `install`, `cp`, or `tee` against a system path outside an enforcing primitive. Markdown/link sanity must resolve every relative link in this document, prove every table row has its header's column count while honoring escaped pipes and code spans, and reject conflict markers. A generated artifact diff or missing signature is a failure even when shell tests pass.

The command metadata gate must continue to enforce summaries, route uniqueness, valid metadata, executable binaries, and `GROUP_DESCRIPTIONS`; generated platform capability IDs do not replace command metadata. Package tests must prove no required package is silently filtered by `omarchy-pkg-add`, that ARM substitutes are mutually exclusive where required, and that install/remove/refresh use one generated record.

### Acceptance and physical gates

There is no graphical change in this design document, so a running-UI visual check is not applicable to this lane. Any future visual implementation must follow `agents/skills/visual-verification.md`. Any package or installation implementation must use a fresh ISO in the disposable VM workflow described by `agents/skills/acceptance-tests.md`; a reused base image is not evidence.

The program's physical gate is required for each exact Apple board/profile and qualified release: clean install; read-only plan; encryption; first boot; required hardware and app capabilities; sleep/resume; update; interrupted update; rollback; uninstall/recovery; full-disk/network/power/process fault injection; stale/invalid signature and identity cases; support-bundle redaction; and a repeated install/update cycle. Evidence must identify board, firmware schema, platform manifest digest, test commit, and outcome. VM, static inspection, parser success, package availability, recognized chip, or a booting desktop cannot substitute for physical qualification.

The m1n1 component remains outside this lane's inspection and test authority under the coordinator supersession fence. Physical or installer gates that depend on it are therefore deferred here and must be supplied as a coordinator-supplied signed opaque envelope before any support statement.

### Gate ownership

| Gate | Owner | Required evidence before integration |
| --- | --- | --- |
| P-01 generated registry and admission | Platform authority plus `omarchy-mac` consumer | Signed fixtures, generated drift-free bindings, exact identity negative cases, zero mutation before admission, adapter negotiation and forged-handle tests. |
| P-02 typed outcomes | `omarchy-mac` | Result schema, exit/status contract, warning-success regression tests, required marker proof. |
| P-03 parity census | `omarchy-mac` with platform manifest owner | Machine-readable census, no unknown required rows, install/remove/launch verification, intentional divergence records. |
| P-04 diagnostics | `omarchy-mac` | Allowlist schema, redaction fixtures, local export and explicit upload tests, no secrets in artifact. |
| P-05 update/recovery | Installer/recovery authority plus `omarchy-mac` UX | Fault-injection journal evidence, last-known-good rollback, boot-health and success-mark consumption, no false completion, no promotion path. |
| Physical qualification | Coordinator-owned lab process | Exact board/release evidence and signed qualification record; no claim from this design lane alone. |

## 13. Dependencies, handoffs, rulings, and residuals

### 13.1 Exact dependency and handoff table

Read from the `PROGRAM.md` slice ledger at `58302d1`. Freshness is the condition under which a consumed artifact is still valid; rejection behavior is what the consumer does otherwise; residual owner is who holds the gap until the row is satisfied. No row is satisfied today: F-02 is rejected at `c315c7e`, and every other named slice is unstarted or in progress in the ledger.

| Edge | Producer | Consumer | Artifact and exact identity | Scope | Freshness | Rejection behavior | Residual owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| F-02 → P-01 | `omarchy-apple-platform` F-02 | P-01 admission adapter | ratified schema set with `schema_set_digest`, generated Python binding with `generated_output_digest`, input and output locks; currently the rejected candidate `c315c7e` | trust seam, payload parsing, identity resolution | binding identity equals the manifest-required entry and lock digests; any new F-02 tip re-runs negotiation | `BINDING_INTEGRITY_FAILURE` or reject; no adapter runs on an unratified tip | F-02 owner until ratified; then `omarchy-mac` |
| Q-00 → P-01 | `omarchy-apple-platform` Q-00 | P-01 identity fixtures and negative cases | cited, immutable, digest-addressed intake dataset and contradiction ledger, identified by its content digest | identity negative and ambiguous fixtures | dataset digest referenced by the fixture set matches the published digest | fixtures that cannot cite the dataset fail the P-01 gate; no board row is an allowlist | Q-00 owner |
| P-01 → P-02 | `omarchy-mac` P-01 | P-02 typed outcomes | admission adapter at a commit SHA with passing seam gates and its fixed adapter-result record | every result record and marker | adapter API `1.0.0` and journal format unchanged; a breaking change reruns P-02 gates | P-02 cannot start; warning-success seams remain in the fail census | `omarchy-mac` |
| F-01 → P-03 | `omarchy-apple-platform` F-01 | P-03 census | ratified `PROGRAM.md` at `58302d1` and its acceptance contract | census classification vocabulary and intentional divergence policy | census cites the exact program commit it classified against | a census against a stale program commit is rejected by the coordinator | `omarchy-mac` |
| F-02 → P-04 | `omarchy-apple-platform` F-02 | P-04 diagnostics | generated projection binding and privacy class registry (PROVISIONAL from `c315c7e`) | support-bundle projection of platform documents | projection policy version and schema-set digest match the consumed documents | bundle export refuses to include any platform document without a generated projection | F-02 owner until ratified; then `omarchy-mac` |
| F-05 → P-05 | `omarchy-apple-platform` F-05 | P-05 update transaction | candidate assembly output: signed `platform-manifest/v1` by `document_id` and `payload_digest`, generated consumer packages, tuple validator | staging, applying, boot selection, attestation | manifest not expired, qualification references resolve, negotiation succeeds | `platform-update` admission exits 3; no staging | F-05 owner; P-05 blocked |
| P-02 → P-06 | `omarchy-mac` P-02 | P-06 legacy conversion removal | typed outcome contract and enforcing primitives at a commit SHA | dependency-graph proof that the installer cannot invoke legacy conversion | P-02 gates pass at that SHA | P-06 cannot claim the proof | `omarchy-mac` |
| P-05, P-06 → P-07 | `omarchy-mac` | P-07 in-place conversion retirement | P-05 journal contract and P-06 removal proof at commit SHAs | separately approved journaled migration or retirement | both prerequisites terminal | P-07 stays unstarted | `omarchy-mac` |
| F-02, Q-00, I-01, I-07 → I-03 | `omarchy-apple-platform` and `omarchy-mac-installer` | I-03 installer admission | same ratified schema set and intake dataset as P-01, plus the I-01 state machine and I-07 credential-state design | the installer's own fail-closed admission | identical to the P-01 row; the installer and product must consume the same schema-set digest | I-03 and P-01 diverging on schema-set digest is a cross-repository rejection | installer owner; `omarchy-mac` supplies nothing to I-03 |
| Q-00, I-02..I-08, P-06, P-07 → I-09 | installer slices and `omarchy-mac` P-06/P-07 | I-09 installer acceptance | P-06 removal proof and P-07 retirement result at commit SHAs | clean-path dependency suite | prerequisites terminal at the SHAs I-09 cites | I-09 cannot pass the clean-path dependency suite | `omarchy-mac` for P-06/P-07 |
| F-05, P-03, P-05, I-09, B-04, Q-04..Q-08 → F-07 | `omarchy-mac` supplies P-03 and P-05 evidence only | F-07 sole stable promotion terminal | census and update evidence files by commit SHA and SHA-256 per section 9.3 | required-slice closure recomputation | evidence cites the exact candidate manifest `document_id` and `payload_digest` being promoted | F-07 rejects the promotion; the product has no way to override | `omarchy-apple-platform`; intake format is BLOCKED (13.3) |

### 13.2 Rulings on the previously open questions

The prior draft listed eight coordinator questions. They are resolved as follows; none remains an open design choice.

| Former question | Ruling |
| --- | --- |
| Bundle layout, signing root, rotation, expiry, offline-cache retention | Come only from the final ratified platform contract and its generated layout binding. The product consumes the generated file names, trust context, and expiry from F-02/F-03 and adds no local layout, root, or retention policy; until ratification the adapter cannot be built. |
| Capability vocabulary and required-versus-optional per board/profile | Capability requiredness and approved substitutes come only from the signed `platform-manifest/v1` for the exact board record. A capability, requiredness, or substitute not present in that signed manifest is `unknown` and blocks; the product keeps no local capability table. |
| Admission as Bash command, library binding, or verifier with adapter | The version-pinned verifier command adapter in section 3, wrapping the generated Python binding. Bash callers use the command only; there is no sourced library seam and no Bash verifier. |
| Which primitives enforce the transaction context | Every primitive in section 4 enforces the admitted handle at its own mutation seam; universal user operations use exactly the `universal-user` scope and still carry a handle. |
| Installer/recovery backend and journal persistence | The installer/recovery repository owns the atomic backend journal, inactive targets, boot selection, health attestation transport, and rollback under I-01, I-04, I-06, and B-04. The product owns UX, read-only status, a non-authoritative evidence linkage record, and evidence (section 9); its record cannot authorize or resume backend mutation. |
| Approved ARM substitute policy | Substitutes for `obsidian`, `obs-studio`, `pinta`, `dotnet-runtime`, recording, gaming, and desktop wrappers are read from the signed manifest capability records. The product proposes census rows; it approves nothing. An unlisted substitute is `unknown` and blocks. |
| Migration cutover and fallback removal | Migrations dual-read legacy state, write canonical state only after admission, and remove fallbacks and deny lists only after parity evidence (section 10, step 6). |
| Physical board matrix and evidence location | `qualification-record/v1` in the immutable candidate bundle points to coordinator-owned evidence in the Q-02 evidence store. The product references records by stable ID and never copies raw lab evidence into product state. Board matrix and lab location are Q-01 and Q-03 decisions and coordinator rulings, not product choices. m1n1-dependent evidence arrives only as a coordinator-supplied signed opaque envelope. |

### 13.3 Blocked cross-repository dependencies

| Dependency | Owner | Consumer | Due before | Effect while blocked |
| --- | --- | --- | --- | --- |
| F-02 ratified schema set and generated Python binding; candidate `c315c7e` is rejected and frozen | `omarchy-apple-platform` F-02 owner and coordinator | P-01, P-04, and every generated product consumer | any P-01 or P-04 implementation commit | adapter, fixtures, and projections cannot be built; every F-02 reference here is provisional |
| F-03 trust context, `AuthorityRoleBinding`, key custody, and admission policy source | `omarchy-apple-platform` F-03 | P-01 admission and I-03 installer admission | any adapter run outside fixtures | `TRUST_FAILURE`; no handle can be issued for a platform scope |
| F-05 candidate assembly and signed manifest for a real tuple | `omarchy-apple-platform` F-05 | P-05 update transaction | P-05 implementation | `platform-update` admission has nothing to stage |
| F-06/F-07 compliance and product-evidence intake formats | `omarchy-apple-platform` F-06 and F-07 owners | F-07 promotion terminal | any F-07 promotion attempt | product produces digest-addressed evidence files and consumes only coordinator-provided compliance/promotion inputs; handoff stays blocked; no shadow payload type is created |
| Q-00 intake dataset digest | `omarchy-apple-platform` Q-00 | P-01 identity fixtures, I-03 inventory, and I-09 acceptance | P-01 fixture authorship | identity fixtures cannot cite a dataset; negative cases are illustrative only |
| I-01/I-04/I-06 and B-04 backend contract for inactive targets, boot selection, and success marking | `omarchy-mac-installer` and `u-boot-omarchy` | P-05 update/recovery UX | P-05 implementation | product state machine is backend-neutral prose; no transition is executable |
| Q-01/Q-02 qualification schema and evidence store | `omarchy-apple-platform` and hardware lab | P-04/P-05 status and F-07 promotion closure | any status display of qualification | product shows `unknown` for qualification; never `qualified` |
| Coordinator-supplied signed opaque envelope for boot components | coordinator and human m1n1 owner | physical and installer gates that depend on external boot evidence | any physical gate that depends on boot components | those physical gates are deferred; no boot claim |

### 13.4 Empirical implementation residuals

These are the coordinator's measured findings on rejected tip `a505588c630c1266ee41767b054d5b3d60b3e8f7`. They describe the current tree and remain true of this correction, which changes only this document. They are future implementation and integration gates, not design accomplishments.

| Residual | Evidence | Owner | Consumer | Due-before gate |
| --- | --- | --- | --- | --- |
| 51 constructed hostile variants produced 0 executable rejections; every variant observed no executable guard | coordinator hostile census on `a505588` | `omarchy-mac` P-01/P-02 implementation | coordinator adversarial review | P-01 integration; every variant must have a named guard and a fixture that proves it bites |
| A copied preflight with unknown Apple identity printed “continuing anyway” and returned 0 | `install.sh:57-64` behavior reproduced by the coordinator | `omarchy-mac` P-01 | P-02, I-03 parity | P-01 integration; must exit 3 through the adapter before `ensure_gum` |
| A copied required-package lookup for an unavailable package printed “Skipping” and returned 0 | `bin/omarchy-pkg-add:12-21` behavior reproduced by the coordinator | `omarchy-mac` P-02 | P-03 census, P-05 | P-02 integration; filtered-empty must be `required_blocked` |
| No product schema directory, generated binding, fixture directory, admission command, or product-specific CI guard exists | coordinator structural census on `a505588`; unchanged here | `omarchy-mac` P-01 | all P slices | P-01 integration, after F-02 ratification |
| `test/shell.d/install-mac-test.sh` fails its `set_pkgrel` no-op/write/reject-junk case | coordinator gate run; this lane must not edit tests or production code | `omarchy-mac` SWE on a separate fix branch | QA gate census | before any P slice claims the section 12 battery |
| The aggregate suite was not proven complete; the coordinator's run ended with exit 130 | coordinator gate run | `omarchy-mac` QA | coordinator | before any P slice integration; a full PASS/FAIL census from a clean checkout is required |
| Bash cannot prevent raw writes by a root shell that bypasses every primitive | design limit of section 3.9 | `omarchy-mac` P-01 | reviewer | P-01 integration; the lint and hostile fixtures must cover every leaf and command |

### 13.5 Deferrals and non-claims

Deferrals are intentional: all production implementation; canonical schema and key-root decisions; generated artifact format; installer/recovery transaction backend; platform repository changes; physical Apple lab runs; qualification records; m1n1-dependent evidence; command/app census generation; migration implementation; and any compatibility or support claim. The open implementation residuals are listed with owner, consumer, and due-before gate in section 13.4, and blocked cross-repository dependencies are listed in section 13.3. This document is not DONE as a program slice; it is a design handoff for coordinator ruling. Nothing here claims compatibility, support, qualification, release readiness, CI success, or physical proof.
