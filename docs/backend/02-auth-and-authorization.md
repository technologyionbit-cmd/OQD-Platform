# Authentication & Authorization

## 1. What the frontend already assumes

The frontend was built against an implied REST auth contract it never got to call for real. `AuthRepository` (`lib/features/auth/domain/repositories/auth_repository.dart`) is the exact method set the backend's auth API must satisfy so `AuthRemoteDataSourceImpl` can be dropped in with **zero repository/controller/screen changes** (this is stated as the explicit design goal in `auth_data_source_provider.dart`'s comments):

```
login({email, password}) → {user, tokens}
register(RegisterRequest) → {user, tokens}
refreshToken(refreshToken) → tokens
currentUser() → user
updateProfile({fullName, email}) → user
logout() → void
requestOtp({destination}) → void
verifyOtp({destination, code}) → bool
resetPassword({destination, code, newPassword}) → void
```

`RegisterRequest` is a discriminated union with three shapes the backend must accept:
- **Individual (client)**: `fullName, phone, email, password`
- **Company**: `companyName, commercialRegistrationNumber, email, phone, password`
- **Lawyer**: `fullName, barLicenseNumber, mainSpecialty, email, phone, password`

Two fields the mock currently **discards** must be persisted for real: `commercialRegistrationNumber` → `Organization.commercialRegistrationNumber` (auto-creates the `Organization` row, see [13-company-team.md](13-company-team.md)); `barLicenseNumber`/`mainSpecialty` → `LawyerRegistrationDetail` → seeds `LawyerProfile`.

Tokens are opaque to the frontend (no JWT-claims inspection anywhere) — the backend is free to use JWT access tokens + opaque refresh tokens, or fully opaque tokens with server-side session lookup. **Recommendation: short-lived JWT access token (15 min) + opaque, rotating refresh token (30 days, stored hashed in `RefreshToken`)** — the interceptor already assumes exactly this refresh-on-401 pattern (`AuthInterceptor` coalesces concurrent 401s into a single refresh call and retries once).

## 2. Registration

1. Client submits one of the three `RegisterRequest` shapes.
2. Backend validates: email uniqueness (case-insensitive), password policy (frontend only enforces min-length-8 client-side; backend must be authoritative — see §7), phone format, and for company/lawyer the registration-number/bar-license uniqueness.
3. Backend creates `User` (`emailVerifiedAt = null`), and:
   - company → creates `Organization` (`ownerUserId = user.id`, `verificationStatus = unverified`) and an `OrganizationMember` row for the owner with `role = owner, status = active`.
   - lawyer → creates `LawyerRegistrationDetail` and a `LawyerProfile` (`verificationStatus = unverified`).
4. Backend sends an email-verification code (see §4) — **does not block registration success on verification**, matching the frontend's flow where OTP is a separate screen, not gating registration itself for the demo accounts. (Recommendation: require verification before allowing consultation booking / contract signing / payment — gate at the *action* level, not login.)
5. Returns `{user, tokens}` — the frontend logs the user in immediately on successful registration.

## 3. Login

Standard email+password. Rate-limit per email and per IP (see [14-security.md](14-security.md)). On success, issue access+refresh tokens, create a `RefreshToken` row capturing device/IP for the Active Sessions UI, update `User.lastLoginAt`.

Frontend never surfaces a generic "auth error" state for a failed login — `AuthController.login` deliberately restores the previous state and returns a `Result.failure` for the *screen* to render inline (never a global error banner). Backend error responses for login failure should be a single generic "invalid credentials" (never reveal whether the email exists) mapped by the frontend's `ApiErrorMapper` to `UnauthorizedFailure`.

## 4. Email/Phone verification & password reset (OTP)

Frontend's `requestOtp`/`verifyOtp`/`resetPassword` are channel-agnostic — the backend infers email vs. SMS purely from the shape of `destination`. Recommend making this explicit only in the request DTO's derived `channel` field (server infers from regex, same as the frontend does) rather than requiring the client to pass it — this preserves the exact frontend calling convention.

- `requestOtp(destination)`: generate a 6-digit numeric code (frontend's `OtpVerificationScreen` is hardcoded to 6 digits with a 30s resend cooldown — mirror both), store as `VerificationCode` (hashed), send via email or SMS provider matching the destination shape. Always return success even for a non-existent destination (prevents account enumeration) — but do not actually create a `User` for password-reset destinations that don't exist.
- `verifyOtp(destination, code)`: compare against the hashed, non-expired, non-consumed code; increment `attemptCount` on failure; lock out after 5 attempts within the code's TTL.
- `resetPassword(destination, code, newPassword)`: re-validate the code, hash the new password, revoke **all** existing `RefreshToken`s for that user (force re-login everywhere — the frontend's own `SecurityPrivacyScreen` "End all sessions" affordance implies this should already be the behavior for a security-sensitive action like password reset).

## 5. Token refresh & session management

- `refreshToken(refreshToken)`: look up by hash, check not expired/revoked, issue a new access token; **rotate** the refresh token (issue a new one, revoke the old) to detect reuse (if a revoked refresh token is presented again, treat as compromise — revoke the entire session family and force re-login).
- `logout()`: revoke the presented refresh token; frontend already unconditionally clears local tokens even if this call fails, so the endpoint can be fire-and-forget from the client's perspective but must still work server-side for real logout semantics.
- **Gap the backend must close that the frontend UI already promises**: `SecurityPrivacyScreen` shows an "Active Sessions" list (device + location + "current" flag) with per-session "End session," none of which calls any real `AuthRepository` method today. New endpoints: `GET /auth/sessions` (list non-revoked `RefreshToken`s for the current user, with device/IP-derived location), `DELETE /auth/sessions/{id}` (revoke one), `DELETE /auth/sessions` (revoke all but current).
- **Gap**: `changePassword({currentPassword, newPassword})` has full UI (`SecurityPrivacyScreen._changePassword`, a bottom sheet validating current/new/confirm) but calls nothing today. New endpoint required; must re-verify `currentPassword`, revoke other sessions on success.
- **Gap**: 2FA toggle exists in UI (`_twoFactorEnabled`) wired to nothing. If built, standard TOTP enrollment (`POST /auth/2fa/enroll` → QR/secret, `POST /auth/2fa/verify` → enable) is the recommended v1 shape; defer to a later phase (not in the Phase 0–4 roadmap, see [16-backend-roadmap.md](16-backend-roadmap.md)).

## 6. Role management vs. real authorization

**Critical instruction from the task, already independently confirmed by the frontend's own code comments**: `UserRole` must never be treated as sufficient authorization. The frontend's own doc comment on the enum says exactly this. The frontend's *entire* authorization model today is a single string-prefix route guard (`app_router.dart._redirect`: is the URL under `/client`, `/lawyer`, or `/company` matching the user's role?) — there is no per-screen capability check, no server-side enforcement of anything, and (per the contracts audit) at least one likely oversight where a lawyer viewing a contract could still trigger `Sign` because the button's only guard is `contract.status == pendingSignature`.

The backend authorization model:

1. **Coarse gate — account type (`User.role`)**: determines which top-level API surface area a token may call at all (e.g., only `role = lawyer` accounts can call `PATCH /lawyers/me/availability`). Cheap to check, mirrors the frontend's shell/route split, but is **necessary, not sufficient**.
2. **Resource ownership checks — on every request**: does the authenticated user own, or have an explicit relationship to, the specific resource being acted on? Examples derived directly from the audits:
   - `Contract`: allowed if `contract.ownerUserId == currentUser.id`, or `currentUser.organizationId == contract.organizationId` (any active member), or `currentUser.id` is one of the contract's `ContractParticipant.userId`s (read-only, mirroring the frontend's "lawyer sees, never edits" rule), or the requester is a `LawyerReviewer` participant.
   - `Consultation`: allowed if `currentUser.id == consultation.clientUserId` or `currentUser.id == lawyerProfile.userId (via consultation.lawyerProfileId)`, or an active member of `consultation.organizationId`.
   - `Document`: same ownership shape as `Contract`.
   - `Message`: allowed only to the two consultation parties.
3. **Action-level permission checks — beyond "can you see it"**: mirror the frontend's explicit read-vs-write split for lawyers on contracts/documents exactly (`lawyer_extra_routes.dart`'s doc comment: *"a lawyer can see a client's paperwork, never create/delete it"*):
   - Lawyer role: read-only on `Contract`/`Document` regardless of participant status; **cannot** call create/update/delete/sign endpoints for these, full stop, at the API layer — this closes the sign-button oversight found in the frontend, since the backend (not the UI) is now the actual enforcement point.
   - `OrganizationMember.role`: `owner`/`admin` can manage members/invitations and billing; `manager`/`member` can create contracts/consultations/documents under the org but not manage membership or billing (frontend's `TeamMemberRole` never gated anything — this is a backend-only addition, see [13-company-team.md](13-company-team.md)).
4. **Permission representation**: implement as a small, explicit permission-check function per endpoint (e.g., `can(user, 'contract.sign', contract)`) rather than a general-purpose policy engine — the permission surface derived from this frontend is small and enumerable (see table below). Revisit if/when a policy engine is justified by real complexity growth.

### Permission matrix (derived from audited frontend restrictions)

| Resource.Action | Client (owner) | Client (org member) | Lawyer | Company owner/admin | Company manager/member |
|---|---|---|---|---|---|
| Contract.create/edit/delete (draft only) | ✅ own | ✅ org contracts | ❌ | ✅ | ✅ |
| Contract.read | ✅ own | ✅ org | ✅ if participant | ✅ | ✅ |
| Contract.sign | ✅ if participant | ✅ if participant | ❌ | ✅ if participant | ✅ if participant |
| Document.upload/rename/delete | ✅ own | ✅ org | ❌ | ✅ | ✅ |
| Consultation.book | ✅ | ✅ (org-billed) | ❌ | ✅ | ✅ |
| Consultation.accept/decline | ❌ | ❌ | ✅ (own bookings) | ❌ | ❌ |
| Availability.manage | ❌ | ❌ | ✅ (own) | ❌ | ❌ |
| LawyerProfile.verify (approve) | ❌ | ❌ | ❌ | admin-only (platform admin, not company) | ❌ |
| OrganizationMember.invite/remove/role-change | n/a | ❌ | n/a | ✅ | ❌ |
| Subscription/PaymentMethod.manage | ✅ own | ❌ (owner only) | n/a | ✅ | ❌ |

Note: "LawyerProfile.verify" needs a **platform-admin** permission that does not exist anywhere in the frontend at all (there is no admin app/screen in this codebase). **Approved decision** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 1): v1 ships a minimal, protected, API-only `platformAdmin` surface (no admin UI) to move a lawyer from `pending` to `verified`/`rejected`. `platformAdmin` is a **backend-only** authorization concept — it is never modeled as, granted through, or exposed alongside the `client`/`lawyer`/`company` `UserRole` values, and no registration/self-service path can obtain it (it is provisioned out-of-band, e.g. a manually-flagged internal operator account or service credential — a specific provisioning mechanism is an implementation detail for Phase 1/2, not this spec).

## 7. Password & security policy (backend-authoritative, frontend is UI-only)

- Frontend only checks length ≥ 8 client-side. Backend must independently enforce and be the source of truth: minimum 8 characters, recommend also requiring at least one letter and one digit (not encoded in the frontend, a reasonable minimum baseline) — never trust client-side validation for security-relevant rules (`core/utils/validators.dart` comment already states the backend is authoritative here).
- Passwords hashed with argon2id (or bcrypt with cost ≥ 12) — never reversible, never logged (`RedactingLoggingInterceptor`'s redaction key list — `password, token, accessToken, refreshToken, cardNumber, cvv, otp` — is a direct signal of what the frontend itself considers sensitive and expects never to see echoed back).
- Account lockout / rate limiting on login and OTP verification (see [14-security.md](14-security.md)).

## 8. Session bootstrap (what `AuthController.build()` expects on app start)

On app launch, the frontend loads persisted tokens (with a 5s timeout, treating any failure as "no session" rather than crashing) and calls `currentUser()` if a token exists. `GET /auth/me` must be cheap and side-effect-free, returning the same `User` shape `login`/`register` return, and must return `401` (never a different error type) for an expired/invalid access token so the interceptor's refresh flow engages correctly.
