# Real-Time Messaging

## 1. What exists today (and what doesn't)

Confirmed by direct audit of `lib/features/messages/**`: there is **no Stream anywhere** in the current implementation. Everything is `Future`-based (`AsyncNotifier.build()` does a one-shot fetch); the "typing indicator" and "lawyer auto-reply" are entirely client-owned `Timer`s in `ChatRoomScreen` simulating behavior with deterministic, seeded fake delays — never a real signal from another party. Sending a message only appends to the sender's own in-memory list and fires a `Notification.create()` call; there is no push path to a second client that has the chat open. This is the single largest "looks real but isn't" surface in the whole prototype, and the backend must build the actual mechanism from scratch.

## 2. Message persistence model

Entity: `Message` (see [01-domain-model.md](01-domain-model.md) §5) — `id, consultationId, senderId, senderRole, type, text, attachmentId, sentAt, readAt`. Scoped 1:1 to `consultationId`; there is no standalone `Conversation`/inbox entity and none should be introduced (see [06-consultations.md](06-consultations.md) §6 for why this boundary is preserved).

- **Sender/recipient**: recipient is implicit — the *other* participant of the consultation (`clientUserId` or the lawyer behind `lawyerProfileId`). No explicit `recipientId` column needed since a consultation always has exactly two human parties.
- **Read/unread**: `readAt: timestamptz?` (null = unread) — matches the frontend exactly, which already models this correctly (unlike `Notification`, which only has a boolean — see [10-notifications.md](10-notifications.md)).
- **Delivered**: not modeled by the frontend at all. Recommend adding a real `deliveredAt` once server-push exists (a message is "delivered" when the WebSocket successfully pushes it to a connected recipient, distinct from "read" which requires the recipient to view the thread) — this is a natural addition once real-time exists, even though it has no frontend precedent to mirror.
- **Ordering**: `sentAt` ascending, exactly as the frontend does (`getMessages` sorts sort ascending). Assign `sentAt` **server-side** at insert time (never trust a client-supplied timestamp) to guarantee monotonic ordering across clients with clock drift.
- **Pagination**: the frontend has none (`getMessages(consultationId)` always returns everything). Backend implements cursor-based pagination (`?before=<messageId>&limit=50`) from day one per [05-api-design.md](05-api-design.md) §5, with the mobile client's first cut simply requesting a large page and rendering it as "everything," matching current behavior while the pagination UI catches up in a later iteration.

## 3. Attachments

`Attachment` entity ([01-domain-model.md](01-domain-model.md) §5) replaces the frontend's opaque `attachmentUrl: String` (which today encodes either a session-only local image-cache key with real bytes that vanish on app restart, or a fully synthetic `mock-file://name::size` string with no bytes at all). Real flow: upload via the signed-URL mechanism in [05-api-design.md](05-api-design.md) §3 (`purpose: chat_attachment`), then `POST /v1/consultations/{id}/messages` with `{type: image|file, attachmentId}` instead of a raw text body.

## 4. Real-time transport: WebSocket

**Recommended mechanism: a single authenticated WebSocket per client session**, not Server-Sent Events or long-polling — chosen because the same connection also carries notification pushes and consultation-room signaling ([06-consultations.md](06-consultations.md) §5), so one bidirectional channel is more efficient than three separate mechanisms, and typing indicators specifically need low-latency bidirectional signaling that SSE can't provide (SSE is server→client only).

### Events

| Event | Direction | Payload | Purpose |
|---|---|---|---|
| `message.send` | client→server | `{consultationId, type, text?, attachmentId?}` | Send (server assigns id/sentAt, persists, then broadcasts `message.created`) |
| `message.created` | server→client | full `Message` | Delivered to both participants (sender gets it as an ack/echo with the server-assigned id) |
| `message.read` | client→server, then server→client | `{consultationId}` | Marks all-unread-from-other-party as read (mirrors `markAllRead`); server broadcasts `message.read` with `{consultationId, readerUserId, readAt}` to the other party so their sent-message UI can show a read receipt |
| `typing.start` / `typing.stop` | client→server, relayed server→client | `{consultationId}` | Replaces the frontend's fake client-only Timer simulation with a genuine cross-client signal; server should auto-expire a `typing.start` after ~5s of silence server-side too, in case a `typing.stop` is lost (dropped connection, app backgrounded) |
| `notification.created` | server→client | full `Notification` | See [10-notifications.md](10-notifications.md) |
| `consultation.status_changed` | server→client | `{consultationId, status, ...timestamps}` | Powers live badge/list updates instead of the client re-polling |
| `session.state_changed` | server→client | `{consultationId, state, reconnectAttempts}` | Consultation-room state, see [06-consultations.md](06-consultations.md) |
| `presence.updated` | server→client | `{userId, status: online\|offline, lastSeenAt}` | Pushed to the other participant(s) of a shared consultation channel when a user's connection-set transitions to/from empty — see § Presence / online-offline below |

### Authorization on subscribe

On connect, the server authenticates the bearer token (same one used for REST) and the client requests to join channel `consultation:{id}` — the server must re-verify the same ownership check as the REST layer (`clientUserId`/`lawyerProfileId` match, or org membership) before allowing the subscription; a WebSocket channel is not a lower-trust surface than a REST endpoint and must not skip [02-auth-and-authorization.md](02-auth-and-authorization.md)'s checks.

### Presence / online-offline

**Not found anywhere in the frontend** (confirmed: no "presence"/"isOnline"/"lastSeen" field or enum exists in the messages feature) — but **approved as required for v1 real messaging** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 7), since the read-receipt/typing mechanisms alone don't tell a user whether the other party is even reachable right now, which is a reasonable baseline expectation once messaging is genuinely real-time rather than simulated.

**Design: presence is realtime/session state, held in Redis, never written to PostgreSQL as a persistent fact.** There is no `presence` table and no `isOnline`/`lastSeenAt` column added to `User` — see [04-database-design.md](04-database-design.md) for the explicit "no presence table" note.

- **State**: a Redis key per user, e.g. `presence:{userId} = {status: online, lastHeartbeatAt}`, with a short TTL (e.g. 45s) refreshed by a periodic heartbeat over the same WebSocket connection used for everything else in this document (no separate connection).
- **Going online**: set on WebSocket connect/auth.
- **Going offline**: either explicit (WebSocket disconnect event) or implicit (TTL expiry with no heartbeat — covers crashes, killed apps, lost connectivity, where no clean disconnect event ever arrives). Implicit expiry is the reason this must be Redis-backed with a TTL rather than a boolean flag flipped only on explicit events — a boolean-in-Postgres design would get stuck "online" forever after an unclean disconnect.
- **Multiple connections per user** (e.g. two tabs, phone + web): track as a small Redis set (`presence:{userId}:connections`) rather than a single flag; user is "online" iff the set is non-empty. A single tab closing must not incorrectly mark the user offline while another connection is still live.
- **Fan-out**: on a state change (offline→online or online→offline), publish a `presence.updated` event (`{userId, status, lastSeenAt}`) via Redis pub/sub to whichever application server instances have a client subscribed to a channel where that user is relevant — scoped the same way as everything else here: the other party of each of the user's active `consultation:{id}` channels, not a global broadcast. This reuses the exact WebSocket fan-out infrastructure already required for `message.*`/`typing.*` events ([00-backend-overview.md](00-backend-overview.md) notes Redis is already the pub/sub backbone across server instances for this reason).
- **Read path**: a client viewing a consultation's chat can request current presence for the other participant on channel-join (`GET`-style request over the WebSocket, or a lightweight `GET /v1/users/{id}/presence` REST fallback for the initial paint before the socket handshake completes) rather than only relying on push events for the very first render.
- **Authorization**: presence for a given user is only visible to someone who shares an active `consultation` (or, later, organization) context with them — the same participant-authorization check as every other channel subscription in this document (§ Authorization on subscribe), not a public "who's online" directory.

### Reconnect handling

On WebSocket reconnect (app resume, network blip), the client should call `GET /v1/consultations/{id}/messages?after=<lastSeenMessageId>` over REST to backfill any messages missed while disconnected, then resume the live subscription — the WebSocket is the low-latency path, REST is the source of truth and reconciliation path. This pattern needs no new server concept beyond the pagination endpoint already specified in §2.

## 5. Migrating the Flutter architecture from mock to real (messages specifically)

The existing `MessagesRepository` interface (`getMessages`, `sendMessage`, `markAllRead`, `getUnreadCounts`) stays almost entirely intact — a `MessagesRemoteDataSourceImpl` backed by `dio` handles the REST calls exactly as `AuthRemoteDataSourceImpl` is already designed to (see [15-mock-to-real-migration.md](15-mock-to-real-migration.md)). The **new** piece with no frontend precedent is the WebSocket subscription layer: `ChatController` (currently a one-shot `AsyncNotifier.build()`) needs to additionally subscribe to `message.created`/`message.read`/`typing.*` events for its `consultationId` and merge them into local state — this is an additive change to the controller's `build()`/dispose lifecycle, not a rewrite of its public API (`sendText`/`sendImage`/`sendFile`/`markRead` keep their exact current signatures). `ChatUnreadCountsController` similarly starts listening for `message.created` events across all the user's consultations to keep badges live instead of only updating after the user's own `sendMessage` call, which is all it does today.

## 6. Endpoint table (REST portion — WebSocket events covered in §4)

| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/consultations/{id}/messages | 🔒 (participant) | Paginated transcript |
| POST /v1/consultations/{id}/messages | 🔒 (participant) | Send (also usable as a WebSocket fallback for clients not connected) |
| POST /v1/consultations/{id}/messages/read | 🔒 (participant) | Mark all unread-from-other-party as read |
| GET /v1/consultations/unread-counts | 🔒 | Map of `consultationId → count` for badge rendering |
| GET /v1/users/{id}/presence | 🔒 (shares an active consultation with `{id}`) | REST fallback for initial presence paint before the WebSocket handshake completes; reads the Redis presence key, not Postgres |
| WS /v1/ws | 🔒 | Single connection carrying message/typing/notification/session/presence events, see §4 |
