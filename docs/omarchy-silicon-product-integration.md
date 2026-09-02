# Omarchy Silicon product integration design (P-01-P-05)

Status: DESIGN CONTRACT ONLY, final bounded correction round 3. This file is non-implementation, non-compatibility, non-support, non-qualification, and non-release material. It changes no production code, schema, binding, fixture, CI workflow, boot artifact, installer behavior, branch protection, or platform behavior. The product routes in live `quattro` remain unimplemented and unsafe relative to this contract.

Identity: correction parent `6238643fe35746bb341738b065a4c19e5a4e5495`; its parent `19b493c6c1688ec6c7a3c0d27d48144aa02cb369`; PR #1 repository `omarchy-silicon/omarchy-mac`; base branch `quattro`; handed-off base commit `95ffbc41a6d5d5356c217e503b51f3f7c3bd80f1`; head branch `factory/design-product-integration`. The program authority is consumed only by its externally supplied exact commit `58302d148f0e8b855578f9aa518ff1c5eb48c515`. F-02, F-03, F-06, F-07, and physical qualification remain gating dependencies.

The `m1n1-omarchy` repository and every m1n1 path are an absolute opaque human-produced boundary. This document does not inspect, read, list, traverse, fetch, clone, browse, test, edit, characterize, or delegate work in that boundary. Any outside boot evidence can enter this contract only as an externally supplied signed hash or metadata envelope treated as an opaque value.

## 1. Contract boundary and non-claims

The product side owns adapters, typed admission, user outcomes, evidence projection, diagnostics projection, and parity census. The platform side owns authenticated payloads, schema locks, trust and authority, generated bindings, candidate assembly, qualification records, boot evidence, and stable promotion. I-03 owns read-only inventory, target identity, exact plan generation, and final consent. I-04 owns the irreversible executor, durable journal, idempotent resume, rollback, and safe return. F-06 owns compliance intake. F-07 is the sole stable-channel promotion writer. These are ownership statements for a future implementation boundary, not evidence that any owner has delivered it.

The design contract is complete only when every field, code, path, phase, state, transition, preimage, route node, fixture, handoff, residual, owner, due gate, and acceptance artifact below is implemented and independently verified at immutable commits. A document, branch, opened pull request, green syntax check, successful desktop boot, architecture string, or coordinator intent is not implementation, compatibility, qualification, or release evidence.

The only allowed current status values are `DESIGN_ONLY`, `HELD`, `NOT_IMPLEMENTED`, `NOT_PRESENT`, `TOOLING_BLOCK`, and `UNSAFE_BASELINE`. No such value is a pass or a DONE signal. A future implementation must fail closed when any required artifact is absent.

The mechanically recomputed census for this document is `PAY=8`, `HOLD=4`, `ROUTE-FAMILY=25`, `STATE=13`, `TRANSITION=44`, `FIXTURE-FAMILY=33`, `FIX-27-SUBCASE=9`, `MATERIALIZED-FIXTURE-CASE=42`, `HANDOFF=4`, `RESULT=10`, `ERROR=64`, `RESIDUAL=15`, and `MARKDOWN-TABLE=13`. These are definition-row counts, not implementation or qualification evidence. The current base census is `SOURCE-NODES=563`, `RELEVANT-ROUTE-MUTATOR-PATHS=123`, and `MENU-ACTION-KEYS=270`; their exact derivations and digests are in section 8.

## 2. Exact upstream authority and dependency holds

The exact externally supplied F-02 candidate vocabulary below is the required contract shape, but F-02 is currently rejected/frozen and not ratified for consumption. The F-03 trust policy, F-06 compliance intake, and F-07 promotion intake are also unratified. Product code must not consume a candidate blob, local alias, handwritten mapping, stale generated output, or prose section as authority.

| Hold ID | Dependency and supplied identity | Owner | Consumers | Due before | Hold result |
| --- | --- | --- | --- | --- | --- |
| `HOLD-01` | F-02 schema and generated binding; candidate comparison blob `c315c7e79928d0041deb582bed79a61074361b21` is non-consumable until ratification | F-02 owner and coordinator | P-01, P-02, P-04, P-05, I-03, I-04 | any schema, binding, fixture, or admission implementation | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, status 4, decision `hold`, no handle, no mutation |
| `HOLD-02` | F-03 trust context, authority role binding, key custody, expiry, rotation, revocation, and offline recovery are unstarted | F-03 owner and coordinator | P-01 through P-05, I-03, I-04, diagnostics | any trust, owner, policy, or role verification | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, status 4, decision `hold`, no handle, no mutation |
| `HOLD-03` | F-06 compliance intake and policy result are unratified | F-06 owner and coordinator | F-07 | any compliance or parity acceptance | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, status 4, decision `hold`, no promotion input |
| `HOLD-04` | F-07 promotion-evidence intake is unratified; F-07 remains the sole stable writer | F-07 owner and coordinator | F-07 promotion terminal | any candidate promotion request | `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, status 4, decision `hold`, no promotion |

### 2.1 Ratification receipt

One immutable receipt is required per consumed dependency. It must contain exactly the following fields; a URL, branch, mutable ref, section citation, local copy, or approval message without these fields does not clear a hold.

```text
RatificationReceipt = {
  receipt_schema: "dependency-ratification/v1",
  receipt_id: LowerAsciiToken,
  dependency_id: "F-02" or "F-03" or "F-06" or "F-07",
  canonical_commit_id: FullCommitId,
  artifact_id: ArtifactId,
  artifact_content_digest: Digest,
  schema_set_digest: Digest,
  generated_output_lock_digest: Digest or null,
  authority_version: Version,
  policy_version: Version,
  generated_binding_identity: BindingIdentity or null,
  conformance_receipt_id: ArtifactId,
  conformance_receipt_digest: Digest,
  owner_decision_log_entry_id: ArtifactId,
  owner_decision_log_entry_digest: Digest,
  trusted_constructor_boundary: ConstructorIdentity,
  ratification_status: "ratified" or "unratified" or "expired" or "mismatch",
  issued_at: Timestamp,
  expires_at: Timestamp
}
```

`artifact_content_digest` is SHA-256 of the exact canonical artifact bytes. The receipt includes the named preimage and encoding for every digest. `generated_binding_identity`, `schema_set_digest`, and `generated_output_lock_digest` are compared byte-for-byte with the consumer lock. `trusted_constructor_boundary` names one immutable implementation ID and digest that returns a nominal trusted value only after strict parse, canonicalization, authentication, context, freshness, replay, and policy checks. A missing, expired, stale, substituted, mixed, or unverifiable receipt returns the single hold result above.

The product slice consumes this exact dependency projection from the supplied program authority commit; it does not invent a shorter path or treat a downstream design as satisfying an upstream node:

```text
PROGRAM_AUTHORITY_GRAPH = {
  F-05: [F-03, F-04, F-06, Q-00, Q-01],
  F-07: [F-05, P-03, P-05, I-09, B-04, Q-04, Q-05, Q-06, Q-07, Q-08],
  P-01: [F-02, Q-00],
  P-02: [P-01],
  P-03: [F-01],
  P-04: [F-02],
  P-05: [F-05],
  P-06: [P-02],
  P-07: [P-05, P-06],
  I-03: [F-02, Q-00, I-01, I-07],
  I-04: [I-02, I-03, I-07],
  I-08: [I-01, I-07, P-04],
  I-09: [Q-00, I-02, I-03, I-04, I-05, I-06, I-07, I-08, P-06, P-07]
}
```

`P-01` therefore cannot clear `HOLD-01` until both F-02 and Q-00 receipts are ratified; `P-05` cannot consume a product result until F-05 is closed; and F-07 cannot accept either product handoff until every listed F-05, P-03, P-05, I-09, B-04, and Q-04 through Q-08 receipt is present, fresh, and terminal. The graph is a prerequisite relation, not a completion assertion.

### 2.2 One trusted constructor seam

There is exactly one future cross-repository construction seam:

```text
construct_trusted<T>(canonical_input, expected_context, verified_clock,
                     ratification_receipt) -> Trusted<T> or TerminalError
```

`Trusted<T>` is a private nominal wrapper. Product code, shell, a fixture, an executor, a journal reader, a support bundle, or a generated binding may not instantiate, deserialize, cast, unwrap, or mint it. A rejected input yields no partially trusted field. Supporting records such as `OwnerProofReceipt`, `TargetAccount`, `Observation`, `VerifiedClock`, `AtomicBootRecord`, and `VerifiedDtbInputs` are not additional payload types and do not create an alternate seam.

## 3. Ratified F-02 capability and boot type mapping

The exact F-02 capability record that this product contract requires a future ratification receipt to ratify is:

```text
ConsumerCapabilities = {
  capabilities_schema: "consumer-capabilities/v1",
  consumer_id: LowerAsciiToken,
  language: "python" or "swift" or "rust-boot",
  consumer_api: ApiVersion,
  api_id: LowerAsciiToken,
  schema_set_digest: Digest,
  generated_binding_identity: {
    binding_id: LowerAsciiToken,
    binding_version: Version,
    binding_source_digest: Digest,
    parser_id: LowerAsciiToken,
    parser_version: Version,
    parser_source_digest: Digest,
    api_id: LowerAsciiToken,
    api_version: Version,
    api_source_digest: Digest
  },
  supported_payload_types: ExactList<PayloadType, payload_type>,
  supported_payload_types_digest: Digest,
  compiled_lock_digest: Digest,
  generated_artifact_id: ArtifactId,
  generated_output_path: RelativeBindingPath,
  generated_output_digest: Digest,
  boot_artifact_id: ArtifactId or null,
  boot_artifact_digest: Digest or null
}
```

The referenced lock and binding identities are closed as follows:

```text
ApiVersion = {major: uint16, minor: uint16, patch: uint16}
BindingIdentity = {
  binding_id: LowerAsciiToken, binding_version: Version, binding_source_digest: Digest,
  parser_id: LowerAsciiToken, parser_version: Version, parser_source_digest: Digest,
  api_id: LowerAsciiToken, api_version: ApiVersion, api_source_digest: Digest
}
GeneratedOutputLock = {
  lock_schema: "generated-output-lock/v1", schema_set_digest: Digest,
  generated_entries: ExactList<GeneratedEntry, language_and_artifact_id>
}
GeneratedEntry = {
  language: "python" or "swift" or "rust-boot", artifact_id: ArtifactId,
  output_path: RelativeBindingPath, binding_identity: BindingIdentity,
  generator_input_id: LowerAsciiToken, parser_input_id: LowerAsciiToken,
  toolchain_input_id: LowerAsciiToken, source_schema_ids: ExactList<SchemaId, schema_id>,
  output_digest: Digest, line_endings: "LF", file_order_digest: Digest,
  bounded_memory_report_digest: Digest, consumer_api: ApiVersion,
  output_role: "parser" or "binding" or "schema-constants" or "boot-binding"
}
CompiledLock = {
  lock_schema: "compiled-binding-lock/v1", schema_set_digest: Digest,
  language: "python" or "swift" or "rust-boot", consumer_api: ApiVersion,
  binding_identity: BindingIdentity, parser_identity: BindingIdentity,
  toolchain_input_id: LowerAsciiToken, source_schema_ids: ExactList<SchemaId, schema_id>,
  generated_artifact_id: ArtifactId, generated_output_path: RelativeBindingPath,
  generated_output_digest: Digest, lock_digest: Digest
}
GeneratedBindingMetadata = {
  metadata_schema: "generated-binding-metadata/v1", language: "python" or "swift" or "rust-boot",
  binding_identity: BindingIdentity, generated_artifact_id: ArtifactId,
  generated_output_digest: Digest, compiled_lock_digest: Digest
}
```

`ApiVersion` is three numeric uint16 components compared lexicographically as `(major, minor, patch)`. `supported_payload_types` is exactly the eight-value set in section 4, in the declared order, with no missing, extra, duplicate, or reordered member; `supported_payload_types_digest = SHA256(FRAME("consumer-capabilities.payload-set/v1", JCS(supported_payload_types)))`. The required manifest binding and consumer capability are compatible only when the schema-set digest, language, API ID and version, parser identity, generated artifact ID/path/digest, compiled lock, boot artifact, payload-set digest, and every supported payload value agree. `load_consumer_capabilities(Trusted<CompiledLock>, Trusted<GeneratedOutputLock>, Trusted<GeneratedBindingMetadata>)` is the only loader. There is no missing-type default, extra-type ignore, mixed-lock selection, parser substitution, output-path substitution, boot-binding substitution, string API comparison, downgrade, or stale-lock fallback.

The exact F-02 boot records are:

```text
AtomicBootRecord = {
  record_schema: "atomic-boot-record/v1",
  record_id: UUID,
  project_id: ProjectId,
  repository_id: RepositoryId,
  slice_id: SliceId,
  board_id: BoardId,
  manifest_id: DocumentId,
  manifest_digest: Digest,
  lineage_id: UUID,
  slot_id: "slot-a" or "slot-b" or "recovery",
  slot_generation: uint64,
  attempt_counter: uint64,
  source_generation: uint64,
  commit_state: "committed",
  bytes_digest: Digest,
  source: SourceEvidence,
  replay_id: UUID
}

BootContext = {
  context_schema: "boot-context/v1",
  board_id: BoardId,
  manifest_id: DocumentId,
  manifest_digest: Digest,
  lineage_id: UUID,
  slot_id: "slot-a" or "slot-b" or "recovery",
  slot_generation: uint64,
  attempt_counter: uint64,
  source_generation: uint64,
  atomic_record_digest: Digest,
  lineage_source_digest: Digest,
  provenance: {
    source_kind: "atomic-boot-journal/v1",
    source_api_version: Version,
    storage_generation: uint64
  }
}
```

The supporting source records used by the F-02 constructor are also closed:

```text
SourceEvidence = {
  evidence_schema: "source-evidence/v1", source_kind: LowerAsciiToken,
  source_id: LowerAsciiToken, adapter_id: LowerAsciiToken, adapter_api_version: Version,
  source_generation: uint64, evidence_digest: Digest, captured_at: Timestamp,
  expires_at: Timestamp, nonce: Nonce, source_record_digest: Digest
}
VerifiedClock = {
  clock_schema: "verified-clock/v1", clock_id: LowerAsciiToken, now: Timestamp,
  source_generation: uint64, monotonic_sequence: uint64, valid_until: Timestamp,
  attestation_digest: Digest
}
BootCheck = {
  check_id: LowerAsciiToken, required: true or false,
  outcome: "pass" or "fail" or "not_run", measurement_digest: Digest,
  evidence_digest: Digest, evaluated_at: Timestamp, expires_at: Timestamp
}
BootHealthCore = {
  document_id: DocumentId, payload_digest: Digest, board_id: BoardId,
  manifest_id: DocumentId, manifest_digest: Digest, profile_id: LowerAsciiToken,
  profile_digest: Digest, lineage_id: UUID, source_generation: uint64,
  slot_id: SlotId, slot_generation: uint64, attempt_counter: uint64,
  checks: ExactList<BootCheck, check_id>, checks_digest: Digest,
  rollback_set_digest: Digest, observed_at: Timestamp, expires_at: Timestamp
}
BootSuccessMark = {
  document_id: DocumentId, payload_digest: Digest, core_digest: Digest,
  board_id: BoardId, manifest_id: DocumentId, manifest_digest: Digest,
  profile_id: LowerAsciiToken, profile_digest: Digest, lineage_id: UUID,
  source_generation: uint64, slot_id: SlotId, slot_generation: uint64,
  attempt_counter: uint64, marker_generation: uint64, marked_at: Timestamp,
  checks_digest: Digest, rollback_set_digest: Digest, marker_replay_id: UUID,
  diagnostic_note: SafeDescription, signatures: ExactList<Signature, key_id>
}
TrustContext = {
  context_schema: "trust-context/v1", context_id: LowerAsciiToken,
  authority_bindings: ExactList<AuthorityRoleBinding, role_and_actor_id>,
  key_set_digest: Digest, revocation_epoch: uint64, issued_at: Timestamp, expires_at: Timestamp
}
AuthorityRoleBinding = {
  binding_schema: "authority-role-binding/v1", authority_id: LowerAsciiToken,
  role: "board-admission" or "manifest-release" or "installer-planner" or "owner-authorization"
        or "ci-conformance" or "qualification-lab" or "boot-runtime" or "dtb-authority" or "evidence-reader",
  actor_id: ActorId, account_id: AccountId, key_ids: ExactList<KeyId, key_id>,
  allowed_methods: ExactList<AuthorizationMethod, method>, service_policy_id: PolicyId,
  service_policy_digest: Digest, issued_at: Timestamp, expires_at: Timestamp,
  binding_digest: Digest
}
```

`verify_boot_context(Trusted<AtomicBootRecord>, Trusted<TrustContext>, VerifiedClock)` is the only constructor. It accepts one complete atomically read trusted record and checks exact bytes and `bytes_digest`, board, manifest, slot, slot generation, monotonic attempt counter, source generation, committed state, expiry, replay reservation, and role `boot-runtime`. A partial read, caller-created record, mutable field, local default, reset, reuse, lower value, missing authenticated source, or failed recomputation returns `TRUST_BOUNDARY_FAILURE` or `BOOT_COUNTER_FAILURE` and no context.

The product mapping is exact and contains no local aliases:

| Product field | F-02 field | Equality and owner | Missing or changed value |
| --- | --- | --- | --- |
| `admission.board_id` | `AtomicBootRecord.board_id`, `BootContext.board_id` | equal to verified board registry and manifest target; F-02 owns source | `BOOT_CONTEXT_MISMATCH` |
| `admission.manifest_document_id` | `manifest_id` | equal to the exact manifest document ID | `BOOT_CONTEXT_MISMATCH` |
| `admission.manifest_payload_digest` | `manifest_digest` | byte-equal in record, context, manifest, health, and marker | `BOOT_CONTEXT_MISMATCH` |
| `boot.lineage_id` | `lineage_id` | equal across record, context, health, marker, and transaction | `BOOT_CONTEXT_MISMATCH` |
| `boot.slot_id` | `slot_id` | one of the three F-02 values and equal to transaction target | `BOOT_CONTEXT_MISMATCH` |
| `boot.slot_generation` | `slot_generation` | uint64 and strictly greater than predecessor for a new target | `BOOT_COUNTER_FAILURE` |
| `boot.attempt_counter` | `attempt_counter` | uint64, committed source value, no reset, gap, duplicate, or wrap | `BOOT_COUNTER_FAILURE` |
| `boot.source_generation` | `source_generation` | equal in atomic record, context, health, marker, and source evidence | `BOOT_CONTEXT_MISMATCH` |
| `boot.atomic_record_digest` | `atomic_record_digest` | digest of the complete authenticated atomic record | `TRUST_BOUNDARY_FAILURE` |
| `boot.lineage_source_digest` | `lineage_source_digest` | digest of the authenticated lineage source, never a local marker | `TRUST_BOUNDARY_FAILURE` |
| `boot.provenance` | `provenance` | exact `atomic-boot-journal/v1`, source API, and storage generation | `TRUST_BOUNDARY_FAILURE` |
| product `context_id` | none | not accepted as authority; a diagnostic reference must be the record digest | `UNKNOWN_FIELD` or `TRUST_BOUNDARY_FAILURE` |
| product clock | `VerifiedClock` | F-02 verified clock is supplied, not caller time | `TRUST_BOUNDARY_FAILURE` |

`evaluate_boot_health(Trusted<BootHealthCore>, Trusted<BootSuccessMark> or None, Trusted<PlatformManifest>, Trusted<BootContext>, VerifiedClock) -> SlotDecision` is the only product health handoff. It checks the exact board, manifest, profile, slot, generation, lineage, source generation, counter, required-check set, check digest, marker core digest, signature context and role, marker generation, verified time, replay reservation, rollback set, and atomic-record length. Missing marker means no success. Product receives evidence only and never constructs context, selects a slot, increments a counter, writes a marker, authorizes rollback, or promotes a candidate.

## 4. Closed authenticated payload registry

The authenticated payload vocabulary is exactly these eight values. The first five are the primary F-02 documents and the last three are auxiliary authenticated payloads. No local ninth type, alternate spelling, owner-specific type, or private extension is valid.

```text
PAYLOAD_TYPES = [
  board-registry/v1,
  platform-manifest/v1,
  installer-plan/v1,
  qualification-record/v1,
  boot-health/v1,
  owner-approval/v1,
  boot-success-mark/v1,
  dtb-mutation-envelope/v1
]
```

Every payload is an `omarchy-signed/v1` envelope with exactly `format`, `payload_type`, `payload_version`, `domain`, `context`, `schema_set_digest`, `payload`, and `signatures`. Every payload object has exactly the common fields `schema`, `schema_set_digest`, `document_id`, `issuer`, `issued_at`, and `expires_at`, followed by its type-specific fields. Every signature has exactly `key_id`, `signer_role`, `algorithm`, `signature_format`, and `signature`; v1 permits only Ed25519 raw signatures with 64 decoded bytes and unpadded base64url encoding.

| Payload ID | Type-specific fields, in closed schema order | Domain, context, producer, consumer |
| --- | --- | --- |
| `PAY-01` | `registry_revision`, `boards`, `capability_vocabulary` | `omarchy-board-registry`, `board-registry-publication`, platform registry, P-01 board admission |
| `PAY-02` | `channel`, `release_version`, `board_registry_digest`, `board_targets`, `qualification_bindings`, `components`, `artifacts`, `package_set`, `compatibility`, `firmware_schema`, `consumer_schema_set`, `minimum_consumer_api`, `rollback` | `omarchy-platform-manifest`, `manifest-publication`, release assembler, P-01 and I-04 |
| `PAY-03` | `inventory`, `selection`, `scope`, `mutations`, `rollback_boundaries`, `recovery_requirements` | `omarchy-installer-plan`, `installer-plan-proposal`, read-only planner, I-03 and I-04 |
| `PAY-04` | `board`, `manifest`, `qualification_profile_id`, `test_results`, `outcome`, `residuals`, `operator`, `lab`, `evidence` | `omarchy-qualification-record`, `qualification-result`, qualification authority, P-01, P-03, P-05, F-07 |
| `PAY-05` | `board_id`, `manifest_id`, `manifest_digest`, `profile_id`, `profile_digest`, `lineage_id`, `source_generation`, `slot_id`, `slot_generation`, `attempt_counter`, `checks`, `checks_digest`, `success`, `fallback` | `omarchy-boot-runtime`, `boot-health-core`, boot runtime, P-05 health evidence |
| `PAY-06` | `plan_digest`, `scope_digest`, `project_id`, `repository_id`, `slice_id`, `board_id`, `board_registry_digest`, `manifest_id`, `manifest_digest`, `schema_set_digest`, `policy_id`, `policy_digest`, `actor_id`, `account_id`, `actor_role`, `approved_at`, `topology_digest`, `target_ids`, `target_identities`, `operations`, `authorization_method`, `authorization_result`, `external_proof_digest`, `authorization_evidence_digest`, `service_policy_id`, `service_policy_digest`, `replay_id`, `proof_receipt_id`, `target_account_record_id`, `target_account_binding` | `omarchy-owner-authorization`, `installer-plan-execution`, owner authorization service, P-01 and I-03 |
| `PAY-07` | `core_digest`, `board_id`, `manifest_id`, `manifest_digest`, `profile_id`, `profile_digest`, `lineage_id`, `source_generation`, `slot_id`, `slot_generation`, `attempt_counter`, `marker_generation`, `marked_at`, `checks_digest`, `rollback_set_digest`, `marker_replay_id`, `diagnostic_note` | `omarchy-boot-runtime`, `boot-success-marker`, boot runtime, P-05 evaluator and F-07 evidence intake |
| `PAY-08` | `board_identity`, `source_identity`, `platform_manifest_document_id`, `platform_manifest_payload_digest`, `pre_mutation_dtb_digest`, `post_mutation_dtb_digest`, `policy_identity`, `tool_identity`, `artifact_identity`, `firmware_bundle_identity`, `dt_schema_identity`, `authorized_mutations`, `signer_authority`, `nonce`, `replay_identity` | `omarchy-dtb-authority`, `dtb-mutation-authorization`, DTB policy authority, I-04 only |

`PAY-07` is listed with its full payload fields once; `schema`, `schema_set_digest`, `document_id`, `issuer`, `issued_at`, and `expires_at` are the common fields and are not duplicated on the wire. `PAY-08` is the eighth and final type. A payload field not listed here or in the closed nested grammar below is `UNKNOWN_FIELD`.

Every payload also has this complete source-to-consumer binding row. The artifact IDs are required future receipts, not claims that the artifacts exist:

```text
PayloadIntegrationMap = [
  {id: PAY-01, source_artifact_id: f02.board-registry.v1, validator_artifact_id: f02.validator.v1,
   binding_identity: f02.generated-binding.board-registry.v1, consumer: P-01,
   freshness: issued_at <= verified_clock.now <= expires_at,
   rejection: {code: SIGNATURE_CONTEXT_MISMATCH, path: $.payload, phase: verify, process_status: 3}},
  {id: PAY-02, source_artifact_id: f02.platform-manifest.v1, validator_artifact_id: f02.validator.v1,
   binding_identity: f02.generated-binding.platform-manifest.v1, consumer: P-01/I-04,
   freshness: issued_at <= verified_clock.now <= expires_at,
   rejection: {code: CROSS_DOCUMENT_MISMATCH, path: $.payload.manifest_digest, phase: cross_document, process_status: 3}},
  {id: PAY-03, source_artifact_id: f02.installer-plan.v1, validator_artifact_id: f02.validator.v1,
   binding_identity: f02.generated-binding.installer-plan.v1, consumer: I-03/I-04,
   freshness: issued_at <= verified_clock.now <= expires_at,
   rejection: {code: PLAN_MISMATCH, path: $.payload.mutations, phase: identity, process_status: 3}},
  {id: PAY-04, source_artifact_id: f02.qualification-record.v1, validator_artifact_id: f02.validator.v1,
   binding_identity: f02.generated-binding.qualification-record.v1, consumer: P-01/P-03/P-05/F-07,
   freshness: issued_at <= verified_clock.now <= expires_at,
   rejection: {code: QUALIFICATION_NOT_BOUND, path: $.payload.board, phase: identity, process_status: 3}},
  {id: PAY-05, source_artifact_id: f02.boot-health.v1, validator_artifact_id: f02.validator.v1,
   binding_identity: f02.generated-binding.boot-health.v1, consumer: P-05,
   freshness: issued_at <= VerifiedClock.now <= expires_at,
   rejection: {code: BOOT_REQUIRED_CHECK_FAILURE, path: $.payload.checks, phase: boot.evaluate, process_status: 4}},
  {id: PAY-06, source_artifact_id: f03.owner-authorization.v1, validator_artifact_id: f03.validator.v1,
   binding_identity: f03.generated-binding.owner-authorization.v1, consumer: P-01/I-03,
   freshness: valid_from <= VerifiedClock.now <= expires_at and replay_id unused,
   rejection: {code: OWNER_PROOF_INVALID, path: $.payload.target_account_binding, phase: identity, process_status: 3}},
  {id: PAY-07, source_artifact_id: f02.boot-success-mark.v1, validator_artifact_id: f02.validator.v1,
   binding_identity: f02.generated-binding.boot-success-mark.v1, consumer: P-05/F-07,
   freshness: marked_at <= VerifiedClock.now <= expires_at and marker_replay_id unused,
   rejection: {code: BOOT_MARKER_AUTH_FAILURE, path: $.payload.signatures, phase: boot.evaluate, process_status: 4}},
  {id: PAY-08, source_artifact_id: f02.dtb-mutation-envelope.v1, validator_artifact_id: f02.validator.v1,
   binding_identity: f02.generated-binding.dtb-mutation-envelope.v1, consumer: I-04,
   freshness: issued_at <= VerifiedClock.now <= expires_at and replay_identity unused,
   rejection: {code: DTB_DECISION_MISSING, path: $.payload.authorized_mutations, phase: handoff, process_status: 3}}
]
```

The validator and binding IDs in this map must resolve through the exact ratification receipt and both generated locks. A missing artifact, handwritten adapter, consumer-specific shadow schema, or stale output changes the row to `DEPENDENCY_UNRATIFIED` or `BINDING_INTEGRITY_FAILURE`; it never yields a local pass.

The closed lexical grammar is: `DocumentId` is lowercase ASCII matching `^[a-z0-9][a-z0-9._:-]{0,127}$`; `Digest` is `sha256:` plus 64 lowercase hexadecimal characters; `UUID` is lowercase RFC 4122 text; `Timestamp` is RFC 3339 UTC ending in `Z` with millisecond precision at most; `Version` and `ApiVersion` have three uint16 components; `uint64` is 0 through 18,446,744,073,709,551,615; `Nonce` is unpadded base64url decoding to 16 through 32 bytes; `B64URL_NO_PAD_64_BYTES` is unpadded base64url decoding to exactly 64 bytes; and every object is closed. Input is at most 1 MiB, depth 32, object properties 128, array length 1,024, string length 4,096 UTF-8 bytes, total string bytes 256 KiB, and integer magnitude 2^63-1 unless a narrower field bound applies.

All named scalar and handoff aliases are closed and machine-checkable:

```text
LowerAsciiToken = lowercase ASCII matching ^[a-z0-9][a-z0-9._:-]{0,127}$
FullCommitId = 40 lowercase hexadecimal characters
ArtifactId = ASCII matching `^[A-Za-z0-9][A-Za-z0-9._:/-]{0,127}$` or UUID; comparison is case-sensitive
ProjectId = LowerAsciiToken
RepositoryId = LowerAsciiToken
SliceId = LowerAsciiToken
BoardId = LowerAsciiToken
ActorId = LowerAsciiToken
AccountId = LowerAsciiToken
PolicyId = LowerAsciiToken
KeyId = LowerAsciiToken
SchemaId = LowerAsciiToken
JsonPointer = RFC6901 pointer with UTF-8 tokens and no unescaped NUL
JsonPath = canonical `$`-rooted path with dot member tokens and bracketed decimal array indices
RelativeRepoPath = UTF-8 relative path with no leading slash, empty component, dot component, or .. component
RelativeBindingPath = RelativeRepoPath with no symlink component; the generated-output root is lock-declared
PathToken = RelativeRepoPath with no wildcard, variable, URL scheme, or shell metacharacter
SafeDescription = UTF-8 string of 1 through 256 bytes with no NUL or control character
SourceText = UTF-8 string of 1 through 4,096 bytes with no NUL
PreimageId = ArtifactId
SourcePointer = {path: RelativeRepoPath, line: uint64, column: uint64, selector: JsonPointer or null}
Status = 0 or 2 or 3 or 4 or 5 or 7 or 8 or 9
SlotId = "slot-a" or "slot-b" or "recovery"
Signature = {key_id: KeyId, signer_role: LowerAsciiToken, algorithm: "Ed25519",
             signature_format: "ed25519-raw-v1", signature: B64URL_NO_PAD_64_BYTES}
RejectionTuple = {code: ErrorCode, path: JsonPath or LowerAsciiToken, phase: Phase,
                  process_status: Status, decision: Decision, message_id: LowerAsciiToken}
RouteResult = {route_id: LowerAsciiToken, node_ids: ExactList<LowerAsciiToken, node_id>,
               edge_ids: ExactList<LowerAsciiToken, edge_id>, observed_result: ErrorCode or ResultCode,
               source_digest: Digest, acceptance_artifact_digest: Digest}
CapabilityResult = {capability_id: LowerAsciiToken, required: true or false,
                    observed: true or false, code: ErrorCode or ResultCode,
                    evidence_digest: Digest}
ResidualStatus = "DESIGN_ONLY" or "HELD" or "NOT_IMPLEMENTED" or "NOT_PRESENT"
                 or "TOOLING_BLOCK" or "UNSAFE_BASELINE" or "IMPLEMENTED_AND_VERIFIED"
ResidualRef = {residual_id: LowerAsciiToken, status: ResidualStatus,
               acceptance_artifact_digest: Digest, owner: LowerAsciiToken, due_before_gate: LowerAsciiToken}
ResidualScope = ExactScope or all-product-routes or all-mutators or all-payload-consumers
                or P01-and-P05 or install-and-update or promotion-terminal or diagnostics-and-promotion
                or I03-I04 or I04-P05-I09 or I08-P04-I04 or all-seams or P01-P05-integration
                or qualification-and-release or merge-and-promotion
HandoffScope = "P03/parity" or "P05/update-evidence" or "F06/compliance"
               or "F07/promotion"
TargetIdentity = {target_id: StableId, target_kind: "disk" or "partition" or "container" or "volume",
                  board_id: BoardId, disk_id: StableId, volume_id: StableId or null,
                  layout_digest: Digest, topology_digest: Digest, mount_generation: uint64}
```

`board-registry/v1` has exact capability vocabulary `cpu-topology`, `memory`, `internal-display`, `backlight`, `external-display`, `gpu`, `media`, `audio`, `camera`, `keyboard`, `trackpad`, `touch-id-sep`, `wifi`, `bluetooth`, `usb`, `thunderbolt`, `nvme`, `sd`, `ethernet`, `charging-battery`, `thermal-fan`, `suspend-resume`, `virtualization`, `recovery`. A board contains exact `board_id`, `identity_match`, `soc`, `firmware`, `physical_capabilities`, `lifecycle`, `qualification_profile`, `install_policy`, and `labels`; labels never authorize identity. A chip family, architecture token, DMI string, PCI ID, GPU vendor, or one compatible token is diagnostic only.

`platform-manifest/v1` has exact component paths `components.linux_kernel`, `components.dtb_set`, `components.firmware_bundle`, `components.mesa_stack`, and `components.boot_stack`, mapping respectively to `linux-kernel`, `dtb-set`, `firmware-bundle`, `mesa-stack`, and `boot-stack`. Its signed projections `artifacts`, `package_set`, `compatibility`, `firmware_schema`, and `rollback` must equal the sorted exact union derived from the component tree. There is no top-level winner, merge, or fallback.

`installer-plan/v1` uses typed stable identities, never a raw disk path, URL, glob, environment expression, or user-provided device name. Each mutation is exactly `sequence`, `step_id`, `operation`, `target_refs`, `preconditions`, `expected_effect`, `rollback_boundary`, and `owner_summary`; each target must match the read-only inventory tuple before every step.

`qualification-record/v1` requires explicit board, manifest, profile, test, evidence, operator, lab, outcome, and residual bindings. A required test is pass only when its profile says required, its measurements and evidence pass, all evidence digests verify, and every residual is explicitly non-blocking under the ratified policy. Static checks, a VM, mocked hardware, recognized chip text, or successful desktop boot do not satisfy physical evidence.

`boot-health/v1` and `boot-success-mark/v1` use the exact F-02 lineage and counter rules in section 3. `dtb-mutation-envelope/v1` binds board, source, manifest, pre- and post-DTB digests, policy, tool, artifact, firmware, DT schema, source generation, ordered mutation set, signer authority, nonce, and replay identity; I-04 consumes it opaquely and product code never edits or selects a mutation.

## 5. Canonical bytes, digest, handle, and error registries

The byte grammar is explicit. `NUL` means exactly one byte `0x00`, never the two characters backslash and zero. `ASCII(s)` encodes the listed ASCII string without a terminator. `UTF8(s)` encodes Unicode as UTF-8 without a BOM. `JCS(o)` is RFC 8785 JSON Canonicalization Scheme with no trailing newline. `B64URL_NO_PAD(b)` is RFC 4648 base64url of bytes `b` with all `=` padding removed. Duplicate JSON names are rejected before JCS. Object member order on the wire is JCS order; collection order is the declared exact order or the named stable-key sort. No implementation may infer an omitted field, normalize duplicate keys, or choose a different digest preimage.

```text
FRAME(label, parts...) = ASCII(label) || NUL || parts joined by NUL
F02_PAYLOAD_DIGEST(P) = SHA256(JCS(P))
HANDOFF_PAYLOAD_BODY(P) = P; the four handoff payload schemas contain no
  `payload_digest`, `content_digest`, or `acceptance_artifact_digest` member
P01_HANDOFF_PAYLOAD_DIGEST(H, P) = SHA256(FRAME("omarchy.payload.v1", UTF8(H.artifact_id), UTF8(H.document_id), JCS(HANDOFF_PAYLOAD_BODY(P))))
HANDOFF_CONTENT_BODY(E) = E with `payload_digest`, `content_digest`, and `acceptance_artifact_digest` omitted
CONTENT_DIGEST(E) = SHA256(FRAME("omarchy.content.v1", UTF8(E.document_id), JCS(HANDOFF_CONTENT_BODY(E))))
AUTH_PREIMAGE(E, S) = ASCII("omarchy-auth-preimage/v1") || NUL || JCS({
  envelope_format: E.format, signature_format: S.signature_format,
  key_id: S.key_id, signer_role: S.signer_role, algorithm: S.algorithm,
  domain: E.domain, context: E.context, payload_type: E.payload_type,
  payload_version: E.payload_version, schema_set_digest: E.schema_set_digest,
  payload_digest: F02_PAYLOAD_DIGEST(E.payload), anti_transplant: {
    document_id: E.payload.document_id, schema: E.payload.schema,
    payload_type: E.payload_type, payload_version: E.payload_version,
    schema_set_digest: E.schema_set_digest, domain: E.domain, context: E.context
  }, payload: E.payload
})
PLAN_BODY(P) = the exact canonical `installer-plan/v1` payload object; it contains no
  `plan_digest`, approval, authorization, or signature member
PLAN_DIGEST(P) = SHA256(FRAME("omarchy-plan-body/v1", JCS(PLAN_BODY(P))))
CORE_BODY(C) = C with exactly `payload_digest` omitted; no other member is omitted
CORE_DIGEST(C) = SHA256(FRAME("omarchy-boot-health-core/v1", JCS(CORE_BODY(C))))
MARK_BODY(M) = M with exactly `payload_digest` omitted; no other member is omitted
MARK_DIGEST(M) = SHA256(FRAME("omarchy-boot-success-mark/v1", JCS(MARK_BODY(M))))
```

The `FRAME` definition is normative: each component is encoded exactly once in the displayed order, with one `0x00` separator and no final separator. `F02_PAYLOAD_DIGEST` is the exact F-02 digest for an authenticated payload. `P01_HANDOFF_PAYLOAD_DIGEST` is used only for a handoff envelope `H` and its payload `P`, and binds both the envelope artifact ID and document ID. `CONTENT_DIGEST` binds the handoff document ID and the exact handoff envelope body with the three named digest fields omitted; it is therefore not self-referential. The named omission sets are closed. Adding a digest to its own preimage returns the domain cycle code; deleting a required field returns a parse code. A digest field never authenticates itself.

The canonical product identities are:

```text
ADMISSION_IDENTITY = {
  operation: ProductOperation, scope: ProductScope, route_id: LowerAsciiToken,
  target: TargetIdentity, registry_ref: PayloadRef, manifest_ref: PayloadRef,
  plan_ref: InstallerPlanRef, qualification_provenance: ExactList<QualificationRef, qualification_record_id>,
  boot_ref: BootIdentity, dtb_ref: DtbIdentity, schema_set_digest: Digest,
  binding_identity: BindingIdentity, authority_context_digest: Digest
}
identity_digest = SHA256(FRAME("P01.AdmissionIdentity/v2", JCS(ADMISSION_IDENTITY)))

RESULT_BODY = {
  result_schema: "P01.AdmissionResult/v2", adapter_identity: LowerAsciiToken,
  decision: Decision, code: ErrorCode or ResultCode, path: JsonPath or LowerAsciiToken,
  phase: Phase, process_status: Status,
  operation: ProductOperation, scope: ProductScope, route_id: LowerAsciiToken,
  transaction_id: UUID or null, handle: HANDLE_BODY or null, rejection: RejectionTuple or null,
  admission_identity: ADMISSION_IDENTITY or null, artifact_refs: ExactList<PayloadRef, payload_type>,
  freshness: Freshness or null, journal_ref: JournalRef or null,
  completed_steps: ExactList<StepRef, step_id>, rollback_state: RollbackState,
  next_action: LowerAsciiToken or null
}
result_without_admission_result_digest_and_handle_mac = RESULT_BODY with `handle` equal to HANDLE_BODY
admission_result_digest = SHA256(FRAME("P01.AdmissionResult/v2", JCS(result_without_admission_result_digest_and_handle_mac)))

HANDLE_BODY = {
  handle_schema: "P01.AdmissionHandle/v2", transaction_id: UUID, identity_digest: Digest,
  plan_digest: Digest, operation: ProductOperation, scope: ProductScope, route_id: LowerAsciiToken,
  issued_at: Timestamp, expires_at: Timestamp, nonce: Nonce,
  mac_algorithm: "HMAC-SHA-256", mac_key_id: LowerAsciiToken
}
handle_mac = HMAC-SHA256(key[mac_key_id],
  FRAME("P01.AdmissionHandle/v2.mac", JCS(HANDLE_BODY)))
handle = "omarchy-admit:v2:" || B64URL_NO_PAD(JCS(HANDLE_BODY || {mac: handle_mac}))

TRANSACTION_BODY = {
  transaction_id: UUID, admission_identity_digest: Digest, operation: ProductOperation, scope: ProductScope,
  route_id: LowerAsciiToken,
  plan_digest: Digest, mutation_list_digest: Digest,
  target_snapshot_digest: Digest, cache_set_digest: Digest, final_consent_digest: Digest,
  qualification_provenance: ExactList<QualificationRef, qualification_record_id>, boot_lineage: BootLineage,
  source_generation: uint64, created_at: Timestamp
}
transaction_identity_digest = SHA256(FRAME("P01.Transaction/v1", JCS(TRANSACTION_BODY)))
FinalConsent_without_consent_digest = FinalConsent with exactly `consent_digest` omitted
CacheSet_without_set_digest = CacheSet with exactly `set_digest` omitted
CapacityReservation_without_reservation_digest = CapacityReservation with exactly `reservation_digest` omitted
JournalEvent_without_event_digest = JournalEvent with exactly `event_digest` omitted
Tombstone_without_tombstone_digest = Tombstone with exactly `tombstone_digest` omitted
consent_digest = SHA256(FRAME("P01.FinalConsent/v1", JCS(FinalConsent_without_consent_digest)))
cache_set_digest = SHA256(FRAME("P01.VerifiedCacheSet/v1", JCS(CacheSet_without_set_digest)))
capacity_reservation_digest = SHA256(FRAME("P01.CapacityReservation/v1", JCS(CapacityReservation_without_reservation_digest)))
journal_event_digest = SHA256(FRAME("P01.JournalEvent/v1", JCS(JournalEvent_without_event_digest)))
tombstone_digest = SHA256(FRAME("P01.TransactionTombstone/v1", JCS(Tombstone_without_tombstone_digest)))
Freshness = {verified_clock_id: LowerAsciiToken, source_generation: uint64,
             issued_at: Timestamp, expires_at: Timestamp, replay_id: UUID}
JournalRef = {journal_id: UUID, chain_digest: Digest, state: StateId, sequence: uint64}
StepRef = {step_id: LowerAsciiToken, primitive_id: LowerAsciiToken,
           target_ids: ExactList<StableId, stable_id>, postcondition_digest: Digest}
RollbackState = {allowed: true or false, depth: 0 or 1, predecessor_digest: Digest or null,
                 action_digest: Digest or null}
```

The handle has a broker-custodied HMAC-SHA-256 key identified by `mac_key_id`, a 32-byte MAC encoded as 43 unpadded base64url characters, a 16-byte nonce, lowercase UUID transaction ID, and a maximum 15-minute lifetime. The F-03 receipt must ratify custody, current and previous key rotation, revocation, and expiry behavior before implementation. A handle is issued only for `decision=admitted`, never for a hold, reject, abort, quarantine, or missing dependency. A caller cannot supply a handle, key, nonce, transaction ID, expiry, or identity field to the verifier.

### 5.1 Deterministic validation and simultaneous-fault precedence

The first failure is determined before any later phase is inspected. Within a phase, the fixed `phase_order` below is followed; within a collection, the first affected JSON pointer in canonical array order wins. The shape suborder is invalid UTF-8, duplicate name, unknown field, required field, then resource bound; the canonical suborder is number, JCS bytes, plan digest cycle, boot-core digest cycle, then marker digest cycle. The dependency receipt is a required typed slot whose `unratified` status is a dependency fault; deleting the slot is a shape fault. There is no source timing, hash-map order, warning aggregation, or “most severe” selection.

```text
phase_order = [
  transport, shape, canonical, parse, bootstrap, dependency, trust, freshness,
  identity, cross_document, authorize, consent, preflight, reserve, execution,
  postcondition, recover, privacy, accessibility, promotion, close
]
```

| Simultaneous faults | First result | Why |
| --- | --- | --- |
| invalid UTF-8 plus any other fault | `PARSE_SCHEMA_FAILURE` at `transport.invalid_utf8` | invalid bytes are the first transport check |
| duplicate JSON name plus any other fault | `DUPLICATE_SEMANTIC_KEY` at `transport.duplicate_name` | duplicate names are checked after UTF-8 and before dependency inspection |
| unknown field plus missing required field, dependency hold, or later fault | `UNKNOWN_FIELD` at `P1.unknown_field` | unknown fields are checked before required fields and ratification |
| missing required field plus dependency hold or later fault | `PARSE_SCHEMA_FAILURE` at `P1.required_field` | required shape is checked before ratification |
| noncanonical number plus digest cycle or dependency hold | `CANONICALIZATION_FAILURE` at `P2.number` | numeric canonicalization precedes digest construction |
| plan digest cycle plus dependency hold or later fault | `PLAN_DIGEST_CYCLE` at `$.payload.plan_digest` | the named plan domain cycle is checked before ratification |
| boot-core digest cycle plus marker digest cycle, dependency hold, or later fault | `BOOT_DIGEST_CYCLE` at the first boot-core cycle pointer | boot-core canonical digest is checked before marker canonical digest and ratification |
| marker digest cycle plus dependency hold or later fault | `BOOT_MARKER_DIGEST_CYCLE` at the first marker cycle pointer | marker canonical digest is checked before ratification |
| missing or unratified dependency plus stale clock, cache miss, or target mismatch | `DEPENDENCY_UNRATIFIED` at `dependency.check` | ratification is before later trust, identity, and execution checks |
| stale or replayed clock plus target mismatch or cache miss | `EXPIRY_OR_REPLAY_FAILURE` at `admission.freshness` | freshness is before identity and execution |
| target mismatch plus cache miss or missing consent | `TARGET_ID_MISMATCH` at `admission.identity` | local identity is before executor preflight |
| cache substitution plus cache miss | `CACHE_SUBSTITUTION` at `executor.preflight` | the first mismatched entry is more specific than absent set |
| missing final consent plus disk full or post-consent network | `CONSENT_MISSING` at `executor.consent` | consent precedes reservation and capacity execution |
| capacity failure plus journal write failure | `JOURNAL_FAILURE` at `executor.reserve` | no capacity decision is durable without a journal |
| changed target plus step failure | `TARGET_REVALIDATION_FAILED` at `executor.verify` | target guard is immediately before the primitive |
| stale health plus a forged success marker | `BOOT_MARKER_AUTH_FAILURE` at `boot.evaluate` | marker authentication precedes cross-result evaluation |
| duplicate transaction with identical terminal identity and terminal state `committed` | `ALREADY_APPLIED` at `executor.idempotence` | idempotence is allowed only for byte-equal committed identity |
| duplicate transaction with identical terminal identity and terminal state `rolled_back` | `ROLLED_BACK` at `recovery.close` | a byte-equal rollback result is replayed without mutation |
| duplicate transaction with identical terminal identity and terminal state `closed` | `CLOSED` at `executor.close` | closed journal identity is replayed without mutation |
| duplicate transaction with identical terminal identity and terminal state `aborted` | `ABORTED` at `recovery.close` | an abort result is replayed without mutation |
| duplicate transaction with a different identity and a live or closed ID | `DUPLICATE_TRANSACTION` at `executor.idempotence` | no transaction ID is rebound |
| duplicate transaction with a tombstoned ID | `TRANSACTION_TOMBSTONED` at `recovery.dispatch` | tombstones are never reopened |
| unknown recovery event plus any requested recovery action | `UNKNOWN_EVENT` and quarantine | no action is inferred from an unknown event |

F-02 error distinctions are preserved. `UNKNOWN_FIELD`, `DUPLICATE_SEMANTIC_KEY`, `CANONICALIZATION_FAILURE`, `SIGNATURE_CONTEXT_MISMATCH`, `TRUST_BOUNDARY_FAILURE`, `BOOT_CONTEXT_MISMATCH`, `BOOT_COUNTER_FAILURE`, `BOOT_REQUIRED_CHECK_FAILURE`, and `BOOT_MARKER_AUTH_FAILURE` are never collapsed into generic success, warning, or one product `TRUST_FAILURE` code. A product projection carries the exact upstream code, path, phase, and redacted fixed message.

### 5.2 Closed result and error registries

The result registry is separate from the error registry. Every result or error selects exactly one row. Status 0 is permitted only for a verified positive result; status 4 is hold or user abort; status 3 is reject; status 8 is invalid handle; status 9 is quarantined. Unknown code, path, phase, state, or result is `UNKNOWN_EVENT` with status 9.

| Result ID | Code | Path | Phase | Status | Decision and terminal meaning |
| --- | --- | --- | --- | --- | --- |
| `RESULT-01` | `ADMITTED` | `admission.open` | `identity` | 0 | `admitted`; handle issued, no mutation yet |
| `RESULT-02` | `VALID` | `admission.check` | `verify` | 0 | `valid`; handle and live journal still required for a step |
| `RESULT-03` | `ALREADY_APPLIED` | `executor.idempotence` | `close` | 0 | `already_applied`; exact terminal transaction already succeeded |
| `RESULT-04` | `CLOSED` | `executor.close` | `close` | 0 | `closed`; journal and evidence closure verified |
| `RESULT-05` | `ROLLED_BACK` | `recovery.close` | `recover` | 0 | `rolled_back`; predecessor verified and closure pending or complete |
| `RESULT-06` | `ABORTED` | `recovery.close` | `recover` | 4 | `aborted`; no resume or mutation permitted |
| `RESULT-07` | `QUARANTINED` | `recovery.close` | `terminal` | 9 | `quarantined`; no mutation, human evidence only |
| `RESULT-08` | `CAPABILITY_VALID` | `capability.check` | `verify` | 0 | `valid`; capability observed and bound to the required manifest |
| `RESULT-09` | `OPTIONAL_CAPABILITY_UNAVAILABLE` | `capability.check` | `verify` | 0 | `valid`; optional capability unavailable with an explicit typed gap |
| `RESULT-10` | `NOT_APPLICABLE` | `capability.check` | `verify` | 0 | `valid`; operation/scope matrix marks the capability not applicable |

| Error code | Path | Phase | Status | Decision and side effect |
| --- | --- | --- | --- | --- |
| `ADMISSION_USAGE` | `route.parse` | `parse` | 2 | reject, no read or write |
| `PATH_TRAVERSAL` | `route.parse` | `parse` | 2 | reject, no target read or write |
| `FORBIDDEN_ROUTE` | `route.authorize` | `authorize` | 2 | reject, no adapter, broker, child, or network call |
| `OMARCHY_PATH_MISSING` | `route.bootstrap` | `bootstrap` | 2 | reject, no fallback path |
| `PARSE_SCHEMA_FAILURE` | first malformed field | `shape` | 3 | reject, no trusted value |
| `UNKNOWN_FIELD` | first unknown field | `shape` | 3 | reject, no trusted value |
| `DUPLICATE_SEMANTIC_KEY` | second duplicate name or key | `shape` | 3 | reject, no deduplication |
| `RESOURCE_LIMIT` | first over-bound value | `shape` | 3 | reject, no truncation |
| `CANONICALIZATION_FAILURE` | first canonical byte mismatch | `canonical` | 3 | reject, no digest or signature check |
| `PLAN_DIGEST_CYCLE` | `$.payload.plan_digest` | `canonical` | 3 | reject, plan not admitted |
| `BOOT_DIGEST_CYCLE` | first forbidden boot self-digest | `canonical` | 3 | reject, no boot result |
| `BOOT_MARKER_DIGEST_CYCLE` | `$.payload.canonical_payload_digest` | `canonical` | 3 | reject, no marker result |
| `DEPENDENCY_UNRATIFIED` | `dependency.check` | `dependency` | 4 | hold, no handle, mutation, promotion, or fallback |
| `BINDING_INTEGRITY_FAILURE` | first lock or capability mismatch | `verify` | 3 | reject, no generated binding use |
| `REQUIRED_CAPABILITY_UNAVAILABLE` | first missing required capability | `capability.check` | 3 | reject, no install or update success |
| `CAPABILITY_RESULT_INCOMPLETE` | required/optional outcome set | `capability.check` | 3 | reject, no partial capability result |
| `HANDLE_INVALID` | handle envelope, MAC, or live journal identity | `admission.check` | 8 | reject, no mutation |
| `SIGNATURE_CONTEXT_MISMATCH` | first domain, context, type, or role mismatch | `verify` | 3 | reject, no trusted value |
| `TRUST_FAILURE` | first authority or proof failure | `verify` | 3 | reject, no trusted value |
| `TRUST_BOUNDARY_FAILURE` | first local untrusted record field | `trust` | 4 | hold, no trusted value |
| `EXPIRY_OR_REPLAY_FAILURE` | first stale, expired, or replay field | `freshness` | 3 | reject, replay reservation unchanged |
| `OWNER_PROOF_VERIFICATION_FAILURE` | owner proof source | `verify` | 3 | reject, no owner context |
| `OWNER_PROOF_INVALID` | owner receipt identity | `identity` | 3 | reject, no handle |
| `IDENTITY_INCOMPLETE` | missing required identity or applicability field | `identity` | 3 | reject, no handle |
| `TARGET_ACCOUNT_INVALID` | target account binding | `identity` | 3 | reject, no handle |
| `TARGET_ID_MISMATCH` | first target identity | `identity` | 3 | reject, no handle or mutation |
| `PLAN_MISMATCH` | first plan or mutation identity | `identity` | 3 | reject, no handle |
| `QUALIFICATION_NOT_BOUND` | qualification board, profile, candidate, or evidence | `identity` | 3 | reject, no qualified result |
| `DTB_DECISION_MISSING` | `$.dtb_identity` | `handoff` | 3 | reject, no DTB action |
| `CROSS_DOCUMENT_MISMATCH` | first unequal bound field | `cross_document` | 3 | reject, no executor handoff |
| `BOOT_CONTEXT_MISMATCH` | first record, context, health, or marker tuple field | `boot.evaluate` | 4 | hold, no success or promotion result |
| `BOOT_COUNTER_FAILURE` | counter, generation, or atomic record path | `boot.lineage` | 4 | hold or recovery, no reset or wrap |
| `BOOT_REQUIRED_CHECK_FAILURE` | profile, check, measurement, or evidence | `boot.evaluate` | 4 | hold or recovery, no success |
| `BOOT_MARKER_AUTH_FAILURE` | marker signature, role, core digest, or replay | `boot.evaluate` | 4 | hold or recovery, no success |
| `BOOT_FALLBACK_FAILURE` | rollback set or predecessor | `boot.evaluate` | 4 | hold or quarantine, no promotion |
| `PRIVILEGE_MISMATCH` | route privilege context | `authorize` | 5 | reject, no broker call |
| `CONSENT_MISSING` | final consent record | `executor.consent` | 4 | hold, no reservation or mutation |
| `CONSENT_REPLAY` | consent nonce or transaction | `executor.consent` | 3 | reject, no mutation |
| `CACHE_MISS` | missing required cache entry | `executor.preflight` | 4 | hold, no network or mutation |
| `CACHE_SUBSTITUTION` | cache entry digest, size, or binding | `executor.preflight` | 3 | reject, no network or mutation |
| `CAPACITY_INSUFFICIENT` | capacity or reservation arithmetic | `executor.reserve` | 4 | hold, no mutation |
| `JOURNAL_FAILURE` | journal header, chain, or durable write | `executor.reserve` | 7 | reject, no irreversible step |
| `DUPLICATE_TRANSACTION` | transaction identity | `executor.idempotence` | 3 | reject, no rebinding |
| `TRANSACTION_TOMBSTONED` | tombstone identity | `recovery.dispatch` | 3 | reject, no resume or rollback |
| `TARGET_REVALIDATION_FAILED` | target immediately before primitive | `executor.verify` | 3 | reject, journal preserved, recovery required |
| `STEP_POSTCONDITION_FAILED` | postcondition digest | `executor.verify` | 3 | reject, recovery required |
| `POWER_LOSS_INTERRUPTED` | interruption boundary | `recovery.resume` | 4 | hold, explicit resume, rollback, or abort |
| `RECOVERY_TERMINAL` | rollback or recovery terminal boundary | `recovery.dispatch` | 9 | quarantine and tombstone |
| `RECOVERY_RECURSION` | rollback depth | `recovery.dispatch` | 9 | quarantine and tombstone |
| `UNKNOWN_EVENT` | first unknown event or transition | `recovery.dispatch` | 9 | quarantine and tombstone, no inferred action |
| `USER_CANCELLED_BEFORE_CONSENT` | consent boundary | `executor.consent` | 4 | abort, no mutation |
| `USER_CANCELLED_AFTER_RESERVE` | recovery cancellation | `recovery.cancel` | 4 | abort only after rollback or quarantine |
| `ACCESSIBILITY_UNAVAILABLE` | UI capability or focus contract | `ux.render` | 4 | hold, no hidden mutation |
| `ACCESSIBILITY_RECOVERY_FAILED` | post-consent recovery UI | `ux.recovery` | 9 | quarantine, accessible CLI evidence only |
| `PRIVACY_POLICY_UNRATIFIED` | privacy policy identity | `diagnostics.policy` | 4 | hold upload, local conservative result only |
| `PRIVACY_FIELD_FORBIDDEN` | first disallowed support field | `diagnostics.redact` | 3 | reject, no persistence |
| `SUPPORT_BUNDLE_REDACTION_FAILED` | redaction proof | `diagnostics.export` | 3 | reject, no persistence or upload |
| `LOCAL_BUNDLE_WRITE_FAILURE` | local mode, permission, or capacity | `diagnostics.persist` | 3 | reject, no partial bundle |
| `UPLOAD_CONSENT_MISSING` | second upload consent | `diagnostics.upload` | 4 | hold, no network |
| `UPLOAD_TLS_FAILURE` | endpoint or TLS verification | `diagnostics.upload` | 3 | reject, no upload |
| `UPLOAD_AUDIT_FAILURE` | remote retention or deletion receipt | `diagnostics.upload` | 3 | reject, local bundle retained for user deletion |
| `RETENTION_POLICY_FAILURE` | retention deadline or policy | `diagnostics.retention` | 3 | reject upload, no policy widening |
| `DELETION_FAILURE` | local or remote deletion proof | `diagnostics.delete` | 3 | retry up to 3, then quarantine evidence and report failure |
| `PROMOTION_INTAKE_INVALID` | first F-07 intake mismatch | `promotion.intake` | 3 | reject, F-07 does not write |

The exact hold-eligible F-02 boot set is `TRUST_BOUNDARY_FAILURE`, `BOOT_CONTEXT_MISMATCH`, `BOOT_COUNTER_FAILURE`, `BOOT_REQUIRED_CHECK_FAILURE`, `BOOT_MARKER_AUTH_FAILURE`, and `BOOT_FALLBACK_FAILURE`. All other errors are rejects unless their result row explicitly says hold or abort. No error message contains input values, secrets, raw paths, serials, signatures, or command output.

In the error registry, phrases such as `first unknown field` are closed selectors, not emitted paths: the returned `RejectionTuple.path` is the concrete `JsonPointer` selected by the phase and canonical collection order above. Literal paths such as `dependency.check` and `executor.preflight` are emitted unchanged. An implementation that returns the selector text, a stack trace, or an unordered aggregate is non-conforming.

## 6. P-01 admission input, applicability, and output

`P01.AdmissionOpenInput/v2` is a closed adapter record, not an authenticated ninth payload. It has exactly:

```text
AdmissionOpenInput = {
  contract_id: "P01.AdmissionOpenInput/v2",
  operation_scope: {operation: ProductOperation, scope: ProductScope, route_id: LowerAsciiToken},
  target: TargetObservation,
  owner_proof_receipt: OwnerProofReceipt or null,
  target_account: TargetAccount or null,
  verified_clock: VerifiedClock,
  payload_refs: ExactList<PayloadRef, payload_type>,
  plan: InstallerPlanRef or null,
  qualification_provenance: ExactList<QualificationRef, qualification_record_id>,
  boot_identity: BootIdentity,
  dtb_identity: DtbIdentity,
  authority_context: ExpectedContext or null,
  replay: {request_id: UUID, request_nonce: Nonce, prior_transaction_id: UUID or null,
           prior_result_digest: Digest or null, caller_uid: uint32}
}
```

The referenced types are closed aliases, not open maps:

```text
PayloadType = one exact member of PAYLOAD_TYPES
ErrorCode = one exact code in the error registry
ResultCode = one exact code in the result registry
Decision = admitted or hold or reject or valid or already_applied or closed or rolled_back or aborted or quarantined
Phase = transport or shape or canonical or dependency or verify or trust or freshness or identity
         or cross_document or authorize or consent or preflight or reserve or apply or close
         or parse or bootstrap or handoff or idempotence or execution or postcondition
         or boot.evaluate or boot.lineage or recover or terminal or privacy or accessibility or promotion
         or admission.check or executor.consent or executor.idempotence or executor.preflight
         or executor.reserve or executor.verify or recovery.cancel or recovery.dispatch or recovery.resume
         or ux.render or ux.recovery or diagnostics.policy or diagnostics.redact or diagnostics.export
         or diagnostics.persist or diagnostics.upload or diagnostics.retention or diagnostics.delete
         or promotion.intake
StateId = STATE-01 through STATE-13
EventId = one exact event name in the transition table
GuardId = one exact guard name in the route graph artifact
MutationClass = read-only or package or config or service or firmware or dtb or boot or storage
                or account or channel or migration or diagnostics or upload or reboot or system
                or hardware or update or user or all-privileged
ExactScope = `operation/scope` using one member of `OPERATIONS` and one member of `SCOPES`
PayloadStatus = "verified" or "not_applicable"
PayloadRef = {payload_type: PayloadType, document_id: DocumentId, content_digest: Digest,
              payload_digest: Digest, schema_set_digest: Digest, binding_identity: BindingIdentity,
              authority_version: Version, issued_at: Timestamp, expires_at: Timestamp,
              source_generation: uint64, status: PayloadStatus, not_applicable_reason: SafeDescription or null}
InstallerPlanRef = {document_id: DocumentId, payload_digest: Digest, mutation_list_digest: Digest,
                    operation: ProductOperation, scope: ProductScope,
                    target_id: StableId, plan_generation: uint64, predecessor_generation: uint64,
                    target_generation: uint64, lineage: UUID, expected_counter: uint64,
                    required_capability_ids: ExactList<LowerAsciiToken, capability_id>}
QualificationRef = {qualification_record_id: ArtifactId, payload_digest: Digest, content_digest: Digest,
                    board_id: BoardId, profile_id: LowerAsciiToken, manifest_id: DocumentId,
                    manifest_digest: Digest, test_run_id: LowerAsciiToken,
                    outcome: "pass" or "fail" or "held"}
BootIdentity = {status: "verified" or "not_applicable", board_id: BoardId, manifest_id: DocumentId,
                manifest_digest: Digest, boot_health_document_id: DocumentId or null,
                boot_health_payload_digest: Digest or null, boot_success_document_id: DocumentId or null,
                boot_success_payload_digest: Digest or null, atomic_record_digest: Digest or null,
                source_generation: uint64 or null, slot_id: SlotId or null,
                slot_generation: uint64 or null, lineage_id: UUID or null, attempt_counter: uint64 or null,
                required_checks_digest: Digest or null}
DtbIdentity = {status: "verified" or "not_applicable", envelope_document_id: DocumentId or null,
               envelope_payload_digest: Digest or null, envelope_content_digest: Digest or null,
               decision_digest: Digest or null, board_id: BoardId, manifest_id: DocumentId,
               target_id: StableId or null, operation: F02Operation or null, mutation_list_digest: Digest or null}
TargetObservation = {requested_target_id: StableId, observed_target_id: StableId,
                     target_kind: "disk" or "partition" or "container" or "volume",
                     board_id: BoardId, soc_id: LowerAsciiToken, device_tree_identity_digest: Digest,
                     firmware_schema_id: SchemaId, disk_id: StableId, volume_id: StableId or null,
                     slot_id: SlotId or null, account_id: AccountId or null}
ExpectedContext = {context_schema: LowerAsciiToken, payload_type: PayloadType, payload_version: Version,
                   domain: LowerAsciiToken, context: LowerAsciiToken, project_id: ProjectId,
                   repository_id: RepositoryId, slice_id: SliceId, operation: F02Operation, board_id: BoardId,
                   manifest_id: DocumentId, manifest_digest: Digest, schema_set_digest: Digest,
                   target_account_id: AccountId, target_account_binding: Digest,
                   target_identity_digests: ExactList<Digest, value>, policy_digest: Digest}
OwnerProofReceipt = {
  receipt_schema: "owner-proof-receipt/v1", receipt_id: ArtifactId,
  project_id: ProjectId, repository_id: RepositoryId, slice_id: SliceId,
  product_operation: ProductOperation, product_scope: ProductScope, operation: F02Operation,
  actor_id: ActorId, subject_account_id: AccountId, target_account_id: AccountId,
  plan_digest: Digest, scope_digest: Digest,
  board_id: BoardId, manifest_id: DocumentId, manifest_digest: Digest,
  schema_set_digest: Digest, policy_id: PolicyId, policy_digest: Digest,
  topology_digest: Digest, target_identity_digests: ExactList<Digest, value>,
  authorization_method: "webauthn/v1" or "oidc-step-up/v1" or "hardware-token/v1",
  authorization_result: "success", assertion_digest: Digest, evidence_digest: Digest,
  source_identity: SourceEvidence, valid_from: Timestamp, expires_at: Timestamp,
  nonce: Nonce, replay_id: UUID, receipt_digest: Digest
}
TargetAccount = {
  account_schema: "target-account/v1", record_id: ArtifactId, account_id: AccountId,
  project_id: ProjectId, repository_id: RepositoryId, slice_id: SliceId,
  product_operation: ProductOperation, product_scope: ProductScope,
  allowed_operations: ExactList<F02Operation, value>, target_identity_digests: ExactList<Digest, value>,
  board_id: BoardId, manifest_id: DocumentId, manifest_digest: Digest,
  schema_set_digest: Digest, policy_id: PolicyId, policy_digest: Digest,
  valid_from: Timestamp, expires_at: Timestamp, nonce: Nonce, replay_id: UUID,
  account_binding: Digest, record_digest: Digest
}
F02Operation = inspect/v1 or write/v1 or replace/v1 or remove/v1 or rollback/v1
ProductOperation = inspect or install or setup or apply-system or apply-hardware or provision-owner
                   or provision-user or first-run or update or channel-set or upgrade
                   or migrate or recover
ProductScope = platform-system or platform-hardware or platform-update or platform-user
               or platform-migration or universal-user or read-only
PRODUCT_TO_F02_OPERATION = {
  inspect: inspect/v1, recover: rollback/v1,
  install: write/v1, setup: write/v1, apply-system: write/v1, apply-hardware: write/v1,
  provision-owner: write/v1, provision-user: write/v1, first-run: write/v1,
  update: replace/v1, channel-set: replace/v1, upgrade: replace/v1, migrate: write/v1
}
StableId = "disk:v1:sha256:" plus 64 lowercase hex or "partition:v1:sha256:" plus 64 lowercase hex
           or "container:v1:sha256:" plus 64 lowercase hex or "volume:v1:sha256:" plus 64 lowercase hex
ConstructorIdentity = {constructor_id: LowerAsciiToken, implementation_digest: Digest,
                       api_version: Version, source_digest: Digest}
```

`payload_refs` has exactly one entry per `PAY-01` through `PAY-08`, each with `payload_type`, `document_id`, `content_digest`, `payload_digest`, `schema_set_digest`, `binding_identity`, `authority_version`, `issued_at`, `expires_at`, `source_generation`, `status`, and `not_applicable_reason`. Omission is invalid; `not_applicable` is valid only in the operation matrix and must carry a reason. The input has no board assumption, architecture decision, raw URL, arbitrary ref, raw package name, firmware path, success flag, promotion flag, key, role override, target-path override, or dynamic command.

For `read-only`, `owner_proof_receipt`, `target_account`, and `authority_context` are null and no transaction is allocated. For every mutating scope they are required and must be independently verified before a handle is issued. Null is never interpreted as a local default.

The operation and scope sets are closed:

```text
OPERATIONS = [install, setup, apply-system, apply-hardware, provision-owner,
              provision-user, first-run, update, channel-set, upgrade,
              migrate, recover]
SCOPES = [platform-system, platform-hardware, platform-update,
          platform-user, platform-migration, universal-user, read-only]
```

Platform scopes require effective uid 0 and a root-owned journal; `platform-user` and `universal-user` require the non-root journal owner; `read-only` has no handle and no journal. The adapter never escalates. Any operation/scope pair outside the explicit route matrix is `ADMISSION_USAGE`; root opening a user scope or a non-root opening a platform scope is `PRIVILEGE_MISMATCH`.

The payload applicability matrix is closed. `R` means required at admission, `L` means required at a later executor or close boundary, `O` means optional only when the manifest says so, and `N` means explicit not applicable. The order of columns is the order below.

```text
operation,scope,PAY-01,PAY-02,PAY-03,PAY-04,PAY-05,PAY-06,PAY-07,PAY-08
inspect,read-only,R,R,N,N,N,N,N,N
install,platform-system,R,R,R,R,N,R,N,N
install,platform-hardware,R,R,R,R,N,R,N,R
setup,platform-system,R,R,R,R,N,R,N,N
setup,platform-hardware,R,R,R,R,N,R,N,R
apply-system,platform-system,R,R,R,R,N,R,N,N
apply-hardware,platform-hardware,R,R,R,R,N,R,N,R
provision-owner,platform-system,R,R,R,R,N,R,N,N
provision-user,platform-user,R,R,R,R,N,R,N,N
first-run,universal-user,R,R,R,O,N,R,N,N
update,platform-update,R,R,R,R,L,R,L,O
channel-set,platform-update,R,R,R,R,N,R,N,N
upgrade,platform-system,R,R,R,R,L,R,L,O
migrate,platform-migration,R,R,R,R,N,R,N,N
recover,platform-update,R,R,N,R,L,O,L,O
```

An operation that needs a payload marked `N` is a schema error; an operation that omits `R` or `L` is `IDENTITY_INCOMPLETE`. `O` cannot be promoted to required or silently omitted after a plan is opened. Qualification provenance is always part of identity when any platform capability is selected, even where the matrix marks the record `O` for a user-only first run.

`P01.AdmissionResult/v2` has exactly `result_schema`, `adapter_identity`, `decision`, `code`, `path`, `phase`, `process_status`, `operation`, `scope`, `route_id`, `transaction_id`, `handle`, `rejection`, `admission_identity`, `artifact_refs`, `freshness`, `journal_ref`, `completed_steps`, `rollback_state`, `next_action`, and `admission_result_digest`. `handle` is null except for `ADMITTED` and `VALID`; transaction and journal IDs are absent whenever the decision terminates before transaction allocation, including route, shape, canonical, dependency, and identity failures. The output is one canonical JSON object and never an authority-bearing payload.

## 7. Typed I-03 and I-04 transaction contract

I-03 and I-04 share one transaction identity. I-03 is pure read-only until final consent. I-04 allocates `transaction_id` exactly once before reserve, writes the journal before any irreversible step, and owns all mutation and recovery. `admission_identity_digest` is copied byte-for-byte from the admitted result into final consent, `TRANSACTION_BODY`, `ExecutorRequest`, and `ExecutorResult`; `transaction_identity_digest` is recomputed from that complete body. A route cannot select a journal path or transaction ID.

```text
TargetSnapshot = {
  snapshot_schema: "target-snapshot/v1",
  snapshot_id: UUID,
  target_ids: ExactList<StableId, stable_id>,
  topology_digest: Digest,
  topology_generation: uint64,
  layout_digest: Digest,
  disk_kind: "apfs" or "gpt" or "unknown",
  block_size_bytes: uint64,
  apfs_container_id: StableId or null, apfs_volume_id: StableId or null,
  mount_generation: uint64, snapshot_generation: uint64,
  total_bytes: uint64,
  used_bytes: uint64,
  available_bytes: uint64,
  required_bytes: uint64,
  reserve_bytes: uint64,
  headroom_bytes: uint64,
  observed_at: Timestamp,
  expires_at: Timestamp,
  source_evidence_digest: Digest
}

CapacityReservation = {
  reservation_schema: "capacity-reservation/v1",
  reservation_id: UUID,
  transaction_id: UUID,
  target_id: StableId,
  target_snapshot_digest: Digest,
  plan_digest: Digest,
  bytes_reserved: uint64,
  reserved_at: Timestamp,
  expires_at: Timestamp,
  state: "active" or "released" or "committed",
  reservation_digest: Digest
}

CacheEntry = {
  entry_id: LowerAsciiToken,
  artifact_id: ArtifactId,
  content_digest: Digest,
  payload_digest: Digest,
  size_bytes: uint64,
  verification_receipt_digest: Digest,
  schema_set_digest: Digest,
  binding_identity: BindingIdentity,
  source_generation: uint64,
  expires_at: Timestamp,
  relative_cache_path: PathToken,
  file_mode: "0600" or "0644"
}
CacheSet = {
  cache_set_schema: "verified-cache-set/v1",
  cache_set_id: UUID,
  manifest_id: DocumentId,
  manifest_digest: Digest,
  plan_digest: Digest,
  entries: ExactList<CacheEntry, entry_id>,
  complete_required_set: true,
  set_digest: Digest
}
MutationStep = {
  sequence: uint64, step_id: LowerAsciiToken, primitive_id: LowerAsciiToken,
  operation: F02Operation, target_ids: ExactList<StableId, stable_id>,
  precondition_digest: Digest, input_digests: ExactList<Digest, value>,
  expected_effect_digest: Digest, postcondition_digest: Digest,
  rollback_action_digest: Digest, irreversible: true
}
BootLineage = {predecessor: LineageTuple or null, target: LineageTuple,
               expected_counter: uint64, source_generation: uint64}

FinalConsent = {
  consent_schema: "final-consent/v1",
  consent_id: UUID, admission_identity_digest: Digest,
  transaction_id: UUID,
  owner_proof_receipt_id: ArtifactId,
  target_account_record_id: ArtifactId,
  operation: ProductOperation, scope: ProductScope, route_id: LowerAsciiToken,
  target_snapshot_digest: Digest, capacity_requirement_digest: Digest,
  plan_digest: Digest, mutation_list_digest: Digest, cache_set_digest: Digest,
  ui_accessibility_receipt_digest: Digest,
  decision: "consent",
  confirmed_at: Timestamp,
  expires_at: Timestamp,
  nonce: Nonce,
  replay_id: UUID,
  consent_digest: Digest
}
```

Capacity arithmetic is checked without wrap: `available_bytes >= required_bytes + reserve_bytes`, `required_bytes + reserve_bytes <= total_bytes`, and every integer operation is checked before addition. `layout_digest`, disk kind, block size, APFS container and volume identities, mount generation, and target snapshot generation are part of the target identity. A stale, missing, divergent, permission-denied, or insufficient reservation is `CAPACITY_INSUFFICIENT` or `JOURNAL_FAILURE` according to the precedence table.

The cache is content-addressed and complete before final consent. The request contains cache digests and relative cache tokens, never a URL. Each entry is verified for bytes, size, schema set, binding, mode, source generation, and expiry. After consent, network access is denied at the executor boundary; a cache miss, substitution, redirect, package-manager lookup, or fetch is a typed failure and never a retry through an arbitrary source.

Transaction ID allocation and a pending-consent journal header are metadata-only operations. They do not mutate the target. The exact mutation order is:

```text
OPEN_READ_ONLY -> VERIFY_DEPENDENCIES -> VERIFY_IDENTITY -> VERIFY_PLAN
-> VERIFY_CACHE -> ALLOCATE_TRANSACTION -> WRITE_PENDING_JOURNAL -> RENDER_CONSENT
-> VERIFY_FINAL_CONSENT -> WRITE_CONSENT_EVENT -> RESERVE_TARGET -> REVALIDATE_TARGET
-> PREPARE_STAGED_CONTENT -> STEP_START -> PRIMITIVE -> POSTCONDITION
-> REVALIDATE_TARGET -> ... repeated in declared sequence ...
-> ATOMIC_COMMIT -> VERIFY_BOOT -> WRITE_EVIDENCE_ONLY -> CLOSE_JOURNAL
```

No mutation, package lookup, network fetch, firmware write, DTB write, boot selection, disk/APFS operation, or service mutation occurs before final consent. Every irreversible step has a declared `step_id`, `primitive_id`, stable target IDs, input digests, precondition digest, postcondition digest, and one rollback action. The primitive checks the live transaction immediately before mutation and records the postcondition immediately after. A process exit code alone is never a postcondition.

`P01.ExecutorRequest/v1` is closed and has exactly:

```text
ExecutorRequest = {
  transaction_id: UUID, admission_identity_digest: Digest, journal_id: UUID,
  operation: ProductOperation, scope: ProductScope,
  route_id: LowerAsciiToken, owner_proof: OwnerProofReceipt,
  target_account: TargetAccount, target_snapshot: TargetSnapshot,
  capacity_reservation: CapacityReservation, verified_cache: CacheSet,
  plan_digest: Digest, mutation_list_digest: Digest, final_consent: FinalConsent,
  mutation_list: ExactList<MutationStep, sequence>, boot_lineage: BootLineage
}
ExecutorResult = {
  transaction_id: UUID, admission_identity_digest: Digest, journal_id: UUID,
  transaction_identity_digest: Digest,
  operation: ProductOperation, scope: ProductScope, plan_digest: Digest,
  mutation_list_digest: Digest, target_ids: ExactList<StableId, stable_id>,
  qualification_provenance: ExactList<QualificationRef, qualification_record_id>,
  state: StateId, code: ErrorCode or ResultCode, path: JsonPath or LowerAsciiToken,
  phase: Phase, process_status: Status, completed_steps: ExactList<StepRef, step_id>,
  rollback_state: RollbackState, boot_lineage: BootLineage,
  journal_chain_digest: Digest, result_digest: Digest
}
```

`ExecutorRequest` is created only after final consent has been verified; the request's metadata allocation cannot invoke a primitive. `ExecutorResult` is a result projection, not an authority-bearing boot or promotion record. A missing field, substituted target, altered cache set, changed consent, or transaction identity mismatch returns the first exact registry row and cannot be repaired by a route or environment value.

## 8. Exhaustive current route and privileged-mutator graph

This is a source census, not a claim that the current tree is safe. The graph is closed over the exact live base snapshot and includes every file in the scoped product roots, not merely representative routes.

```text
BASE_COMMIT = 95ffbc41a6d5d5356c217e503b51f3f7c3bd80f1
ROOTS = [install.sh, bin, install, default/omarchy/omarchy-menu.jsonc]
SOURCE_NODES = 563 files from install.sh plus every file under bin and install
BIN_NODE_COUNT = 458
INSTALL_NODE_COUNT = 104
RELEVANT_ROUTE_MUTATOR_PATHS = 123 source paths: install.sh plus every bin/omarchy-* path whose first token is apply, channel, install, migrate, pkg, provision, refresh, reinstall, remove, update, or upgrade
BASE_PATH_SET_SHA256 = sha256:03b62f5693f9080c183bd3a40249ca5ead9b274c87ed40bb5199abe3f2492dc
RELEVANT_ROUTE_MUTATOR_PATH_SET_SHA256 = sha256:d5682e84433723d72e88c45102daa867681e6283e037e994edafc5052c1ffa7a
BIN_TREE_ID = f11f7222f51da7cff7383e7505510e8656fefb3e
INSTALL_TREE_ID = 6af308308bafa310b23ade52b08a761cf7fc46f7
INSTALL_SH_BLOB_ID = 1189095e4fa14709256b505e9637e119a0692aeb
MENU_BLOB_ID = 59582db734570d1fa7b346f7b53541a3343cc45f
MENU_ACTION_COUNT = 270
MENU_ACTION_LINES_SHA256 = sha256:e6b5a3c874a397d54005d3beb776acead9bcef47d9f65be4813d2c88edaa7620
```

The source path set is mechanically reproduced only from these non-opaque roots:

```text
{ printf '%s\n' install.sh;
  git ls-tree -r --name-only 95ffbc41a6d5d5356c217e503b51f3f7c3bd80f1 -- bin install;
} | LC_ALL=C sort -u

{ printf '%s\n' install.sh;
  git ls-tree -r --name-only 95ffbc41a6d5d5356c217e503b51f3f7c3bd80f1 -- bin install \
    | rg '^bin/omarchy-(apply|channel|install|migrate|pkg|provision|refresh|reinstall|remove|update|upgrade)';
} | LC_ALL=C sort -u

git show 95ffbc41a6d5d5356c217e503b51f3f7c3bd80f1:default/omarchy/omarchy-menu.jsonc \
  | rg '"action"[[:space:]]*:'
```

The route graph artifact must contain one `RouteNode` for every source node and one menu edge for every parsed action. It is invalid to publish only 21 route rows or to aggregate a directory into one node.

```text
RouteNode = {
  node_id: LowerAsciiToken,
  path: RelativeRepoPath,
  blob_digest: Digest,
  node_kind: "root" or "command" or "install-leaf" or "service" or "asset",
  route_key: LowerAsciiToken or null,
  metadata_digest: Digest or null,
  parent_node_ids: ExactList<LowerAsciiToken, node_id>,
  outgoing_edge_ids: ExactList<LowerAsciiToken, edge_id>,
  privilege_class: "read-only" or "user" or "root" or "user-or-root" or "broker-only" or "forbidden",
  mutation_class: MutationClass,
  required_guard: GuardId,
  status: "UNSAFE_BASELINE" or "DESIGN_ONLY" or "IMPLEMENTED_AND_VERIFIED"
}
RouteEdge = {
  edge_id: LowerAsciiToken,
  from_node_id: LowerAsciiToken,
  to_node_id: LowerAsciiToken or null,
  edge_kind: "router" or "metadata" or "menu-action" or "menu-condition" or "alias"
              or "literal-source" or "literal-exec" or "primitive" or "dynamic",
  source_pointer: SourcePointer, menu_key: LowerAsciiToken or null,
  command_token: SourceText,
  privilege_class: "read-only" or "user" or "root" or "user-or-root" or "broker-only" or "forbidden",
  mutation_class: MutationClass,
  guard: GuardId,
  expected_result: ErrorCode or ResultCode
}
MenuEntry = {
  menu_key: LowerAsciiToken, action: SourceText or null, when: SourceText or null,
  checked: SourceText or null, disabled: SourceText or null, aliases: ExactList<LowerAsciiToken, alias>
}
```

The graph generator is exact: a literal `source` or `.` path under the roots creates a `literal-source` edge; a literal executable token creates a `literal-exec` edge; a token in the closed primitive set creates a `primitive` edge; each menu `action`, `when`, `checked`, and `disabled` expression produces a `menu-action` or `menu-condition` edge; aliases produce `alias` edges. `eval`, `bash -c`, variable `source`, variable `exec`, command substitution used as a command, or unresolved menu action creates a `dynamic` edge that is forbidden. `bin/omarchy` metadata is read only from its first 80 lines and route keys are compared with the repository command registry. A missing source node, unresolved edge, duplicate route key, path alias, dynamic edge, or unclassified primitive is a CI failure, not an ignored path.

The privileged primitive set is closed to `pacman`, `paru`, `yay`, `fwupdmgr`, `install`, `cp`, `mv`, `rm`, `ln`, `tee`, `dd`, `mount`, `umount`, `mkfs`, `btrfs`, `systemctl`, `loginctl`, `useradd`, `usermod`, `passwd`, `chown`, `chmod`, `setfacl`, `git clone`, `git fetch`, `git checkout`, `git reset`, `curl`, `wget`, `flatpak`, `reboot`, `shutdown`, `efibootmgr`, `mkinitcpio`, and every direct `sudo` or `pkexec` invocation. Each occurrence receives a source pointer and a `MutationClass` such as `package`, `config`, `service`, `firmware`, `dtb`, `boot`, `storage`, `account`, `channel`, `migration`, `diagnostics`, `upload`, or `reboot`. A future broker guard is required at every edge, not only at the public command.

The privileged occurrence inventory is also closed; a path-only count is not sufficient. Its record is:

```text
PrimitiveOccurrence = {
  occurrence_id: LowerAsciiToken, source_pointer: SourcePointer,
  primitive_token: one exact member of the privileged primitive set,
  enclosing_node_id: LowerAsciiToken, incoming_edge_id: LowerAsciiToken,
  argument_digest: Digest, privilege_class: "user" or "root" or "broker-only" or "forbidden",
  mutation_class: MutationClass, required_guard: GuardId,
  current_status: "UNSAFE_BASELINE" or "NOT_PRESENT" or "IMPLEMENTED_AND_VERIFIED",
  expected_result: ErrorCode or ResultCode
}
RouteGraph = {
  graph_schema: "product-route-graph/v1",
  base_commit: FullCommitId,
  source_path_set_digest: Digest, menu_action_lines_digest: Digest,
  source_nodes: ExactList<RouteNode, node_id>,
  edges: ExactList<RouteEdge, edge_id>,
  primitive_occurrences: ExactList<PrimitiveOccurrence, occurrence_id>,
  graph_digest: Digest, occurrence_set_digest: Digest
}
```

The exact base graph artifact must publish every `PrimitiveOccurrence`, including occurrences in comments only when the parser classifies them as non-executable and records that classification, and must publish a canonical occurrence-set digest. A shell lexical scan, a count of command names, or a clean syntax result is not a graph. In this docs-only lane the graph artifact is `NOT_IMPLEMENTED`; every scoped source node and occurrence remains `UNSAFE_BASELINE`, and no current route is thereby accepted.

### 8.1 Product route families and explicit omitted base paths

The 25 product route families are projections over the full graph and are not the graph itself: `install`, `setup`, `apply-system`, `apply-hardware`, `provision-owner`, `provision-user`, `first-run`, `channel-set`, `update`, `update-system-pkgs`, `update-dev`, `update-firmware`, `reinstall-pkgs`, `update-restart`, `upgrade-to-quattro-mac`, `pkg-add`, `pkg-drop`, `refresh-pacman`, `refresh-config`, `migrate`, `debug`, `admission`, `omarchy-platform`, `install/helpers`, and forbidden direct or dynamic invocation. Every family must resolve to the source-node and edge records above.

The family projection is itself closed:

```text
route_id,entry_point,route_class,edge_target,privilege_class,mutation_class
ROUTE-01,install.sh,adapter,admission.open,root,system
ROUTE-02,bin/omarchy-mac-setup,adapter,admission.open,root,system
ROUTE-03,bin/omarchy-apply-system,adapter,broker,root,system
ROUTE-04,bin/omarchy-apply-hardware,adapter,broker,root,hardware
ROUTE-05,bin/omarchy-provision-owner,adapter,I-03,root,account
ROUTE-06,bin/omarchy-provision-user,adapter,I-03,user,user
ROUTE-07,bin/omarchy-provision-first-run,adapter,I-03,user,user
ROUTE-08,bin/omarchy-channel-set,adapter,I-04,root,channel
ROUTE-09,bin/omarchy-update,adapter,I-04,root,update
ROUTE-10,bin/omarchy-update-system-pkgs,adapter,broker,root,package
ROUTE-11,bin/omarchy-update-dev,development-only,forbidden,root,channel
ROUTE-12,bin/omarchy-update-firmware,forbidden,forbidden,root,firmware
ROUTE-13,bin/omarchy-reinstall-pkgs,adapter,broker,root,package
ROUTE-14,bin/omarchy-update-restart,adapter,I-04,root,service
ROUTE-15,bin/omarchy-upgrade-to-quattro-mac,adapter,I-03,root,system
ROUTE-16,bin/omarchy-pkg-add,adapter,broker,root,package
ROUTE-17,bin/omarchy-pkg-drop,adapter,broker,root,package
ROUTE-18,bin/omarchy-refresh-pacman,adapter,broker,root,package
ROUTE-19,bin/omarchy-refresh-config,adapter,broker,user-or-root,config
ROUTE-20,bin/omarchy-migrate,adapter,I-04,root,migration
ROUTE-21,bin/omarchy-debug,adapter,read-only,user,diagnostics
ROUTE-22,bin/omarchy-admission,proposed,construct_trusted,broker-only,read-only
ROUTE-23,omarchy-platform,proposed,I-04,broker-only,all-privileged
ROUTE-24,install/helpers,leaf,broker,root,all-privileged
ROUTE-25,direct-copied-generated-dynamic,forbidden,none,forbidden,all-privileged
```

The exact 123-path relevant set, recomputed from the predicate above, is:

```text
bin/omarchy-apply-hardware
bin/omarchy-apply-lock
bin/omarchy-apply-system
bin/omarchy-channel-current
bin/omarchy-channel-set
bin/omarchy-install-1password
bin/omarchy-install-ai-chatgpt
bin/omarchy-install-and-launch
bin/omarchy-install-app
bin/omarchy-install-browser
bin/omarchy-install-chromium-copy-url
bin/omarchy-install-chromium-google-account
bin/omarchy-install-chromium-ytdlp
bin/omarchy-install-cursor
bin/omarchy-install-dev-env
bin/omarchy-install-docker-dbs
bin/omarchy-install-editor-emacs
bin/omarchy-install-editor-helix
bin/omarchy-install-editor-vscode
bin/omarchy-install-editor-zed
bin/omarchy-install-font
bin/omarchy-install-gaming-battlenet
bin/omarchy-install-gaming-geforce-now
bin/omarchy-install-gaming-gpu-lib32
bin/omarchy-install-gaming-heroic
bin/omarchy-install-gaming-lutris
bin/omarchy-install-gaming-retroarch
bin/omarchy-install-gaming-steam
bin/omarchy-install-gaming-xbox-cloud
bin/omarchy-install-gaming-xbox-controllers
bin/omarchy-install-preinstalls
bin/omarchy-install-service-1password
bin/omarchy-install-service-dropbox
bin/omarchy-install-service-nordvpn
bin/omarchy-install-service-once
bin/omarchy-install-service-signal
bin/omarchy-install-service-spotify
bin/omarchy-install-service-sunshine
bin/omarchy-install-service-tailscale
bin/omarchy-install-terminal
bin/omarchy-installed-service-dropbox
bin/omarchy-installed-service-tailscale
bin/omarchy-migrate
bin/omarchy-migrate-notify
bin/omarchy-pkg-add
bin/omarchy-pkg-aur-accessible
bin/omarchy-pkg-aur-add
bin/omarchy-pkg-aur-install
bin/omarchy-pkg-drop
bin/omarchy-pkg-install
bin/omarchy-pkg-missing
bin/omarchy-pkg-present
bin/omarchy-pkg-publish-aarch64
bin/omarchy-pkg-remove
bin/omarchy-provision-first-run
bin/omarchy-provision-owner
bin/omarchy-provision-user
bin/omarchy-refresh-applications
bin/omarchy-refresh-chromium
bin/omarchy-refresh-config
bin/omarchy-refresh-herdr
bin/omarchy-refresh-hyprland
bin/omarchy-refresh-hyprsunset
bin/omarchy-refresh-limine
bin/omarchy-refresh-pacman
bin/omarchy-refresh-pacman-mirrorlist
bin/omarchy-refresh-plymouth
bin/omarchy-refresh-sddm
bin/omarchy-refresh-shell
bin/omarchy-refresh-tmux
bin/omarchy-reinstall
bin/omarchy-reinstall-configs
bin/omarchy-reinstall-pkgs
bin/omarchy-remove-ai-chatgpt
bin/omarchy-remove-ai-grok-bot
bin/omarchy-remove-ai-lm-studio
bin/omarchy-remove-ai-ollama
bin/omarchy-remove-ai-t3-code
bin/omarchy-remove-browser
bin/omarchy-remove-dev-env
bin/omarchy-remove-gaming-battlenet
bin/omarchy-remove-gaming-geforce-now
bin/omarchy-remove-gaming-heroic
bin/omarchy-remove-gaming-lutris
bin/omarchy-remove-gaming-minecraft
bin/omarchy-remove-gaming-retroarch
bin/omarchy-remove-gaming-steam
bin/omarchy-remove-gaming-xbox-cloud
bin/omarchy-remove-gaming-xbox-controllers
bin/omarchy-remove-launcher-entry
bin/omarchy-remove-preinstalls
bin/omarchy-remove-security-fido2
bin/omarchy-remove-security-fingerprint
bin/omarchy-remove-security-sshd
bin/omarchy-remove-security-sudoless-docker
bin/omarchy-remove-service-1password
bin/omarchy-remove-service-dropbox
bin/omarchy-remove-service-sunshine
bin/omarchy-remove-service-tailscale
bin/omarchy-update
bin/omarchy-update-analyze-logs
bin/omarchy-update-aur-pkgs
bin/omarchy-update-available
bin/omarchy-update-confirm
bin/omarchy-update-dev
bin/omarchy-update-firmware
bin/omarchy-update-keyring
bin/omarchy-update-lock
bin/omarchy-update-mise
bin/omarchy-update-orphan-pkgs
bin/omarchy-update-pacman-guard
bin/omarchy-update-pkg-prune
bin/omarchy-update-requires-free-space
bin/omarchy-update-restart
bin/omarchy-update-status
bin/omarchy-update-stay-awake
bin/omarchy-update-system-pkgs
bin/omarchy-update-system-pkgs-when-conflicted
bin/omarchy-update-time
bin/omarchy-update-user-notify
bin/omarchy-upgrade-to-quattro
bin/omarchy-upgrade-to-quattro-mac
install.sh
```

The graph also includes all direct menu actions from the exact menu blob, all command metadata routes, all `install/**` leaves and services, and every direct or transitive edge from `install.sh`. An action with no matching command node, a copied leaf, a sourced leaf, a generated wrapper, an environment-only fallback, a raw package or firmware primitive, a development channel, or an arbitrary reference is a forbidden edge with the exact error row from section 5. The base graph is a coverage input; it is not a product admission implementation. `ROUTE-01` through `ROUTE-25` are projections over this graph; they do not replace the 563 source nodes, 123 relevant paths, 270 menu action edges, or every primitive occurrence.

### 8.2 Current unsafe observations and required guards

The live base remains unsafe relative to this contract. These observations are recorded as residuals, not fixed behavior:

| Base path | Current unsafe behavior | Required typed outcome |
| --- | --- | --- |
| `install.sh` | unknown Apple identity warns and continues | `TRUST_FAILURE` before package or source access |
| `bin/omarchy-pkg-add` | an unavailable or filtered package can print `Skipping` and exit 0 | `CACHE_MISS` or `PLAN_MISMATCH`, never success for required package |
| `bin/omarchy-pkg-remove` | the menu exposes a direct package-removal primitive | `FORBIDDEN_ROUTE` before package action; only a declared I-04 step may remove |
| `bin/omarchy-remove-preinstalls` | the menu exposes a direct preinstall-removal route | `FORBIDDEN_ROUTE` before package or marker mutation |
| `bin/omarchy-channel-set` | `dev` can select a mutable remote and invoke package mutation | `FORBIDDEN_ROUTE` before checkout or package action |
| `bin/omarchy-mac-setup` | `--repo` and `--ref` are accepted by the current command grammar | `FORBIDDEN_ROUTE` before source access |
| `bin/omarchy-upgrade-to-quattro-mac` | arbitrary `--ref` is advertised | `FORBIDDEN_ROUTE` before checkout replacement |
| `bin/omarchy-update-firmware` | raw EFI install and `fwupdmgr` mutation are reachable | `FORBIDDEN_ROUTE` until a manifest-bound I-04 step exists |
| `bin/omarchy-update-time` | the menu exposes a direct system-time mutation route | `FORBIDDEN_ROUTE` until a typed, manifest-bound executor step exists |
| `bin/omarchy-debug` | current diagnostics can copy raw logs or upload to the public log endpoint | `SUPPORT_BUNDLE_REDACTION_FAILED` or `UPLOAD_CONSENT_MISSING` before persistence or network |
| `install/helpers/logging.sh` | current logging creates a world-writable log artifact | `LOCAL_BUNDLE_WRITE_FAILURE` until the fixed allowlist and mode `0600` are enforced |
| `bin/omarchy-refresh-config` | caller path is interpolated without the promised traversal and symlink guard | `PATH_TRAVERSAL` before read or write |
| `bin/omarchy-apply-system`, `bin/omarchy-apply-hardware`, `bin/omarchy-provision-user` | environment fallback can supply `OMARCHY_PATH` or `OMARCHY_INSTALL` | `OMARCHY_PATH_MISSING` with no fallback |

No current route is allowed to claim safety, support, compatibility, or release readiness from this table. `OMARCHY_PATH` is a required existing absolute environment value for packaged code; it is not a trust input and cannot be defaulted, re-exported, or supplied by a caller to bypass admission.

## 9. F-06 and F-07 evidence handoffs

P-03 and P-05 produce evidence only. They do not write stable state, select a channel, qualify a board, issue boot authority, or replace F-07. The following artifact IDs and preimages are the exact proposed handoff contract; `HOLD-03` and `HOLD-04` remain until F-06 and F-07 ratify their receipts.

```text
HandoffEnvelope = {
  handoff_schema: "product-handoff/v1",
  handoff_id: LowerAsciiToken,
  artifact_id: ArtifactId,
  document_id: DocumentId,
  producer: LowerAsciiToken,
  consumer: LowerAsciiToken,
  owner: LowerAsciiToken,
  due_before_gate: LowerAsciiToken,
  scope: HandoffScope,
  payload_digest: Digest,
  content_digest: Digest,
  preimage_id: LowerAsciiToken,
  schema_set_digest: Digest,
  binding_identity: BindingIdentity,
  candidate_id: ArtifactId,
  manifest_id: DocumentId,
  manifest_digest: Digest,
  board_profile_refs: ExactList<QualificationRef, qualification_record_id>,
  issued_at: Timestamp,
  expires_at: Timestamp,
  acceptance_artifact_id: ArtifactId,
  acceptance_artifact_digest: Digest,
  rejection: RejectionTuple
}
HandoffReceipt = {
  receipt_type: "F05" or "P03" or "P05" or "I09" or "B04" or "Q04" or "Q05" or "Q06" or "Q07" or "Q08",
  artifact_id: ArtifactId, document_id: DocumentId, content_digest: Digest,
  payload_digest: Digest, schema_set_digest: Digest, binding_identity: BindingIdentity,
  candidate_id: ArtifactId, manifest_id: DocumentId, manifest_digest: Digest,
  scope: HandoffScope, producer: LowerAsciiToken, issued_at: Timestamp, expires_at: Timestamp,
  acceptance_artifact_id: ArtifactId, acceptance_artifact_digest: Digest
}
```

| Handoff ID | Artifact and exact payload | Producer and owner | Consumer and due gate | Scope and identity bindings | Rejection |
| --- | --- | --- | --- | --- | --- |
| `HANDOFF-01` | `P03.PARITY-CENSUS.V1`, document `p03.parity.v1:candidate_id:revision_decimal`; payload has exact command route IDs, operation/scope, parity status, source blob digests, capability outcomes, residual refs, and candidate/manifest refs | P-03 census generator; P-03 owner | F-06 intake and F-07; due before F-07 | scope `P03/parity`; exact candidate, manifest, board/profile, qualification, route-graph, schema-set, binding, authority, and verified-clock digests | `PROMOTION_INTAKE_INVALID` at `promotion.intake`, phase `promotion`, status 3, reject |
| `HANDOFF-02` | `P05.UPDATE-EVIDENCE.V1`, document `p05.update.v1:transaction_id:revision_decimal`; payload has transaction, plan, target, cache, consent, capacity, mutation, journal, boot-health, success-mark, slot, lineage, counter, rollback, and result refs | P-05 evidence producer; P-05 owner | F-06 intake and F-07; due before F-07 | scope `P05/update-evidence`; exact board, candidate, manifest, qualification, transaction, cache, target, health, lineage, slot, generation, counter, and clock bindings | `PROMOTION_INTAKE_INVALID` at `promotion.intake`, phase `promotion`, status 3, reject |
| `HANDOFF-03` | `F06.COMPLIANCE-INTAKE.V1`, document `f06.compliance.v1:candidate_id:revision_decimal`; payload has F-05 receipt, P-03 receipt, P-05 receipt, I-09 receipt, B-04 receipt, Q-04, Q-05, Q-06, Q-07, Q-08 receipts, legal inventory, owner decision, conformance, candidate, rollback, ledger, and required-slice closure | F-06 compliance owner; F-06 owner | F-07 promotion terminal; due before promotion | scope `F06/compliance`; exact candidate, manifest, product, installer, boot, qualification, legal, rollback, ledger, authority, policy, schema-set, binding, clock, and expiry bindings | missing, unratified, stale, incomplete, or mismatched is `DEPENDENCY_UNRATIFIED` at `dependency.check`, phase `dependency`, status 4, hold |
| `HANDOFF-04` | `F07.PROMOTION-EVIDENCE.V1`, document `f07.promotion.v1:candidate_id:revision_decimal`; payload has exact required-slice closure, candidate and rollback digests, applicable signed qualification records, compliance attestation, public-ledger projection, channel target, product handoff digests, and the F-07 decision | F-07 promotion terminal; F-07 owner | F-07 sole stable-channel writer; due before atomic digest copy | scope `F07/promotion`; exact candidate, manifest, board/profile, qualification, transaction, health, lineage, slot, generation, counter, authority, policy, legal, rollback, and ledger bindings | `PROMOTION_INTAKE_INVALID` at `promotion.intake`, phase `promotion`, status 3, reject; product cannot write |

The four handoff payloads are closed as follows. `receipts` is an exact named list, not a free-form map:

```text
P03ParityPayload = {
  candidate_id: ArtifactId, manifest_id: DocumentId, manifest_digest: Digest,
  route_graph_commit: FullCommitId, route_graph_digest: Digest,
  route_results: ExactList<RouteResult, route_id>, capability_results: ExactList<CapabilityResult, capability_id>,
  residuals: ExactList<ResidualRef, residual_id>, qualification_refs: ExactList<QualificationRef, qualification_record_id>,
  generated_at: Timestamp, expires_at: Timestamp
}
P05UpdateEvidencePayload = {
  candidate_id: ArtifactId, manifest_id: DocumentId, manifest_digest: Digest,
  transaction_id: UUID, transaction_identity_digest: Digest, plan_digest: Digest,
  mutation_list_digest: Digest, target_snapshot_digest: Digest, capacity_reservation_digest: Digest,
  cache_set_digest: Digest, final_consent_digest: Digest, journal_chain_digest: Digest,
  boot_health_document_id: DocumentId, boot_health_payload_digest: Digest,
  boot_success_document_id: DocumentId, boot_success_payload_digest: Digest,
  slot_id: SlotId, slot_generation: uint64, lineage_id: UUID, attempt_counter: uint64,
  rollback_evidence_digest: Digest, result_digest: Digest, qualification_refs: ExactList<QualificationRef, qualification_record_id>,
  issued_at: Timestamp, expires_at: Timestamp
}
F06CompliancePayload = {
  candidate_id: ArtifactId, manifest_id: DocumentId, manifest_digest: Digest,
  receipts: ExactList<HandoffReceipt, receipt_type> in exact order
             [F05, P03, P05, I09, B04, Q04, Q05, Q06, Q07, Q08],
  license_inventory_digest: Digest, notice_bundle_digest: Digest, source_offer_digest: Digest,
  owner_decision_log_entry_digest: Digest, conformance_receipt_digest: Digest,
  rollback_digest: Digest, public_ledger_projection_digest: Digest, required_slice_closure_digest: Digest,
  issued_at: Timestamp, expires_at: Timestamp
}
F07PromotionPayload = {
  candidate_id: ArtifactId, manifest_id: DocumentId, manifest_digest: Digest,
  rollback_digest: Digest, qualification_refs: ExactList<QualificationRef, qualification_record_id>,
  compliance_receipt_digest: Digest, parity_receipt_digest: Digest, update_evidence_digest: Digest,
  channel_target: "stable", public_ledger_projection_digest: Digest,
  required_slice_closure_digest: Digest, promotion_decision: "promote" or "reject",
  decision_log_entry_digest: Digest, issued_at: Timestamp, expires_at: Timestamp
}
```

All four handoffs use the explicit preimages in section 5: `payload_digest` uses `P01_HANDOFF_PAYLOAD_DIGEST(H, P)` over the exact envelope `H` and payload `P` without digest fields, and `content_digest` uses `CONTENT_DIGEST(E)` over the complete canonical envelope bytes. The F-02 payload references retain `F02_PAYLOAD_DIGEST` and are never silently recomputed under a product label. The handoff `acceptance_artifact_digest` is outside the input preimage and points to the immutable consumer receipt. F-07 never accepts a section reference in place of a digest-addressed receipt. P-03, P-05, or a product route attempting to copy stable-channel state is `FORBIDDEN_ROUTE`.

## 10. Total recovery, journal, and lineage

The recovery machine has 13 states, all terminal and nonterminal behavior is explicit, and no `ANY` transition is permitted. `MAX_RECOVERY_ATTEMPTS = 3` per transaction. `rollback_depth` starts at 0 and may become 1 exactly once; a rollback failure or second rollback request enters quarantine and then tombstone, never recursive rollback.

```text
JournalHeader = {
  journal_schema: "executor-journal/v1",
  journal_id: UUID,
  transaction_id: UUID,
  transaction_identity_digest: Digest,
  owner_account_id: AccountId,
  plan_digest: Digest,
  target_snapshot_digest: Digest,
  state: StateId,
  sequence: uint64,
  chain_digest: Digest,
  rollback_depth: 0 or 1,
  attempt_count: uint16,
  tombstone_digest: Digest or null
}
LineageTuple = {lineage_id: UUID, source_generation: uint64, slot_generation: uint64,
                attempt_counter: uint64}
JournalEvent = {
  event_schema: "executor-journal-event/v1",
  journal_id: UUID,
  transaction_id: UUID,
  sequence: uint64,
  previous_chain_digest: Digest,
  event_id: EventId,
  state_before: StateId,
  state_after: StateId,
  step_id: LowerAsciiToken or null,
  target_snapshot_digest: Digest,
  precondition_digest: Digest or null,
  postcondition_digest: Digest or null,
  result_code: ErrorCode or ResultCode, process_status: Status, decision: Decision,
  rollback_depth: 0 or 1,
  event_digest: Digest
}
Tombstone = {
  tombstone_schema: "transaction-tombstone/v1",
  transaction_id: UUID,
  transaction_identity_digest: Digest,
  journal_chain_digest: Digest,
  last_state: StateId,
  attempt_count: uint16,
  predecessor_lineage: LineageTuple,
  terminal_code: ErrorCode or ResultCode,
  terminal_result_digest: Digest,
  terminal_path: JsonPath or LowerAsciiToken,
  terminal_phase: Phase,
  terminal_process_status: Status, terminal_decision: Decision,
  closed_at: Timestamp,
  redacted_evidence_digest: Digest,
  tombstone_digest: Digest
}
```

The state IDs and meanings are:

| State ID | State | Allowed events and meaning |
| --- | --- | --- |
| `STATE-01` | `pending_consent` | `consent_accepted`, `cancel_before_consent`, `interrupt_before_consent` |
| `STATE-02` | `consented` | `reserve_verified`, `cancel_before_reserve`, `interrupt_before_reserve` |
| `STATE-03` | `reserved` | `step_started`, `cancel_after_reserve`, `interrupt_reserved` |
| `STATE-04` | `applying` | `step_verified`, `step_failed`, `cancel_during_step`, `interrupt_applying` |
| `STATE-05` | `verifying` | `commit_verified`, `postcondition_failed`, `target_changed`, `interrupt_verifying` |
| `STATE-06` | `committed` | `health_evaluation_started`, `interrupt_committed` |
| `STATE-07` | `evaluating` | `health_passed`, `health_failed`, `health_stale`, `interrupt_evaluating` |
| `STATE-08` | `recovering` | `resume_to_applying`, `resume_to_verifying`, `rollback_once`, `rollback_again`, `abort_after_recovery`, `rollback_failed`, `attempt_limit_reached`, `interrupt_recovering`, `accessibility_failure` |
| `STATE-09` | `rolled_back` | `close_rolled_back`, `duplicate_exact_terminal` |
| `STATE-10` | `quarantined` | `write_quarantine_evidence`, `close_quarantine`, `duplicate_tombstoned` |
| `STATE-11` | `aborted` | `close_aborted`, `duplicate_exact_terminal` |
| `STATE-12` | `closed` | `duplicate_exact_terminal`, `duplicate_conflicting`, `unknown_terminal_event` |
| `STATE-13` | `tombstoned` | `duplicate_tombstoned`, `unknown_terminal_event`; no mutation, resume, or rollback |

The complete transition table is:

| From | Event | Guard | To | Exact result |
| --- | --- | --- | --- | --- |
| `pending_consent` | `consent_accepted` | fresh final consent, exact plan, target, cache, accessibility receipt | `consented` | `VALID` |
| `pending_consent` | `cancel_before_consent` | no mutation and no reservation | `aborted` | `USER_CANCELLED_BEFORE_CONSENT` |
| `pending_consent` | `interrupt_before_consent` | journal durable, no mutation | `aborted` | `POWER_LOSS_INTERRUPTED` |
| `consented` | `reserve_verified` | journal, target, capacity, cache, privilege all verify | `reserved` | `VALID` |
| `consented` | `cancel_before_reserve` | no reservation or mutation | `aborted` | `USER_CANCELLED_BEFORE_CONSENT` |
| `consented` | `interrupt_before_reserve` | journal durable, no mutation | `aborted` | `POWER_LOSS_INTERRUPTED` |
| `reserved` | `step_started` | declared step and target revalidated | `applying` | `VALID` |
| `reserved` | `cancel_after_reserve` | rollback action available and depth 0 | `recovering` | `USER_CANCELLED_AFTER_RESERVE` |
| `reserved` | `interrupt_reserved` | reservation and journal durable | `recovering` | `POWER_LOSS_INTERRUPTED` |
| `applying` | `step_verified` | postcondition and target revalidated | `verifying` | `VALID` |
| `applying` | `step_failed` | failure journaled, rollback action exists | `recovering` | `STEP_POSTCONDITION_FAILED` |
| `applying` | `cancel_during_step` | primitive stopped at safe boundary | `recovering` | `USER_CANCELLED_AFTER_RESERVE` |
| `applying` | `interrupt_applying` | event durable before or after primitive is identified | `recovering` | `POWER_LOSS_INTERRUPTED` |
| `verifying` | `commit_verified` | exact postconditions, target, and journal chain verify | `committed` | `VALID` |
| `verifying` | `postcondition_failed` | exact rollback action available | `recovering` | `STEP_POSTCONDITION_FAILED` |
| `verifying` | `target_changed` | target differs at protected boundary | `recovering` | `TARGET_REVALIDATION_FAILED` |
| `verifying` | `interrupt_verifying` | journal identifies commit boundary | `recovering` | `POWER_LOSS_INTERRUPTED` |
| `committed` | `health_evaluation_started` | atomic commit record is durable | `evaluating` | `VALID` |
| `committed` | `interrupt_committed` | commit record durable, health not evaluated | `evaluating` | `POWER_LOSS_INTERRUPTED` |
| `evaluating` | `health_passed` | full BOOT mapping and checks pass | `closed` | `CLOSED` |
| `evaluating` | `health_failed` | predecessor and rollback set verify, depth 0 | `recovering` | `BOOT_REQUIRED_CHECK_FAILURE` |
| `evaluating` | `health_stale` | health or clock is expired | `recovering` | `EXPIRY_OR_REPLAY_FAILURE` |
| `evaluating` | `interrupt_evaluating` | journal durable, no success inferred | `recovering` | `POWER_LOSS_INTERRUPTED` |
| `recovering` | `resume_to_applying` | state re-derived at a pre-primitive boundary, target and cache revalidated, attempt below 3 | `applying` | `VALID` |
| `recovering` | `resume_to_verifying` | state re-derived after a primitive, target and postcondition revalidated, attempt below 3 | `verifying` | `VALID` |
| `recovering` | `rollback_once` | depth 0, predecessor exact, target safe | `rolled_back` | `ROLLED_BACK` |
| `recovering` | `rollback_again` | rollback depth is already 1 | `quarantined` | `RECOVERY_RECURSION` |
| `recovering` | `abort_after_recovery` | no further mutation and evidence durable | `aborted` | `ABORTED` |
| `recovering` | `rollback_failed` | the one rollback action failed | `quarantined` | `RECOVERY_TERMINAL` |
| `recovering` | `attempt_limit_reached` | attempt count is exactly 3 before another resume | `quarantined` | `RECOVERY_TERMINAL` |
| `recovering` | `interrupt_recovering` | journal event durable | `recovering` | `POWER_LOSS_INTERRUPTED` |
| `recovering` | `accessibility_failure` | recovery controls cannot be restored and redacted evidence is durable | `quarantined` | `ACCESSIBILITY_RECOVERY_FAILED` |
| `rolled_back` | `close_rolled_back` | predecessor and evidence verify | `closed` | `CLOSED` |
| `rolled_back` | `duplicate_exact_terminal` | exact same transaction identity | `closed` | `ROLLED_BACK` |
| `quarantined` | `write_quarantine_evidence` | redacted evidence durable | `quarantined` | `QUARANTINED` |
| `quarantined` | `close_quarantine` | evidence receipt durable | `tombstoned` | `QUARANTINED` |
| `quarantined` | `duplicate_tombstoned` | transaction identity is tombstoned | `tombstoned` | `TRANSACTION_TOMBSTONED` |
| `aborted` | `close_aborted` | journal and evidence durable | `closed` | `CLOSED` |
| `aborted` | `duplicate_exact_terminal` | exact same transaction identity | `closed` | `ABORTED` |
| `closed` | `duplicate_exact_terminal` | exact transaction and result digest | `closed` | `CLOSED` |
| `closed` | `duplicate_conflicting` | same transaction ID with any changed identity | `tombstoned` | `DUPLICATE_TRANSACTION` |
| `closed` | `unknown_terminal_event` | event not in this table | `tombstoned` | `UNKNOWN_EVENT` |
| `tombstoned` | `duplicate_tombstoned` | any replay of tombstoned identity | `tombstoned` | `TRANSACTION_TOMBSTONED` |
| `tombstoned` | `unknown_terminal_event` | any other event | `tombstoned` | `UNKNOWN_EVENT` |

Every row writes one chained journal event before the state becomes visible; the event contains the row's exact result code, status, decision, state pair, and guard digest. A missing or torn event is `JOURNAL_FAILURE`; an event with a wrong previous chain digest is `JOURNAL_FAILURE`; a repeated sequence is `DUPLICATE_TRANSACTION`; an unknown state or event is `UNKNOWN_EVENT`. `attempt_count` starts at zero. Resume re-derives from the last durable record, never process memory. A `resume_to_applying` or `resume_to_verifying` event increments `attempt_count` exactly once after its guard passes and is allowed only when the prior count is below 3; `attempt_limit_reached` is the only transition when the count is exactly 3. Interruption, duplicate delivery, rollback, closure, and tombstoning never increment it. A rollback to another manifest or slot generation creates a new lineage ID and tombstones the old tuple; within one lineage, source generation, slot generation, and attempt counter are strictly monotonic and are compared from authenticated predecessor records. Counters are never reset, reused, wrapped, or inferred from a success marker. `close_rolled_back`, `close_aborted`, and `health_passed` require the terminal journal event, exact result digest, redacted evidence receipt, and released reservation; only then may the transaction be `closed`. Quarantine closure writes the tombstone before exposing `tombstoned`; the tombstone permanently binds transaction ID, identity digest, last journal chain digest, terminal code, terminal result, and closure time.

## 11. Privacy, accessibility, upload, retention, and deletion

The privacy result is machine-checkable and closed. Redaction occurs before journal, log, local bundle, or upload persistence. A field not in the allowlist is a failure, not an omitted warning.

```text
PrivacyReceipt = {
  receipt_schema: "privacy-outcome/v1",
  bundle_id: UUID,
  transaction_id: UUID or null,
  privacy_policy_id: PolicyId, privacy_policy_digest: Digest,
  allowlist_id: "support-allowlist/v1",
  allowlist_digest: Digest,
  redaction_input_digest: Digest,
  redacted_content_digest: Digest,
  local_mode: "0600",
  local_retention_deadline: Timestamp,
  deletion_requested_at: Timestamp or null,
  local_deletion_attempts: uint8,
  local_deletion_result: "deleted" or "not-found" or "failed" or null,
  local_deletion_evidence_digest: Digest or null,
  upload_consent_id: UUID or null,
  endpoint_id: "logs-omarchy-org-support-bundles-v1" or null,
  tls_verification_digest: Digest or null,
  remote_retention_deadline: Timestamp or null,
  remote_deletion_attempts: uint8 or null,
  remote_deletion_result: "deleted" or "not-found" or "failed" or null,
  remote_deletion_evidence_digest: Digest or null,
  audit_digest: Digest, result_code: ErrorCode or ResultCode,
  process_status: Status, decision: Decision
}
```

The closed support allowlist is `result_schema`, adapter identity, operation, scope, route ID, transaction pseudonym, journal chain digest, code, path, phase, process status, decision, safe next action, artifact/document/content/payload/schema/binding digests, authority and policy versions, verified-clock ID and quantized times, capability IDs and statuses, `board_id_pseudonym`, `qualification_profile_id_pseudonym`, and pseudonymized target, owner, and account IDs. The fixed allowlist has no policy escape: raw board/profile identifiers are forbidden, and a stricter policy may remove fields but may not add them. Raw account names, UIDs, proofs, target serials, disk or volume paths, environment values, credentials, keys, handles, MACs, package secrets, query-bearing URLs, raw command output, raw device-tree bytes, and raw firmware identifiers are never persisted.

The proposed privacy policy is local mode `0600`, local retention 30 days, immediate local deletion, upload opt-in through a second consent, one endpoint `https://logs.omarchy.org/v1/support-bundles`, verified TLS, no redirects, and remote retention 24 hours with deletion evidence. These values are design requirements, not current behavior; upload remains `PRIVACY_POLICY_UNRATIFIED` until its policy receipt is ratified. A stricter ratified policy may narrow the allowlist or retention, never widen it. Privacy checks run in this order: allowlist and redaction, local write and mode, local retention and deletion, second consent, endpoint and redirect, TLS, remote retention, remote deletion, then audit closure.

| Boundary | Required machine outcome |
| --- | --- |
| redaction sees an extra or secret field | `PRIVACY_FIELD_FORBIDDEN` at the first disallowed field, no persistence |
| redaction digest or proof cannot be produced after the allowlist passes | `SUPPORT_BUNDLE_REDACTION_FAILED`, no persistence |
| local file cannot be created, is not mode 0600, or disk is full | `LOCAL_BUNDLE_WRITE_FAILURE`, no partial bundle or upload |
| local deletion cannot be proven | `DELETION_FAILURE`; no upload; retry deletion exactly three times then terminal failure |
| upload not explicitly requested | `UPLOAD_CONSENT_MISSING`, no network |
| endpoint differs or redirects | `FORBIDDEN_ROUTE`, no upload |
| TLS validation fails | `UPLOAD_TLS_FAILURE`, no upload |
| certificate policy is absent | `PRIVACY_POLICY_UNRATIFIED`, no upload |
| remote retention receipt is absent | `UPLOAD_AUDIT_FAILURE`, no success result |
| remote deletion receipt is absent or reports failure | `DELETION_FAILURE`, no success result |
| accessible control, focus restoration, keyboard path, or screen-reader state is missing before consent | `ACCESSIBILITY_UNAVAILABLE`, no mutation |
| accessibility is lost after reserve or during recovery | `ACCESSIBILITY_RECOVERY_FAILED`, journal preserved, no hidden action, quarantine if safe recovery UI cannot be restored |

The receipt has these totality invariants: `privacy_policy_id` and `privacy_policy_digest` must resolve to the ratified policy before upload; `upload_consent_id`, endpoint, TLS, remote-retention, remote-deletion, and `remote_deletion_attempts` fields are all null when upload is not requested; a remote receipt is impossible without a verified upload; `local_deletion_attempts` and `remote_deletion_attempts` are zero before their respective deletion requests and never exceed three; `local_deletion_result=deleted` or `not-found` requires a non-null local deletion evidence digest; a failed deletion has exactly three bounded attempts, then `DELETION_FAILURE` and a quarantine evidence receipt; and no success result is emitted while any required local or remote deletion receipt is missing. No retry widens the endpoint, allowlist, retention, or consent policy.

Every UI state has a visible label, programmatic role and name, keyboard order, live-region transition, and non-color/non-audio meaning. Target summary, scope, plan, required and optional outcomes, consent, cancel, resume, rollback, and abort are visible and keyboard reachable. `Esc` maps to the current cancellation event. Recovery controls are not hidden from assistive technology. An inaccessible implementation cannot proceed by using a background or terminal-only implicit consent.

## 12. Full fixture schema and hostile corpus

The fixture corpus is a design requirement. Every fixture has one canonical input and one mutation. The fixture record is:

```text
Fixture = {
  fixture_id: "FIX-01" through "FIX-33" or "FIX-27-A" through "FIX-27-I",
  owner: LowerAsciiToken,
  due_before_gate: LowerAsciiToken,
  operation: ProductOperation, scope: ProductScope, exact_scope: ExactScope,
  input_artifact_id: ArtifactId,
  input_content_digest: Digest,
  mutation: {selector: JsonPath, before_digest: Digest, after_digest: Digest, description: SafeDescription},
  event_id: EventId or null,
  expected_phase: Phase,
  expected_code: ErrorCode or ResultCode,
  expected_path: JsonPath or LowerAsciiToken,
  expected_process_status: Status,
  expected_decision: Decision,
  expected_state: StateId or null,
  expected_side_effect: "none" or "journal-only" or "rollback-only" or "quarantine-only",
  expected_evidence_artifact_id: ArtifactId,
  preimage_id: LowerAsciiToken,
  implementation_status: "NOT_IMPLEMENTED" or "IMPLEMENTED_AND_VERIFIED"
}
```

For fixture `FIX-NN`, `expected_evidence_artifact_id` is the exact token `p01.fixture-result.fix-nn.v1` and `preimage_id` is `p01.fixture-result.fix-nn.v1`; interruption subcases use the same form with the lowercase subcase suffix. The acceptance artifact named in the table is a separate owner receipt and must itself carry the fixture ID, input digest, mutation digest, expected result tuple, and implementation status. `expected_state` is the destination state in section 10, or null only for a rejection before transaction allocation.

The expected destination state is closed and independently checkable:

```text
FIXTURE_EXPECTED_STATE = {
  FIX-01:null, FIX-02:null, FIX-03:null, FIX-04:null, FIX-05:null, FIX-06:null, FIX-07:null,
  FIX-08:null, FIX-09:null, FIX-10:null, FIX-11:null, FIX-12:STATE-02, FIX-13:STATE-01,
  FIX-14:STATE-08, FIX-15:STATE-08, FIX-16:null, FIX-17:null, FIX-18:null, FIX-19:null,
  FIX-20:null, FIX-21:null, FIX-22:null, FIX-23:STATE-07, FIX-24:STATE-07,
  FIX-25:null, FIX-26:STATE-13, FIX-27:STATE-08, FIX-28:null, FIX-29:null, FIX-30:STATE-10,
  FIX-31:STATE-08, FIX-32:STATE-07, FIX-33:STATE-08
}
FIX-27-A: STATE-11; FIX-27-B: STATE-11; FIX-27-C: STATE-08; FIX-27-D: STATE-08;
FIX-27-E: STATE-08; FIX-27-F: STATE-07; FIX-27-G: STATE-08; FIX-27-H: STATE-08; FIX-27-I: STATE-10

FIXTURE_EVENT = {
  FIX-27-A: interrupt_before_consent, FIX-27-B: interrupt_before_reserve,
  FIX-27-C: interrupt_reserved, FIX-27-D: interrupt_applying,
  FIX-27-E: interrupt_verifying, FIX-27-F: interrupt_committed,
  FIX-27-G: interrupt_evaluating, FIX-27-H: interrupt_recovering,
  FIX-27-I: rollback_again
}
```

Each `FIX-27-*` record inherits operation `update`, scope `platform-update`, status 4, and the exact `POWER_LOSS_INTERRUPTED` result unless the subcase explicitly names `RECOVERY_RECURSION`; it must materialize its own input artifact ID, input digest, mutation before/after digests, expected evidence ID, owner acceptance receipt, and preimage. Missing materialization is `NOT_IMPLEMENTED`, not a pass.

| Fixture | Single mutation and operation/scope | Expected code, path, phase, status, decision, side effect | Owner, due, acceptance |
| --- | --- | --- | --- |
| `FIX-01` | add unknown nested property to a payload, `inspect/read-only` | `UNKNOWN_FIELD`, `$.payload.unexpected`, `shape`, 3, reject, none | P-02; before P-01; receipt `p02.fixture-01.v1` and digest |
| `FIX-02` | repeat a JSON name or semantic collection key, `inspect/read-only` | `DUPLICATE_SEMANTIC_KEY`, `$.payload.boards[0].duplicate_key`, `shape`, 3, reject, none | F-02; before P-01; receipt `f02.canonical.v1` and digest |
| `FIX-03` | replace canonical bytes with a UTF-8 BOM, `inspect/read-only` | `PARSE_SCHEMA_FAILURE`, `$.transport.utf8`, `shape`, 3, reject, none | F-02; before P-01; receipt `f02.parse.v1` and digest |
| `FIX-04` | change document ID without changing signed payload, `inspect/read-only` | `SIGNATURE_CONTEXT_MISMATCH`, `$.payload.document_id`, `verify`, 3, reject, none | F-02/F-03; before P-01; receipt `f02.transplant.v1` and digest |
| `FIX-05` | use a stale or replayed verified clock, `update/platform-update` | `EXPIRY_OR_REPLAY_FAILURE`, `$.verified_clock`, `freshness`, 3, reject, none | F-03; before P-01; receipt `f03.replay.v1` and digest |
| `FIX-06` | replace one input byte with invalid UTF-8 while the dependency is missing and cache is absent, `inspect/read-only` | `PARSE_SCHEMA_FAILURE`, `$.transport.utf8`, `shape`, 3, reject, none | P-01; before P-01; receipt `p01.precedence.v1` and digest |
| `FIX-07` | set the F-02 receipt status to `unratified` while preserving the required receipt slot, `inspect/read-only` | `DEPENDENCY_UNRATIFIED`, `dependency.check`, `dependency`, 4, hold, none | P-01; before P-01; receipt `p01.dependency.v1` and digest |
| `FIX-08` | alter the owner proof subject, `install/platform-system` | `OWNER_PROOF_INVALID`, `$.owner_proof_receipt.subject_account_id`, `identity`, 3, reject, none | I-03; before I-03; receipt `i03.owner.v1` and digest |
| `FIX-09` | alter the target-account binding, `install/platform-system` | `TARGET_ACCOUNT_INVALID`, `$.target_account.account_binding`, `identity`, 3, reject, none | I-03; before I-03; receipt `i03.account.v1` and digest |
| `FIX-10` | substitute one cache entry content digest, `update/platform-update` | `CACHE_SUBSTITUTION`, `executor.preflight`, `preflight`, 3, reject, none | I-03/I-04; before I-04; receipt `i04.cache.v1` and digest |
| `FIX-11` | remove one required cache entry, `update/platform-update` | `CACHE_MISS`, `executor.preflight`, `preflight`, 4, hold, none | I-04; before I-04; receipt `i04.offline.v1` and digest |
| `FIX-12` | reduce available capacity below required plus reserve bytes, `install/platform-system` | `CAPACITY_INSUFFICIENT`, `executor.reserve`, `reserve`, 4, hold, journal-only | I-03; before I-03; receipt `i03.capacity.v1` and digest |
| `FIX-13` | invoke a package primitive before final consent, `install/platform-system` | `CONSENT_MISSING`, `executor.consent`, `executor.consent`, 4, hold, none | I-03/I-04; before I-04; receipt `i04.consent.v1` and digest |
| `FIX-14` | fetch an artifact after final consent, `update/platform-update` | `FORBIDDEN_ROUTE`, `route.authorize`, `authorize`, 2, reject, journal-only | I-04; before I-04; receipt `i04.no-network.v1` and digest |
| `FIX-15` | change the target stable ID after reserve, `install/platform-system` | `TARGET_REVALIDATION_FAILED`, `executor.verify`, `executor.verify`, 3, reject, journal-only | I-04; before I-04; receipt `i04.target.v1` and digest |
| `FIX-16` | call a direct leaf with a forged handle MAC, `install/platform-system` | `HANDLE_INVALID`, `admission.check`, `admission.check`, 8, reject, none | P-01/P-02; before P-01; receipt `p01.handle.v1` and digest |
| `FIX-17` | source a copied leaf with an environment-only handle, `install/platform-system` | `FORBIDDEN_ROUTE`, `route.authorize`, `authorize`, 2, reject, none | P-01/P-02; before route gate; receipt `p01.leaf.v1` and digest |
| `FIX-18` | select the `dev` channel, `channel-set/platform-update` | `FORBIDDEN_ROUTE`, `route.authorize`, `authorize`, 2, reject, none | P-01/P-05; before route gate; receipt `p01.channel.v1` and digest |
| `FIX-19` | pass an arbitrary upgrade `--ref`, `upgrade/platform-system` | `FORBIDDEN_ROUTE`, `route.authorize`, `authorize`, 2, reject, none | P-01/P-05; before route gate; receipt `p01.ref.v1` and digest |
| `FIX-20` | invoke the raw firmware/EFI primitive, `apply-hardware/platform-hardware` | `FORBIDDEN_ROUTE`, `route.authorize`, `authorize`, 2, reject, none | P-01/P-05; before route gate; receipt `p01.firmware.v1` and digest |
| `FIX-21` | remove `OMARCHY_PATH`, `install/platform-system` | `OMARCHY_PATH_MISSING`, `route.bootstrap`, `bootstrap`, 2, reject, none | P-01; before route gate; receipt `p01.path.v1` and digest |
| `FIX-22` | pass `../config` to refresh-config, `apply-system/platform-system` | `PATH_TRAVERSAL`, `route.parse`, `parse`, 2, reject, none | P-01; before route gate; receipt `p01.traversal.v1` and digest |
| `FIX-23` | change a committed atomic-record counter without changing `bytes_digest`, `update/platform-update` | `TRUST_BOUNDARY_FAILURE`, `$.atomic_record.attempt_counter`, `trust`, 4, hold, none | F-02/F-03; before P-05; receipt `f02.boot.v1` and digest |
| `FIX-24` | change the boot-success signer role, `update/platform-update` | `BOOT_MARKER_AUTH_FAILURE`, `$.boot_success.signatures[0].signer_role`, `boot.evaluate`, 4, hold, none | P-05; before F-07; receipt `p05.boot.v1` and digest |
| `FIX-25` | reuse a transaction ID with a changed plan digest, `update/platform-update` | `DUPLICATE_TRANSACTION`, `executor.idempotence`, `idempotence`, 3, reject, journal-only | I-04; before recovery gate; receipt `i04.idempotence.v1` and digest |
| `FIX-26` | submit a transaction ID already tombstoned, `recover/platform-update` | `TRANSACTION_TOMBSTONED`, `recovery.dispatch`, `recovery.dispatch`, 3, reject, none | I-04; before recovery gate; receipt `i04.tombstone.v1` and digest |
| `FIX-27` | interrupt after a declared step primitive starts, `update/platform-update` | `POWER_LOSS_INTERRUPTED`, `recovery.resume`, `recovery.resume`, 4, hold, journal-only | I-04; before I-09; receipt `i04.recovery.v1` and digest |
| `FIX-28` | add `private_key` to the support allowlist, `inspect/read-only` | `PRIVACY_FIELD_FORBIDDEN`, `diagnostics.redact`, `diagnostics.redact`, 3, reject, none | P-04; before F-06; receipt `p04.redaction.v1` and digest |
| `FIX-29` | make local deletion proof fail after the retention deadline, `inspect/read-only` | `DELETION_FAILURE`, `diagnostics.delete`, `diagnostics.delete`, 3, reject, quarantine-only | P-04/I-08; before F-06; receipt `p04.deletion.v1` and digest |
| `FIX-30` | make focus restoration fail during recovery, `recover/platform-update` | `ACCESSIBILITY_RECOVERY_FAILED`, `ux.recovery`, `ux.recovery`, 9, quarantined, quarantine-only | I-08; before I-09; receipt `i08.recovery-ux.v1` and digest |
| `FIX-31` | expire the boot-health evidence before evaluation, `update/platform-update` | `EXPIRY_OR_REPLAY_FAILURE`, `admission.freshness`, `freshness`, 3, reject, journal-only | P-05; before F-07; receipt `p05.stale-health.v1` and digest |
| `FIX-32` | publish a success marker before health evaluation, `update/platform-update` | `BOOT_MARKER_AUTH_FAILURE`, `$.boot_success.marked_at`, `boot.evaluate`, 4, hold, journal-only | P-05; before F-07; receipt `p05.premature-marker.v1` and digest |
| `FIX-33` | lower the predecessor lineage or attempt counter, `update/platform-update` | `BOOT_COUNTER_FAILURE`, `$.boot.lineage`, `boot.lineage`, 4, hold, journal-only | F-02/F-03; before P-05; receipt `f02.lineage.v1` and digest |

`FIX-27` also requires these exact interruption subcases, each materialized with its own `input_content_digest`, mutation digest, expected result, and acceptance receipt: `FIX-27-A` before consent to `aborted` with `POWER_LOSS_INTERRUPTED` and no mutation; `FIX-27-B` after consent before reserve to `aborted` with `POWER_LOSS_INTERRUPTED` and no mutation; `FIX-27-C` after reserve to `recovering` with `POWER_LOSS_INTERRUPTED` and one rollback allowance; `FIX-27-D` during applying to `recovering` with `POWER_LOSS_INTERRUPTED`; `FIX-27-E` during verifying to `recovering` with `POWER_LOSS_INTERRUPTED`; `FIX-27-F` after committed before health to `evaluating` with `POWER_LOSS_INTERRUPTED`; `FIX-27-G` during evaluating to `recovering` with `POWER_LOSS_INTERRUPTED`; `FIX-27-H` during recovering to `recovering` with `POWER_LOSS_INTERRUPTED` without incrementing `rollback_depth`; and `FIX-27-I` after one rollback requests another rollback and enters `quarantined` with `RECOVERY_RECURSION`, quarantine evidence, and tombstone. A missing executable or fixture returns `NOT_IMPLEMENTED`, never a fabricated typed rejection. The current slice has no product admission executable, broker, schemas, bindings, product fixture corpus, or product CI, so all 33 fixture families and their 9 interruption subcases remain `NOT_IMPLEMENTED`.

## 13. Residual schema and owned blockers

Each absent artifact is a separate residual. The residual itself has a closed schema and cannot be closed by a prose claim.

```text
Residual = {
  residual_id: LowerAsciiToken,
  artifact_id: ArtifactId,
  owner: LowerAsciiToken,
  consumer: LowerAsciiToken,
  due_before_gate: LowerAsciiToken,
  scope: ResidualScope,
  required_inputs: ExactList<ArtifactId, artifact_id>,
  acceptance_artifact_id: ArtifactId,
  acceptance_digest_preimage_id: PreimageId,
  acceptance_command: PathToken,
  rejection_if_absent: ErrorCode or ResidualStatus,
  status: "NOT_IMPLEMENTED" or "NOT_PRESENT" or "TOOLING_BLOCK" or "UNSAFE_BASELINE" or "IMPLEMENTED_AND_VERIFIED"
}
```

The omitted collection fields are fixed by this manifest, not by table-cell inference:

```text
RESIDUAL_REQUIRED_INPUTS = {
  RES-01:[f02.ratification.v1, f03.ratification.v1, p01.route-manifest.v1],
  RES-02:[p01.admission-gate.v1, p01.executor-request.v1, i04.journal.v1],
  RES-03:[f02.ratification.v1, p01.payload-registry.v1],
  RES-04:[f02.ratification.v1, f03.ratification.v1, p01.consumer-capabilities.v1],
  RES-05:[p01.admission-gate.v1, p02.capability-outcome.v1],
  RES-06:[p03.parity-census.v1, p01.route-manifest.v1],
  RES-07:[p04.privacy-policy.v1, p04.support-bundle.v1],
  RES-08:[i03.inventory.v1, p03.installer-plan.v1, p01.final-consent.v1],
  RES-09:[i04.executor.v1, i04.journal.v1, i04.recovery.v1],
  RES-10:[i08.accessibility.v1, i04.recovery.v1, p04.privacy.v1],
  RES-11:[p01.fixture-schema.v1, p01.expected-results.v1],
  RES-12:[p01.product-ci-contract.v1, p01.route-manifest.v1],
  RES-13:[f05.closure.v1, f06.compliance-intake.v1, f07.promotion-evidence.v1],
  RES-14:[q00.intake.v1, q01.profile.v1, f07.promotion-evidence.v1],
  RES-15:[p01.required-checks.v1, f07.promotion-evidence.v1]
}
RESIDUAL_ACCEPTANCE_COMMAND = {
  RES-01:tests/product/admission, RES-02:tests/product/broker,
  RES-03:tests/product/schema, RES-04:tests/product/binding,
  RES-05:tests/product/capabilities, RES-06:tests/product/route-graph,
  RES-07:tests/product/privacy, RES-08:tests/product/executor-plan,
  RES-09:tests/product/executor-recovery, RES-10:tests/product/accessibility,
  RES-11:tests/product/fixtures, RES-12:.github/workflows/product.yml,
  RES-13:tests/product/promotion-intake, RES-14:tests/product/qualification,
  RES-15:tests/product/branch-protection
}
RESIDUAL_REJECTION_IF_ABSENT = {
  RES-01:NOT_IMPLEMENTED, RES-02:NOT_IMPLEMENTED, RES-03:DEPENDENCY_UNRATIFIED,
  RES-04:BINDING_INTEGRITY_FAILURE, RES-05:NOT_IMPLEMENTED, RES-06:NOT_IMPLEMENTED,
  RES-07:PRIVACY_POLICY_UNRATIFIED, RES-08:NOT_IMPLEMENTED, RES-09:NOT_IMPLEMENTED,
  RES-10:ACCESSIBILITY_UNAVAILABLE, RES-11:NOT_IMPLEMENTED, RES-12:NOT_PRESENT,
  RES-13:DEPENDENCY_UNRATIFIED, RES-14:NOT_PRESENT, RES-15:NOT_PRESENT
}
```

`required_inputs`, `acceptance_artifact_id`, `acceptance_digest_preimage_id`, `acceptance_command`, `rejection_if_absent`, and `status` are read from the same residual ID in this manifest and the row below. A missing manifest member is a residual-schema failure, not an implicit empty list or acceptance.

| Residual | Artifact and scope | Owner, consumer, due | Acceptance artifact and exact preimage | Current status and absence effect |
| --- | --- | --- | --- | --- |
| `RES-01` | `bin/omarchy-admission`, P-01 public adapter and result contract | P-01/P-02; `all-product-routes`; before P-01 | `P01.AdmissionGateReceipt/v1`, preimage `p01.admission-gate-receipt.v1` | `NOT_IMPLEMENTED`; no admission, handle, or typed route result |
| `RES-02` | `omarchy-platform` constrained broker, every privileged edge | I-04; `all-mutators`; before P-05 | `P01.BrokerConformance/v1`, preimage `p01.broker-conformance.v1` | `NOT_IMPLEMENTED`; no package, config, firmware, DTB, APFS, or boot mutation authorized |
| `RES-03` | canonical schemas and `schemas/schema-input.lock`, eight payloads | F-02; `all-payload-consumers`; before P-01 | `dependency-ratification/v1`, preimage `dependency-ratification.v1` | `NOT_IMPLEMENTED`; `DEPENDENCY_UNRATIFIED` before parse authority |
| `RES-04` | generated bindings and `bindings/generated-output.lock`, Python, Swift, bounded boot | F-02/F-03; `P01-and-P05`; before P-01 | `ConsumerCapabilities`, preimage `f02.consumer-capabilities.v1` | `NOT_IMPLEMENTED`; no binding negotiation or boot constructor |
| `RES-05` | P-02 required/optional capability result implementation | P-02; `install-and-update`; before P-02 | `P02.CapabilityOutcome/v1`, preimage `p02.capability-outcome.v1` | `NOT_IMPLEMENTED`; warning, skip, or zero exit cannot be success |
| `RES-06` | P-03 parity census and route graph | P-03; `promotion-terminal`; before F-07 | `P03.PARITY-CENSUS.V1`, preimage `p03.parity-census.v1` | `NOT_IMPLEMENTED`; no parity acceptance |
| `RES-07` | P-04 diagnostics and redacted support export | P-04; `diagnostics-and-promotion`; before F-06 | `P04.PRIVACY.V1`, preimage `p04.privacy.v1` | `NOT_IMPLEMENTED`; no bundle or upload is evidence |
| `RES-08` | I-03 inventory, target IDs, capacity, cache, consent, plan | I-03; `I03-I04`; before I-03 | `I03.ExecutorPlan/v1`, preimage `i03.executor-plan.v1` | `NOT_IMPLEMENTED`; no irreversible handoff |
| `RES-09` | I-04 journal, executor, interruption, rollback, and closure | I-04; `I04-P05-I09`; before I-04 | `P01.ExecutorResult/v1`, preimage `p01.executor-result.v1` | `NOT_IMPLEMENTED`; no mutation, resume, rollback, or close |
| `RES-10` | accessible/localized native and CLI recovery UX | I-08; `I08-P04-I04`; before I-08 | `I08.AccessibilityReceipt/v1`, preimage `i08.accessibility-receipt.v1` | `NOT_IMPLEMENTED`; post-consent recovery cannot be assumed accessible |
| `RES-11` | hostile fixture corpus and mutation-detection runner | P-02 and CI owner; `all-seams`; before P-02 | `P02.FixtureCorpusReceipt/v1`, preimage `p02.fixture-corpus.v1` | `NOT_IMPLEMENTED`; no hostile rejection is executable |
| `RES-12` | product-specific CI workflow and clean-checkout gate | CI owner; `P01-P05-integration`; before integration | `.github/workflows/product.yml`, preimage `p01.product-ci.v1` | `NOT_PRESENT`; design is not enforced |
| `RES-13` | F-05, F-06, F-07, P-05, I-09, B-04, Q-04 through Q-08 closure receipts | respective owners; `promotion-terminal`; before promotion | `F06.COMPLIANCE-INTAKE.V1` and `F07.PROMOTION-EVIDENCE.V1`, preimage `f07.promotion-intake.v1` | `NOT_PRESENT`; no promotion or release evidence |
| `RES-14` | physical qualification for each exact board/profile plus clean install, boot, update, interruption, rollback, and recovery | qualification owners and lab; `qualification-and-release`; before qualification or release | `Q.PhysicalQualificationBundle/v1`, preimage `q.qualification-bundle.v1` | `NOT_PRESENT`; no compatibility, support, qualification, or release claim |
| `RES-15` | branch protection and required checks | repository owner and coordinator; `merge-and-promotion`; before merge or promotion | `Repository.RequiredChecksReceipt/v1`, preimage `repository.required-checks.v1` | `NOT_PRESENT`; PR remains draft and merge/promotion is blocked |

## 14. Executable artifact and CI expectations

The following are required future artifacts, not present artifacts:

```text
bin/omarchy-admission
omarchy-platform
schemas/schema-input.lock
schemas/common/v1/common.schema.json
schemas/signed-document/v1/signed-document.schema.json
schemas/board-registry/v1/board-registry.schema.json
schemas/platform-manifest/v1/platform-manifest.schema.json
schemas/installer-plan/v1/installer-plan.schema.json
schemas/qualification-record/v1/qualification-record.schema.json
schemas/boot-health/v1/boot-health.schema.json
schemas/owner-approval/v1/owner-approval.schema.json
schemas/boot-success-mark/v1/boot-success-mark.schema.json
schemas/dtb-mutation-envelope/v1/dtb-mutation-envelope.schema.json
bindings/generated-output.lock
fixtures/accepted/
fixtures/hostile/
fixtures/canonicalization/
tests/product/
.github/workflows/product.yml
```

The product workflow must run from a clean checkout and fail closed on: schema and JCS vectors, exact payload set, two-lock acyclic binding graph, ConsumerCapabilities equality, Trusted constructor misuse, F-02 error preservation, admission result totality, owner proof and target account, route graph source-set digest, every privileged edge, missing path and environment fallback, capacity arithmetic, cache substitution, pre- and post-consent network, target swap, skipped required package, journal chain, duplicate transaction, monotonic lineage, tombstone and closure, all fixture boundary parameters, privacy redaction and deletion, keyboard and screen-reader recovery, F-06/F-07 handoffs, and generated drift.

Unavailable `dtc`, `dt-validate`, Sphinx/docutils, full JCS tooling, or any required schema verifier is `TOOLING_BLOCK`, never a successful validation. A product executable that is absent, returns 127, or cannot produce the typed result is `NOT_IMPLEMENTED`, never a typed rejection. Branch protection must require the product workflow, generated drift, fixture, and clean-checkout reports before merge or promotion.

## 15. Baseline, gating, and completion honesty

The current base commands and routes are not repaired by this document. Known baseline failures remain separately tracked: macOS Bash 3.2 associative-array and command-check failures, shell-suite/runtime incompatibilities and failures, and an aggregate suite that did not complete in the prior bounded run. Syntax-only success is not runtime or product-contract evidence. The base route observations in section 8.2 remain live unsafe behavior until implementation and hostile tests prove otherwise.

F-02 and F-03 remain gating because no ratified schema, trust root, generated binding, exact constructor, or authority receipt exists. F-06 and F-07 remain gating because no ratified compliance/promotion intake, signed evidence, or sole-writer promotion terminal exists. Physical qualification remains gating because no exact board/profile physical evidence bundle exists. I-03, I-04, P-02, P-03, P-04, P-05, I-08, I-09, CI, and branch protection remain residuals above.

This document explicitly makes no implementation, compatibility, support, qualification, physical-success, stable-promotion, or release-readiness claim. The product routes remain unimplemented/unsafe relative to this contract. No slice or program is DONE. Completion of this documentation correction is established only by external review of the single pushed commit and its verification state; this file never self-marks completion.
