# Contracts, Documents & Signatures

## 1. Entities

Full field lists in [01-domain-model.md](01-domain-model.md) §7: `ContractTemplate`, `ContractTemplateField`, `Contract`, `ContractParticipant` (**new**), `ContractSignature` (**new**), `SavedSignature`, `Document`, `DocumentVersion` (**new**).

## 2. Templates & dynamic fields

The frontend's 7-category catalog (`employment, sale, rental, partnership, nda, serviceAgreement, other`) is currently hardcoded as parallel Arabic/English Dart arrays inside the mock datasource. The backend makes this **data, not code**: `ContractTemplate`/`ContractTemplateField` rows with `jsonb` localized content (`{en: "...", ar: "..."}`), managed via the same protected, UI-less `platformAdmin` surface approved for lawyer verification ([16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 1, [02-auth-and-authorization.md](02-auth-and-authorization.md) §6) rather than a separate admin concept — no admin UI exists in this frontend, and none is required for v1 since `ContractTemplate` is platform-owned reference data seeded once at launch (per [03-multi-tenancy.md](03-multi-tenancy.md) §6), not something end users manage.

Field types (8, unchanged from frontend): `text, multiline, number, date, dropdown, phone, email, currency`. Every template always has a `partyA`/`partyB` text-field pair in the frontend — recommend keeping this as a template-authoring convention rather than a schema-level special case (both are just `ContractTemplateField` rows with `type = text`).

**Template versioning** (`ContractTemplate.version`, new relative to the frontend): editing a template's fields must not retroactively change the rendering of contracts already generated from an earlier version. `Contract.templateVersion` snapshots which version was used at generation time.

## 3. Contract lifecycle

`ContractStatus`: `draft, pendingSignature, signed, completed, cancelled` (5 values, exactly as the frontend defines — the mock only ever exercises `draft → pendingSignature → signed`).

**Approved decision** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 4): **no separate `completed` status is required for v1 — `signed` is the terminal successful state.** The `completed` value stays defined on the enum for frontend parity (it exists in the frontend's own `ContractStatus`), but the v1 backend never transitions a contract into it; there is no `signed → completed` transition in the state machine below. If a future product need for a distinct post-signing "completed" step emerges (e.g. all post-signing formalities done), that is new scope requiring its own decision, not something this phase builds speculatively.

**Approved decision** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 5): **contract cancellation is in scope for v1.** The frontend has no cancel action/button/repository method at all for contracts (unlike consultations, which do have one) — this is net-new backend capability, not a gap-fill, but it is now approved and specified below rather than deferred.

| Transition | Trigger | Notes |
|---|---|---|
| (create) → draft | `POST /v1/contracts` (save draft) | Owner or org member (per [02-auth-and-authorization.md](02-auth-and-authorization.md) matrix — never a lawyer) |
| draft → pendingSignature | `POST /v1/contracts/{id}/generate` | Validates all required `ContractTemplateField`s have a value matching `type`; renders the document (see §5); creates `ContractParticipant` rows for every named party |
| pendingSignature → signed | Last outstanding `ContractParticipant.status` flips to `signed` | **Not** a single unconditional flip like the frontend — see §4. `signed` is terminal for v1 (see above) |
| draft/pendingSignature → cancelled | Owner or org admin (§3.1) | See §3.1 for full authorization/reason/timestamp design |
| draft → (delete) | Owner or org member, `draft` only | Matches frontend's exact rule (`contract_details_screen.dart`: delete only offered when `status == draft`) |
| completed, cancelled | (terminal, no further transitions) | `signed` is also effectively terminal in v1 since nothing transitions out of it |

### 3.1 Cancellation — who, when, why, and audit trail

- **Who can cancel**: the contract's `ownerUserId`, or — for an org-scoped contract (`organizationId` set) — any `OrganizationMember` with `role ∈ {owner, admin}` for that organization. A `ContractParticipant` who is not the owner (e.g. a counterparty or the `lawyerReviewer`) cannot cancel; a lawyer can never cancel, consistent with lawyers being read-only on contracts everywhere else in this spec ([02-auth-and-authorization.md](02-auth-and-authorization.md) §6).
- **Valid transitions**: `draft → cancelled` and `pendingSignature → cancelled` only. A `signed` contract cannot be cancelled through this endpoint — an already-executed contract is out of scope for a simple status-flip cancellation and would require a distinct legal process (amendment/termination) not modeled in v1.
- **Required fields on cancel** (mirrors `Consultation`'s existing cancellation shape in [01-domain-model.md](01-domain-model.md) §4): `cancellationReason: text` (required), `cancelledByUserId: uuid` (set server-side from the authenticated caller), `cancelledAt: timestamptz` (set server-side at the moment of cancellation). These are **new** fields on `Contract` — see [01-domain-model.md](01-domain-model.md) §7.
- **Authorization enforcement**: `POST /v1/contracts/{id}/cancel` re-checks the ownership/org-admin rule above server-side on every call, the same as every other mutating contract endpoint — never trusted from a client-supplied flag.
- **Side effects**: any outstanding `ContractParticipant` rows are left as-is (their individual `status` is not altered — a cancelled contract simply stops being actionable); a `Notification` (`contractUpdated` or a new `contractCancelled` type, product's choice at Phase 3 implementation time) is sent to all participants; an `AuditLog` row is written per [14-security.md](14-security.md).

## 4. Signing — fixing the frontend's single biggest structural gap

The frontend has **no `ContractParticipant`/`ContractSignature` entity at all**. `Contract.parties: List<String>` is free text, and `signContract(id)` unconditionally sets the whole contract to `signed` regardless of who calls it or how many parties exist — with, per the audit, no role check even preventing a lawyer viewer from triggering it (the Sign button's only guard is `status == pendingSignature`), which reads as an oversight relative to the frontend's own stated intent that lawyers get read-only access everywhere else.

Real design:

1. On `generate()`, create one `ContractParticipant` row per named party (parsed from the template's party fields, e.g. `partyA`/`partyB` values), each `status = pending`. If a party's name matches a real registered `User` (by email, if collected) link `userId`; otherwise leave `userId = null` (external counterparty with no account — still needs a way to sign, e.g. a tokenized signing link sent by email, out of scope for the exact mechanism here but the entity shape supports it).
2. `POST /v1/contracts/{id}/sign` requires the caller to be an **authorized signer**: `ContractParticipant.userId == currentUser.id` (or `currentUser` has org-level permission to sign on behalf of the org party, per [02-auth-and-authorization.md](02-auth-and-authorization.md)). **A lawyer participant with `role = lawyerReviewer` is explicitly barred from signing**, even if somehow listed as a participant, closing the frontend's apparent oversight at the backend layer rather than relying on the UI to hide the button.
3. Creates a `ContractSignature` row (`signatureType`, `signatureData`, `signedAt`, `ipAddress`) and flips that participant's `status = signed`.
4. Once **every** `ContractParticipant.status = signed`, the backend (not the client) flips `Contract.status = signed` and triggers regeneration of the final signed document (see §5) — the frontend today never regenerates `generatedContent` after signing at all, which the backend must fix since a signed contract's document should visibly reflect all signatures, not just an in-place status label.
5. Multi-party: this design supports N parties natively (frontend never had more than an implicit 2-party model via `partyA`/`partyB` strings). `signingOrder` on `ContractParticipant` allows sequential signing later (e.g. counterparty can't sign until the owner has); v1 can treat all participants as parallel (`signingOrder = 0` for everyone) since nothing in the frontend implies sequential signing was ever a requirement.

## 5. Document generation & storage

- **`generatedContent` (frontend: a plain-text string field on `Contract`) becomes a real rendered `Document`** — `Contract.generatedDocumentId → Document.id`, with the actual bytes (PDF, recommended, since this is a legal artifact meant to be downloaded/shared/printed) in object storage via `DocumentVersion.storageKey`.
- **Regeneration on signing**: a new `DocumentVersion` is created once the contract is fully signed (embedding a visual representation of each signature — rendered from `ContractSignature.signatureData`), rather than mutating the draft-time text in place, giving a clean "pre-signature draft" vs. "final signed" document pair.
- **Storage split** (repeats [04-database-design.md](04-database-design.md) §5 for this module specifically): `Contract.fieldValues` stays relational `jsonb`; the rendered document (draft preview and final signed PDF) is object storage, referenced by `DocumentVersion`.

## 6. Documents (vault) — versions, metadata, access control

Frontend `Document` has no version field, no real file bytes/path/URL, and a fabricated `sizeLabel` string rather than a real byte count. Backend adds `DocumentVersion` (real `storageKey`, `mimeType`, `sizeBytes`) so rename/replace operations preserve history instead of mutating in place. `Document.ownerUserId`/`organizationId` (new, per [03-multi-tenancy.md](03-multi-tenancy.md)) replace the frontend's total absence of ownership.

**Upload**: real bytes via the signed-URL flow ([05-api-design.md](05-api-design.md) §3, `purpose: document`) — the frontend's current "upload" only registers a title string with a fabricated size, no real file at all.

**Access control**, mirroring the audited restriction exactly: lawyers get read-only access to a client's/org's documents wherever they're a contract participant or explicitly shared; upload/rename/delete are **never** available to a lawyer, enforced at the API layer (not just hidden in the UI as today).

**Download/access URLs**: short-lived signed GET URLs generated per-request after an authorization check (`GET /v1/documents/{id}/download` → 302 to a signed object-storage URL, or returns the signed URL in the JSON body for the client to fetch directly) — never a permanently public URL, since these are legal/personal documents.

## 7. Saved signatures

`SavedSignature` ([01-domain-model.md](01-domain-model.md) §7) persists what the frontend currently only keeps in-memory per session (`SavedSignatureController`, wiped on app restart, never linked to any actual contract signature). Real flow: `GET/POST /v1/users/me/saved-signatures` lets a user save a reusable signature once; `POST /v1/contracts/{id}/sign` can accept either `savedSignatureId` (reuse) or fresh `signatureType`/`signatureData` (one-off) — this mirrors the frontend's 3-tab sign sheet (saved / upload / draw) exactly, just with real persistence behind the "saved" tab instead of session-only state.

## 8. Endpoint table

| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/contract-templates | 🔒 | Catalog (category + fields), locale-aware |
| GET /v1/contracts | 🔒 | List (owner, org, or participant-visible) |
| GET /v1/contracts/{id} | 🔒 | Detail |
| POST /v1/contracts | 🔒 (not lawyer) | Create/save draft |
| PATCH /v1/contracts/{id} | 🔒 (owner/org, draft only, not lawyer) | Update draft fields |
| DELETE /v1/contracts/{id} | 🔒 (owner/org, draft only, not lawyer) | Delete |
| POST /v1/contracts/{id}/generate | 🔒 (owner/org, not lawyer) | draft → pendingSignature, creates participants + draft document |
| POST /v1/contracts/{id}/sign | 🔒 (authorized signer only, never lawyer reviewer) | Records signature; flips contract status once all sign |
| POST /v1/contracts/{id}/cancel | 🔒 (owner/org admin) | `{cancellationReason}` — draft/pendingSignature only, see §3.1 |
| GET /v1/documents | 🔒 | List (owner/org, filterable by sourceType) |
| POST /v1/documents | 🔒 (not lawyer) | Register upload (see [05-api-design.md](05-api-design.md) §3 for the 2-step signed-upload flow) |
| PATCH /v1/documents/{id} | 🔒 (owner/org, not lawyer) | Rename |
| DELETE /v1/documents/{id} | 🔒 (owner/org, not lawyer) | Delete |
| GET /v1/documents/{id}/download | 🔒 (owner/org/participant) | Signed download URL |
| GET /v1/users/me/saved-signatures | 🔒 | List |
| POST /v1/users/me/saved-signatures | 🔒 | Create |
| DELETE /v1/users/me/saved-signatures/{id} | 🔒 | Remove |
