# Security Checklist

Each item below is tied to a concrete frontend observation where one exists, so the checklist reflects real requirements this app surfaces rather than a generic list.

## Authentication
- [ ] Passwords hashed with argon2id/bcrypt (cost ≥ 12); never logged. The frontend's own `RedactingLoggingInterceptor` already redacts `password, token, accessToken, refreshToken, cardNumber, cvv, otp` from request/response logs — the backend's own logging must honor the same list at minimum.
- [ ] Backend-authoritative password policy (min 8 chars + complexity), independent of the frontend's client-side-only length check ([02-auth-and-authorization.md](02-auth-and-authorization.md) §7).
- [ ] Account enumeration prevented: login, registration, and password-reset responses never reveal whether an email exists.
- [ ] Rate limiting on login (per-IP and per-email) and OTP verification (5 attempts per code, per [01-domain-model.md](01-domain-model.md) `VerificationCode.attemptCount`).
- [ ] OTP codes: 6-digit, short TTL (10 min), single-use, hashed at rest — never the frontend mock's permanent `'1234'`.
- [ ] Refresh-token rotation with reuse detection — a replayed revoked refresh token revokes the entire session family ([02](02-auth-and-authorization.md) §5).
- [ ] Password reset / change password revokes all other active sessions.

## Authorization
- [ ] `UserRole` is a coarse account-type gate only, never sufficient for a real permission decision — matches the frontend's own explicit doc-comment disclaimer on the enum. Every mutating endpoint re-checks resource ownership/participation server-side ([02-auth-and-authorization.md](02-auth-and-authorization.md) §6).
- [ ] Lawyer role is hard-enforced read-only on `Contract`/`Document` at the API layer — this specifically closes the audited gap where the frontend's Sign button had no role guard beyond contract status, relying entirely on the UI not offering the button.
- [ ] Org membership/role checked on every org-scoped write (contracts, documents, consultations booked under an org, member management, billing) — including where the caller is a member of more than one organization (approved multi-org membership, [13-company-team.md](13-company-team.md) §6): the check must be against the specific `organizationId` on the resource, never "any org the caller belongs to."
- [ ] `platformAdmin` is a backend-only permission, never modeled as or exposed through a `UserRole` value, never obtainable via registration/self-service, and gated on every `/v1/admin/**` route independently of the normal Client/Lawyer/Company auth path ([02-auth-and-authorization.md](02-auth-and-authorization.md) §6, [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 1).
- [ ] Subscription quota checks (`plan_limits`) are enforced server-side on every relevant create endpoint, never trusted from a client-supplied flag or skippable by omitting a field — these are real limits, not display-only copy ([12-billing.md](12-billing.md) §3).

## Tenant isolation
- [ ] Every tenant-scoped table (`contracts`, `documents`, `consultations`, `messages`, `ai_conversations`, `notifications`) filtered by ownership/participation in application code, with Postgres Row-Level Security as a backstop ([03-multi-tenancy.md](03-multi-tenancy.md) §4, [04-database-design.md](04-database-design.md) §6).
- [ ] Integration/contract tests specifically assert cross-tenant access returns 403/404, not just that same-tenant access works.

## Token security
- [ ] Access tokens short-lived (≤15 min); refresh tokens stored hashed, never in plaintext.
- [ ] Media/room-join tokens ([06-consultations.md](06-consultations.md) §5) are single-use-scoped to `(consultation, user)`, short TTL (≤5 min) — a leaked token must not grant standing access to a legal consultation.
- [ ] Contract-signing links for external (non-account) parties, if built, are single-use, expiring, and bound to a specific `ContractParticipant`.

## File upload validation
- [ ] MIME type and declared size validated both client-declared (init) and server-verified (post-upload HEAD check) per [05-api-design.md](05-api-design.md) §3.
- [ ] File type allow-list per `purpose` (e.g. `verification_document`/`document` accept PDF/image only; reject executables universally).
- [ ] Uploaded content scanned for malware before being marked "complete"/made downloadable, given this platform handles legal documents and lawyer verification IDs — sensitive enough to warrant it even though the frontend's mock upload obviously has no such concern.
- [ ] Orphaned uploads (initiated, never completed) cleaned up on a TTL ([05-api-design.md](05-api-design.md) §6).

## Signed URLs / document access
- [ ] All object-storage reads (documents, signed contracts, chat attachments, verification documents) go through short-lived signed URLs generated per-request after an authorization check — never permanent public bucket ACLs ([08-contracts-documents-signatures.md](08-contracts-documents-signatures.md) §6).
- [ ] Signed URL TTL kept short (minutes, not hours) and scoped to the exact object.

## Audit logging
- [ ] `AuditLog` ([01-domain-model.md](01-domain-model.md) §11) captures every contract-lifecycle transition (create/generate/sign/cancel), consultation lifecycle transition, org membership change, and lawyer verification decision — none of these have any audit trail in the frontend today, and a legal-document platform needs one regardless.
- [ ] Signature events specifically record `ipAddress`/`userAgent` on `ContractSignature` as evidentiary metadata ([01-domain-model.md](01-domain-model.md) §7).

## Sensitive data
- [ ] `commercialRegistrationNumber`, `barLicenseNumber` treated as sensitive PII-adjacent identifiers — access logged, not exposed in public marketplace responses beyond what `LawyerProfile`'s public fields already show.
- [ ] Contract `fieldValues` (often contains counterparty PII, salary figures, etc.) never appears in application logs.

## Payment data
- [ ] Raw card data (number/expiry/CVV) **never** reaches the Aqd backend or database — client-side tokenization via the chosen provider's SDK only; backend stores `providerPaymentMethodId` + display metadata ([12-billing.md](12-billing.md) §5). This directly closes a real risk: the frontend's `Validators` currently reveal a raw-card-collecting form (`isValidExpiry`, CVV, card-number length checks) with no tokenization step at all.
- [ ] Payment-provider webhooks verified by signature, not trusted on payload alone ([12-billing.md](12-billing.md) §9).
- [ ] PCI scope minimized by design (SAQ-A eligible) via the tokenization requirement above — never pursue a design that has the backend touch raw card numbers.

## AI data
- [ ] Contract text sent to a third-party AI provider for analysis is disclosed in the platform's privacy policy — this is new user-data-sharing surface with no frontend precedent to audit against, since the mock never left the device.
- [ ] AI conversations/analyses scoped strictly to `userId` — never shared across users or used for provider model training without explicit consent language, given the legal/confidential nature of contract content passed through this feature.

## WebSocket authorization
- [ ] WebSocket connection authenticated with the same bearer token as REST; channel subscriptions re-run the same ownership checks as the equivalent REST endpoint before allowing a join ([07-messaging-realtime.md](07-messaging-realtime.md) §4) — a socket channel is not a lower-trust surface.
- [ ] Presence reads/subscriptions (`presence.updated`, `GET /v1/users/{id}/presence`) are gated by the same participant/shared-context authorization as every other channel — presence is not a public "who's online" directory ([07-messaging-realtime.md](07-messaging-realtime.md) § Presence / online-offline).

## API validation
- [ ] All enum fields (`ContractStatus`, `ConsultationStatus`, etc.) validated server-side against the exact allowed value set from [01-domain-model.md](01-domain-model.md) — never trust a client-supplied status value directly; all status changes happen via dedicated transition endpoints, never a generic `PATCH {status: ...}`.
- [ ] Consultation/contract state-machine transitions validated against the graphs in [06-consultations.md](06-consultations.md)/[08-contracts-documents-signatures.md](08-contracts-documents-signatures.md) — illegal transitions rejected with 422, not silently accepted (the frontend's own transition validator exists in code but is never actually invoked by the mock; the backend must be the first real enforcer).

## CORS
- [ ] Explicit origin allow-list for the Flutter web build's deployed origin(s) per environment (`EnvConfig`'s dev/staging/prod split already gives three concrete origins to configure against) — no wildcard.

## Secrets management
- [ ] Database credentials, AI/payment/media/push provider API keys, JWT signing keys stored in a secrets manager (not `.env` files committed to the repo, not `EnvConfig`'s dart-define mechanism, which is client-side and inherently public — no backend secret should ever be reachable via a client-side config mechanism like that one).
- [ ] Signing keys rotated on a schedule; rotation doesn't invalidate already-issued tokens mid-rotation (support N and N-1 key simultaneously during rotation windows).

## Rate limiting (general, beyond auth)
- [ ] Booking/messaging/AI-chat endpoints rate-limited per user to prevent abuse (e.g. spamming consultation bookings, flooding a chat, hammering the AI provider — the latter has real cost implications once a paid provider is integrated).
