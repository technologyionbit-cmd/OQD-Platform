# Domain Model — Complete Entity Inventory

Conventions used below:
- **PK** = primary key. All PKs are `uuid` (v4/v7) unless noted — the frontend's mock string IDs (`c_seed_1`, `u_client_1`) are prototype artifacts, not a schema requirement.
- Every entity gets `createdAt: timestamptz` implicitly and `updatedAt: timestamptz` where the frontend shows edit/mutation; these are omitted from field tables below only when truly absent from the source entity, and called out explicitly otherwise.
- "Frontend source" cites the entity/file the design is reverse-engineered from. "**NEW**" marks a field or whole entity that does not exist in the frontend at all but is required for a real multi-tenant backend — these are the gaps enumerated in [00-backend-overview.md](00-backend-overview.md).
- Soft-delete (`deletedAt: timestamptz?`) is called out per-entity only where user-facing recovery or audit retention is likely required (contracts, documents, consultations, invoices); everything else uses hard delete unless stated.

---

## 1. Identity & Access

### `User`
Frontend source: `AuthUser` (`lib/features/auth/domain/entities/auth_user.dart`) — deliberately minimal (`id, fullName, email, role`); real backend needs far more.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| fullName | text | no | |
| email | citext | no | unique constraint |
| phone | text | yes | unique; sign-in identifier and where every code is texted, stored as `+9627XXXXXXXX`. Null only for old accounts whose number could not be normalized (migration `phone_sign_in`) |
| phoneVerifiedAt | timestamptz | yes | set by the texted code (sign-up or password reset); sensitive actions need it |
| passwordHash | text | no | never sent to client; bcrypt/argon2 |
| role | enum `UserRole` | no | `client, lawyer, company` — see note below |
| status | enum `UserStatus` | no | **NEW**: `active, suspended, banned, pendingDeletion` — no such concept exists client-side today |
| twoFactorEnabled | boolean | no, default false | **NEW** — `SecurityPrivacyScreen` has a toggle wired to nothing |
| lastLoginAt | timestamptz | yes | **NEW** |
| createdAt / updatedAt | timestamptz | no | |
| deletedAt | timestamptz | yes | soft delete — account closure must not cascade-delete contracts/consultations other parties depend on |

**Important design note on `role`**: the frontend enum comment states explicitly *"Drives UX only... this enum must never be treated as an authorization mechanism"* (`user_role.dart`). The backend keeps `role` as the primary **account type** (drives which shell/onboarding a user gets and is a coarse gate), but real authorization is permission-based — see [02-auth-and-authorization.md](02-auth-and-authorization.md). `company` is an account type that always owns exactly one `Organization` (see §6) as its creator/owner; it is not itself a workspace.

### `LawyerRegistrationDetail`
**NEW** — captures fields `RegisterRequest.lawyer` collects (`barLicenseNumber`, `mainSpecialty`) but the mock discards. One-to-one with `User` where `role = lawyer`, feeds initial `LawyerProfile` creation.

| Field | Type | Null? | Notes |
|---|---|---|---|
| userId | uuid | PK, FK → User.id | |
| barLicenseNumber | text | no | unique — used in verification |
| mainSpecialty | enum `LawyerSpecialty` | no | seeds `LawyerProfile.specialties[0]` |

### `RefreshToken` / `Session`
**NEW** — the frontend's `TokenManager`/`AuthTokens` treats tokens as two opaque strings with no server-side model implied; a real backend needs one to support revocation, the "Active Sessions" list UI (`SecurityPrivacyScreen._MockSession`), and refresh-token rotation.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| userId | uuid | FK → User.id, indexed | |
| refreshTokenHash | text | no | never store raw token |
| deviceLabel | text | yes | e.g. "Chrome on Windows" — powers the Active Sessions UI |
| ipAddress | inet | yes | |
| createdAt | timestamptz | no | |
| expiresAt | timestamptz | no | |
| revokedAt | timestamptz | yes | set on logout / explicit "End session" / password change |
| lastUsedAt | timestamptz | yes | |

### `PasswordResetToken` / `VerificationCode`
**NEW** — backs `requestOtp`/`verifyOtp`/`resetPassword` (mock hardcodes `'1234'` as always-valid).

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| userId | uuid | FK → User.id, yes (registration-time email verification may precede user creation in some flows) | |
| destination | text | no | email or phone the code was sent to |
| channel | enum | no | **NEW**, `email, sms` — frontend infers this from destination shape only; backend should be explicit |
| codeHash | text | no | short numeric code, hashed |
| purpose | enum | no | `passwordReset, phoneVerification` |
| expiresAt | timestamptz | no | short TTL (10 min) |
| consumedAt | timestamptz | yes | |
| attemptCount | int | no, default 0 | rate-limit brute force |

---

## 2. Organization / Company

### `Organization`
**NEW entity entirely** — frontend has no `Company`/`Organization` model; `UserRole.company` plus a single flat `TeamMember` list stands in for it. See [13-company-team.md](13-company-team.md) for full rationale.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| name | text | no | frontend source: `RegisterRequest.company.companyName`, currently mapped (wrongly, for a real system) onto `AuthUser.fullName` |
| commercialRegistrationNumber | text | no | unique — captured at registration, currently **discarded** by the mock; must be persisted |
| ownerUserId | uuid | no | FK → User.id — the `company`-role account that created the org |
| verificationStatus | enum | no | **NEW**: `unverified, pending, verified, rejected` — no CR-number verification exists client-side at all |
| createdAt / updatedAt | timestamptz | no | |

### `OrganizationMember`
Frontend source: `TeamMember` (`lib/features/team/domain/entities/team_member.dart`) — **missing `organizationId` entirely** in the frontend (single implicit company).

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| organizationId | uuid | no | **NEW** FK → Organization.id |
| userId | uuid | yes | FK → User.id — null until an invited email registers/links |
| email | citext | no | invite target, also display fallback pre-acceptance |
| fullName | text | no | frontend field, kept for pre-registration display |
| role | enum `OrgMemberRole` | no | frontend: `admin, manager, member` (`TeamMemberRole`) — recommend adding `owner` (auto-assigned to `ownerUserId`, not removable) since none of the three existing values is un-demotable/un-removable today |
| status | enum | no | **NEW**: `invited, active, removed` — frontend has no invitation lifecycle, membership is instant on `addMember` |
| joinedAt | timestamptz | yes | frontend field; null while `status = invited` |
| invitedAt | timestamptz | no | **NEW** |
| removedAt | timestamptz | yes | **NEW** |

### `OrganizationInvitation`
**NEW entity** — frontend's `addMember` is synchronous/immediate with no token, no expiry, no accept/decline step (confirmed zero matches for "Invitation" anywhere in the repo).

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| organizationId | uuid | no | FK |
| email | citext | no | |
| role | enum `OrgMemberRole` | no | proposed role on acceptance |
| token | text | no | unique, single-use |
| invitedByUserId | uuid | no | FK → User.id |
| status | enum | no | `pending, accepted, declined, expired, revoked` |
| expiresAt | timestamptz | no | e.g. 7 days |
| respondedAt | timestamptz | yes | |
| createdAt | timestamptz | no | |

---

## 3. Lawyer Marketplace

### `LawyerProfile`
Frontend source: `lib/features/lawyers/domain/entities/lawyer_profile.dart`.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| userId | uuid | no, unique | **NEW as an explicit FK** — frontend has `LawyerProfile.id` (`kDemoLawyerId`) totally disconnected from `AuthUser.id` (`kDemoLawyerUserId`); backend must unify these 1:1 |
| fullName | text | no | denormalized from `User.fullName` for read performance; kept in sync on update |
| bio | text | no | |
| yearsOfExperience | int | no | |
| barLicenseNumber | text | no | moved here from `LawyerRegistrationDetail` once profile exists, or kept there and joined — see [09](09-lawyers-marketplace.md) |
| rating | numeric(3,2) | no, default 0 | **derived/denormalized** aggregate — see `Review` below for source of truth |
| reviewsCount | int | no, default 0 | denormalized count |
| verificationStatus | enum | no | **NEW, replaces the frontend's two independent booleans** `isVerified`/`hasPendingVerification`: `unverified, pending, verified, rejected` |
| verificationRejectionReason | text | yes | **NEW** |
| createdAt / updatedAt | timestamptz | no | |

### `LawyerSpecialty` (join table `LawyerProfileSpecialty`)
Frontend enum `LawyerSpecialty`: `commercial, personalStatus, criminal, labor, realEstate, corporate, intellectualProperty, general` (8 fixed values, confirmed against ARB `specialty*` keys). Modeled as a lookup enum + join table (`lawyerProfileId`, `specialty`) since a lawyer has many.

### `LawyerConsultationOffering`
Frontend source: `LawyerProfile.consultationTypes: List<ConsultationType>` + `LawyerProfile.pricing: Map<ConsultationType, double>`, normalized into a table.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| lawyerProfileId | uuid | no | FK |
| consultationType | enum `ConsultationType` | no | `video, voice, written` |
| price | numeric(10,2) | no | |
| currency | text | no, default 'SAR' | frontend hardcodes SAR display string (`lawyerPriceSar`) |
| isActive | boolean | no, default true | lets a lawyer stop offering a type without deleting price history |
| unique(lawyerProfileId, consultationType) | | | |

### `Review`
**NEW entity entirely** — frontend's "Reviews" section on `LawyerDetailsScreen` is hardcoded static demo content (2 fixed entries), explicitly documented in-code as not backed by any list/submission flow. `LawyerProfile.rating`/`reviewsCount` are the only real aggregate fields.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| lawyerProfileId | uuid | no | FK, indexed |
| consultationId | uuid | no | FK → Consultation.id — a review must be tied to a completed consultation (prevents drive-by reviews) |
| reviewerUserId | uuid | no | FK → User.id (the client) |
| rating | smallint | no | 1–5, check constraint |
| comment | text | yes | |
| createdAt | timestamptz | no | |
| unique(consultationId, reviewerUserId) | | | one review per consultation |

---

## 4. Consultations & Live Sessions

### `Consultation`
Frontend source: `lib/features/consultations/domain/entities/consultation.dart`.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| lawyerProfileId | uuid | no | FK, indexed |
| clientUserId | uuid | no | **NEW** — frontend has no `clientId` at all, only a denormalized `clientName` string (explicit code comment calls this out as a known gap: *"Consultation has no clientId to derive 'the other party' from"*) |
| organizationId | uuid | yes | **NEW** — set when booked under a company account, null for an individual client |
| type | enum `ConsultationType` | no | `video, voice, written` |
| status | enum `ConsultationStatus` | no | 12 values — see [06-consultations.md](06-consultations.md) for the full state machine |
| scheduledAt | timestamptz | no | |
| durationMinutes | int | no, default 60 | frontend's `ConsultationRoomTiming.maxSessionDuration` |
| price | numeric(10,2) | no | snapshotted from `LawyerConsultationOffering.price` at booking time (price changes later must not retroactively alter a booked consultation) |
| currency | text | no | |
| notes | text | no, default '' | client-entered at booking |
| cancellationReason | text | yes | **NEW** — no reason field/enum exists client-side at all today |
| cancelledByUserId | uuid | yes | **NEW** |
| declineReason | text | yes | **NEW** |
| confirmedAt / startedAt / endedAt / completedAt | timestamptz | yes | **NEW** — lifecycle timestamps the frontend never persists (it infers "imminent"/"active" purely from `scheduledAt` math client-side) |
| createdAt / updatedAt | timestamptz | no | |
| deletedAt | timestamptz | yes | soft delete (audit trail for cancelled/disputed bookings) |

### `AvailabilitySlot`
Frontend source: `lib/features/consultations/domain/entities/availability_slot.dart`.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| lawyerProfileId | uuid | no | FK, indexed |
| startAt / endAt | timestamptz | no | |
| isBooked | boolean | no, default false | **denormalized flag**; source of truth for the "is this slot free" answer must be a DB-level exclusion constraint (see below) — frontend has zero server-side race protection today |
| consultationId | uuid | yes | FK → Consultation.id, set when booked |
| createdAt | timestamptz | no | |

**Concurrency requirement not present in the frontend at all**: a Postgres exclusion constraint (`EXCLUDE USING gist (lawyer_profile_id WITH =, tstzrange(start_at, end_at) WITH &&) WHERE (is_booked)`) or an equivalent transactional check-and-set is required so two clients cannot book the same slot — the mock's `_markSlot` runs no such check.

### `ConsultationRoomSession`
Frontend source: `lib/features/consultation_room/domain/entities/consultation_room_session.dart`.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| consultationId | uuid | no, unique | FK, 1:1 with Consultation |
| state | enum `SessionState` | no | `waiting, ready, connecting, active, ended, failed` |
| reconnectAttempts | int | no, default 0 | capped at `maxReconnectionAttempts = 3` (frontend constant) |
| durationSeconds | int | no, default 0 | accumulated active time |
| providerRoomId | text | yes | **NEW** — opaque id from whichever media provider is chosen (Phase 7+, see [06-consultations.md](06-consultations.md) §Room provider) |
| createdAt / updatedAt | timestamptz | no | |

### `ConsultationParticipantEvent`
**NEW** — an append-only join/leave/reconnect audit log; frontend has no server-observable event trail today (all state is client-computed).

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| consultationId | uuid | no | FK, indexed |
| userId | uuid | no | FK |
| eventType | enum | no | `joined, left, reconnect_attempted, reconnected, connection_lost, muted, unmuted, camera_on, camera_off` |
| occurredAt | timestamptz | no | |

---

## 5. Messaging

### `Message`
Frontend source: `lib/features/messages/domain/entities/message.dart` — described in-code as "the one real, live message model" (a legacy `ConsultationMessage` entity is dead code, superseded by this one).

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| consultationId | uuid | no | FK, indexed — chat is 1:1 scoped to a consultation, there is no standalone conversation/inbox concept anywhere in the frontend |
| senderId | uuid | no | FK → User.id |
| senderRole | enum `UserRole` | no | denormalized for display without a join |
| type | enum `MessageType` | no | `text, image, file` |
| text | text | no, default '' | body, or file display name for `file` type |
| attachmentId | uuid | yes | **NEW, replaces frontend's opaque `attachmentUrl: String`** — FK → Attachment.id |
| sentAt | timestamptz | no | |
| readAt | timestamptz | yes | null = unread |

### `Attachment`
**NEW entity** — the frontend has no dedicated attachment model; `attachmentUrl` is a raw string encoding either a session-only local image-cache key or a synthetic `mock-file://name::size` string with no real bytes.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| uploaderUserId | uuid | no | FK |
| consultationId | uuid | yes | set for chat attachments |
| contractId | uuid | yes | set for contract-related uploads |
| documentId | uuid | yes | set when an attachment is also registered in the document vault |
| fileName | text | no | |
| mimeType | text | no | |
| sizeBytes | bigint | no | frontend only ever fabricates a display string (`sizeLabel`) from string length — a real byte count is required |
| storageKey | text | no | object storage key/path, not a public URL (see [08](08-contracts-documents-signatures.md) storage design) |
| createdAt | timestamptz | no | |

---

## 6. Notifications

### `Notification`
Frontend source: `lib/features/notifications/domain/entities/app_notification.dart`.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| recipientUserId | uuid | no | frontend allows `null` = broadcast/legacy; backend should require a recipient and use a separate broadcast mechanism instead (see [10-notifications.md](10-notifications.md)) |
| type | enum `NotificationType` | no | 13 values, full taxonomy in [10-notifications.md](10-notifications.md) |
| title / body | text | no | frontend pre-renders localized strings at creation time rather than storing a template + params; backend should store `type` + structured `data` (jsonb) and let each client render its own locale — see migration note in [10](10-notifications.md) |
| relatedEntityType | enum | yes | **NEW, replaces overloading `type` as the sole discriminator** |
| relatedEntityId | uuid | yes | frontend field `relatedId` |
| isRead | boolean | no, default false | |
| readAt | timestamptz | yes | **NEW** — frontend only has the boolean |
| createdAt | timestamptz | no | |

### `PushDeliveryReceipt`
**NEW** — separates in-app notification persistence from actual push delivery, since the frontend has no push integration at all today.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| notificationId | uuid | no | FK |
| channel | enum | no | `push, email, sms` |
| status | enum | no | `queued, sent, delivered, failed` |
| providerMessageId | text | yes | |
| sentAt / deliveredAt / failedAt | timestamptz | yes | |

---

## 7. Contracts, Documents, Signatures

Full detail in [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md); entity list here for completeness.

### `ContractTemplate`
Frontend source: `lib/features/contracts/domain/entities/contract_template.dart` — currently a hardcoded 7-category catalog (`employment, sale, rental, partnership, nda, serviceAgreement, other`), duplicated per-locale as parallel arrays in the mock datasource.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| category | enum `ContractCategory` | no | |
| titleKey / title | jsonb | no | **NEW: localized content**, `{ "en": "...", "ar": "..." }` — frontend hardcodes two parallel Dart string arrays; backend should own this as data, not code |
| isActive | boolean | no, default true | allows retiring a template without deleting historical contracts that reference it |
| version | int | no, default 1 | **NEW** — a template edit must not silently alter contracts already generated from it; see [08](08-contracts-documents-signatures.md) |
| createdAt / updatedAt | timestamptz | no | |

### `ContractTemplateField`
Frontend source: `lib/features/contracts/domain/entities/contract_field.dart`.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| templateId | uuid | no | FK |
| label | jsonb | no | localized, same reasoning as template title |
| type | enum `ContractFieldType` | no | `text, multiline, number, date, dropdown, phone, email, currency` |
| isRequired | boolean | no | |
| options | jsonb | yes | array of localized option strings, dropdown only |
| hint | jsonb | yes | |
| sortOrder | int | no | |

### `Contract`
Frontend source: `lib/features/contracts/domain/entities/contract.dart` — **carries no owner/tenant field of any kind today.**

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| templateId | uuid | no | FK |
| templateVersion | int | no | snapshot of the template version used, so later template edits don't retroactively change a signed contract's rendering |
| ownerUserId | uuid | no | **NEW** — the account that created the draft |
| organizationId | uuid | yes | **NEW** — set when created under a company account |
| title | text | no | copied from template at creation |
| category | enum `ContractCategory` | no | denormalized from template |
| status | enum `ContractStatus` | no | `draft, pendingSignature, signed, completed, cancelled` — `completed` is defined for frontend parity but unused by the v1 state machine; `signed` is the terminal successful state for v1 (approved decision, see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 4) |
| fieldValues | jsonb | no | `{fieldId: value}` — frontend stores every value (dates, numbers) as strings; backend should keep this shape for simplicity but validate types server-side against `ContractTemplateField.type` |
| generatedDocumentId | uuid | yes | **NEW, replaces frontend's inline `generatedContent: String`** — FK → Document.id (the rendered PDF/text), see [08](08-contracts-documents-signatures.md) |
| cancellationReason | text | yes | **NEW** — approved decision, see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 5; required when `status` transitions to `cancelled`, mirrors `Consultation.cancellationReason` |
| cancelledByUserId | uuid | yes | **NEW** — FK → User.id, set server-side from the authenticated caller on cancel |
| cancelledAt | timestamptz | yes | **NEW** — set server-side at the moment of cancellation |
| createdAt / updatedAt | timestamptz | no | |
| deletedAt | timestamptz | yes | soft delete — frontend only allows delete while `status = draft`; keep that rule server-side too |

### `ContractParticipant`
**NEW entity entirely** — frontend's `Contract.parties: List<String>` is free text with no identity, no per-party signing state, and no role.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| contractId | uuid | no | FK |
| userId | uuid | yes | null when the party has no Aqd account (external counterparty) |
| fullName | text | no | |
| email | text | yes | |
| role | enum | no | `owner, counterparty, lawyerReviewer, witness` |
| signingOrder | int | no, default 0 | supports sequential signing later; v1 can treat all as order 0 (parallel) |
| status | enum | no | `pending, signed, declined` |
| invitedAt | timestamptz | no | |

### `ContractSignature`
**NEW entity entirely** — today a single `signContract(id)` call flips the whole contract to `signed` with no per-party record and, notably, no role check preventing a lawyer viewer from triggering it.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| contractId | uuid | no | FK |
| participantId | uuid | no | FK → ContractParticipant.id |
| signatureType | enum `SavedSignatureType` | no | `drawn, uploaded, typed` — reuses the frontend's existing 3-value enum |
| signatureData | jsonb | no | for `drawn`: stroke point arrays (frontend: `List<List<Offset>>`); for `typed`: the text; for `uploaded`: a pointer to the image `Attachment` |
| signedAt | timestamptz | no | |
| ipAddress | inet | yes | evidentiary metadata |
| userAgent | text | yes | |

### `SavedSignature`
Frontend source: `lib/features/profile/domain/entities/saved_signature.dart` — currently one signature per session, in-memory only, never persisted or linked to any contract.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| userId | uuid | no | FK, indexed |
| type | enum `SavedSignatureType` | no | `drawn, uploaded, typed` |
| data | jsonb | no | strokes / typed text / uploaded-image attachment id |
| isDefault | boolean | no, default true | frontend only ever has one; schema allows multiple for future-proofing without forcing it |
| createdAt / updatedAt | timestamptz | no | |

### `Document`
Frontend source: `lib/features/documents/domain/entities/document.dart` — no version field, no real file bytes/URL, no MIME type today.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| ownerUserId | uuid | no | **NEW** |
| organizationId | uuid | yes | **NEW** |
| sourceType | enum `DocumentSourceType` | no | `generatedContract, uploaded` |
| contractId | uuid | yes | FK, set only when `sourceType = generatedContract` |
| title | text | no | |
| currentVersionId | uuid | no | **NEW** FK → DocumentVersion.id |
| createdAt / updatedAt | timestamptz | no | |
| deletedAt | timestamptz | yes | soft delete |

### `DocumentVersion`
**NEW** — frontend's rename mutates a single record in place with no history at all.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| documentId | uuid | no | FK |
| versionNumber | int | no | |
| storageKey | text | no | |
| mimeType | text | no | |
| sizeBytes | bigint | no | |
| createdAt | timestamptz | no | |
| createdByUserId | uuid | no | |

---

## 8. AI

Full detail in [11-ai.md](11-ai.md).

### `AiConversation`
Frontend source: `lib/features/ai/domain/entities/ai_conversation.dart` — **no `userId` field at all today** (single global in-memory list).

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| userId | uuid | no | **NEW** |
| title | text | no | derived from first message, same as frontend |
| createdAt / updatedAt | timestamptz | no | |

### `AiMessage`
| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| conversationId | uuid | no | FK |
| role | enum | no | **NEW, replaces frontend's plain `isFromUser: bool`**: `user, assistant, system` — future-proofs for system prompts |
| text | text | no | |
| sentAt | timestamptz | no | |
| isError | boolean | no, default false | kept for parity though unused by the current mock |

### `ContractAnalysis`
Frontend source: `lib/features/ai/domain/entities/contract_analysis.dart` — **synchronous in the mock, no status/job concept.**

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| userId | uuid | no | **NEW** |
| sourceDocumentId | uuid | yes | FK → Document.id |
| documentTitle | text | no | |
| status | enum | no | **NEW**: `pending, processing, completed, failed` — required once analysis becomes a real async job |
| overallRisk | enum `AnalysisRiskLevel` | yes | `low, medium, high`; null until `completed` |
| summary | text | yes | |
| providerName | text | yes | **NEW** — which AI provider/model produced this, for audit/debugging |
| createdAt | timestamptz | no | |
| completedAt | timestamptz | yes | |
| failureReason | text | yes | **NEW** |

### `AnalysisClause`
| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| analysisId | uuid | no | FK |
| title / content / recommendation | text | no | |
| riskLevel | enum `AnalysisRiskLevel` | no | |
| sortOrder | int | no | |

---

## 9. Billing

Full detail in [12-billing.md](12-billing.md).

### `SubscriptionPlan`
**NEW entity** — approved decision, see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 2. Replaces the frontend's hardcoded tier×cycle→price table ([12-billing.md](12-billing.md) §3) so pricing changes don't require a frontend release.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| tier | enum `SubscriptionTier` | no | `basic, pro, enterprise` |
| billingCycle | enum `BillingCycle` | no | `monthly, sixMonths, annual` |
| price | numeric(10,2) | no | |
| currency | text | no, default 'JOD' | matches the frontend's displayed price currency |
| unique(tier, billingCycle) | | | |

### `PlanLimit`
**NEW entity** — approved decision, see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 2. Subscription limits are real, backend-enforced quotas, not marketing-only copy; the exact quota values are the "Advertised limits" column already documented in [12-billing.md](12-billing.md) §3.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| tier | enum `SubscriptionTier` | no | |
| resourceType | enum | no | **NEW**: `contract, contractAnalysis, lawyerConsultation` — one row per (tier, resourceType) |
| monthlyLimit | int | yes | null = unlimited (e.g. Pro/Enterprise contracts) |
| unique(tier, resourceType) | | | |

### `Subscription`
Frontend source: inline state in `SubscriptionController` (`lib/features/billing/presentation/providers/subscription_controller.dart`) — no repository/datasource layer exists at all today.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| subjectType | enum | no | **NEW**: `user, organization` — a subscription can belong to an individual or a company |
| subjectId | uuid | no | polymorphic FK |
| tier | enum `SubscriptionTier` | no | `basic, pro, enterprise` |
| billingCycle | enum `BillingCycle` | no | `monthly, sixMonths, annual` |
| status | enum | no | **NEW**: `active, pastDue, cancelled, expired` — frontend has no status concept, just a nullable current tier |
| currentPeriodStart / currentPeriodEnd | timestamptz | no | **NEW** |
| cancelAtPeriodEnd | boolean | no, default false | **NEW** |
| createdAt / updatedAt | timestamptz | no | |

### `PaymentMethod`
Frontend source: `lib/features/billing/domain/entities/payment_method.dart` — explicitly documented in-code as "lightweight UI-only mock state, not a domain entity."

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| subjectType / subjectId | enum / uuid | no | polymorphic, same pattern as Subscription |
| provider | text | no | **NEW** — e.g. `stripe`; frontend never references a provider |
| providerPaymentMethodId | text | no | **NEW** — opaque token from the provider; raw card data (`Validators` reveals the frontend form collects card number/expiry/CVV client-side) must never reach the backend/DB — tokenize at the provider's client SDK |
| brand | text | no | e.g. `visa` |
| last4 | text | no | |
| expiryMonth / expiryYear | smallint | no | **NEW** — frontend collects but never models expiry on the entity |
| holderName | text | no | |
| isDefault | boolean | no, default false | |
| createdAt | timestamptz | no | |

### `Invoice`
Frontend source: `lib/features/billing/domain/entities/invoice.dart` — flat row, only `paid`/`pending` statuses, no line items, no link to subscription/consultation.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| subjectType / subjectId | enum / uuid | no | polymorphic |
| subscriptionId | uuid | yes | **NEW** FK, set for plan invoices |
| consultationId | uuid | yes | **NEW** FK, set for pay-per-consultation invoices (the frontend already pays for a booked consultation through the same `PaymentPanel`) |
| title | text | no | |
| amount | numeric(10,2) | no | |
| currency | text | no | |
| status | enum | no | **expanded from frontend's 2 values**: `draft, pending, paid, overdue, void` |
| dueDate | timestamptz | yes | **NEW** |
| paidAt | timestamptz | yes | **NEW** |
| createdAt | timestamptz | no | |

### `Transaction`
**NEW entity** — no payment-provider transaction record exists in the frontend at all.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| invoiceId | uuid | no | FK |
| paymentMethodId | uuid | yes | FK |
| provider | text | no | |
| providerTransactionId | text | no | |
| amount / currency | numeric / text | no | |
| status | enum | no | `succeeded, failed, pending, refunded` |
| failureReason | text | yes | |
| createdAt | timestamptz | no | |

---

## 10. Government Procedures

Frontend source: `lib/features/gov_documents/domain/entities/gov_procedure.dart` — a small, fixed, backend-owned reference catalog (4 items today), plus ephemeral unpersisted per-user progress.

### `GovProcedure`
| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| type | enum `GovProcedureType` | no, unique | `companyRegistration, propertyRegistration, contractNotarization, lawsuitFiling` |
| durationLabel | jsonb | no | localized display string |
| accessType | enum `GovProcedureAccessType` | no | `directLink, guide` |

### `GovRequiredDocument` / `GovProcedureStep`
Simple child tables (`procedureId` FK, `title`/`description` jsonb, `sortOrder`) matching `GovRequiredDocument`/`GovProcedureStep` 1:1.

### `UserGovProcedureProgress`
**NEW** — frontend's `GovProceduresProgressController` is a pure in-memory Riverpod `Notifier`, resets on every app restart; if this feature is meant to be real, it needs persistence.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| userId | uuid | no | FK |
| procedureId | uuid | no | FK |
| startedAt | timestamptz | yes | |
| checkedDocumentIds | uuid[] | no, default '{}' | |
| unique(userId, procedureId) | | | |

---

## 11. Cross-cutting

### `AuditLog`
**NEW** — required per [17 Security](14-security.md) even though the frontend has no audit trail concept at all.

| Field | Type | Null? | Notes |
|---|---|---|---|
| id | uuid | PK | |
| actorUserId | uuid | yes | null for system-triggered events |
| action | text | no | e.g. `contract.signed`, `consultation.cancelled` |
| entityType / entityId | text / uuid | no | |
| metadata | jsonb | yes | before/after diff where relevant |
| ipAddress | inet | yes | |
| createdAt | timestamptz | no | |

## Enum reference (exhaustive, as found in frontend source)

| Enum | Values | Source |
|---|---|---|
| `UserRole` | client, lawyer, company | `auth_user.dart` |
| `ConsultationType` | video, voice, written | `lawyers/domain/entities/consultation_type.dart` |
| `ConsultationStatus` | pendingApproval, confirmed, waiting, ready, connecting, active, ended, completed, cancelled, declined, missed, failed | `consultation_status.dart` |
| `SessionState` | waiting, ready, connecting, active, ended, failed | `consultation_room/domain/entities/session_state.dart` |
| `LawyerSpecialty` | commercial, personalStatus, criminal, labor, realEstate, corporate, intellectualProperty, general | `lawyer_specialty.dart` |
| `MessageType` | text, image, file | `messages/domain/entities/message_type.dart` |
| `NotificationType` | contractCreated, contractUpdated, contractReady, contractRequiresAction, consultationBooked, consultationAccepted, consultationRejected, consultationCancelled, consultationCompleted, consultationReminder, newMessage, documentUploaded, aiAnalysisCompleted | `notification_type.dart` |
| `ContractCategory` | employment, sale, rental, partnership, nda, serviceAgreement, other | `contract_category.dart` |
| `ContractFieldType` | text, multiline, number, date, dropdown, phone, email, currency | `contract_field_type.dart` |
| `ContractStatus` | draft, pendingSignature, signed, completed, cancelled | `contract_status.dart` |
| `DocumentSourceType` | generatedContract, uploaded | `document_source_type.dart` |
| `SavedSignatureType` | drawn, uploaded, typed | `saved_signature.dart` |
| `AnalysisRiskLevel` | low, medium, high | `analysis_risk_level.dart` |
| `SubscriptionTier` | basic, pro, enterprise | `subscription_tier.dart` |
| `BillingCycle` | monthly, sixMonths, annual | `billing_cycle` in `subscription_tier.dart` |
| `InvoiceStatus` | paid, pending (backend expands to 5 — see §9) | `invoice.dart` |
| `TeamMemberRole` | admin, manager, member (backend adds `owner` — see §2) | `team_member_role.dart` |
| `GovProcedureType` | companyRegistration, propertyRegistration, contractNotarization, lawsuitFiling | `gov_procedure.dart` |
| `GovProcedureAccessType` | directLink, guide | `gov_procedure.dart` |
