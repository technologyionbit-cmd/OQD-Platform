# Multi-Tenancy & Ownership

## 1. The core problem

The frontend was built with **zero data-level tenancy**. Every audit confirms the same pattern: `Contract`, `Document`, `Consultation`, `AiConversation` carry no owner/tenant foreign key at all — the mock datasources hold one flat in-memory list per entity type, shared identically across whichever role is currently "logged in." The only thing that differs per role in the running app is:

1. Which route/shell renders the screen (`routeBase` parameter: `/client`, `/lawyer`, `/company`).
2. Which buttons/FABs that screen chooses to show (`_canManage`, `canCreate` booleans checked against `routeBase`).

**This must not be copied into the backend.** The task instructions are explicit about this, and the audits independently confirm why: there is no mock simplification to preserve here — the frontend simply never had to solve isolation because it only ever ran one demo identity per role at a time.

## 2. Ownership axes the backend must introduce

| Axis | Field | Lives on | Why |
|---|---|---|---|
| Individual ownership | `ownerUserId` / `clientUserId` | Contract, Document, AiConversation, ContractAnalysis, Consultation | The account that created/booked the resource |
| Organization scoping | `organizationId` (nullable) | Contract, Document, Consultation, Subscription, PaymentMethod, Invoice | Set when the resource was created under a company account; null for individual-client resources |
| Lawyer scoping | `lawyerProfileId` | Consultation, AvailabilitySlot, Review, LawyerConsultationOffering | A lawyer's own bookings/schedule — a lawyer is never the "owner" of a client's contract, only ever a `ContractParticipant` with a `lawyerReviewer` role |
| Participant scoping | `ContractParticipant.userId` | Contract (indirect) | Grants read access without ownership — this is exactly the frontend's "lawyer sees, never edits" behavior, made real |

### Why `organizationId` is nullable rather than every user having an implicit personal org

Rejected alternative: give every individual user an auto-created 1-row "personal organization" so `organizationId` could be non-null everywhere (a common SaaS pattern). **Not recommended here** because:
- The frontend has three genuinely distinct account types with different registration fields and different UI (`RegisterRequest.individual/company/lawyer`) — collapsing "individual" into "org of one" adds a layer of indirection the frontend never needed and complicates the permission matrix in [02-auth-and-authorization.md](02-auth-and-authorization.md) for no observed benefit.
- The company routing comment is explicit that company is "just another account that creates contracts and books lawyers" — i.e., the differentiator is *membership*, not a structurally different resource shape. A nullable `organizationId` models exactly that difference with the least new structure.

## 3. Where each ownership field goes (full list, cross-referenced to §7 of [01-domain-model.md](01-domain-model.md))

- **`Contract.ownerUserId` (required) + `Contract.organizationId` (nullable)**: the creator's individual id is always recorded even for an org contract (for audit — "who on the team drafted this"), and `organizationId` gates the org-wide visibility a company account gets over its members' contracts.
- **`Document`**: identical shape to `Contract` for the same reason (documents are 1:1-ish with contracts via `contractId`, but uploaded documents need their own ownership independent of any contract).
- **`Consultation.clientUserId` (required) + `Consultation.organizationId` (nullable)**: closes the frontend's most concrete, code-commented gap (`Consultation` "has no clientId to derive 'the other party' from"). `lawyerProfileId` is always required (a consultation always has exactly one lawyer).
- **`AiConversation.userId` (required)**: AI chat is always personal, never org-shared, even when the account is a company — matches the frontend's UI, where AI is a client-only tab with no company-facing entry point.
- **`Subscription`/`PaymentMethod`/`Invoice`.subjectType/subjectId (polymorphic: `user` or `organization`)**: billing can belong to either an individual or a company — mirrors that both roles reach the same `SubscriptionPlansScreen`/`PaymentPanel` in the frontend, just from different shells.

## 4. Enforcement layers

Ownership fields alone are inert — they only matter if every read/write path actually filters by them. Three enforcement layers, from strongest to weakest, and the recommendation for this project:

1. **Row-Level Security (RLS) at the Postgres level**, keyed off a `current_setting('app.current_user_id')`/`current_setting('app.current_org_id')` set per request. **Recommended** as a defense-in-depth backstop given this is a legal-document platform (Contract/Document rows contain sensitive personal/business data) — even if application code has a bug, RLS prevents cross-tenant leakage at the database layer. See policy sketch in [04-database-design.md](04-database-design.md).
2. **Application-layer scoping in every repository/query** (e.g., every `Contract` query includes `WHERE owner_user_id = :uid OR organization_id = :org_id OR id IN (SELECT contract_id FROM contract_participants WHERE user_id = :uid)`). This is the primary, always-on layer; RLS is the safety net behind it, not a replacement for careful query-writing.
3. **API-layer authorization checks** (per [02-auth-and-authorization.md](02-auth-and-authorization.md) §6) — verifies the *authenticated* user is allowed to perform the *specific action*, not just that the row is visible to them (e.g., visible-but-read-only for a lawyer on a contract).

## 5. Company as tenant — the specific decision the task calls out

Per the billing/company/team audit: `Company` in the frontend is unambiguously **a role of an individual account** (`UserRole.company`), not a separate multi-tenant entity — there is no `Company`/`Organization` class anywhere in the code, and `TeamMember` has zero `companyId`/`organizationId` field (the mock keeps exactly one implicit company, ever).

**Backend decision: introduce `Organization` as a real, separate entity** (see [01-domain-model.md](01-domain-model.md) §2 and [13-company-team.md](13-company-team.md) for full schema/rationale), owned by the `company`-role user that created it, with `OrganizationMember` rows giving other users (who may be `client`- or `lawyer`-role accounts, or newly-invited people with no account yet) membership and an internal role. This is **not** copying the mock's simplification forward — it is the minimum real structure needed to support more than one company ever existing on the platform, which the mock never had to prove out.

Reasoning for why this must be a first-class entity and not just "a flag on User":
- Multiple humans need shared access to the same set of contracts/documents/consultations (that's the entire premise of `TeamMember` existing at all in the UI).
- A company needs its own billing subject (`Subscription`/`Invoice` polymorphic `subjectId`) independent of any one member's personal account, matching how `CompanyHomeScreen` aggregates contracts/documents/team/consultations as one unit today, just without real isolation.
- Verification (`commercialRegistrationNumber`) is a property of the *business*, not of the individual account that happened to register it — it must survive that user leaving/being removed as `ownerUserId` (recommend: ownership transfer capability, at least as a documented future requirement, not built in Phase 1–3).

## 6. What does NOT need per-tenant isolation

- `ContractTemplate`/`ContractTemplateField`, `GovProcedure` (and children), `LawyerSpecialty` lookup values: these are **platform-owned reference data**, identical to how the frontend hardcodes them as static catalogs today (7 contract categories, 4 gov procedures, 8 specialties) — no `organizationId`/`ownerUserId` on any of these; they are global and admin-managed.
- `LawyerProfile`/`Review`/`LawyerConsultationOffering`: **public marketplace data** — every user, in every tenant, can read every lawyer's profile (this is the point of a marketplace). Tenancy applies to *who booked which lawyer* (`Consultation`), not to the lawyer directory itself.

## 7. Summary decision table (answers the task's explicit question)

| Data | Owner axis | Notes |
|---|---|---|
| individual user's personal data (profile, saved signature, AI conversations, notifications, payment methods when acting personally) | `userId` | never org-visible |
| lawyer's marketplace profile & availability | `lawyerProfileId` (1:1 `userId`) | public read, owner write |
| client's contracts/documents/consultations (no org) | `ownerUserId` / `clientUserId`, `organizationId = null` | |
| company/workspace's contracts/documents/consultations | `ownerUserId` (who on the team acted) + `organizationId` (the tenant) | org members share visibility per [02](02-auth-and-authorization.md) matrix |
| consultation | `clientUserId`, `lawyerProfileId`, `organizationId` nullable | three-way visibility: client, lawyer, and (if org-booked) the org |
| contract | `ownerUserId`, `organizationId` nullable, plus `ContractParticipant` rows for read-only external/lawyer access | |
| document | same shape as contract | |
