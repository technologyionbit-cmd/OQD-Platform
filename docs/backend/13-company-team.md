# Company / Team (Organization Workspace)

## 1. The frontend's actual model — confirmed, not assumed

Direct grep confirms **zero** matches for `companyId`/`organizationId`/`orgId`/`workspaceId`/`tenantId` anywhere in `contracts`, `documents`, `team`, `billing`, or `company`. `lib/features/company/**` is presentation-only (a single dashboard screen reusing the generic `contracts`/`documents`/`consultations`/`teamControllerProvider` — the same providers an individual client uses). `lib/features/team/**` has a real `TeamMember` entity but **no `companyId` field on it at all** — the mock maintains exactly one flat, implicit company, ever. The routing layer's own doc comment states the model plainly: *"a company is, in this mock backend, just another account that creates contracts and books lawyers."*

**This is confirmed to be a mock simplification the task explicitly says not to copy forward.** See [03-multi-tenancy.md](03-multi-tenancy.md) for the full reasoning; this document covers the `Organization`/`OrganizationMember`/`OrganizationInvitation` design itself.

## 2. Entities

Full field lists in [01-domain-model.md](01-domain-model.md) §2: `Organization`, `OrganizationMember`, `OrganizationInvitation`.

## 3. Organization creation

An `Organization` is created automatically when a `company`-role account registers (`RegisterRequest.company`), using the two fields the mock currently **discards**: `companyName` → `Organization.name` (currently miswired onto `AuthUser.fullName` in the mock — a real system must keep the individual account's own name separate from the business name), `commercialRegistrationNumber` → `Organization.commercialRegistrationNumber` (persisted for the first time; unique constraint). The registering user becomes `OrganizationMember(role: owner, status: active)` and `Organization.ownerUserId`.

## 4. Membership & roles

Frontend `TeamMemberRole`: `admin, manager, member` — reused, with `owner` added (auto-assigned only to the org creator, not independently grantable, and not removable via the normal remove-member flow — an org must always have exactly one owner; ownership transfer, if ever needed, is a distinct explicit action out of scope for Phase 1–3).

Permission implications (full matrix in [02-auth-and-authorization.md](02-auth-and-authorization.md) §6): `owner`/`admin` manage members, invitations, and billing; `manager`/`member` can create/edit contracts, documents, and consultations under the org but cannot manage membership or billing. **This is new relative to the frontend**, where `TeamMemberRole` is purely a display attribute with zero effect on what a member can actually do (`TeamMemberRole` never appears anywhere in routing/permission logic today).

## 5. Invitation flow (new — frontend has none)

Confirmed by repo-wide grep: no `Invitation` entity/enum/string exists anywhere. The frontend's `addMember({fullName, email, role})` is synchronous and immediate — it directly creates an **active** `TeamMember`, with no token, no email step, no accept/decline state.

Real flow:
1. `owner`/`admin` calls `POST /v1/organizations/me/invitations {email, role}` → creates `OrganizationInvitation` (`status = pending`, unique token, e.g. 7-day expiry) and an `OrganizationMember` row (`status = invited`, `userId = null`) so the pending member already shows up in the team list (matching the frontend's existing "just add them, see them immediately" UX, just now representing a real pending state rather than a false-active one).
2. Invited email receives a link containing the token. If they already have an Aqd account, accepting (`POST /v1/organizations/invitations/{token}/accept`, authenticated) links `OrganizationMember.userId` and flips `status = active, joinedAt = now()`. If they don't have an account yet, the invitation flow can carry them through registration first, then auto-accept.
3. `declined`/`expired`/`revoked` are terminal — a revoked or expired invitation's associated `invited`-status `OrganizationMember` row should also be removed/marked, so it doesn't linger as a phantom pending member.

## 6. Company contracts/documents — the actual isolation model

Per the audit, the frontend never distinguishes "my company's contracts" from "my own contracts" — company reuses the identical `ContractsListScreen`/`DocumentsScreen` the client role uses, via the `routeBase` cosmetic parameter, over the exact same unfiltered global list. There is no aggregation-over-members view either (a `TeamMember` has no join key to any `Contract`/`Document` at all).

Real design (already specified in [01-domain-model.md](01-domain-model.md)/[03-multi-tenancy.md](03-multi-tenancy.md), restated here for this module's context): `Contract`/`Document`/`Consultation` gain `organizationId` (nullable). When a user acts while "in" an organization context (the frontend's company shell is exactly this context — the client just never had to plumb it through to data), the created resource gets `organizationId` set, and every `OrganizationMember` with `status = active` can see it per the permission matrix — this is a **real shared-visibility model**, replacing the mock's accidental global-visibility-to-everyone with actual, correct member-only visibility.

**Approved decision** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 3): the backend supports a user belonging to more than one organization — `OrganizationMember` is already a many-to-many join between `User` and `Organization` (one `User` can have several `OrganizationMember` rows across different `Organization`s), so no schema change is needed beyond what [01-domain-model.md](01-domain-model.md) §2 already specifies. Concretely: a `company`-role account's registration auto-creates and owns exactly one `Organization` (per §3 above); that same account, or any client/lawyer account, can additionally be *invited into* other organizations as a `manager`/`member` via the invitation flow in §5. Organization membership and every permission derived from it (§4, [02-auth-and-authorization.md](02-auth-and-authorization.md) §6) are checked server-side on every request — the client never needs to declare "which org am I acting as," since a resource's `organizationId` and the caller's `OrganizationMember` rows are sufficient to authorize.

**v1 does not require an organization-switcher UI**, and the frozen frontend is not modified to add one — a user who is a member of multiple organizations still only ever sees the single implicit organization context the frozen UI already assumes (their own owned org, if any). Building a real switcher is out of scope for this phase and is not scheduled against a roadmap phase; it remains a future frontend enhancement once product wants to expose multi-org membership in the UI.

## 7. Endpoint table

| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/organizations/me | 🔒 (member) | Current user's org (if any) |
| PATCH /v1/organizations/me | 🔒 (owner/admin) | Update org profile |
| GET /v1/organizations/me/members | 🔒 (member) | List (incl. invited/pending) |
| POST /v1/organizations/me/invitations | 🔒 (owner/admin) | Invite by email + role |
| POST /v1/organizations/invitations/{token}/accept | 🔒 | Accept |
| POST /v1/organizations/invitations/{token}/decline | 🔓 | Decline (no login required to decline) |
| PATCH /v1/organizations/me/members/{id} | 🔒 (owner/admin) | Change role |
| DELETE /v1/organizations/me/members/{id} | 🔒 (owner/admin) | Remove (not the owner) |
