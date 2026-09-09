# Backend Implementation Roadmap

Phases are ordered by dependency, not by audit order. Each phase lists what it depends on, what gets built, what gets tested, which frontend mock datasource gets replaced (per [15-mock-to-real-migration.md](15-mock-to-real-migration.md)), and acceptance criteria.

## Phase 0 — Architecture & Specification (this document set)

**Status: complete, decisions approved.** Deliverable: `docs/backend/00`–`16`. No code. Dependencies: none. The 8 product decisions this phase's audit flagged as open are now resolved — see §Phase 0 Product Decisions (Approved) below. Phase 1 implementation has not started.

## Phase 1 — Infrastructure, Database, Authentication

**Depends on**: Phase 0 sign-off — see §Phase 0 Product Decisions (Approved) below; all 8 items are now resolved for v1.

**Implements**:
- Stack bootstrap (NestJS/TypeScript per [00-backend-overview.md](00-backend-overview.md)), Postgres provisioning, Redis, object storage bucket, CI pipeline.
- Full schema migration for §1 (Identity) and §2 (Organization) of [01-domain-model.md](01-domain-model.md): `users`, `refresh_tokens`, `verification_codes`, `lawyer_registration_details`, `organizations`, `organization_members`, `organization_invitations`.
- Auth API per [02-auth-and-authorization.md](02-auth-and-authorization.md): register (all 3 variants), login, refresh, logout, me, change-password, sessions list/revoke, OTP request/verify, password reset.
- Core middleware: JWT verification, `ApiErrorMapper`-matching error envelope ([05-api-design.md](05-api-design.md) §4), rate limiting, request logging with redaction.

**Tested**: unit tests per endpoint; integration tests for the full register→login→refresh→logout cycle for each of the 3 registration variants; rate-limit and lockout behavior; token-rotation-reuse-detection.

**Frontend datasource replaced**: `AuthMockDataSource` → `AuthRemoteDataSourceImpl`.

**Acceptance criteria**: all 462 pre-freeze frontend tests still pass with `AuthMockDataSource` (untouched); a new integration-test target exercises the Flutter app's auth flows against the real Phase-1 backend end-to-end (register each account type, login, token refresh under a simulated 401, logout) and passes; `flutter analyze` clean; no `lib/` changes beyond the single provider-override flip plus the additive `changePassword`/sessions/2FA wiring called out in [15](15-mock-to-real-migration.md) §3.

## Phase 2 — Users, Lawyer Profiles, Marketplace

**Depends on**: Phase 1 (auth, organizations exist).

**Implements**: `lawyer_profiles`, `lawyer_profile_specialties`, `lawyer_consultation_offerings`, `reviews` tables; lawyer marketplace API ([09-lawyers-marketplace.md](09-lawyers-marketplace.md)); minimal internal admin verify/reject endpoints — **approved for v1**: a protected, backend-only `platformAdmin` permission with no admin UI (see §Phase 0 Product Decisions (Approved) item 1).

**Tested**: marketplace search/filter correctness; verification state-machine transitions; review uniqueness constraint (`consultationId`+`reviewerUserId`) and rating-aggregate recomputation trigger.

**Frontend datasource replaced**: `LawyersMockDataSource`.

**Acceptance criteria**: `LawyersListScreen`/`LawyerDetailsScreen`/`LawyerProfileEditScreen` fully functional against real data; verification status enum change absorbed per [15](15-mock-to-real-migration.md); a lawyer created via Phase-1 registration correctly appears (as `unverified`) in the internal admin queue and, once verified, in public marketplace search.

## Phase 3 — Contracts, Documents, Signatures

**Depends on**: Phase 1 (users/orgs).

**Implements**: `contract_templates`+fields (seeded with the 7 existing categories, localized), `contracts`, `contract_participants`, `contract_signatures`, `saved_signatures`, `documents`, `document_versions`; the full signing state machine and API from [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md); the signed-upload flow from [05-api-design.md](05-api-design.md) §3.

**Tested**: template field validation against all 8 field types; multi-participant signing (2 and 3+ parties); lawyer-role write-attempt rejection at the API layer (regression test for the specific frontend-audited gap); document version history on rename/replace; RLS policy tests for cross-tenant contract/document access.

**Frontend datasource replaced**: `ContractsMockDataSource`, `DocumentsMockDataSource`, `SavedSignatureController`'s new backing repository.

**Acceptance criteria**: draft→generate→sign→signed cycle works end-to-end from the Flutter app for a 2-party contract; a lawyer account cannot sign or mutate a contract via direct API call even if a client somehow exposed the action; document upload round-trips real bytes (not a fabricated size label).

## Phase 4 — Consultations & Availability

**Depends on**: Phase 2 (lawyer profiles/offerings exist).

**Implements**: `availability_slots` (with the exclusion constraint) — **v1 scope is one-off slots only** (approved decision, see §Phase 0 Product Decisions (Approved) item 8); `consultations`, `consultation_room_sessions` (state machine only — no real media provider yet, see Phase 7), `consultation_participant_events`, `reviews` write path; booking, accept/decline/cancel/reschedule, auto-miss scheduled job.

**Deferred, not in this phase**: recurring availability templates (`RecurringAvailabilityRule`) — approved to ship after the initial consultation/booking implementation is stable; the `availability_slots` schema in Phase 4 must not preclude adding it later (see [06-consultations.md](06-consultations.md) §4).

**Tested**: concurrent double-booking attempts (must reject one via the exclusion constraint, not just at the app layer); full 12-state lifecycle transition matrix (valid transitions succeed, invalid ones return 422); auto-miss job correctness against `gracePeriod`.

**Frontend datasource replaced**: `ConsultationsMockDataSource`.

**Acceptance criteria**: booking wizard fully functional; a race-condition test (two simultaneous booking requests for the same slot) proves exactly one succeeds; lawyer request accept/decline notifies the correct client (closing the `clientId`-gap notification workaround).

## Phase 5 — Messaging & Real-Time Transport

**Depends on**: Phase 4 (consultations exist, since messages are consultation-scoped).

**Implements**: `messages`, `attachments`, WebSocket gateway (auth, channel subscription authorization, `message.*`/`typing.*` events per [07-messaging-realtime.md](07-messaging-realtime.md)); real chat-attachment upload; **Redis/WebSocket-backed online/offline presence** (approved, see §Phase 0 Product Decisions (Approved) item 7) — presence is session/realtime state, not written to Postgres.

**Tested**: message ordering/pagination; read-receipt correctness; typing-indicator round-trip between two real connected clients; unauthorized channel-subscription attempts rejected; reconnect-and-backfill flow; presence goes online on connect and offline on disconnect/TTL-expiry without any Postgres write.

**Frontend datasource replaced**: `MessagesMockDataSource`; `ChatController`/`ChatUnreadCountsController` gain the additive WebSocket subscription per [15](15-mock-to-real-migration.md).

**Acceptance criteria**: two real devices/sessions can exchange messages live with working typing indicators and read receipts — a genuine behavioral upgrade over the frozen frontend's fully-simulated version, verified manually and via an integration test driving two authenticated WebSocket clients.

## Phase 6 — Notifications

**Depends on**: Phases 3–5 (needs contract/consultation/message events to notify about).

**Implements**: `notifications`, `push_delivery_receipts`; wiring notification creation into every relevant write path from Phases 3–5; WebSocket `notification.created` push; device-token registration endpoints (net new, no push provider integrated yet — just the registration surface and the internal event, actual push send stubbed/logged until a provider is chosen).

**Tested**: every notification type in the 13-value taxonomy is producible by its triggering action; the `aiAnalysisCompleted` client-only routing gap is preserved correctly (never emitted for lawyer/company); unread-count correctness.

**Frontend datasource replaced**: `NotificationsMockDataSource`; client-side per-type title/body templating added per [15](15-mock-to-real-migration.md).

**Acceptance criteria**: booking, signing, messaging, and document-upload actions each produce the correct notification, delivered live via WebSocket to an open app and visible in the notification center on next open otherwise.

## Phase 7 — AI & Live Consultation Media

**Depends on**: Phase 3 (documents/contracts to analyze), Phase 4 (consultations to hold live sessions in).

**Implements**: `ai_conversations`, `ai_messages`, `contract_analyses`, `analysis_clauses`; real AI provider integration (chat + document analysis as an async job per [11-ai.md](11-ai.md)) — **chat streaming is approved and implemented in this phase** (see §Phase 0 Product Decisions (Approved) item 6); real media-provider integration for voice/video (`providerRoomId`, token minting, join/leave webhook handling per [06-consultations.md](06-consultations.md) §5).

**Tested**: AI job success/failure/timeout handling; analysis result parsing into `AnalysisClause` rows; media-provider token scoping/expiry; consultation-room state machine driven by real provider webhooks instead of mock timers.

**Frontend datasource replaced**: `AiMockDataSource`, `ConsultationRoomMockDataSource`.

**Acceptance criteria**: a real document produces a real, non-hardcoded analysis result; a real voice/video call connects between two real devices through the chosen media provider; session auto-end at 60 minutes and reconnection-retry (≤3 attempts) both function against real provider connection-loss events, not simulated ones.

## Phase 8 — Billing & Payments

**Depends on**: Phase 4 (consultations, for per-consultation invoicing) and an org existing (Phase 1) for company billing.

**Implements**: `subscriptions`, `payment_methods`, `invoices`, `transactions`, `subscription_plans` + `plan_limits` reference tables; real payment-provider integration (client-side tokenization + webhook handling per [12-billing.md](12-billing.md)); the earnings/invoice reconciliation described in [12](12-billing.md) §6; scheduled renewal/overdue jobs; **real, backend-enforced subscription quotas** (approved, see §Phase 0 Product Decisions (Approved) item 2) — quota checks on `POST /v1/contracts`, `POST /v1/ai/analyses`, `POST /v1/consultations` against `plan_limits`.

**Tested**: subscription lifecycle (subscribe/renew/cancel/expire); webhook signature verification; PCI-scope check (confirm no raw card data ever reaches the backend in any code path, including logs); lawyer earnings figure matches the sum of their `Invoice`/`Transaction` records exactly (closing the frontend's disconnect); quota-enforcement tests (create requests beyond a tier's monthly limit are rejected with 422/403, requests within limit succeed).

**Frontend datasource replaced**: billing's currently-nonexistent data layer is built for the first time (`SubscriptionController`/`InvoicesController`/`PaymentMethodsController` gain real repositories).

**Acceptance criteria**: a real (sandbox/test-mode) payment completes a subscription purchase and a consultation-booking payment; a webhook-driven renewal correctly extends `currentPeriodEnd`; overdue-invoice job correctly flags a failed renewal as `pastDue`.

## Phase 9 — Production Security & Observability

**Depends on**: all prior phases functionally complete.

**Implements**: full [14-security.md](14-security.md) checklist verification pass; centralized structured logging with the redaction list applied consistently across every service (not just the frontend's own interceptor); `audit_logs` populated across every module; RLS policies verified on every tenant-scoped table (not just contracts); load/rate-limit testing; secrets-manager migration off any dev-time `.env` usage; monitoring/alerting on job-queue failures (especially AI-analysis and payment jobs), WebSocket connection health, and auth failure-rate spikes (brute-force detection).

**Acceptance criteria**: every checklist item in [14-security.md](14-security.md) has a corresponding automated test or documented manual verification; a third-party or internal security review sign-off before public launch.

## Phase 0 Product Decisions (Approved)

The 8 items below were explicitly flagged throughout the docs as questions the frontend audit alone could not answer. They have now been **reviewed and approved** as product decisions for v1, closing Phase 0. Each entry states the resolution and which documents were updated to reflect it. No frontend (`lib/`) changes were made or are required by any of these decisions.

1. **Platform admin surface** — **Approved**: v1 ships a protected, minimal, backend-only platform-admin API (`POST /v1/admin/lawyers/{id}/verify` / `.../reject`) for lawyer-verification approval/rejection. No admin UI in v1. The `platformAdmin` permission is a backend-only authorization concept — it is never exposed as, or combined with, the `client`/`lawyer`/`company` `UserRole` values, and no API surface grants it to a normal user account. See [02-auth-and-authorization.md](02-auth-and-authorization.md) §6, [09-lawyers-marketplace.md](09-lawyers-marketplace.md) §3, [14-security.md](14-security.md).
2. **Subscription tier limit enforcement** — **Approved**: subscription limits are real, backend-enforced quotas, not marketing-only copy. The exact quota values are documented in [12-billing.md](12-billing.md) §3 (the per-tier table) and are the single source of truth — enforced via a `plan_limits` reference table checked at the relevant create endpoints. See [12-billing.md](12-billing.md) §3, [01-domain-model.md](01-domain-model.md) §9.
3. **Multi-organization membership** — **Approved**: the backend data model supports a user belonging to more than one `Organization` (multiple `OrganizationMember` rows per `User`, already the natural shape of the existing schema). A company registration auto-creates its own `Organization`; users (client, lawyer, or company accounts) can additionally be invited into other organizations as members. Organization membership and all authorization derived from it are enforced server-side only. **v1 does not require an organization-switcher UI**, and the frozen frontend is not modified to add one. See [13-company-team.md](13-company-team.md) §6, [03-multi-tenancy.md](03-multi-tenancy.md).
4. **`Contract.status` completion semantics** — **Approved**: no separate `completed` contract status is required for v1. `signed` is the terminal successful state. See [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md) §3.
5. **Contract cancellation** — **Approved**: in scope for v1. The backend defines who can cancel, valid cancellation transitions, a cancellation reason, timestamps, and authorization — see [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md) §3–§4 and [01-domain-model.md](01-domain-model.md) §7 (`Contract.cancelledByUserId`/`cancellationReason`/`cancelledAt`). The frozen frontend is not redesigned now; this is a backend-only capability until product scopes the UI.
6. **AI chat streaming** — **Approved**: real AI chat supports streaming responses. The streaming *implementation* (SSE/WebSocket token delivery) belongs to Phase 7 (AI provider integration), but the backend interfaces are designed now ([11-ai.md](11-ai.md) §4, §7) so streaming can be introduced without redesigning the conversation/message data model or the API surface.
7. **Presence/online-offline indicators** — **Approved**: required for real messaging. Presence is realtime/session state, not a permanent database fact — it is designed around Redis + the existing WebSocket connection (a `presence.updated` event and a Redis-backed online/offline key per user), not persisted to PostgreSQL. See [07-messaging-realtime.md](07-messaging-realtime.md) §4.
8. **Recurring lawyer availability rules vs. one-off slots only** — **Approved**: v1 supports one-off `AvailabilitySlot` creation only. Recurring availability templates (`RecurringAvailabilityRule`) are deferred until after the initial consultation/booking implementation (Phase 4) is stable. The `availability_slots` schema is designed so recurring templates can be added later without a breaking change. See [06-consultations.md](06-consultations.md) §4.
