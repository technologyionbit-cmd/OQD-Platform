# Notifications

## 1. Entity

`Notification` — see [01-domain-model.md](01-domain-model.md) §6. Frontend source: `AppNotification` (`lib/features/notifications/domain/entities/app_notification.dart`).

## 2. Full notification taxonomy (13 types, exhaustive from frontend source)

```
contractCreated, contractUpdated, contractReady, contractRequiresAction,
consultationBooked, consultationAccepted, consultationRejected, consultationCancelled,
consultationCompleted, consultationReminder,
newMessage,
documentUploaded,
aiAnalysisCompleted
```

No billing-related notification type exists in the frontend today despite the task brief listing "billing events" as an expected category — this is a genuine gap to fill, not an oversight to preserve: recommend adding `invoicePaid`, `invoiceOverdue`, `subscriptionRenewed`, `subscriptionCancelled` as new types when [12-billing.md](12-billing.md)'s module goes live, following the exact same `(type, relatedEntityId)` shape as everything else.

## 3. Routing table (type + role → destination) — reproduced from the frontend, kept intact

This table is exactly what `NotificationsScreen._routeFor` already implements; the backend's job is only to supply `type` + `relatedEntityId` correctly so each client's own routing table (unchanged) resolves correctly. Nothing here is a backend responsibility beyond emitting the right `type`/`relatedEntityId` pair.

| Type | Client route | Lawyer route | Company route |
|---|---|---|---|
| contractCreated / contractUpdated / contractReady / contractRequiresAction | Contract details | Contract details (read-only) | Contract details |
| consultationBooked / Accepted / Rejected / Cancelled / Completed / Reminder | Consultation details | Consultation details | Consultation details |
| newMessage | Chat room | Chat room | Chat room |
| documentUploaded | Documents list (no id needed) | Documents list | Documents list |
| aiAnalysisCompleted | AI analysis result | **null — no route, by design** (AI is client-only) | **null — no route, by design** |

**Known, deliberate gap preserved as-is**: `aiAnalysisCompleted` has no lawyer/company destination because AI analysis is a client-only feature with no equivalent screen for the other two roles. The frontend already handles this gracefully (marks read, shows "unavailable for this role" snackbar, no crash) — the backend should simply **not emit** `aiAnalysisCompleted` notifications to lawyer/company recipients in the first place (it structurally can't, since AI conversations/analyses are always `userId`-scoped to whoever ran them — see [11-ai.md](11-ai.md)), so this isn't actually a routing problem to solve, just a taxonomy fact to be aware of.

## 4. What changes vs. the frontend's current shape

- **`recipientUserId` becomes required**, never null. The frontend allows `null` to mean "broadcast/legacy," shown to everyone — this is a mock-only convenience with no real multi-tenant meaning; every real notification has exactly one intended recipient (a genuine broadcast/announcement feature, if ever needed, should be a separate mechanism, not an overloaded null on this table).
- **`title`/`body` become client-rendered from `type` + structured `data: jsonb`, not server-pre-rendered localized strings.** The frontend currently stores fully-rendered Arabic/English text at creation time (baked into whatever locale the *creating* code happened to run in) — this breaks the moment a user changes their locale after the notification was created, since a Riverpod/`intl` locale switch has no way to re-render already-stored text. Backend stores `type` + minimal structured `data` (e.g. `{contractTitle: "...", lawyerName: "..."}`), and the client's existing per-type icon/tone mapping (`NotificationTypeX`) is extended with a per-type ARB-templated title/body — this is a client-side change flagged in [15-mock-to-real-migration.md](15-mock-to-real-migration.md), not a backend one, but the API contract (§6) must supply `data`, not pre-rendered text, to make it possible.
- **`relatedEntityType` added explicitly** alongside `relatedEntityId` rather than overloading `type` as the sole discriminator (cleaner for the client's routing switch and for any future generic "show me the source" affordance).
- **`readAt: timestamptz?` added** — the frontend only has a boolean `isRead`; harmless to also track *when*, useful for analytics ("time to read") and matches the pattern already used correctly on `Message.readAt`.

## 5. Delivery: persisted notification vs. push delivery (explicitly separated per task instruction)

- **Persisted `Notification` row** — always created for every event in §2, regardless of whether the user is online. This is what powers the in-app notification center and unread badge (`unreadNotificationsCountProvider`), exactly as today.
- **`PushDeliveryReceipt`** ([01-domain-model.md](01-domain-model.md) §6) — a separate, optional side effect: if the recipient has push enabled (`AppPreferences.notificationsEnabled`, already modeled client-side) and a registered device token (new — the frontend has no device-token registration endpoint or FCM/APNs integration at all today, confirmed absent from `pubspec.yaml`), queue a push send job. Push failure must never block or roll back the underlying `Notification` row — the two are independent, which is exactly why they're separate tables.
- **Live in-app delivery while the app is open** uses the WebSocket channel from [07-messaging-realtime.md](07-messaging-realtime.md) (`notification.created` event) — this is what makes the unread badge update live instead of only on next `refresh()`/app-foreground, which is all the current Future-only frontend can do.

## 6. Endpoint table

| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/notifications | 🔒 | Paginated, reverse-chronological, current user only |
| GET /v1/notifications/unread-count | 🔒 | Badge count |
| POST /v1/notifications/{id}/read | 🔒 | Mark one read |
| POST /v1/notifications/read-all | 🔒 | Mark all read |
| DELETE /v1/notifications/{id} | 🔒 | Delete (real delete, matching frontend — no evidence of an "undo" need) |
| POST /v1/users/me/devices | 🔒 | Register a push device token — **new**, no frontend precedent |
| DELETE /v1/users/me/devices/{token} | 🔒 | Unregister (e.g. on logout) |

`Notification` creation itself has **no public endpoint** — it is always an internal side effect of another module's write path (booking, signing, messaging, etc.), triggered server-side within the same transaction as the originating event, mirroring how the frontend's various controllers call `NotificationsRepository.create()` as a side effect rather than the user ever directly creating one.
