# Database Design

## 1. Technology choice: PostgreSQL

The task brief specifically asks about PostgreSQL suitability — it is the right choice here, and no serious alternative beats it for this domain:

- **Relational integrity matters a lot**: contracts/signatures/consultations/billing are exactly the kind of data where foreign-key integrity, transactional multi-table writes (e.g. "book consultation + create notification + decrement slot" must be atomic), and check constraints (e.g. `rating BETWEEN 1 AND 5`) carry real correctness weight. A document-store-first choice (MongoDB, etc.) would fight this domain, not help it.
- **jsonb** covers every place the frontend uses loosely-typed data well (`Contract.fieldValues`, localized template content, notification `data` payload) without giving up relational guarantees elsewhere.
- **Row-Level Security** (native Postgres feature) directly supports the multi-tenancy backstop described in [03-multi-tenancy.md](03-multi-tenancy.md).
- **Range types + exclusion constraints** solve the availability double-booking gap identified in the consultations audit (`EXCLUDE USING gist` on `tstzrange(start_at, end_at)`) — this is a real, non-trivial correctness problem the frontend never solved, and Postgres has a purpose-built feature for it.
- **`citext`** extension for case-insensitive email uniqueness (frontend normalizes email casing in the mock already — `auth_mock_data_source.dart` re-keys accounts by normalized email).
- **pg_trgm** for lawyer name/specialty search (frontend currently does naive client-side substring filtering over the full lawyer list — fine at prototype scale, `pg_trgm` gives production-scale fuzzy search on the same field without introducing a separate search engine for what is, per the audit, a catalog of a few hundred/thousand lawyer profiles at realistic scale).

No case was found in the audits for time-series, graph, or heavy full-text search workloads that would justify a second database at launch. Object storage (S3-compatible) is used alongside Postgres for binary content — see §5.

## 2. Schema organization

One schema (`public`) is sufficient at this scale; do not over-engineer with per-module schemas prematurely. Group tables conceptually as in [01-domain-model.md](01-domain-model.md):

- **Identity**: users, lawyer_registration_details, refresh_tokens, verification_codes
- **Organizations**: organizations, organization_members, organization_invitations
- **Marketplace**: lawyer_profiles, lawyer_profile_specialties, lawyer_consultation_offerings, reviews
- **Consultations**: consultations, availability_slots, consultation_room_sessions, consultation_participant_events
- **Messaging**: messages, attachments
- **Notifications**: notifications, push_delivery_receipts
- **Contracts**: contract_templates, contract_template_fields, contracts, contract_participants, contract_signatures, saved_signatures
- **Documents**: documents, document_versions
- **AI**: ai_conversations, ai_messages, contract_analyses, analysis_clauses
- **Billing**: subscription_plans, plan_limits, subscriptions, payment_methods, invoices, transactions
- **Gov procedures**: gov_procedures, gov_required_documents, gov_procedure_steps, user_gov_procedure_progress
- **Cross-cutting**: audit_logs

## 3. ERD (textual)

```
User ──1:1── LawyerRegistrationDetail
User ──1:N── RefreshToken
User ──1:N── VerificationCode
User ──1:1── LawyerProfile (nullable, only role=lawyer)
User ──1:N── OrganizationMember ──N:1── Organization
User ──1:1── Organization (as owner)
Organization ──1:N── OrganizationInvitation

LawyerProfile ──1:N── LawyerProfileSpecialty
LawyerProfile ──1:N── LawyerConsultationOffering
LawyerProfile ──1:N── AvailabilitySlot
LawyerProfile ──1:N── Consultation
LawyerProfile ──1:N── Review

User(client) ──1:N── Consultation ──N:1── Organization (nullable)
Consultation ──1:1── ConsultationRoomSession
Consultation ──1:N── ConsultationParticipantEvent
Consultation ──1:N── Message ──N:1── Attachment (nullable)
Consultation ──1:N── AvailabilitySlot (booking link)
Consultation ──0:1── Review

User ──1:N── Notification
Notification ──1:N── PushDeliveryReceipt

ContractTemplate ──1:N── ContractTemplateField
ContractTemplate ──1:N── Contract
Contract ──N:1── User (owner) / Organization (nullable)
Contract ──1:N── ContractParticipant ──1:N── ContractSignature
Contract ──1:1── Document (generated) [Document.contractId nullable FK]
User ──1:N── SavedSignature

User ──1:N── Document ──1:N── DocumentVersion
Document ──N:1── Organization (nullable)

User ──1:N── AiConversation ──1:N── AiMessage
User ──1:N── ContractAnalysis ──N:1── Document (sourceDocumentId, nullable)
ContractAnalysis ──1:N── AnalysisClause

SubscriptionPlan (tier, billingCycle) ──reference, no FK── Subscription
PlanLimit (tier, resourceType) ──reference, no FK── (quota check at write time)
(User | Organization) ──1:N── Subscription
(User | Organization) ──1:N── PaymentMethod
(User | Organization) ──1:N── Invoice ──1:N── Transaction
Invoice ──N:1── Subscription (nullable)
Invoice ──N:1── Consultation (nullable)

GovProcedure ──1:N── GovRequiredDocument
GovProcedure ──1:N── GovProcedureStep
User ──1:N── UserGovProcedureProgress ──N:1── GovProcedure

User ──1:N── AuditLog (actor, nullable)
```

## 4. Key tables — columns, constraints, indexes

Full field lists are in [01-domain-model.md](01-domain-model.md); this section lists constraints/indexes not obvious from the field tables.

### `users`
- `UNIQUE (lower(email))` via `citext` column type
- `CHECK (role IN ('client','lawyer','company'))`
- Index on `role` (coarse filtering is common — e.g. admin listing all lawyers pending verification)

### `organizations`
- `UNIQUE (commercial_registration_number)`
- FK `owner_user_id → users.id ON DELETE RESTRICT` (an org must never be left ownerless silently; ownership transfer must be an explicit action)

### `organization_members`
- `UNIQUE (organization_id, user_id)` where `user_id IS NOT NULL`
- `UNIQUE (organization_id, lower(email))` where `status = 'invited'`
- Index on `(user_id)` for "which orgs am I in"

### `lawyer_profiles`
- `UNIQUE (user_id)`
- `UNIQUE (bar_license_number)`
- Index on `verification_status` (marketplace search excludes non-verified by default; admin queue needs `pending`)
- `rating`/`review_count` updated via trigger or application-transaction on `reviews` insert — **not** client-writable

### `availability_slots`
- **Exclusion constraint** (the core fix for the frontend's unenforced double-booking):
  ```sql
  ALTER TABLE availability_slots
    ADD CONSTRAINT no_overlapping_booked_slots
    EXCLUDE USING gist (
      lawyer_profile_id WITH =,
      tstzrange(start_at, end_at) WITH &&
    ) WHERE (is_booked);
  ```
- Requires `btree_gist` extension (to mix the equality column with the range in one exclusion constraint).
- Index on `(lawyer_profile_id, start_at)` for calendar queries.

### `consultations`
- `CHECK (status IN (12 enum values))`
- Index on `(client_user_id, status)`, `(lawyer_profile_id, scheduled_at)`, `(organization_id)`
- `FK lawyer_profile_id`, `FK client_user_id`, `FK organization_id NULLABLE`

### `consultation_room_sessions`
- `UNIQUE (consultation_id)`

### `messages`
- Index on `(consultation_id, sent_at)` — the frontend always fetches/orders a consultation's full transcript by `sentAt`; this is the hot path once pagination is added (see [07-messaging-realtime.md](07-messaging-realtime.md))
- Index on `(consultation_id, read_at)` for unread-count queries (mirrors `getUnreadCounts`)

**No `presence`/online-offline table exists in this schema, deliberately.** Presence is approved (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 7) but is realtime/session state, not a permanent database fact — it lives in Redis (a per-user online/offline key with a heartbeat TTL), not Postgres. See [07-messaging-realtime.md](07-messaging-realtime.md) §4.

### `notifications`
- Index on `(recipient_user_id, is_read, created_at DESC)` — this is exactly the frontend's "unread badge + reverse-chronological list" access pattern

### `contracts`
- `CHECK (status IN ('draft','pendingSignature','signed','completed','cancelled'))`
- Index on `(owner_user_id)`, `(organization_id)`
- `fieldValues jsonb` — no GIN index needed at launch (not queried by field value in any frontend flow); add one later only if server-side contract search-by-field-value becomes a real requirement
- Soft-delete: partial index `WHERE deleted_at IS NULL` on the common list queries

### `contract_participants` / `contract_signatures`
- `UNIQUE (contract_id, user_id)` where `user_id IS NOT NULL` on participants (a user can't be double-added)
- `contract_signatures.participant_id` `UNIQUE` (one signature per participant — resigning would be a new participant/version in a future contract-amendment model, out of scope for v1)

### `documents`
- Index on `(owner_user_id)`, `(organization_id)`, `(contract_id)`

### `ai_conversations` / `ai_messages`
- Index on `(user_id, updated_at DESC)` (conversation list, most-recent-first — matches frontend sort)
- Index on `(conversation_id, sent_at)`

### `subscription_plans` / `plan_limits`
- `subscription_plans`: `UNIQUE (tier, billing_cycle)` — reference/pricing table, platform-managed, not tenant-scoped (same category as `contract_templates`/`gov_procedures` in [03-multi-tenancy.md](03-multi-tenancy.md) §6).
- `plan_limits`: `UNIQUE (tier, resource_type)`, `CHECK (resource_type IN ('contract','contractAnalysis','lawyerConsultation'))` — **backend-enforced quotas** (approved decision, see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 2), not display-only; read at the relevant create endpoints (`POST /v1/contracts`, `POST /v1/ai/analyses`, `POST /v1/consultations`) alongside a usage count for the subject's current billing period.

### `subscriptions` / `payment_methods` / `invoices`
- All three use the polymorphic `(subject_type, subject_id)` pair — **not** a native FK (Postgres can't FK across two possible parent tables cleanly). Enforce referential integrity via a trigger or application-layer check, or normalize into a `billing_subjects` bridge table (`id, subject_type, user_id NULLABLE, organization_id NULLABLE, CHECK exactly one is set`) if strict FK integrity is a hard requirement — **recommended** over trigger-based enforcement for a billing-adjacent table.
- `invoices`: index on `(subject_type, subject_id, status)`

### `reviews`
- `UNIQUE (consultation_id, reviewer_user_id)`
- `CHECK (rating BETWEEN 1 AND 5)`

## 5. Database vs. object storage split

Direct answer to the task's explicit question:

| Content | Where |
|---|---|
| Contract field values, generated contract **text** (small, structured) | Postgres (`contracts.field_values jsonb`; rendered text can live in Postgres `text` column OR as a generated PDF in object storage — recommend: render to PDF and store the PDF in object storage via `Document`/`DocumentVersion`, keep only the structured `fieldValues` in Postgres, since a legal document should be an immutable rendered artifact, not just re-renderable text) |
| Uploaded documents, generated PDFs, signature images | Object storage (S3-compatible), referenced by `storageKey` in `DocumentVersion`/`Attachment` — never store binary blobs in Postgres |
| Chat image/file attachments | Object storage, referenced by `Attachment.storageKey` |
| Signature stroke data (drawn) | Postgres `jsonb` (small, structured vector data — no reason to push to object storage) |
| Signature images (uploaded/typed rendered to image) | Object storage |
| Everything else (all relational entities in [01-domain-model.md](01-domain-model.md)) | Postgres |

Access to object storage content is always via short-lived signed URLs generated per-request after an authorization check — never public bucket ACLs (see [14-security.md](14-security.md)).

## 6. Row-Level Security policy sketch

Applied to the tenant-scoped tables identified in [03-multi-tenancy.md](03-multi-tenancy.md) §4 (contracts, documents, consultations, messages, ai_conversations, notifications):

```sql
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;

CREATE POLICY contract_isolation ON contracts
  USING (
    owner_user_id = current_setting('app.current_user_id')::uuid
    OR organization_id = NULLIF(current_setting('app.current_org_id', true), '')::uuid
    OR id IN (
      SELECT contract_id FROM contract_participants
      WHERE user_id = current_setting('app.current_user_id')::uuid
    )
  );
```

The application sets `app.current_user_id`/`app.current_org_id` via `SET LOCAL` at the start of each request-scoped transaction. This is a backstop, not the primary access-control mechanism — see [03-multi-tenancy.md](03-multi-tenancy.md) §4 for the layering rationale.

## 7. Soft delete vs. hard delete

Soft-deleted (`deletedAt`, excluded from default queries via a partial index / view): `User` (never lose audit trail for a party to a signed contract), `Contract`, `Document`, `Consultation`, `Invoice`, `Organization`.

Hard-deleted: `AvailabilitySlot` (removing an unbooked slot), `RefreshToken` (or just marked `revokedAt` — effectively soft), `Notification` (frontend's `deleteNotification` is a real delete, not an archive — no evidence users need deleted notifications back), `SavedSignature` replacement, cache/ephemeral rows.

## 8. Transaction boundaries (multi-table writes that must be atomic)

Derived directly from frontend flows that touch more than one entity per user action:

- **Book consultation**: insert `Consultation` + mark `AvailabilitySlot.is_booked = true, consultation_id = ...` + insert `Invoice`/`Transaction` (payment) + insert `Notification` — one transaction; the exclusion constraint in §4 is the final race guard even under concurrent requests.
- **Accept/decline/cancel consultation**: update `Consultation.status` + release or keep the slot + insert `Notification` for the other party + (on cancel) insert `AuditLog`.
- **Sign contract**: insert `ContractSignature` + update `ContractParticipant.status` + (if all participants signed) update `Contract.status = signed` + generate/attach the signed `Document`/`DocumentVersion` + insert `Notification`s to other participants — one transaction per signature event.
- **Register (company/lawyer)**: insert `User` + insert `Organization`/`LawyerRegistrationDetail`(+`LawyerProfile`) + insert `OrganizationMember` (owner) — one transaction; a partial failure must not leave an orphaned `User` with no profile.
- **Send message**: insert `Message` + upsert unread-count cache (if materialized, see [07](07-messaging-realtime.md)) + insert `Notification` for the recipient — one transaction.

## 9. What Phase 0 does **not** produce

No `CREATE TABLE` migration files, no ORM model classes, no seed-data scripts. This document is the specification those artifacts will be written against in Phase 1 (see [16-backend-roadmap.md](16-backend-roadmap.md)).
