# Consultations — Booking, Availability, Lifecycle, Room

## 1. Entities

See [01-domain-model.md](01-domain-model.md) §4 for full field lists: `Consultation`, `AvailabilitySlot`, `ConsultationRoomSession`, `ConsultationParticipantEvent`, plus `Review` ([01](01-domain-model.md) §3) which attaches to a completed consultation.

## 2. Booking flow (from `BookingController`'s 3-step wizard)

1. **Select type** — client picks from `lawyer.consultationTypes` (`video/voice/written`), sees per-type price from `LawyerConsultationOffering`.
2. **Select slot** — client picks an `AvailabilitySlot` from `GET /v1/lawyers/{id}/availability`; already-booked slots are excluded/disabled server-side, not just client-side (closes the frontend's unenforced double-booking gap — see [04-database-design.md](04-database-design.md) §4 exclusion constraint).
3. **Details + payment** — free-text notes, then payment via the billing flow ([12-billing.md](12-billing.md)); on success:
   - `POST /v1/consultations` creates the `Consultation` (`status = pendingApproval`), atomically marks the chosen slot `is_booked = true, consultation_id = ...` in the same transaction as an `EXCLUDE`-constraint-guarded write.
   - Creates an `Invoice`/`Transaction` for the consultation price.
   - Creates a `Notification` (`consultationBooked`) for the lawyer (the frontend only ever notifies the client side of this event today, due to the missing-clientId gap — with a real `clientUserId`, the backend should notify **both** the client, confirming their booking, and the lawyer, alerting them to a new pending request; the frontend's one-sided notification was a workaround, not the intended UX).

Price is **snapshotted onto the `Consultation` row at booking time** from `LawyerConsultationOffering.price` — a later price change by the lawyer must never retroactively alter an already-booked consultation.

## 3. Lifecycle state machine

`ConsultationStatus` (12 values) and its transition graph are already fully specified in the frontend's domain layer (`consultation_status.dart`) — a genuinely useful artifact, since it documents the *intended* real state machine even though the mock datasource itself doesn't currently enforce it (mutates status directly, never calls the validator). The backend should be the first real enforcer of this graph:

```
pendingApproval → confirmed | declined | cancelled
confirmed        → waiting | cancelled
waiting          → ready | cancelled
ready            → connecting | active | missed | cancelled
connecting       → active | failed
active           → ended | failed
ended            → completed
completed / cancelled / declined / missed / failed → (terminal)
```

### Who can trigger each transition

| Transition | Actor | Endpoint |
|---|---|---|
| (create) → pendingApproval | client | POST /v1/consultations |
| pendingApproval → confirmed | lawyer only | POST /v1/consultations/{id}/accept |
| pendingApproval → declined | lawyer only | POST /v1/consultations/{id}/decline `{reason}` |
| pendingApproval/confirmed → cancelled | client or lawyer | POST /v1/consultations/{id}/cancel `{reason}` |
| confirmed → confirmed (new time) | client only | POST /v1/consultations/{id}/reschedule `{newDateTime}` — must re-validate slot availability |
| confirmed → waiting | system, on either party opening the room within the join window | (internal, via room session join) |
| waiting → ready | system, once both/either party has joined per session rules | (internal) |
| ready → connecting/active | system, session negotiation | (internal, room service) |
| connecting → active/failed | system | (internal) |
| active → ended | client or lawyer (manual end) or system (max-duration timeout) | POST /v1/consultations/{id}/room/end |
| any pre-active → missed | **system only**, scheduled job | scan job, `scheduledAt + gracePeriod` elapsed with no join |
| active → failed | system, reconnection attempts exhausted | (internal) |
| ended → completed | system, immediately following a clean end (or lawyer explicit "End" action from `confirmed` directly for a session that never entered the live room, matching `ConsultationDetailsScreen`'s lawyer-side "End" button today) | (internal) / POST /v1/consultations/{id}/complete |

**Required timestamps** (all `NEW` relative to the frontend, which infers everything from `scheduledAt` client-side math): `confirmedAt`, `startedAt` (first `active` transition), `endedAt`, `completedAt`, plus `cancelledByUserId`/`cancellationReason` and `declineReason` — none of these exist on the frontend entity today; all are required for a real audit trail and for the lawyer dashboard's earnings/history views to be backend-computed rather than client-inferred.

### Cancellation reason & no-show handling

- `cancellationReason: text` — **new field**; the frontend's `cancel(id)` takes only an ID, no reason at all. Recommend requiring a reason for lawyer-initiated cancellations at minimum (client cancellations can be reason-optional).
- `missed` is the no-show outcome: the state machine allows `ready → missed`, meaning a no-show is only registered once the session was genuinely reachable (past the join window) and nobody connected — not simply "time passed." This distinguishes a true no-show from a consultation nobody needed to act on yet.
- No separate no-show party attribution exists in the frontend (`missed` doesn't record *which* party failed to join). Recommend adding `ConsultationParticipantEvent` rows (join attempts logged per user, see [01-domain-model.md](01-domain-model.md) §4) so a `missed` consultation can later be attributed if disputes arise — this is new relative to the frontend, which has no server-observable join log at all.

### Grace period, join window, duration (from `ConsultationRoomTiming` — already-specified frontend constants, reused as-is)

| Constant | Value | Meaning |
|---|---|---|
| `joinWindow` | 15 min before scheduled time | Either party may open the room from `scheduledAt - 15min` |
| `gracePeriod` | 10 min after scheduled time | Past this with nobody joined → `missed` |
| `maxSessionDuration` | 60 min | Hard cap; auto-end |
| `firstWarningThreshold` | 5 min remaining | Client UI warning (no backend action needed, but the timestamp math must be server-derivable so all clients agree) |
| `finalWarningThreshold` | 1 min remaining | Same |
| `maxReconnectionAttempts` | 3 | After which `connecting → failed` is final for that attempt cycle |
| `reconnectionInterval` | 10 sec | Retry cadence |

These are reused verbatim rather than reinvented — they are already tuned, documented constants in the frozen frontend and changing them would be a product decision, not a backend-architecture one.

## 4. Availability model

`AvailabilitySlot` — one lawyer, one time range, booked or not. The frontend generates hourly slots 9:00–17:00 Sun–Thu for 14 days rolling and never prevents concurrent double-booking at the data layer. The backend:
- Lawyer manages slots via `POST /v1/lawyers/me/availability` (create) / `DELETE /v1/lawyers/me/availability/{id}` (remove, only if `!is_booked` — matches frontend's implicit rule that a booked slot can only be freed by cancelling the consultation, not deleted directly).
- `GET /v1/lawyers/{id}/availability?from=&to=` — public read for booking.
- **Approved decision** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 8): slot generation policy (recurring weekly template vs. explicit per-slot creation) was not resolved by the frontend (which just seeds random data) — **v1 supports one-off slots only**, created/removed one at a time exactly as the two endpoints above describe. A `RecurringAvailabilityRule` (day-of-week + time range) that materializes concrete `AvailabilitySlot` rows on a rolling window is **deferred until after the initial consultation/booking implementation** (this phase) is stable — it is not built in Phase 4. The `AvailabilitySlot` table design (a flat, independent row per slot, with no assumption of where a slot came from) does not need to change to add this later: a future `RecurringAvailabilityRule` table would simply be an additional generator that inserts `AvailabilitySlot` rows the same way the lawyer's manual `POST` does today, so this decision does not block or complicate Phase 4's schema.

## 5. Consultation room — application backend vs. media provider split

**Do not implement WebRTC/Agora/etc. in this phase** (explicit instruction) — this section only separates responsibilities so a future phase knows the boundary.

### Application backend owns:
- `ConsultationRoomSession` row: `state` (`waiting/ready/connecting/active/ended/failed`), `reconnectAttempts`, `durationSeconds`.
- **Room identity**: `consultationId` *is* the room identity for the written-chat case (no external provider needed — it's just the `Message` table scoped to that id). For voice/video, the room needs a `providerRoomId` (opaque token from whichever media provider is chosen) — created lazily on first `connect()` call, stored on `ConsultationRoomSession.providerRoomId`.
- **Participant authorization**: before issuing a session token (see below), verify the requesting user is `consultation.clientUserId` or the lawyer behind `consultation.lawyerProfileId`, and that `consultation.status` is in a joinable state (`blocksLiveSession` is `false` only for `confirmed/waiting/ready/connecting/active` — reuse this exact rule server-side).
- **Session token generation**: `POST /v1/consultations/{id}/room/token` → backend calls the chosen media provider's server SDK to mint a short-lived, room-scoped join token for the authenticated user, returns it to the client. The application backend never proxies media itself.
- **Join/leave events**: client reports `POST /v1/consultations/{id}/room/join` and `.../leave` (or the provider's server-side webhooks report them, if the provider supports that — preferred, since it can't be spoofed by a client that simply stops calling `leave`); each recorded as a `ConsultationParticipantEvent`.
- **Connection state**: `waiting → ready → connecting → active → ended/failed`, driven by join events and provider webhooks (e.g. a provider "participant disconnected unexpectedly" webhook → `reportConnectionLost` equivalent → `active → failed`).
- **Session duration enforcement**: the max-duration auto-end job (§6 in [05-api-design.md](05-api-design.md)) is application-backend responsibility regardless of provider.
- **Failed sessions**: `failed` state plus `reconnectAttempts` counter, capped at 3 — retried by the client calling `POST /v1/consultations/{id}/room/retry`, which re-mints a token and increments the counter.
- **Security requirement**: room tokens must be single-use-scoped to (consultation, user, short TTL e.g. 5 min) — never a long-lived or shareable credential, since a leaked token would let an unauthorized party join a legal consultation.

### Media provider (Agora/Twilio/LiveKit/etc. — vendor choice deferred, not made in this phase) owns:
- Actual audio/video transport, codecs, bandwidth adaptation, device permission negotiation.
- Its own room/channel abstraction (mapped 1:1 to our `providerRoomId`).
- Low-level reconnection/ICE negotiation (our `reconnectAttempts` counter tracks *application-level* retry cycles the UI shows, which may wrap several provider-level ICE retries — these are related but not identical concepts).

### Written (chat) consultations
No media provider at all — `ChatRoomScreen`'s "room" *is* the messages transcript. The same `ConsultationRoomSession` state machine still applies for consistency (waiting/ready/active/ended), but `connect()` for a written consultation transitions `ready → active` directly (no `connecting` phase — matches the frontend's session controller, which skips `connecting` for written type). See [07-messaging-realtime.md](07-messaging-realtime.md) for the chat transport itself.

## 6. Consultation ↔ Messages boundary (carried into the backend unchanged)

Per the audit, chat is not an independent inbox — it is 1:1 keyed by `consultationId`, functioning as that session's transcript, and this is a deliberate, sound design worth preserving: **`Message.consultationId` remains the sole scoping key**; there is no general/standalone conversation entity in this domain, and none should be introduced. A video/voice consultation's in-call "chat" side-channel (the frontend's `VideoCallScreen` chat icon) uses the exact same `Message`/consultation-scoped model, not a separate ephemeral in-call chat — this avoids a duplicate messaging concept.

## 7. Endpoint table

| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/consultations | 🔒 | List current user's consultations (client, lawyer, or org-scoped) |
| GET /v1/consultations/{id} | 🔒 | Detail |
| POST /v1/consultations | 🔒 (client) | Book |
| POST /v1/consultations/{id}/accept | 🔒 (lawyer) | Confirm |
| POST /v1/consultations/{id}/decline | 🔒 (lawyer) | Decline `{reason}` |
| POST /v1/consultations/{id}/cancel | 🔒 (client or lawyer) | Cancel `{reason}` |
| POST /v1/consultations/{id}/reschedule | 🔒 (client) | New `scheduledAt`, re-checks slot |
| POST /v1/consultations/{id}/complete | 🔒 (lawyer) | Manual end from `confirmed` without entering the room |
| GET /v1/lawyers/{id}/availability | 🔓/🔒 | Public slot listing for booking |
| POST /v1/lawyers/me/availability | 🔒 (lawyer) | Add slot |
| DELETE /v1/lawyers/me/availability/{id} | 🔒 (lawyer) | Remove (unbooked only) |
| POST /v1/consultations/{id}/room/token | 🔒 (participant) | Mint media-join token |
| POST /v1/consultations/{id}/room/join | 🔒 (participant) | Report join |
| POST /v1/consultations/{id}/room/leave | 🔒 (participant) | Report leave |
| POST /v1/consultations/{id}/room/retry | 🔒 (participant) | Reconnect attempt |
| POST /v1/consultations/{id}/room/end | 🔒 (participant) | End session |
| PATCH /v1/consultations/{id}/room/metrics | 🔒 (participant) | Mute/camera/speaker toggles (optional — could stay entirely client-local like today if no other participant needs server-relayed state; recommend keeping server-authoritative only for what other participants must see, e.g. "is muted" indicator) |
| POST /v1/consultations/{id}/review | 🔒 (client, post-`completed` only) | Submit `Review` |
