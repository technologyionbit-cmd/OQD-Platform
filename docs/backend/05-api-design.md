# API Architecture

## 1. REST vs. GraphQL — decision: REST

- The frontend's repository interfaces are already shaped as discrete, purpose-built calls (`getContracts()`, `getConsultationById(id)`, `bookConsultation({...})`) — not ad hoc field-selection queries. There is no screen in the audits that needs arbitrary nested-field flexibility GraphQL is best at; every screen's data needs are already known and stable (frozen UI).
- `dio` (already a dependency) is a REST-oriented HTTP client; nothing in `pubspec.yaml` or the network layer (`DioClient`, `AuthInterceptor`, `ApiErrorMapper`) suggests GraphQL was ever the intended shape.
- REST's resource-oriented structure maps directly onto the entity inventory in [01-domain-model.md](01-domain-model.md) with minimal translation, keeping the "repository interface → HTTP call" mapping in [15-mock-to-real-migration.md](15-mock-to-real-migration.md) mechanical rather than requiring a query-language layer to design and version.
- **Recommendation: versioned REST (`/v1/...`)**, JSON request/response bodies, following the error envelope defined in §4 (which resolves the frontend's own explicitly-flagged "backend error envelope shape is not finalized yet" gap).

## 2. Real-time layer: WebSocket

Required for messaging (typing/live delivery) and notifications (live badge updates) and consultation room signaling (join/leave/state changes) — none of which the current Future-only frontend actually has today, but all of which the UI's own affordances (typing indicator, unread badges, live "active session" banner) imply as the real product intent once a live backend exists. See [07-messaging-realtime.md](07-messaging-realtime.md) for the full design; summary:

- One authenticated WebSocket connection per client session (`wss://.../v1/ws?token=...` or upgraded with the same bearer token used for REST).
- Server-pushed events: `message.created`, `message.read`, `typing.started/stopped`, `notification.created`, `consultation.status_changed`, `session.state_changed`, `presence.updated` (approved for v1 — Redis/session-backed, not a Postgres write, see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 7 and [07-messaging-realtime.md](07-messaging-realtime.md) §4).
- The client subscribes to channels scoped to resources it's authorized for (its own consultations, its own notifications) — the server must re-run the same ownership checks as the REST layer before allowing a subscription (a WebSocket channel is not exempt from [02-auth-and-authorization.md](02-auth-and-authorization.md)'s rules).
- Video/voice **media** itself is out of scope for this application's own WebSocket — see [06-consultations.md](06-consultations.md) §Room provider for the split between "our backend" and "the media provider."

## 3. File uploads

Two-step, signed-URL pattern (never proxy raw file bytes through the application server for large files):
1. Client calls `POST /v1/uploads/init` with `{fileName, mimeType, sizeBytes, purpose}` (`purpose` ∈ `document, chat_attachment, verification_document, signature_image`) → server authorizes the purpose against the resource being attached to, creates a pending `Attachment`/`DocumentVersion` row, returns a pre-signed PUT URL (object storage) + the created row's id.
2. Client uploads bytes directly to object storage via the signed URL.
3. Client calls `POST /v1/uploads/{id}/complete` → server verifies the object exists (HEAD request) and sizeBytes/mimeType match what was declared, marks the row active.

This matches (and finally makes real) the frontend's `image_picker`-based flows in the chat attachment and lawyer-verification-document screens, which today only fake the upload step.

## 4. Standard response & error envelope

Resolves the frontend's own flagged gap (`ApiErrorMapper` comment: *"Backend error envelope shape is not finalized yet"*) by committing to exactly the shape the frontend already defensively probes for:

```json
// success
{ "data": { ... } }

// paginated success
{ "data": [ ... ], "meta": { "nextCursor": "...", "hasMore": true } }

// error
{
  "error": {
    "message": "Human-readable summary",
    "code": "VALIDATION_ERROR",
    "errors": { "email": ["already in use"] }   // present only for 422
  }
}
```

Status code mapping (must match `ApiErrorMapper`'s existing switch exactly, since that mapping is already implemented client-side and expects these codes): `401 → UnauthorizedFailure`, `403 → ForbiddenFailure`, `404 → NotFoundFailure`, `422 → ValidationFailure` (reads `error.errors`), `408`/timeout → `TimeoutFailure`, `5xx → ServerFailure`, network-level failure (no response) → `NetworkFailure`.

## 5. Pagination

The frontend currently fetches full collections unconditionally everywhere (`getMessages`, `getNotifications`, `getContracts`, etc. all return the complete list, no cursor/page params exist in any signature audited). The backend should still **implement real pagination from day one** (cursor-based, `?cursor=...&limit=...`) even though the v1 mobile client will initially just request a large default page size and treat the full result as "everything" — this avoids an unbounded-response footgun once real data volume exists, and the migration doc ([15](15-mock-to-real-migration.md)) covers introducing pagination into the Flutter repositories as a controlled follow-up rather than a blocking Phase-1 requirement.

## 6. Background & scheduled jobs

| Job | Trigger | Purpose |
|---|---|---|
| Contract analysis processing | Async, on `POST /ai/analyses` | Real AI provider call is not instant like the mock's synchronous fake delay — must be a queued job (see [11-ai.md](11-ai.md)) |
| Consultation reminder | Scheduled (e.g. every 5 min, scan upcoming `scheduledAt`) | Powers `NotificationType.consultationReminder`, which the mock only ever seeds statically |
| Consultation auto-miss | Scheduled | Transition `confirmed → missed` once `scheduledAt + gracePeriod (10 min)` elapses with no join event — the frontend does this client-side (`consultation_waiting_screen.dart._markMissedIfNeeded`) purely because there's no server; a real backend must own this transition authoritatively so it fires even if no client happens to be open |
| Session auto-end | Scheduled / duration-triggered | Enforce `maxSessionDuration = 60 min` server-side, not just via the client's local timer |
| Invoice due-date / subscription renewal | Scheduled (daily) | Standard billing cron — see [12-billing.md](12-billing.md) |
| Push delivery retry | Queue-driven | Retries failed `PushDeliveryReceipt`s |
| Document/attachment orphan cleanup | Scheduled (daily) | Removes object-storage objects for uploads that were `init`ed but never `complete`d within a TTL |

Recommend a standard job queue (e.g. a Postgres-backed queue like `pg-boss`/`graphile-worker`, or Sidekiq/BullMQ depending on the chosen stack in [18](../backend/00-backend-overview.md) — see [16-backend-roadmap.md](16-backend-roadmap.md) for stack recommendation) rather than ad hoc cron scripts, since several of these jobs (analysis processing, push retry) are genuinely queue-shaped (retryable, backpressured) rather than purely time-triggered.

## 7. Endpoint tables by module

Auth/purpose columns: 🔓 = no auth required, 🔒 = auth required, plus the resource-level authorization from [02-auth-and-authorization.md](02-auth-and-authorization.md) §6 always applies on top of 🔒.

### Auth
| Method & path | Auth | Purpose |
|---|---|---|
| POST /v1/auth/register | 🔓 | Create account (individual/company/lawyer variant body) |
| POST /v1/auth/login | 🔓 | Issue tokens |
| POST /v1/auth/refresh | 🔓 (refresh token in body) | Rotate tokens |
| POST /v1/auth/logout | 🔒 | Revoke current refresh token |
| GET /v1/auth/me | 🔒 | Current user |
| PATCH /v1/auth/me | 🔒 | Update fullName/email |
| POST /v1/auth/change-password | 🔒 | New endpoint — closes UI gap |
| POST /v1/auth/otp/request | 🔓 | Send verification code |
| POST /v1/auth/otp/verify | 🔓 | Verify code |
| POST /v1/auth/password-reset | 🔓 | Consume code, set new password |
| GET /v1/auth/sessions | 🔒 | List active sessions — closes UI gap |
| DELETE /v1/auth/sessions/{id} | 🔒 | Revoke one session |
| DELETE /v1/auth/sessions | 🔒 | Revoke all but current |

### Users & Profile
| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/users/me/preferences | 🔒 | Locale/theme/notification toggle (mirrors `AppPreferences`) |
| PATCH /v1/users/me/preferences | 🔒 | Update prefs |
| GET /v1/users/me/saved-signatures | 🔒 | List saved signatures |
| POST /v1/users/me/saved-signatures | 🔒 | Create/replace |
| DELETE /v1/users/me/saved-signatures/{id} | 🔒 | Remove |

### Organizations / Team
See [13-company-team.md](13-company-team.md) for the full table.

### Lawyers Marketplace
See [09-lawyers-marketplace.md](09-lawyers-marketplace.md) for the full table.

### Consultations
See [06-consultations.md](06-consultations.md) for the full table.

### Messaging
See [07-messaging-realtime.md](07-messaging-realtime.md) for the full table.

### Contracts / Documents / Signatures
See [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md) for the full table.

### Notifications
See [10-notifications.md](10-notifications.md) for the full table.

### AI
See [11-ai.md](11-ai.md) for the full table.

### Billing
See [12-billing.md](12-billing.md) for the full table.

### Government Procedures
| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/gov-procedures | 🔓 (or 🔒, either is fine — pure reference content) | List the 4 procedures + steps/required docs |
| GET /v1/gov-procedures/{id} | 🔓 | Detail |
| GET /v1/gov-procedures/{id}/progress | 🔒 | Current user's checklist state |
| PATCH /v1/gov-procedures/{id}/progress | 🔒 | Toggle a checked document / mark started |

## 8. CORS, versioning, and client compatibility

- CORS: allow the Flutter web build's origin(s) explicitly (no `*` given cookie-free bearer-token auth makes this less risky, but still avoid wildcard once any cookie-based mechanism is ever introduced).
- Versioning via URL prefix (`/v1`) rather than headers — simplest to reason about and matches `EnvConfig.apiBaseUrl` already being a full base-URL string the frontend swaps per environment (dev/staging/prod), not a header-negotiated version.
- The mobile/web client's `dio` timeouts (connect 15s, receive 15s, send 30s) are a real constraint: any endpoint expected to take longer (AI analysis, PDF generation) **must** be async/job-based (§6), not a long-held synchronous HTTP request.
