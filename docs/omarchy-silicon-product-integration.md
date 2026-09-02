# Omarchy Silicon product integration design (P-01–P-05)

Status: DESIGN CONTRACT ONLY, correction round 2. This file is non-implementation, non-support, and non-release material. It changes no production code, schemas, bindings, fixtures, CI, qualification record, boot artifact, branch protection, or platform behavior. No slice or program is DONE, and no compatibility or Apple Silicon support claim is made here.

Identity: pre-correction tip `19b493c6c1688ec6c7a3c0d27d48144aa02cb369`, its parent `a505588c630c1266ee41767b054d5b3d60b3e8f7`, base branch `quattro`, and PR #1 kept OPEN/DRAFT. The frozen program baseline is the coordinator-pinned `PROGRAM.md` commit `58302d148f0e8b855578f9aa518ff1c5eb48c515`; this document does not silently consume a later baseline.

The `m1n1-omarchy` boundary is opaque and human-produced. This lane does not inspect, read, list, traverse, fetch, clone, characterize, edit, test, or use any artifact behind that boundary. Any required external boot evidence enters only as an externally supplied signed hash or metadata envelope, treated as an opaque input.

## 1. Scope and design acceptance

The product side owns the command and app adapters, admission orchestration, typed user outcomes, local evidence linkage, diagnostics projection, and parity evidence. The platform side owns the authenticated registry and payloads, authority and policy, generated bindings, qualification, release assembly, boot evidence, and stable promotion. The installer/recovery side owns the irreversible system, package, configuration, APFS, slot, and rollback executor. This separation is a contract boundary, not an implementation claim.

The design is acceptable only when the following are independently demonstrated at an immutable commit and the relevant gate is green: a ratified dependency receipt for every consumed upstream contract; one generated verifier and one `Trusted<T>` constructor boundary; a closed admission input/output schema; all eight payloads mapped to source, validator, binding, consumer, freshness, and rejection; qualification bound into admission identity; the `Trusted<BootContext>` and `VerifiedClock` boot handoff; a typed I-03/I-04 transaction; the closed route and call-graph manifest; typed F-06/F-07 evidence intake; total recovery; privacy and accessibility outcomes; hostile fixtures and product CI; physical qualification; and branch protection.

The document-level invariants are exact and checked mechanically: payload types = 8, dependency holds = 4, route entries = 25, recovery states = 11, hostile fixtures = 21, implementation residuals = 11, and baseline failure records = 3. Missing executables or evidence remain `NOT IMPLEMENTED` or `NOT PRESENT`; they are never counted as a pass.

## 2. Authority holds and one trust seam

### 2.1 Dependency HOLDs

The product does not treat rejected, frozen, unstarted, or unratified upstream prose as local authority. F-02 candidate vocabulary is not a product schema; F-03 policy names are not a product trust table; F-06 and F-07 intake names are not promotion artifacts until their owners ratify them. The eight payload identifiers below are the frozen program set only, and their final field grammar is consumed through the future ratified generated binding.

| Hold ID | Dependency and current status | Owner | Consumer | Due before | Effect while held |
| --- | --- | --- | --- | --- | --- |
| `HOLD-01` | F-02 platform schema and generated binding: rejected/frozen candidate `c315c7e79928d0041deb582bed79a61074361b21` is non-consumable | F-02 owner and coordinator | P-01, P-02, P-04, P-05, I-03, I-04 | any product binding, fixture, or admission implementation | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, process status 4, decision `hold`, no handle, no mutation |
| `HOLD-02` | F-03 trust context, authority policy, key custody, and role binding are unstarted | F-03 owner and coordinator | admission, executor handoff, diagnostics projection | any trust or policy verification | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, process status 4, decision `hold`, no handle, no mutation |
| `HOLD-03` | F-06 compliance intake contract is unratified | F-06 owner and coordinator | F-07 promotion terminal | any compliance intake or parity acceptance | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, process status 4, decision `hold`, no handle, no promotion input |
| `HOLD-04` | F-07 promotion-evidence intake contract is unratified; F-07 remains the sole stable-channel writer | F-07 owner and coordinator | F-07 promotion terminal | any candidate promotion request | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, process status 4, decision `hold`, no handle, no product promotion |

For every dependency, missing, mismatched, stale, unratified, or unverifiable evidence has exactly one terminal result: `decision=hold`, `code=DEPENDENCY_UNRATIFIED`, `path=dependency.check`, `phase=dependency`, `process_status=4`, `handle` absent, and `mutation=false`. A diagnostic cause may identify the hold ID, but it cannot change the code, path, phase, result, or process status. There is no warning, skip, local substitute, or partial authority path.

### 2.2 Required future ratification evidence

The hold clears only when the owner supplies one immutable ratification receipt that contains every field below for the exact consumed dependency. A URL, branch name, section reference, local copy, or prose approval without these fields is not evidence.

| Evidence field | Required value and verification |
| --- | --- |
| `canonical_commit_id` | Full immutable commit ID for the canonical source, resolved by the coordinator and not a branch or mutable ref |
| `artifact_id` | Exact immutable artifact/document identifier for the consumed contract or generated output |
| `artifact_content_digest` | SHA-256 of the exact canonical artifact bytes, with the preimage and encoding recorded in the receipt |
| `schema_set_digest` | Exact digest of the complete schema set used by the producer and consumer, compared byte-for-byte |
| `generated_output_lock_digest` | Exact digest of the generator lock and generated output lock, including generator, parser, interpreter, and dependency versions |
| `authority_version` | Version of the authority and key-custody policy that was approved for this artifact |
| `policy_version` | Version of the consumer and admission policy that was approved for this artifact |
| `generated_binding_identity` | Binding ID, binding version, source digest, generated output digest, parser ID/version, and declared consumer capability identity |
| `conformance_receipt` | Immutable receipt ID and digest showing schema, canonicalization, signature, context, freshness, replay, negative-fixture, and consumer-binding conformance |
| `owner_decision_log_entry` | Immutable owner decision-log entry ID and digest naming the artifact, the exception or ratification decision, reason, scope, and effective version |
| `trusted_constructor_boundary` | Exactly one named constructor boundary, with an immutable implementation ID and digest, producing `Trusted<T>` only after strict parse, canonicalization, verification, context, freshness, and policy checks |
| `issued_at` and `expires_at` | Verified clock values with a bounded freshness interval and no open-ended validity |

The consumer compares all fields against the manifest-required binding and the locally pinned ratification receipt. Any comparison failure returns the same `DEPENDENCY_UNRATIFIED` result. The product must not hand-copy a field list or create a shadow registry to bridge a hold.

### 2.3 One `Trusted<T>` constructor boundary

There is exactly one future cross-repository constructor boundary: `construct_trusted<T>(canonical_input, expected_context, verified_clock, ratification_receipt) -> Trusted<T> | terminal rejection`. It is implemented by the ratified generated verifier owned by F-02/F-03; product code only receives an opaque `Trusted<T>` and cannot instantiate, deserialize, cast, unwrap, or mint one. `Trusted<BootContext>` uses the same boundary. No shell route, app route, executor, test fixture, journal record, or support bundle is an alternate constructor.

The product adapter derives `expected_context` from the closed operation, scope, target identity, candidate identity, and authority context. It never accepts a caller-provided context, role, key, board identity, timestamp, digest, or trust decision. A rejected or unratified value cannot be downgraded to evidence, `not_applicable`, or a warning.

## 3. The eight authenticated payloads

The following table is the complete payload map. Each row names the source, validator, generated binding, producer, consumer, freshness/replay rule, and terminal rejection behavior. These are the eight frozen program payload types and not a locally extensible schema registry. While any dependency hold in 2.1 remains uncleared, its universal `DEPENDENCY_UNRATIFIED` result supersedes every row-specific parse or identity rejection.

| Payload ID | Authenticated type | Source and producer | Validator | Binding | Product consumer and operation | Freshness and replay | Rejection behavior |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `PAY-01` | `board-registry/v1` | F-02 canonical bundle; platform registry publisher | one `Trusted<T>` constructor using ratified trust context | generated binding identity from the ratification receipt | `admit_board` in P-01 for `inspect`, `install`, `setup`, `update`, `recover` | immutable document ID, payload digest, schema-set digest, issued/expiry window, nonce and replay identity; no duplicate document ID | `TRUST_FAILURE` at `admission.verify`, phase `verify`, process status 3, decision `reject`, no identity or handle |
| `PAY-02` | `platform-manifest/v1` | F-02/F-05 candidate assembly; platform release publisher | same constructor plus cross-document and candidate checks | generated manifest binding named by the ratified lock | `admit_operation` and I-04 executor for exact operation, scope, target, component, channel, health, and rollback policy | immutable candidate tuple, expiry, schema/binding lock, monotonic candidate generation, no replay across board or target | `BINDING_MISMATCH` or `TRUST_FAILURE` at `admission.verify`, phase `verify`, process status 3, no handle or staging |
| `PAY-03` | `installer-plan/v1` | I-03 planner; read-only plan producer | constructor plus operation/scope/target and mutation-list binding | generated plan binding and plan lock digest | P-01 `open` and I-03/I-04 typed executor handoff | plan digest and target IDs cannot change after open; a replayed plan or changed mutation list is rejected | `PLAN_MISMATCH` at `admission.identity`, phase `identity`, process status 3, no handle |
| `PAY-04` | `qualification-record/v1` | Q-00/Q-01/Q-02 qualification authority; lab evidence publisher | constructor plus exact board, candidate, manifest, test, and residual checks | generated qualification binding and qualification evidence projection | `admit_board`, P-03 census, P-05 update evidence, and F-07 intake; qualification is never produced by product code | exact board/profile and manifest binding, record expiry, test-run identity, operator receipt, no replay across candidate or board | `QUALIFICATION_NOT_BOUND` at `admission.identity`, phase `identity`, process status 3, no handle and result cannot be `qualified` |
| `PAY-05` | `boot-health/v1` | boot-health producer after the boot backend checks the candidate | constructor plus `Trusted<BootContext>` and `VerifiedClock` comparison | generated health binding and required-check-set digest | `evaluate_boot_health` for P-05 recovery/update state; product records evidence only | source generation, slot, generation, lineage, counter, manifest tuple, required checks, issued/expiry, and replay identity must match the transaction | `BOOT_TUPLE_MISMATCH` or `HEALTH_REQUIRED_CHECK_FAILED` at `boot.evaluate`, phase `verify`, process status 3, no success result |
| `PAY-06` | `owner-approval/v1` | owner-authorized approval service; product never creates it | constructor plus scope, operation, target, plan, topology, schema-set, authority role, expiry, and replay checks | generated approval binding and authority/policy version | `admit_operation` and I-03 final consent preflight; approval authorizes only the named transaction | one nonce and approval ID per plan/target; expiry is the earliest of approval, policy, manifest, and verified-clock limits | `OWNER_PROOF_INVALID` at `admission.identity`, phase `identity`, process status 3, no handle |
| `PAY-07` | `boot-success-mark/v1` | boot backend after verified health; product never creates or promotes it | constructor plus `Trusted<BootContext>`, `Trusted<boot-health/v1>`, and clock comparisons | generated success-mark binding and required-check-set digest | `evaluate_boot_health` and I-04 transaction close; F-07 may consume it as evidence | source generation, slot, generation, lineage, counter, manifest, board, transaction, and required checks must equal the live context; one-time marker identity | `BOOT_TUPLE_MISMATCH` at `boot.evaluate`, phase `verify`, process status 3, no close and no promotion |
| `PAY-08` | `dtb-mutation-envelope/v1` | platform DTB decision producer; product does not mutate DTB | constructor plus board, manifest, target, operation, policy, and mutation digest checks | generated DTB envelope binding and decision digest | `admit_operation` consumes the verified decision; I-04 consumes the envelope for the authorized DTB mutation step | exact board, target, manifest, transaction, operation, mutation list, expiry, and nonce; no envelope transplant or replay | `DTB_DECISION_MISSING` at `admission.handoff`, phase `handoff`, process status 3, no handle and no DTB action |

The `dtb-mutation-envelope/v1` has one product operation: `apply-hardware` under `platform-hardware`. The product consumer verifies that the envelope is present, bound to the exact board/manifest/target/operation and included in the admission identity, then passes it opaquely to I-04. I-04 is the only consumer allowed to execute the DTB mutation primitive. Product code never reads it as authority, edits it, selects a mutation, or writes a DTB.

## 4. Closed product admission contract

### 4.1 `P01.AdmissionOpenInput/v2`

`P01.AdmissionOpenInput/v2` is a product adapter input/output contract, not an authenticated ninth payload. It is closed: unknown top-level fields, absent required values, duplicate entries, caller-supplied semantic identities, and unbounded strings are rejected before the dependency check. Paths are only transport references to bounded files; path contents are read through the one generated verifier boundary.

| Input ID | Field and exact members | Source and rule |
| --- | --- | --- |
| `IN-01` | `contract_id = P01.AdmissionOpenInput/v2` | adapter constant; any other value is `ADMISSION_USAGE` |
| `IN-02` | `operation_scope = {operation, scope, route_id}` | operation and scope come from the closed tables in 4.3; route ID must be in the route manifest; no default operation or scope |
| `IN-03` | `target = {requested_target_id, observed_target_id, target_kind, board_id, soc_id, device_tree_identity_digest, firmware_schema_id, disk_id, volume_id, slot, account_id}` | requested ID comes from the verified plan; observed ID comes from the adapter-owned source; every exact identity must compare; raw serials and device paths are not authority |
| `IN-04` | `owner_proof_receipt = {receipt_id, issuer_id, subject_account_id, operation, scope, target_id, plan_document_id, plan_digest, issued_at, expires_at, nonce, replay_counter, authority_version, verifier_id, verification_digest}` | independently verified receipt from the owner-proof service; a signed approval alone is insufficient; receipt subject and target account must match |
| `IN-05` | `target_account = {account_id, account_kind, uid, ownership_receipt_id, account_policy_version, issued_at, expires_at, nonce, verification_digest}` | independently verified target-account source; uid, account kind, operation, scope, and exact target are compared; no caller string grants ownership |
| `IN-06` | `verified_clock = {clock_id, source_generation, observed_at, monotonic_counter, fresh_until, replay_nonce, verifier_digest}` | adapter-attested source only; no `--at`, environment timestamp, wall-clock-only value, or fixture argv injection |
| `IN-07` | `payload_refs = exactly eight entries each with {payload_type, document_id, content_digest, payload_digest, schema_set_digest, binding_identity, authority_version, issued_at, expires_at, source_generation, status, not_applicable_reason}` | one entry for each `PAY-01` through `PAY-08`; `status=not_applicable` is explicit and must be authorized by the manifest; omission is invalid |
| `IN-08` | `plan = {document_id, payload_digest, mutation_list_digest, operation, scope, target_id, plan_generation, predecessor_generation, target_generation, lineage, expected_counter, required_capability_ids}` | verified `installer-plan/v1`; exact operation/scope/target and mutation list are immutable after open |
| `IN-09` | `qualification_provenance = {qualification_document_id, qualification_payload_digest, qualification_content_digest, board_id, profile_id, manifest_document_id, manifest_payload_digest, test_run_id, evidence_receipt_digest, status}` | independently verified `PAY-04`; one or more records are required for a platform mutation, sorted by document ID, and included in identity hashing |
| `IN-10` | `boot_identity = {boot_health_document_id, boot_health_payload_digest, boot_success_document_id, boot_success_payload_digest, context_id, source_generation, slot, generation, lineage, counter, required_checks_digest}` | explicit `present` or `not_applicable` state according to operation; update/recovery requires present and later `Trusted<BootContext>` verification |
| `IN-11` | `dtb_identity = {envelope_document_id, envelope_payload_digest, envelope_content_digest, decision_digest, board_id, manifest_document_id, target_id, operation, mutation_list_digest}` | explicit `present` or `not_applicable`; `apply-hardware` requires present; no product mutation is allowed |
| `IN-12` | `authority_context = {trust_context_id, trust_context_digest, authority_role, authority_version, policy_id, policy_digest, policy_version, expected_context_digest}` | future ratified F-03 source and policy; product derives expected context and compares the supplied digest, never the reverse |
| `IN-13` | `replay = {request_id, request_nonce, prior_transaction_id, prior_result_digest, caller_uid}` | adapter-generated request identity plus the live journal and verified clock; a caller cannot reuse an old transaction or choose the journal path |

The input has no fields for an assumed board, chip family, architecture decision, arbitrary ref, raw URL, package name outside the verified plan, firmware path, success flag, promotion flag, handle value, key, role override, target-path override, or dynamic command. `OMARCHY_PATH` locates packaged code only and is required as an existing absolute environment value; missing or empty `OMARCHY_PATH` is `OMARCHY_PATH_MISSING`, not a fallback.

### 4.2 `P01.AdmissionResult/v2`

Every adapter subcommand emits exactly one canonical JSON result on stdout and a fixed human summary on stderr unless `--json` suppresses that summary. The result is not one of the eight authenticated payloads and cannot be presented as a platform authority. A successful `open` has a non-forgeable handle; every other outcome has the complete rejection or terminal result object and no handle.

| Output ID | Field and rule |
| --- | --- |
| `OUT-01` | `result_schema = P01.AdmissionResult/v2` |
| `OUT-02` | `adapter_identity = {adapter_id, adapter_api, binding_identity, schema_set_digest}` |
| `OUT-03` | `decision` is exactly one of `admitted`, `hold`, `reject`, `valid`, `already_applied`, `closed`, `aborted`, `quarantined` |
| `OUT-04` | `code` is exactly one code in 4.4; unknown or absent code is invalid |
| `OUT-05` | `path` is exactly one path in 4.4 and identifies the public seam, not a free-form stack trace |
| `OUT-06` | `phase` is exactly one phase in 4.4 |
| `OUT-07` | `process_status` is the numeric status in 4.4; no zero status is allowed for a reject, hold, abort, or quarantine |
| `OUT-08` | `operation`, `scope`, `route_id`, and `transaction_id` are copied from verified context; transaction ID is absent only when parsing fails before a transaction can exist |
| `OUT-09` | `handle` is present only for `decision=admitted` or `decision=valid`; its opaque form is `omarchy-admit:v2:transaction-id:nonce:mac`, and only the adapter verifies it against a live journal |
| `OUT-10` | `rejection = {code, path, phase, process_status, safe_next_action}` is mandatory whenever `decision` is `hold`, `reject`, `aborted`, or `quarantined` |
| `OUT-11` | `admission_identity = {identity_digest, board_id, soc_id, device_tree_identity_digest, firmware_schema_id, target_id, registry_ref, manifest_ref, plan_ref, qualification_provenance, boot_ref, dtb_ref, schema_set_digest, binding_identity, authority_context_digest}` |
| `OUT-12` | `qualification_provenance` repeats every verified `IN-09` record and is part of `identity_digest`, `admission_result_digest`, journal binding, executor request, and close result |
| `OUT-13` | `artifact_refs` repeats all eight payload refs with document IDs, content digests, payload digests, schema/binding digests, authority version, freshness, and status |
| `OUT-14` | `freshness = {verified_clock_id, source_generation, issued_at, expires_at, replay_counter, nonce}`; the earliest expiry governs |
| `OUT-15` | `admission_result_digest` is `SHA-256(CONCAT(UTF8("P01.AdmissionResult/v2\\0"), UTF8(JCS(result_without_admission_result_digest_and_handle_mac))))` |
| `OUT-16` | `journal_ref` is an adapter-generated transaction journal identifier and chain digest; the output never accepts a caller-selected journal path |

The identity preimage is exact: `identity_digest = SHA-256(UTF8("P01.AdmissionIdentity/v2\\0") || UTF8(JCS({operation, scope, target, registry_ref, manifest_ref, plan_ref, sorted qualification_provenance, boot_ref, dtb_ref, schema_set_digest, binding_identity, authority_context_digest})))`. Qualification provenance cannot be omitted, replaced by a boolean, or added after the handle is issued.

### 4.3 Closed operation and scope sets

| Operation ID | Operation | Permitted scopes | Product consumer |
| --- | --- | --- | --- |
| `OP-01` | `install` | `platform-system`, `platform-hardware` | install adapter and I-03/I-04 |
| `OP-02` | `setup` | `platform-system`, `platform-hardware` | Mac setup adapter and I-03/I-04 |
| `OP-03` | `apply-system` | `platform-system` | hidden apply-system adapter and privileged broker |
| `OP-04` | `apply-hardware` | `platform-hardware` | hidden apply-hardware adapter and I-04 DTB/hardware executor |
| `OP-05` | `provision-owner` | `platform-system` | hidden owner-provision adapter and I-03 |
| `OP-06` | `provision-user` | `platform-user`, `universal-user` | hidden user-provision adapter |
| `OP-07` | `first-run` | `platform-user`, `universal-user` | hidden first-run adapter |
| `OP-08` | `update` | `platform-update` | update adapter and I-04 |
| `OP-09` | `channel-set` | `platform-update` | channel adapter and I-04 |
| `OP-10` | `upgrade` | `platform-system`, `platform-update` | upgrade adapter and I-03/I-04 |
| `OP-11` | `migrate` | `platform-migration`, `universal-user` | migration adapter and the declared migration primitive |
| `OP-12` | `recover` | `platform-update`, `platform-system` | resume, rollback, abort, and recovery UI |

| Scope ID | Scope | Privilege and journal owner | Mutation authority |
| --- | --- | --- | --- |
| `SCOPE-01` | `platform-system` | effective uid 0; root journal | only the exact admitted system package/config/service/user/checkout/initramfs steps |
| `SCOPE-02` | `platform-hardware` | effective uid 0; root journal | only the exact admitted hardware, firmware-profile, kernel-parameter, audio, and DTB steps |
| `SCOPE-03` | `platform-update` | effective uid 0; root journal | only the exact staged tuple, slot request, boot evidence, and update steps |
| `SCOPE-04` | `platform-user` | effective uid nonzero and equal to journal owner; user journal | only the exact admitted user hardware and capability-marker steps |
| `SCOPE-05` | `platform-migration` | effective uid 0; root journal | only the exact named migration and marker step |
| `SCOPE-06` | `universal-user` | effective uid nonzero and equal to journal owner; user journal | only user configuration/theme/application state; no platform-capable primitive |
| `SCOPE-07` | `read-only` | any uid; no journal or handle | observation and diagnostics only; no mutation |

An operation/scope pair outside these tables returns `ADMISSION_USAGE` at `route.parse`, phase `parse`, process status 2. Root opening a user scope returns `PRIVILEGE_MISMATCH`; a non-root opening a platform scope returns the same code. The adapter never escalates. In a visible terminal, the caller uses `sudo` according to repository privilege rules; without a terminal, a systemd root service or constrained broker uses `pkexec` only where its policy permits it. The adapter never nests or silently chooses an elevation path.

### 4.4 Closed code, path, phase, and result registry

The following registry is closed. Every terminal output must select one row, and every fixture or route rejection cites the exact code, path, phase, process status, and result. Unknown events or codes are themselves `UNKNOWN_EVENT` with process status 9.

| Code | Path | Phase | Process status | Terminal result |
| --- | --- | --- | --- | --- |
| `ADMISSION_USAGE` | `route.parse` | `parse` | 2 | `reject`, no handle |
| `PATH_TRAVERSAL` | `route.parse` | `parse` | 2 | `reject`, no read or write |
| `FORBIDDEN_ROUTE` | `route.authorize` | `authorize` | 2 | `reject`, no adapter or broker call |
| `OMARCHY_PATH_MISSING` | `route.bootstrap` | `bootstrap` | 2 | `reject`, no fallback path |
| `DEPENDENCY_UNRATIFIED` | `dependency.check` | `dependency` | 4 | `hold`, no handle, no mutation |
| `BINDING_MISMATCH` | `admission.verify` | `verify` | 3 | `reject`, no handle |
| `TRUST_FAILURE` | `admission.verify` | `verify` | 3 | `reject`, no handle |
| `OWNER_PROOF_INVALID` | `admission.identity` | `identity` | 3 | `reject`, no handle |
| `TARGET_ACCOUNT_INVALID` | `admission.identity` | `identity` | 3 | `reject`, no handle |
| `TARGET_ID_MISMATCH` | `admission.identity` | `identity` | 3 | `reject`, no handle |
| `PLAN_MISMATCH` | `admission.identity` | `identity` | 3 | `reject`, no handle |
| `QUALIFICATION_NOT_BOUND` | `admission.identity` | `identity` | 3 | `reject`, no handle and no `qualified` result |
| `DTB_DECISION_MISSING` | `admission.handoff` | `handoff` | 3 | `reject`, no handle and no DTB action |
| `FRESHNESS_REPLAY` | `admission.freshness` | `freshness` | 6 | `reject`, no handle |
| `HANDLE_INVALID` | `admission.check` | `verify` | 8 | `reject`, no mutation |
| `JOURNAL_FAILURE` | `executor.reserve` | `reserve` | 7 | `reject`, no irreversible step |
| `CONSENT_MISSING` | `executor.consent` | `consent` | 4 | `hold`, no mutation |
| `CACHE_MISS` | `executor.preflight` | `preflight` | 4 | `hold`, no network or mutation |
| `PRIVILEGE_MISMATCH` | `route.authorize` | `authorize` | 5 | `reject`, no broker call |
| `TARGET_REVALIDATION_FAILED` | `executor.verify` | `verify` | 3 | `reject`, journal preserved, rollback decision required |
| `BOOT_TUPLE_MISMATCH` | `boot.evaluate` | `verify` | 3 | `reject`, no success or promotion result |
| `HEALTH_REQUIRED_CHECK_FAILED` | `boot.evaluate` | `verify` | 3 | `reject`, no success or promotion result |
| `USER_CANCELLED_BEFORE_CONSENT` | `executor.consent` | `consent` | 4 | `aborted`, no transaction mutation |
| `USER_CANCELLED_AFTER_RESERVE` | `recovery.cancel` | `recover` | 4 | `aborted` only after safe rollback or quarantine |
| `POWER_LOSS_INTERRUPTED` | `recovery.resume` | `recover` | 4 | `hold`, resume/rollback/abort required |
| `DISK_FULL` | `executor.apply` | `apply` | 4 | `reject`, journal preserved, rollback required |
| `RECOVERY_TERMINAL` | `recovery.dispatch` | `terminal` | 9 | `quarantined`, tombstone required |
| `UNKNOWN_EVENT` | `recovery.dispatch` | `terminal` | 9 | `quarantined`, no action inferred |
| `PRIVACY_POLICY_UNRATIFIED` | `diagnostics.policy` | `privacy` | 4 | `hold`, local-only conservative result |
| `SUPPORT_BUNDLE_REDACTION_FAILED` | `diagnostics.export` | `privacy` | 3 | `reject`, bundle not persisted or uploaded |
| `ACCESSIBILITY_UNAVAILABLE` | `ux.render` | `authorize` | 4 | `hold`, no hidden mutation or false success |
| `PROMOTION_INTAKE_INVALID` | `promotion.intake` | `promotion` | 3 | `reject`, F-07 must not write |

## 5. Identity, qualification, and result binding

`admit_board` is the only identity resolver. Its input is a verified observation plus `PAY-01`, `PAY-02`, and every qualification record referenced by the exact candidate. It performs ordered exact matching on the signed board ID, SoC identity, normalized device-tree identity digest, firmware schema, lifecycle, and capability IDs. A chip family, `aarch64`, `uname -m`, DMI text, PCI ID, GPU vendor, or one compatible token is diagnostic evidence only. Unknown, ambiguous, unsupported, stale, invalid, unqualified, or cross-board/cross-manifest results are terminal rejects before inventory, package lookup, source access, privilege, or mutation.

The required identity result contains the exact board ID, SoC identity, normalized device-tree identity digest, firmware schema, registry document ID and payload digest, manifest document ID and payload digest, operation, scope, target ID, schema-set digest, binding identity, authority context digest, and the complete qualification provenance. The computed identity and admission result digests include qualification provenance in sorted stable-document order. A qualification record that names a different board, profile, candidate, manifest, test run, or evidence receipt returns `QUALIFICATION_NOT_BOUND`; it cannot downgrade to `unknown` or `not_applicable` after a required capability has been selected.

## 6. Boot handoff and health evaluation

The product boot handoff is `Trusted<BootContext> + VerifiedClock + Trusted<boot-health/v1> + Trusted<boot-success-mark/v1> -> evaluate_boot_health -> product evidence result`. The product does not construct `Trusted<BootContext>`, write a success mark, select a slot, increment a counter, authorize rollback, or promote a candidate. The boot backend and F-07 remain the authorities for those actions.

`Trusted<BootContext>` must expose the verified context identity, board ID, candidate manifest document ID and payload digest, source generation, active slot, target generation, lineage, boot counter, required-check-set digest, verified clock ID, issued-at, expiry, and source evidence digest. `evaluate_boot_health` consumes only that typed context and the two typed boot payloads; a plain JSON marker, shell variable, journal flag, or success string is not a boot context.

| Comparison ID | Exact comparison before `healthy` or `success` result |
| --- | --- |
| `BOOT-01` | `context.board_id == admission.board_id == plan.board_id` and all board identities resolve to the same `PAY-01` document and payload digest |
| `BOOT-02` | `context.manifest_document_id == health.manifest_document_id == success.manifest_document_id == admission.manifest_document_id` and payload digests are byte-equal |
| `BOOT-03` | `context.slot == health.slot == success.slot == transaction.target_slot`; any unknown or changed slot is `BOOT_TUPLE_MISMATCH` |
| `BOOT-04` | `context.generation == health.generation == success.generation == transaction.target_generation`; target generation must be greater than the predecessor generation |
| `BOOT-05` | `context.source_generation == health.source_generation == success.source_generation == transaction.source_generation`; the source generation is recorded, never inferred from a marker |
| `BOOT-06` | `context.lineage == health.lineage == success.lineage == transaction.target_lineage`, and target lineage names the exact rollback predecessor |
| `BOOT-07` | `context.counter == health.counter == success.counter == transaction.expected_counter`, where `expected_counter = predecessor.counter + 1`; reset, decrement, gap, or duplicate counter is `BOOT_TUPLE_MISMATCH` |
| `BOOT-08` | `health.required_checks_digest == success.required_checks_digest == manifest.required_checks_digest`, and every required check has an independently verified pass receipt |
| `BOOT-09` | `VerifiedClock` is fresh for all records, `issued_at <= observed_at <= expires_at`, replay nonce/counter is unused, and no record predates the transaction source generation |
| `BOOT-10` | `success` is accepted only after `health` is verified and the backend reports the exact transaction ID; a product-generated or embedded success string is never accepted |

`evaluate_boot_health` returns `healthy`, `success`, `failed`, or `pending` only as a product evidence result with the exact code/path/phase/status. It never returns a promotion authority. F-07 alone consumes the signed digest-addressed evidence bundle and writes stable-channel promotion. A product update route that attempts to write a success or promotion marker is `FORBIDDEN_ROUTE` at `route.authorize`, phase `authorize`, process status 2.

## 7. I-03/I-04 typed executor handoff

The product-to-installer handoff is a closed typed transaction named `P01.ExecutorRequest/v1`; I-03 validates and owns the install-side admission boundary, and I-04 owns the irreversible executor and durable journal. The product may produce a read-only plan and final-consent evidence, but it cannot execute the request or resume it by trusting product-local state.

| Request field | Exact contents and rule |
| --- | --- |
| `transaction_id` | UUID generated once by the executor boundary; never reused, copied into every journal and result, and never chosen by a route caller |
| `operation` and `scope` | Closed values from 4.3, identical to the admitted plan and handle |
| `owner_proof` and `target_account` | Independently verified receipts from `IN-04` and `IN-05`, bound to the same operation, scope, exact target, plan digest, uid, expiry, and replay identity |
| `target_ids` | Exact board, SoC, device-tree identity digest, firmware schema, disk, volume, boot target, slot, generation, lineage, and account IDs; revalidated before every irreversible step and again before commit |
| `verified_cache` | Content-addressed entries `{artifact_id, content_digest, payload_digest, size, verification_receipt_digest, schema_set_digest, binding_identity, source_generation, expires_at}`; all required entries exist and verify before consent |
| `plan_digest` | Exact digest of the verified plan and its immutable mutation list; an executor never recomputes a new plan from command arguments |
| `final_consent_receipt` | `{receipt_id, owner/account identity, operation, scope, target_ids, plan_digest, mutation_list_digest, issued_at, expires_at, nonce, replay_counter, decision=consent}` from the final consent boundary; `owner-approval/v1` alone is not final consent |
| `mutation_list` | Ordered steps `{step_id, primitive_id, target_ids, input_digests, precondition_digest, postcondition_digest, irreversible, rollback_action}`; no unknown primitive or undeclared step is accepted |
| `journal_id` and `resume_state` | Durable executor journal ID, chain digest, current state, last completed step, predecessor state, retry count, and tombstone/quarantine state; state is re-derived from the journal on resume |
| `boot_lineage` | Predecessor slot/generation/lineage/counter plus target slot/generation/lineage/counter, exactly matching the admission and boot handoff |

No network fetch, package operation, configuration write, firmware write, DTB write, boot selection, disk/APFS mutation, or system-state mutation occurs before final consent. Cache verification, read-only observation, and consent rendering may happen before it; durable reservation begins only after consent is verified. After consent, stable execution uses the verified cache and exact plan, not the network. Every irreversible step performs target-ID revalidation immediately before the primitive and postcondition verification immediately after it. A mismatch returns `TARGET_REVALIDATION_FAILED` at `executor.verify`, phase `verify`, process status 3 and enters the recovery table.

The executor result is `P01.ExecutorResult/v1` with `{transaction_id, journal_id, operation, scope, plan_digest, mutation_list_digest, target_ids, qualification_provenance, state, code, path, phase, process_status, completed_steps, rollback_state, boot_lineage, result_digest}`. It cannot contain a product-generated success marker or promotion authority. Missing cache is `CACHE_MISS` at `executor.preflight`, phase `preflight`, process status 4; missing or expired final consent is `CONSENT_MISSING` at `executor.consent`, phase `consent`, process status 4; an unwritable or divergent journal is `JOURNAL_FAILURE` at `executor.reserve`, phase `reserve`, process status 7.

## 8. Closed route and call-graph manifest

The route manifest below is the complete product integration census for the current relevant install, apply, provision, channel, update, upgrade, firmware, package, refresh, migration, debug, admission, platform, and leaf-runner paths. The manifest is a closed call graph and is the authority for coverage; grep-style absence checks are not proof. Existing command metadata and `bin/omarchy` discovery remain the repository route authority. The platform registry is not a second command registry.

| Route ID | Current or proposed path | Class | Call-graph role | Exact authorization and terminal rejection |
| --- | --- | --- | --- | --- |
| `ROUTE-01` | `install.sh` | adapter | `install -> admission.open -> platform broker -> I-03/I-04` | `install/platform-system` and `install/platform-hardware` handles; pre-consent package/network behavior is forbidden and missing identity returns `TRUST_FAILURE` |
| `ROUTE-02` | `bin/omarchy-mac-setup` | adapter | `setup -> admission.open -> I-03/I-04` | exact setup plan, owner proof, target account, cache, final consent, and root scope; `--repo`, `--ref`, dynamic steps, and stale markers are rejected |
| `ROUTE-03` | `bin/omarchy-apply-system` | adapter | hidden apply route -> `apply-system` handle -> broker | retains `# omarchy:hidden=true`; no visible group entry; root scope and exact plan required |
| `ROUTE-04` | `bin/omarchy-apply-hardware` | adapter | hidden apply route -> `apply-hardware` handle -> broker and I-04 | retains `# omarchy:hidden=true`; DTB envelope required; product never writes DTB |
| `ROUTE-05` | `bin/omarchy-provision-owner` | adapter | hidden provision route -> `provision-owner` -> I-03 | retains `# omarchy:hidden=true`; root scope, exact target account, and owner proof required |
| `ROUTE-06` | `bin/omarchy-provision-user` | adapter | hidden provision route -> `provision-user` -> user executor | retains `# omarchy:hidden=true`; user scope must match journal owner; root invocation is `PRIVILEGE_MISMATCH` |
| `ROUTE-07` | `bin/omarchy-provision-first-run` | adapter | hidden first-run route -> `first-run` -> user executor | retains `# omarchy:hidden=true`; retry marker is evidence only and must revalidate the plan and target |
| `ROUTE-08` | `bin/omarchy-channel-set` | adapter | channel intent -> manifest-bound `channel-set` update | stable/rc/edge require an exact signed candidate; `dev` is `FORBIDDEN_ROUTE` and cannot enter the stable call graph |
| `ROUTE-09` | `bin/omarchy-update` | adapter | stable update -> admission -> I-04 -> boot evaluation | exact `platform-update` plan, cache, consent, and boot tuple; ignored snapshot or ignored restart is not completion |
| `ROUTE-10` | `bin/omarchy-update-system-pkgs` | adapter | package step -> broker -> package primitive | requires a declared plan step and handle; filtered-empty required package is `CACHE_MISS` or `PLAN_MISMATCH`, never successful skip |
| `ROUTE-11` | `bin/omarchy-update-dev` | development-only | mutable checkout research route | never reachable from stable `update`; a stable caller receives `FORBIDDEN_ROUTE`, and no compatibility or support result is inferred |
| `ROUTE-12` | `bin/omarchy-update-firmware` | forbidden | current raw fwupd/EFI mutation path | raw firmware refresh and copied EFI writes are forbidden; only a future manifest-bound executor step may replace it |
| `ROUTE-13` | `bin/omarchy-reinstall-pkgs` | adapter | reinstall intent -> plan -> broker -> package primitive | stable candidate and exact package plan required; raw stable-channel selection is not authorization |
| `ROUTE-14` | `bin/omarchy-update-restart` | adapter | post-update health/restart evidence | restart is a declared postcondition; `true` suppression cannot close a required transaction |
| `ROUTE-15` | `bin/omarchy-upgrade-to-quattro-mac` | adapter | upgrade intent -> admission -> I-03/I-04 | `--yes` and `--reboot` are consent/UI options only; arbitrary `--ref`, raw script fetch, and mutable checkout replacement are `FORBIDDEN_ROUTE` |
| `ROUTE-16` | `bin/omarchy-pkg-add` | adapter | package intent -> declared plan step -> broker | exact package/provider/capability and requiredness from manifest; no direct pacman and no required-package skip |
| `ROUTE-17` | `bin/omarchy-pkg-drop` | adapter | removal intent -> declared plan step -> broker | exact installed target IDs and rollback action; raw package removal is forbidden |
| `ROUTE-18` | `bin/omarchy-refresh-pacman` | adapter | source refresh intent -> manifest-bound broker step | exact signed source plan and root broker only; current direct `cp`/pacman route cannot be a stable authority |
| `ROUTE-19` | `bin/omarchy-refresh-config` | adapter | config intent -> bounded user/system primitive | source must be under `$OMARCHY_PATH/config` and target under the allowed config root; `..`, absolute caller paths, symlinks, and missing `OMARCHY_PATH` are rejected |
| `ROUTE-20` | `bin/omarchy-migrate` | adapter | named migration -> migration admission -> one marker-after-success step | exact migration ID, plan digest, scope, and marker postcondition; a fallback path or pre-marked migration is not success |
| `ROUTE-21` | `bin/omarchy-debug` | adapter | read-only diagnostics -> local projection -> explicit upload consent | local export uses the allowlist in 11.3; current world-readable log and upload behavior cannot be the product contract |
| `ROUTE-22` | `bin/omarchy-admission` | stable | public `open/check/close/status` -> one verifier adapter | exact first-80-line metadata in 8.1; adapter never escalates, never mints `Trusted<T>`, and issues a handle only after every hold clears |
| `ROUTE-23` | `omarchy-platform` | privileged-broker | adapter -> constrained broker -> I-04 primitives | not present; future broker accepts only typed request, exact handle, immutable plan/cache, and final consent; root/raw calls outside it remain residual |
| `ROUTE-24` | `install/helpers/logging.sh` and sourced leaves | adapter | leaf runner -> per-step handle check -> primitive | a leaf is not authority; direct `source`, `bash`, copied leaf, or environment-only handle is `FORBIDDEN_ROUTE` |
| `ROUTE-25` | direct, routed, copied, generated, or dynamic invocation forms | forbidden | hostile call-graph edges | each form maps to a fixture in 12 and must terminate before mutation with its exact code/path/phase/result |

### 8.1 Proposed `bin/omarchy-admission` metadata and grammar

The proposed executable must begin within its first 80 lines with this exact metadata shape. This is a future implementation contract, not a present artifact:

```bash
#!/bin/bash

# omarchy:summary=Open and verify typed platform admission transactions
# omarchy:group=admission
# omarchy:args=[open|check|close|status] [--operation OP] [--scope SCOPE] [--bundle-dir DIR] [--plan FILE] [--owner-proof FILE] [--target-account FILE] [--trust-context FILE] [--policy FILE] [--resume TXN] [--handle HANDLE] [--step STEP] [--json]
# omarchy:examples=omarchy admission status
```

The command grammar is closed: one subcommand; `open` accepts the bounded file and operation/scope options from 4.1; `check` accepts exactly `--handle`, one declared `--step` or `--complete`, and the expected step/postcondition digest; `close` accepts exactly `--handle` and one outcome from `completed`, `completed_with_optional_gaps`, `failed`, `rolled_back`, or `aborted`; `status` accepts no mutating option and uses `read-only`. Unknown options, duplicated options, arbitrary environment semantics, `--at`, `--board`, `--assume-apple`, `--ref`, raw URL, or shell command arguments return `ADMISSION_USAGE` or `FORBIDDEN_ROUTE` as specified in 4.4.

The `admission` group must be added to the authoritative `GROUP_DESCRIPTIONS` in `bin/omarchy` when the command is implemented. No second group registry is permitted. Existing `apply` and `provision` commands retain their hidden metadata and may remain routed without a group description. Command metadata still scans only the first 80 lines, uses the repository's supported keys, and keeps the filename route aligned with the declared group and name.

## 9. F-06/F-07 evidence handoffs

The product does not refer to a prose section as promotion input. The exact artifact IDs below are the proposed handoff contracts and remain `HOLD-03`/`HOLD-04` until their owners ratify them. F-07 is the sole stable-channel writer. P-03 and P-05 produce evidence only; neither product artifact is a manifest, a qualification record, a boot authority, or a promotion decision.

| Handoff ID | Artifact ID and document ID grammar | Required payload and digest preimages | Producer | Consumer | Freshness and bindings | Rejection code/path/phase/result |
| --- | --- | --- | --- | --- | --- | --- |
| `HANDOFF-01` | `P03.PARITY-CENSUS.V1`; document ID `p03.parity.v1:candidate_id:revision_decimal` | canonical payload excludes digest fields; `payload_digest = SHA-256(CONCAT(UTF8("omarchy.payload.v1\\0"), UTF8("P03.PARITY-CENSUS.V1"), UTF8("\\0"), JCS(payload_without_digests)))`; `content_digest = SHA-256(CONCAT(UTF8("omarchy.content.v1\\0"), UTF8(document_id), UTF8("\\0"), canonical_envelope_bytes))` | P-03 product census generator | F-07 through the ratified F-06 intake | board/profile, candidate, manifest, qualification, schema-set, binding, authority, and verified-clock bindings; expires with candidate and cannot be replayed across board or candidate | missing/mismatched intake is `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, process status 4, `hold` |
| `HANDOFF-02` | `P05.UPDATE-EVIDENCE.V1`; document ID `p05.update.v1:transaction_id:revision_decimal` | same exact preimage framing with artifact ID `P05.UPDATE-EVIDENCE.V1`; payload includes transaction, plan, mutation, cache, owner/account, boot-health, success-mark, slot, generation, lineage, counter, and rollback evidence digests | P-05 product evidence producer | F-07 through the ratified F-06 intake | exact board, candidate, manifest, qualification, transaction, health, lineage, slot, generation, counter, and verified-clock bindings; evidence is immutable and expires with transaction policy | a mismatch is `PROMOTION_INTAKE_INVALID` at `promotion.intake`, phase `promotion`, process status 3, `reject`; F-07 does not write |
| `HANDOFF-03` | `F06.COMPLIANCE-INTAKE.V1`; document ID `f06.compliance.v1:candidate_id:revision_decimal` | canonical compliance payload uses the same explicit `payload_digest` and `content_digest` preimages recorded in its ratification receipt; it includes the exact product evidence document IDs and digests, owner decision-log entry, conformance receipt, qualification refs, and required-slice closure | F-06 compliance owner | F-07 promotion terminal | candidate/manifest/qualification/transaction/health/lineage bindings, authority/policy version, schema-set/binding digest, verified clock and expiry | absent, unratified, stale, or mismatched is `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, process status 4, `hold` |
| `HANDOFF-04` | `F07.PROMOTION-EVIDENCE.V1`; document ID `f07.promotion.v1:candidate_id:revision_decimal` | exact candidate evidence payload and its ratification receipt; content and payload digest preimages are those ratified by F-07, never inferred from a section reference; product data remains nested evidence | F-07 promotion terminal | stable-channel release writer owned by F-07 | exact candidate, manifest, board/profile, qualification, transaction, health, lineage, slot, generation, counter, authority, and policy bindings; one candidate and one immutable revision per decision | invalid intake is `PROMOTION_INTAKE_INVALID` at `promotion.intake`, phase `promotion`, process status 3, `reject`; product cannot override or write promotion |

The product records the artifact ID, document ID, content digest, payload digest, schema-set digest, binding identity, producer, consumer, verified clock, freshness, and decision-log/conformance references in its evidence result. It does not manufacture F-06 or F-07 authority fields. A product output is evidence only, and a missing F-07 artifact remains `NOT IMPLEMENTED` in section 13.

## 10. Total recovery and rollback

Recovery is a closed state machine. `MAX_RECOVERY_ATTEMPTS = 3` is numeric and applies per durable transaction ID. `transaction_id` is never reused. Resume re-derives state from the journal, revalidates all exact target and artifact identities, and issues no authority from carried process memory. A second rollback attempt is forbidden: `rollback_depth` may reach 1 only; a rollback failure enters quarantine and tombstone rather than recursive rollback.

| State ID | State | Durable meaning and allowed next state |
| --- | --- | --- |
| `STATE-01` | `pending_consent` | verified read-only plan exists; cancel or consent only |
| `STATE-02` | `consented` | final consent receipt is durable and fresh; reserve or abort only |
| `STATE-03` | `reserved` | exact transaction and target IDs reserved after consent; apply or recover only |
| `STATE-04` | `applying` | one declared mutation step is active; verify, interrupted, or recover only |
| `STATE-05` | `verifying` | postcondition and target identity are being checked; next commit, recover, or quarantine |
| `STATE-06` | `committed` | atomicity boundary completed and target generation/slot is recorded; health evaluation only |
| `STATE-07` | `recovering` | rollback or resume action is active with `rollback_depth <= 1`; verify or terminal only |
| `STATE-08` | `rolled_back` | exact predecessor restored and verified; close or quarantine only |
| `STATE-09` | `quarantined` | no further mutation permitted; operator evidence and abort/tombstone only |
| `STATE-10` | `aborted` | transaction ended without success; journal and evidence retained; no resume |
| `STATE-11` | `tombstoned` | terminal identity permanently closed; no handle, resume, rollback, or mutation |

| Event ID | Event | From | Action and result |
| --- | --- | --- | --- |
| `EVENT-01` | `open_verified` | none | create `pending_consent` with exact input/result digests; unknown dependency holds before this state |
| `EVENT-02` | `consent_accepted` | `pending_consent` | verify final consent and move to `consented`; missing/expired receipt is `CONSENT_MISSING` |
| `EVENT-03` | `cancel_before_consent` | `pending_consent` | write `aborted` with `USER_CANCELLED_BEFORE_CONSENT`; no executor mutation or journal reservation |
| `EVENT-04` | `reserve_verified` | `consented` | create durable `reserved` record after target/cache/privilege revalidation |
| `EVENT-05` | `step_started` | `reserved`, `applying` | move to `applying` only for a declared step with exact target IDs |
| `EVENT-06` | `step_verified` | `applying` | move to `verifying`; postcondition and target revalidation are mandatory |
| `EVENT-07` | `commit_verified` | `verifying` | atomically commit exact target generation and slot, then move to `committed` |
| `EVENT-08` | `health_passed` | `committed` | `evaluate_boot_health` verifies all BOOT comparisons and closes as evidence; no product promotion |
| `EVENT-09` | `health_failed` | `committed`, `verifying` | move to `recovering` with exact predecessor, unless rollback depth or identity rules fail |
| `EVENT-10` | `cancel_after_reserve` | `reserved`, `applying`, `verifying` | stop at the atomic boundary and rollback exactly once; result is `USER_CANCELLED_AFTER_RESERVE` |
| `EVENT-11` | `power_loss_or_process_loss` | any nonterminal state | re-open as `recovering` with `POWER_LOSS_INTERRUPTED`; rederive the last durable step |
| `EVENT-12` | `rollback_verified` | `recovering` | restore predecessor slot/generation/lineage/counter and move to `rolled_back` |
| `EVENT-13` | `retry_exhausted_or_rollback_failed` | `recovering` | increment attempts; at attempt 3 or rollback failure move to `quarantined`, then tombstone |
| `EVENT-14` | `unknown_or_impossible` | any state | perform no inferred action; write `UNKNOWN_EVENT`, quarantine, and tombstone after preserving evidence |

The atomicity boundary is the I-04 backend's durable commit of the staged content, exact inactive/active target identity, boot selection request, and journal commit record. Before that boundary, an interrupted step must either prove no visible mutation or use the one exact rollback action. After it, health evaluation and rollback use the recorded predecessor; neither product code nor a stale marker invents a predecessor. Slot, generation, lineage, and counter comparisons are the BOOT-03 through BOOT-07 rules. Tombstone/quarantine records include transaction ID, journal chain digest, last state, attempt count, predecessor, exact failure code/path/phase, and redacted evidence only.

## 11. UX, accessibility, privacy, and user-visible outcomes

The UX consumes typed results and never renders a green completion state from a warning, skipped required action, missing marker, or zero exit alone. Every outcome below has an exact machine result and an exact user-visible result. The screen-reader and keyboard path has the same state transitions and cannot expose a hidden recovery action.

| UX case | Machine result | User-visible result and accessibility rule |
| --- | --- | --- |
| Cancel before final consent | `USER_CANCELLED_BEFORE_CONSENT`, `executor.consent`, `consent`, status 4, `aborted` | `Cancelled before changes. Nothing was mutated.` Focus returns to the operation; the cancel and confirm controls have labels, keyboard order, and screen-reader names |
| Cancel after reserve | `USER_CANCELLED_AFTER_RESERVE`, `recovery.cancel`, `recover`, status 4, `aborted` only after verified rollback | `Cancellation requested; the system is verifying rollback.` No success state is shown until rollback or quarantine is terminal; progress is exposed through an accessible live region |
| Offline or cache miss | `CACHE_MISS`, `executor.preflight`, `preflight`, status 4, `hold` | `Required verified content is unavailable offline. No changes were made.` The retry action is keyboard reachable and cannot fetch an arbitrary URL |
| Disk full | `DISK_FULL`, `executor.apply`, `apply`, status 4, `reject` | `The operation stopped because the target is full. Recovery is required.` The result keeps the journal and names resume/rollback; no false completion or reboot prompt |
| Wrong target at admission | `TARGET_ID_MISMATCH`, `admission.identity`, `identity`, status 3, `reject` | `The selected target is not the verified target. No mutation was authorized.` Exact target identity is announced without exposing raw serials |
| Wrong target at irreversible step | `TARGET_REVALIDATION_FAILED`, `executor.verify`, `verify`, status 3, `reject` | `The target changed before a protected step. The transaction is preserved for recovery.` Exact target identity is announced without exposing raw serials |
| Interrupted recovery | `POWER_LOSS_INTERRUPTED`, `recovery.resume`, `recover`, status 4, `hold` | `Recovery is pending for the redacted transaction identifier. Choose resume, rollback, or abort.` The same actions are available by keyboard and screen reader; no automatic recursion |
| Unknown or impossible event | `UNKNOWN_EVENT`, `recovery.dispatch`, `terminal`, status 9, `quarantined` | `Recovery entered a safe terminal state. Support evidence is available; no further changes will be attempted.` |
| Missing accessible control | `ACCESSIBILITY_UNAVAILABLE`, `ux.render`, `authorize`, status 4, `hold` | `This operation cannot safely continue without an accessible control path.` No mutation starts and no control is hidden from keyboard or assistive technology |
| No false success | no success code; any required gap remains `required_blocked` represented by `PLAN_MISMATCH`, `HEALTH_REQUIRED_CHECK_FAILED`, or another exact registry code | Only `Applied and verified`, `Completed with optional gaps`, `Rolled back`, `Aborted`, `Quarantined`, or a named hold/reject may be shown; `Install complete` and `Update complete` require all required postconditions |
| Support bundle redaction failure | `SUPPORT_BUNDLE_REDACTION_FAILED`, `diagnostics.export`, `privacy`, status 3, `reject` | `Diagnostics were not saved because sensitive data could not be removed.` No raw bundle is persisted or uploaded |
| Unratified privacy policy | `PRIVACY_POLICY_UNRATIFIED`, `diagnostics.policy`, `privacy`, status 4, `hold` | `Upload is unavailable until the privacy policy is ratified. A conservative local result may remain available.` |
| Upload declined or endpoint not allowed | `FORBIDDEN_ROUTE`, `route.authorize`, `authorize`, status 2, `reject` | `Upload was not requested or the endpoint is not approved. The local bundle remains available.` |

### 11.1 Keyboard and screen-reader contract

Every operation has a visible focus order of target summary, exact scope, plan summary, required/optional capability result, consent, cancel, and recovery actions. Every status transition uses a text label and live-region announcement; color, audio, timer, and motion never carry the only meaning. `Esc` or an explicit Cancel action maps to the cancellation event at the current state. Resume, rollback, and abort are separate controls with the same exact transaction ID and result code, and their disabled state is exposed programmatically. A keyboard or screen-reader implementation that cannot preserve this contract returns `ACCESSIBILITY_UNAVAILABLE` before consent.

### 11.2 Support-bundle field allowlist and redaction

Redaction happens before journal, log, local bundle, or upload persistence. The allowlist is closed to these fields: `result_schema`, adapter identity, operation, scope, route ID, transaction ID pseudonym, journal chain digest, exact code/path/phase/process status, decision, safe next action, artifact IDs, document IDs, content/payload/schema/binding digests, authority and policy versions, verified-clock ID and quantized times, capability IDs/status/reason code, board/profile IDs when policy permits, and pseudonymized target/owner/account IDs. Raw account names, UIDs, owner proof contents, target serials, disk paths, volume paths, environment values, access tokens, private keys, handles, MAC keys, package credentials, URLs with query secrets, command output containing secrets, and raw device-tree or firmware identifiers are never persisted.

The local default is a redacted file with mode 0600 and a 30-day retention timer; user deletion removes the local bundle and its index immediately. Upload is opt-in after a second explicit consent, uses only `https://logs.omarchy.org/v1/support-bundles` over verified TLS, rejects redirects and every other endpoint, and carries only the allowlist. The proposed remote retention is 24 hours with server-side deletion evidence. F-06/F-07 or I-08 may ratify a stricter policy, but until the privacy policy owner supplies its ratification receipt, upload returns `PRIVACY_POLICY_UNRATIFIED` and local-only conservative export is the only available outcome. A policy hold never authorizes a broader field set.

## 12. Enforcement and hostile fixtures

The enforcement promise is a closed route/call-graph manifest plus a privileged mutation boundary, not a grep-style assertion. The future boundary is: public route validates metadata and routes to the adapter; the adapter validates typed inputs and handle; the constrained `omarchy-platform` broker validates handle, plan, cache, consent, target IDs, and step; each privileged primitive validates the same live transaction immediately before mutation and writes its postcondition. Generated and copied code must be compiled or invoked through the same broker, and direct leaf sourcing is forbidden.

Root/raw writes remain an implementation residual. Bash cannot prove that a root actor outside the broker is physically incapable of writing a system path, so the design never claims that impossibility. The supported product graph must nevertheless reject every listed route and fixture before mutation, and CI must prove each primitive guard by planting the violation and observing the exact terminal result.

| Fixture ID | Hostile form | Expected code/path/phase/process status/result |
| --- | --- | --- |
| `FIX-01` | direct `pacman` or package primitive without handle | `HANDLE_INVALID` / `admission.check` / `verify` / 8 / `reject`, no package mutation |
| `FIX-02` | routed public package command with forged or closed handle | `HANDLE_INVALID` / `admission.check` / `verify` / 8 / `reject`, no package mutation |
| `FIX-03` | copied install or sourced leaf with environment-only handle | `FORBIDDEN_ROUTE` / `route.authorize` / `authorize` / 2 / `reject`, no leaf mutation |
| `FIX-04` | generated wrapper that bypasses the declared broker | `FORBIDDEN_ROUTE` / `route.authorize` / `authorize` / 2 / `reject`, no broker call |
| `FIX-05` | dynamic `eval`, `source` of adapter output, `bash -c` consumer, or unquoted result dispatch | `FORBIDDEN_ROUTE` / `route.authorize` / `authorize` / 2 / `reject`, no child process |
| `FIX-06` | raw network fetch or pipe-to-shell upgrade | `FORBIDDEN_ROUTE` / `route.authorize` / `authorize` / 2 / `reject`, no network or mutation |
| `FIX-07` | raw package lookup/install before consent or required-package filtering | `CONSENT_MISSING` / `executor.consent` / `consent` / 4 / `hold`, no package action |
| `FIX-08` | raw firmware/EFI write or unmanifested firmware update | `FORBIDDEN_ROUTE` / `route.authorize` / `authorize` / 2 / `reject`, no firmware action |
| `FIX-09` | missing `OMARCHY_PATH` or attempted fallback to a packaged path | `OMARCHY_PATH_MISSING` / `route.bootstrap` / `bootstrap` / 2 / `reject`, no fallback read |
| `FIX-10` | `refresh-config` with `../`, absolute caller path, symlink, or target escape | `PATH_TRAVERSAL` / `route.parse` / `parse` / 2 / `reject`, no read or write |
| `FIX-11` | arbitrary upgrade `--ref`, dev channel, or stable-to-dev route | `FORBIDDEN_ROUTE` / `route.authorize` / `authorize` / 2 / `reject`, no checkout or channel mutation |
| `FIX-12` | unknown board identity | `TRUST_FAILURE` / `admission.verify` / `verify` / 3 / `reject`, no identity or handle |
| `FIX-13` | ambiguous board identity | `TRUST_FAILURE` / `admission.verify` / `verify` / 3 / `reject`, no identity or handle |
| `FIX-14` | cross-board or cross-manifest payload transplant | `BINDING_MISMATCH` / `admission.verify` / `verify` / 3 / `reject`, no handle |
| `FIX-15` | stale or unqualified qualification record | `QUALIFICATION_NOT_BOUND` / `admission.identity` / `identity` / 3 / `reject`, no handle |
| `FIX-16` | forged or embedded boot-success mark | `BOOT_TUPLE_MISMATCH` / `boot.evaluate` / `verify` / 3 / `reject`, no success result |
| `FIX-17` | reset, decrement, gap, or duplicate boot counter | `BOOT_TUPLE_MISMATCH` / `boot.evaluate` / `verify` / 3 / `reject`, no success result |
| `FIX-18` | changed target ID immediately before an irreversible step | `TARGET_REVALIDATION_FAILED` / `executor.verify` / `verify` / 3 / `reject`, journal preserved |
| `FIX-19` | missing or expired content-addressed cache entry | `CACHE_MISS` / `executor.preflight` / `preflight` / 4 / `hold`, no network or mutation |
| `FIX-20` | power loss or process loss during an open transaction | `POWER_LOSS_INTERRUPTED` / `recovery.resume` / `recover` / 4 / `hold`, resume/rollback/abort required |
| `FIX-21` | support bundle containing a field outside the redaction allowlist | `SUPPORT_BUNDLE_REDACTION_FAILED` / `diagnostics.export` / `privacy` / 3 / `reject`, no persistence or upload |

The expected fixture results are design requirements only. `bin/omarchy-admission`, `omarchy-platform`, schemas, bindings, and fixtures are absent in this slice, so none of these 21 fixtures is executable or a PASS. A missing executable produces `NOT IMPLEMENTED`, never a fabricated typed rejection.

## 13. Absent implementation and evidence residuals

Each absent artifact is tracked separately. Acceptance requires the named immutable artifact and its digest, not a claim that a future file exists. The due-before gate is the first gate allowed to consume it; while absent, the listed fail-closed effect applies.

| Residual ID | Absent artifact | Owner | Consumer | Acceptance artifact and digest | Due before | Fail-closed effect |
| --- | --- | --- | --- | --- | --- | --- |
| `RES-01` | admission command `bin/omarchy-admission` | omarchy-mac P-01/P-02 | all product routes | executable at immutable commit plus `P01.AdmissionGateReceipt/v1` content digest and hostile-fixture receipt | P-01 | no admission, handle, or typed route result; `NOT IMPLEMENTED` |
| `RES-02` | platform backend and constrained `omarchy-platform` broker | I-04 installer/recovery owner | P-05 and every privileged primitive | `P01.ExecutorResult/v1` conformance artifact plus broker binary/source commit and content digest | P-05 | no network/package/config/APFS/firmware mutation is authorized |
| `RES-03` | canonical schemas and schema-set lock | F-02 owner | generated verifier and all payload consumers | ratification receipt with canonical commit, schema-set digest, preimage, and owner decision-log digest | P-01 | `DEPENDENCY_UNRATIFIED` before parse or handle |
| `RES-04` | generated bindings and output lock | F-02/F-03 owners | adapter, executor, boot evaluator | generated binding identity and output-lock digest plus conformance receipt | P-01 | `DEPENDENCY_UNRATIFIED` before binding load |
| `RES-05` | hostile fixture corpus | omarchy-mac P-02 and CI owner | route/broker/primitive gates | 21 fixture files, expected result manifest, and corpus digest | P-02 | missing executable/fixture is `NOT IMPLEMENTED`, never PASS |
| `RES-06` | product-specific CI workflow | omarchy-mac CI owner | P-01 through P-05 and branch protection | immutable workflow commit plus run receipt covering route manifest, bindings, fixtures, privacy, recovery, and generated drift | P-01 integration | no design rule is treated as enforced; integration blocked |
| `RES-07` | generated P-03 parity artifact | P-03 owner | F-06/F-07 and coordinator | `P03.PARITY-CENSUS.V1` document ID and content/payload digests bound to candidate/manifest/qualification | P-03 | F-07 intake rejects; no parity claim |
| `RES-08` | P-05/F-07 update evidence artifact | P-05 owner and F-07 owner | F-07 promotion terminal | `P05.UPDATE-EVIDENCE.V1` and `F07.PROMOTION-EVIDENCE.V1` receipts with exact digest preimages | P-05 and F-07 | `PROMOTION_INTAKE_INVALID` or `DEPENDENCY_UNRATIFIED`; no promotion |
| `RES-09` | qualification records for exact board/profile/candidate | Q-00/Q-01/Q-02 owners | P-01, P-03, P-05, F-07 | `qualification-record/v1` records and evidence receipt digests bound to board, candidate, manifest, and test run | P-01 identity admission | no `qualified` result; `QUALIFICATION_NOT_BOUND` |
| `RES-10` | physical evidence for clean install, boot, hardware, update, interruption, rollback, and recovery | coordinator-owned lab and Q owners | P-05, I-09, F-07 | signed board/profile evidence bundle with exact manifest, transaction, health, lineage, and test digests | physical qualification and release | no support, compatibility, or release claim; status `NOT PRESENT` |
| `RES-11` | branch protection and required checks for the integration/release path | repository owner/coordinator | F-07 and merge gate | live repository protection configuration and immutable required-check receipt | before merge or release | no integration or release; draft remains blocked |

## 14. Existing baseline failures, tracked separately

These baseline failures are not fixed by this docs-only slice and are not evidence against the contract being described. They block integration and require a later baseline repair/QA slice. No result below is green or inferred green.

| Baseline ID | Command and observed failure | Owner and due-before effect |
| --- | --- | --- |
| `BASE-01` | `./test/cli` fails under macOS `/bin/bash` 3.2 because associative-array declarations are unsupported; the hardware-group assertion fails | Omarchy-mac baseline repair owner; repair and rerun before P-01 integration |
| `BASE-02` | `bin/omarchy commands --check` fails under macOS Bash 3.2 with associative-array and expression errors | Omarchy-mac CLI/QA owner; metadata and router baseline must be repaired before route-gate consumption |
| `BASE-03` | `./test/all` reports package/provision/install-mac failures and can hang at the sleep-lock test; the controlled run is not a PASS | Omarchy-mac baseline repair/QA owner; complete a bounded clean-run census before integration |

The shell/Python syntax loop may show parser success for some files, but syntax success is not runtime, route, authority, privacy, recovery, qualification, or release evidence. This file does not claim the baseline is green.

## 15. Design-level checks and gate ownership

The design checks run against the pinned target/base blobs and explicitly exclude the opaque boot boundary. A check that requires an absent executable or unavailable validator is `NOT IMPLEMENTED` or `TOOLING_BLOCK`, never PASS.

| Check | Expected design signal | Owner and gate |
| --- | --- | --- |
| exact target/parent/base and one-file scope | target `19b493c6c1688ec6c7a3c0d27d48144aa02cb369`, exact parent, base `quattro`, only this file | coordinator pre-edit and commit gate |
| `git diff --check` and conflict-marker scan | no whitespace errors, tabs, or conflict markers | every commit |
| Markdown table parser and width census | all table rows have the header column count; declared table counts match actual counts | design gate |
| exact payload/route/state/fixture/residual scan | 8 / 25 / 11 / 21 / 11, unique definition IDs | design gate |
| closed code/path/phase/result scan | every fixture and rejection cites a registry row; unknown is terminal `UNKNOWN_EVENT` | design gate and CI residual `RES-06` |
| required-term scan | holds, owner proof, target account, qualification provenance, DTB consumer, `Trusted<BootContext>`, `VerifiedClock`, final consent, cache, target revalidation, F-06/F-07 IDs, recovery fence, privacy, metadata, and `OMARCHY_PATH` are present | design gate |
| forbidden-claim scan | no compatibility, support, qualification, release, green baseline, or m1n1 characterization claim | coordinator adversarial gate |
| source-to-design route coverage | all 21 current non-opaque command/install paths plus 4 proposed/forbidden paths are in ROUTE-01 through ROUTE-25 | route gate; absent routes are residuals, not PASS |
| hostile fixture status | all 21 expected fixtures are specified; absent executable/corpus is `NOT IMPLEMENTED` | P-02 gate after RES-01/RES-05 |
| external validator availability | unavailable DT/schema/JCS/doc tooling remains `TOOLING_BLOCK` | coordinator report |

Gate ownership is explicit: F-02/F-03 owners ratify schema, trust, authority, and generated outputs; I-03/I-04 owners ratify executor and recovery; Q owners produce qualification; P-01/P-02/P-03/P-04/P-05 owners implement product artifacts; F-06/F-07 owners ratify and consume promotion evidence; the coordinator independently reruns the hostile and full gate battery. Nothing in this design self-marks a gate DONE.

## 16. Handoff and non-claims

This correction closes the design contract at the seams that the first review found open: dependency holds have one deterministic terminal result; admission input and output are typed and complete; all eight payloads have end-to-end source/validator/binding/consumer/freshness/rejection rows; qualification and DTB provenance are bound; boot evaluation is `Trusted<BootContext>` plus `VerifiedClock`; I-03/I-04 have a closed transaction; route/call-graph coverage and metadata/privilege/path rules are explicit; F-06/F-07 have exact artifact IDs and digest preimages; recovery is total; UX/accessibility/privacy are typed; enforcement uses a manifest and broker boundary; residuals and baseline failures are separate.

The contract is still a design handoff, not an implementation or evidence handoff. F-02, F-03, F-06, F-07, I-03, I-04, qualification, physical evidence, CI, and branch protection remain held or absent as recorded above. The product lane does not establish compatibility, support, qualification, release readiness, stable promotion, or physical success. The only completion signal for this lane is the coordinator's external verification after the single atomic commit; this document itself never says DONE.
