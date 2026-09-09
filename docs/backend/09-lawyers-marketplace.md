# Lawyers Marketplace

## 1. Entities

Full field lists in [01-domain-model.md](01-domain-model.md) §3: `LawyerProfile`, `LawyerProfileSpecialty`, `LawyerConsultationOffering`, `Review`.

## 2. Identity: unifying auth and marketplace profile

The frontend's most concrete marketplace-specific gap: `LawyerProfile.id` (`kDemoLawyerId = 'lwr_seed_1'`) and `AuthUser.id` (`kDemoLawyerUserId = 'u_lawyer_1'`) are **two disconnected identity spaces** — every lawyer-role screen just hardcodes scoping to the fixed demo profile id because there's no real multi-lawyer backend to look anything up against.

**Decision: `LawyerProfile.userId` is a required, unique 1:1 foreign key to `User.id`.** A `LawyerProfile` is created automatically at registration time for `role = lawyer` accounts (seeded from `LawyerRegistrationDetail`'s `barLicenseNumber`/`mainSpecialty`, per [02-auth-and-authorization.md](02-auth-and-authorization.md)). Every "my profile"/"my schedule"/"my dashboard" endpoint resolves the profile via `currentUser.id → LawyerProfile.userId`, never via a separate id the client has to track — this both fixes the disconnect and matches how every other role-scoped resource in this spec works.

## 3. Verification flow

Frontend models verification as **two independent booleans** on `LawyerProfile` (`isVerified: bool`, default `true`; `hasPendingVerification: bool`, default `false`), yielding three effective UI states (Verified / Pending Review / Not Verified) with no way to go from "pending" back to "verified" anywhere in the app — there is no admin/reviewer action modeled at all.

**Decision: replace both booleans with a single `verificationStatus` enum**: `unverified, pending, verified, rejected` (plus `verificationRejectionReason: text?`). This is a strict improvement — it removes the two illegal/ambiguous boolean combinations the frontend's pair allows (e.g. both `true`) and adds the missing `rejected` terminal state.

Flow:
1. New lawyer registers → `verificationStatus = unverified` (mirrors the frontend defaulting `isVerified: true` for the seeded *demo* account being intentionally misleading for a prototype — a real backend must never default a fresh registration to verified).
2. Lawyer uploads a verification document (bar license, ID, etc.) via the signed-upload flow ([05-api-design.md](05-api-design.md) §3, `purpose: verification_document`) → `POST /v1/lawyers/me/verification-documents` → `verificationStatus = pending`. This matches the frontend's existing `_submitVerificationDocument` flow (`image_picker` → preview → confirm), just with a real upload behind it instead of a same-call boolean flip.
3. **New required capability with zero frontend precedent**: an approve/reject action. No admin app/screen exists anywhere in this codebase. **Approved** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 1): a minimal, UI-less, protected internal endpoint ships in Phase 2 (`POST /v1/admin/lawyers/{id}/verify` / `.../reject`), gated by a new `platformAdmin` permission that never maps to, or is combined with, any `UserRole` value (`client`/`lawyer`/`company`) — it is a backend-only concept with no self-service or normal-user path to obtain it, and no admin UI ships in v1.
4. Until a lawyer is `verified`, recommend excluding them from public marketplace search by default (the frontend doesn't currently filter by verification status in `LawyersListScreen`, but doing so is an obviously correct real-world requirement the mock never had to enforce because its one demo lawyer is always verified).

## 4. Profile fields, specialties, pricing

- `bio`, `yearsOfExperience`, `fullName` — plain profile fields, editable by the lawyer only.
- `LawyerProfileSpecialty` — many-to-many via join table; frontend's 8-value `LawyerSpecialty` enum (`commercial, personalStatus, criminal, labor, realEstate, corporate, intellectualProperty, general`) is reused verbatim, confirmed against the ARB `specialty*` keys as a fixed, complete set — no evidence a lawyer needs a specialty not on this list.
- `LawyerConsultationOffering` — normalizes the frontend's `Map<ConsultationType, double>` into `(lawyerProfileId, consultationType, price, currency, isActive)` rows, letting a lawyer stop offering a consultation type without losing historical price data tied to past consultations (which snapshot their own price at booking time — see [06-consultations.md](06-consultations.md) §2).

## 5. Search & filtering

Frontend does everything client-side over the full lawyer list (`LawyersListScreen`): text match on `fullName`, single-select specialty chip, min-rating bucket (`4.5+`/`4.0+`/all), and a cosmetic "availability window" bucket (`today/thisWeek/later`, deliberately derived from a hash of the lawyer id, **not** the real slot calendar — explicitly documented in-code as decoupled from `consultations` on purpose).

Backend `GET /v1/lawyers` should support real equivalents of the first three (text search via `pg_trgm` on `fullName`, `specialty` filter, `minRating` filter) plus pagination — and should decide the availability filter for real: querying "has at least one open `AvailabilitySlot` in the next N days" against the actual `AvailabilitySlot` table, replacing the frontend's decoupled hash-based placeholder with a real answer now that a real slot calendar exists server-side. No price-range filter exists in the frontend despite `pricing` being queryable — worth adding given the data now supports it, but not required to match parity.

## 6. Reviews & ratings

**Entirely new** — the frontend's "Reviews" section is two hardcoded static entries with an explicit in-code comment stating there is no real per-lawyer review list or submission flow, only the aggregate `rating`/`reviewsCount` numbers.

- `Review` ([01-domain-model.md](01-domain-model.md) §3): one per `(consultationId, reviewerUserId)`, only submittable once that consultation is `completed` (prevents reviewing a consultation that never happened) — see [06-consultations.md](06-consultations.md) §7 endpoint.
- `LawyerProfile.rating`/`reviewsCount` become **derived/denormalized** — recomputed (trigger or application-transaction) whenever a `Review` is inserted, never client-writable directly. This preserves the exact fields the frontend already reads (`rating: double`, `reviewsCount: int`) so `LawyerProfile`'s public shape doesn't change from the client's point of view — only the source of truth behind it does.

## 7. Endpoint table

| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/lawyers | 🔓/🔒 | Marketplace search/list (text, specialty, minRating, availability filters) |
| GET /v1/lawyers/{id} | 🔓/🔒 | Public profile detail |
| GET /v1/lawyers/{id}/reviews | 🔓/🔒 | Paginated reviews |
| GET /v1/lawyers/me | 🔒 (lawyer) | Own profile (full, incl. verification status) |
| PATCH /v1/lawyers/me | 🔒 (lawyer) | Edit bio/specialties/experience/pricing |
| POST /v1/lawyers/me/verification-documents | 🔒 (lawyer) | Submit for verification → `pending` |
| POST /v1/admin/lawyers/{id}/verify | 🔒 (platform admin — new role, needs approval) | `pending → verified` |
| POST /v1/admin/lawyers/{id}/reject | 🔒 (platform admin) | `pending → rejected` `{reason}` |
| GET/POST/DELETE /v1/lawyers/me/availability | 🔒 (lawyer) | See [06-consultations.md](06-consultations.md) |
