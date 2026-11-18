# Aqd (OQD-Platform) — Implementation Roadmap

Derived from `FULL_APPLICATION_AUDIT.md` (2026-11-17). That report defers its earlier findings (SEC-/BIZ-/DB-/PERF-/TST-/FE-/CFG-/MISS-/API-) to `COMPLETE_APPLICATION_AUDIT.md` (2026-11-12), so both were read; every issue below comes from one of them.

**Status: planning only.** No source code, UI, or file was changed or deleted to produce this document.

## Implementation log — pass 1 (2026-11-17)

Nothing was deployed or committed. **No database was available** (no PostgreSQL, Docker or `psql` on this machine), so no DB-level behaviour was exercised; DB-dependent statements below say so.

**Status words:** FIXED = code changed and covered by tests that ran green · PARTIALLY FIXED = part done, remainder stated · BLOCKED = cannot be done/verified without a decision or resource named in the row · NOT STARTED = not attempted in this pass (reason given).

### Test results (actual)

| Check | Result |
|---|---|
| `flutter analyze` (final) | No issues found |
| `flutter test` (full run after the FE-02/FE-01b changes) | **620 passed, 0 failed** (was 609). One later edit changed only `const` keywords inside `test/app/release_features_test.dart`; that file was re-run alone: 10/10 pass, analyzer clean |
| Backend `tsc --noEmit` | exit 0 |
| Backend `eslint src test` | exit 0 |
| Backend `jest` | **16 suites, 118 passed** (was 13 / 100) |
| Backend e2e (7 specs incl. the new one) | **Not run — BLOCKED (no PostgreSQL).** The new spec was type-checked and linted only |
| Mutation check for SEC-04 | Running the new `token.service.spec.ts` against the **pre-fix** `token.service.ts` fails exactly the concurrent-refresh test (1 failed, 3 passed); against the fix all 4 pass |

### Status per issue

| ID | Status | What was done / why not |
|---|---|---|
| **REL-01** | BLOCKED | Needs an upload keystore + `android/key.properties` from the owner. Not creatable here. |
| **OPS-01** | BLOCKED | No PostgreSQL/Docker. Migrations (incl. DB-01 index and the `phone_sign_in` data migration) remain unapplied and unread-in-depth; e2e unrun. |
| **DB-03** | BLOCKED | Decision D-3 (contract retention) and a database to verify the migration. |
| **FE-01b** | PARTIALLY FIXED | In release builds (flag off), all mock-only screens are now unreachable and their entry points hidden: company Documents tab, company home Documents/Team cards and add-member action, the written-consultation chat button, the video-call chat button, the waiting-room hand-off to chat, and the Help & Support "contact" form (it only showed a fake "sent" snackbar). A central router redirect also sends typed/stale links (AI, documents, team, chat, subscription/invoices/payment-methods/signature routes) to the user's home. **Not done:** nothing was rendered on a device; D-2 was applied as "hide" without your confirmation — consequence: a *written* consultation has no message channel in release until real messaging (roadmap 5.1) exists. Debug/profile builds are unchanged. |
| **BIZ-01** | BLOCKED | D-4 (who decides outcomes) unanswered; not guessed. |
| **BIZ-02** | PARTIALLY FIXED | Server now rejects past slots, slots over 8 h (`MAX_SLOT_DURATION_MS`), slots overlapping the lawyer's own others (409), booking and rescheduling into a started slot. 10 new unit tests pass. **Not verified:** the overlap query against a real DB; concurrent creation of two overlapping slots can still both pass (no DB constraint — would need a migration); how the lawyer_schedule/booking screens display the new 400/409 (no Flutter code changed, not exercised against the real API). The 8 h cap is my choice, not a stated requirement. |
| **BIZ-03** | FIXED | `HttpExceptionFilter` maps Prisma `P2002` to 409 `CONFLICT`; other Prisma errors stay an opaque 500. 2 new filter tests. The real concurrent-review race was not run (no DB). |
| **BIZ-04** | BLOCKED | D-5; also needs a schema/model change that cannot be verified without a DB. |
| **BIZ-05** | BLOCKED | D-6 and a schema change (content hash) not verifiable without a DB. |
| **FE-02** | FIXED | An `admin` (or any role the app has no shell for) now yields `ForbiddenFailure(code: UNSUPPORTED_ROLE)` with a localized Arabic/English message instead of a generic error, and the session the server just opened is revoked via `POST /auth/logout`. Splash/restore of such a session clears local state via the existing Forbidden path. 4 new tests (wire, message, data source incl. revoke call, client login unaffected). |
| **SEC-03** | BLOCKED | D-7 (UI change to edit_profile). |
| **SEC-04** | FIXED | `TokenService.rotate` revokes with a conditional `updateMany({id, revokedAt: null})`; the loser of a concurrent refresh is treated as replay (family revoked, 401). `POST /auth/refresh` now has a 30/min/IP throttle. Unit-tested incl. the mutation check above. **Not verified:** behaviour on real Postgres; the throttle value is untested. |
| **SEC-05** | FIXED | `GET /lawyers/:id/reviews` no longer returns `reviewerUserId` and returns 404 for unverified/unknown lawyers. 3 new tests. The Flutter app does not call this endpoint, so no client model changed. |
| **AUD-05** | BLOCKED | D-1 (build the reviews UI?) — it is a UI feature. Backend prerequisites SEC-05/BIZ-03 are done; BIZ-01 is not. |
| **WIRE-01** | NOT STARTED | Large read-only comparison (55 routes) not attempted in this pass. Still the main unverified contract risk. |
| **TST-01 / TST-02** | PARTIALLY FIXED | Added unit specs: `TokenService.rotate`, `LawyersService.findReviews`, `ConsultationsService` availability/book/reschedule rules, filter. Added `backend/test/lawyers-public.e2e-spec.ts` (public list/detail, 401/403 on `/lawyers/me`, reviews, slot rules) — **written, type-checked, linted, never executed**. **Not done:** specs for the consultation state machine, `ConsultationRoomService`, `GovProceduresService`; CI configuration. |
| **PERF-01** | PARTIALLY FIXED | `GET /lawyers/:id/availability` returns only slots that have not started (unit-tested). `GET /consultations` is still unpaginated — doing it needs a response-shape/paging change in Flutter and was not attempted. |
| **DB-02** | BLOCKED | Needs a scheduler decision (D-8) and a DB. |
| **SEC-06** | BLOCKED | Object-storage infrastructure decision (D-8). |
| **SEC-07 / AUD-09** | NOT STARTED | Redis (D-8) and per-route limits/caching for the public endpoints not done. (Only the refresh throttle from SEC-04 exists.) |
| **SEC-08** | NOT STARTED | Needs knowledge of the deployment environment; a guess at a startup rule could break legitimate dev setups. |
| **BIZ-06** | BLOCKED | The allowed join window is a product decision; pairs with BIZ-04. |
| **BIZ-07** | BLOCKED | D-9. |
| **AUD-06** | BLOCKED | Depends on BIZ-04. |
| **AUD-07** | NOT STARTED | Risk was never reproduced; reproduce before changing the router. |
| **MISS-01** | OUT OF SCOPE | Backend roadmap phases 4–8; interim handling is FE-01b. |
| **API-A** | NOT STARTED | Contract test vs OpenAPI; shares work with WIRE-01. |
| **ENUM-01** | NO CHANGE | D-10 unanswered; behaviour kept. |
| **SEC-RT** | BLOCKED | Needs a running stack (OPS-01). |
| **P3 items** (FE-03r, FE-04, FE-05, FE-06r, FE-07, FE-08, FE-10, FMT-01, DB-04, DB-05, SEC-10, PERF-02/03/04, QUAL-01, QA-01, AUD-08, DATA-01) | NOT STARTED | UI-affecting ones are parked by your no-UI-change rule; FE-08 needs D-11 (deletions); the rest are low priority and were not reached. |

### Files modified in this pass

**Backend (source):** `backend/src/auth/auth.controller.ts`, `backend/src/auth/services/token.service.ts`, `backend/src/common/filters/http-exception.filter.ts`, `backend/src/consultations/consultations.service.ts`, `backend/src/lawyers/lawyers.service.ts`
**Backend (tests, new unless noted):** `backend/src/auth/services/token.service.spec.ts`, `backend/src/consultations/consultations.service.spec.ts`, `backend/src/lawyers/lawyers.service.spec.ts`, `backend/src/common/filters/http-exception.filter.spec.ts` (extended), `backend/test/lawyers-public.e2e-spec.ts`
**Flutter (source):** `lib/core/errors/failure.dart`, `lib/core/errors/failure_message.dart`, `lib/core/routing/app_router.dart`, `lib/core/routing/routes/company_routes.dart`, `lib/features/auth/domain/entities/user_role.dart`, `lib/features/auth/data/datasources/auth_wire.dart`, `lib/features/auth/data/datasources/auth_remote_data_source_impl.dart`, `lib/features/company/presentation/screens/company_home_screen.dart`, `lib/features/consultations/presentation/screens/consultation_details_screen.dart`, `lib/features/consultation_room/presentation/screens/video_call_screen.dart`, `lib/features/consultation_room/presentation/screens/consultation_waiting_screen.dart`, `lib/features/profile/presentation/screens/help_support_screen.dart`, `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb` (+ regenerated `lib/core/localization/generated/*`)
**Flutter (tests):** `test/app/release_features_test.dart` (extended), `test/core/errors/failure_message_test.dart` (extended), `test/features/auth/data/auth_wire_test.dart` (updated: admin now a typed failure), `test/features/auth/data/auth_login_admin_test.dart` (new)

Several of these files (arb, generated localization, app_router, auth data sources, `app_localizations*`) already had your uncommitted edits before this pass; my changes are additive on top. I ran `dart format` on one file by mistake (`consultation_details_screen.dart`); it had no prior changes, so I restored it from `HEAD` and re-applied only the two intended lines (diff is 2 insertions, 1 deletion).

### Behaviour changes to be aware of
- Lawyers can no longer publish past/over-long/overlapping slots; clients can no longer book or reschedule into a started slot. Existing clients receive 400/409 with the usual error envelope.
- `GET /lawyers/:id/availability` hides slots that already started (a lawyer's own schedule screen therefore no longer lists past slots).
- `GET /lawyers/:id/reviews` response lost `reviewerUserId`.
- Release builds: see FE-01b above.

---

## 0. How to read this document

**Root-cause rule.** "Root cause" is filled in only where the audit read the code and states the cause (`[CODE]`/`[RUN]`). Where the audit marked an item `[RISK]`, `[NOT TESTED]` or `[BLOCKED]`, the field says **Unconfirmed** and the first task is a reproduction or verification step, not a fix.

**Spot-check against the tree** (done while writing this): the backend module layout, the migration folder (including `20261112120000_refresh_token_hash_unique`), `UserRole.fromWire` using `byName`, `reviewerUserId` returned at `lawyers.service.ts:175`, and `P2002` handled only in `auth.service.ts:520` (nowhere in `HttpExceptionFilter`) all match the audit. Line numbers elsewhere are the audit's and may have drifted — re-locate before editing.

**Layer tags:** `FL` = Flutter · `BE` = Node.js/NestJS · `DB` = Prisma schema/migration/SQL · `OPS` = deployment/process/no code.

**"UI-affecting"** = would change how a screen looks. You said not to change UI designs, so these items are **parked** until you approve them explicitly (see §6).

**Priorities**
- **P0** security hole, data loss, or broken core functionality, or a prerequisite that gates everything else
- **P1** broken/missing integration, DB failure risk, non-functional feature
- **P2** incomplete functionality, validation, error handling, hardening
- **P3** UI polish, minor bugs, optimisation, hygiene

Per-issue "Testing" lists the tests that must exist or pass before the item is closed. "Regression" always means: `flutter analyze`, `flutter test` (609), backend `tsc --noEmit`, `eslint`, `jest` (100).

---

## 1. Already done — do NOT redo

| ID | What was done | Remaining action |
|---|---|---|
| SEC-01 | Release signing from `android/key.properties`; `bundleRelease` refuses without it | Signed path never exercised → **REL-01** |
| SEC-02 | `npm audit fix` (prod: 0 vulns; 31 dev-only remain, not shipped) | None |
| SEC-09 | Foreign SMS account name removed from `backend/.env.example` | Rotate it if it was a live account (**OPS**, owner decision) |
| DB-01 | Unique index migration written | **Not applied to any DB** → **OPS-01** |
| CFG-01 | Debug/profile default `http://10.0.2.2:3000/v1`; release = prod | None |
| FE-01 | `FeatureFlags.previewFeatures` hides AI, Documents, analysis tile, vault banner, scripted lawyer reply in release | Residual gaps → **FE-01b** |
| AUD-01 | `GET /lawyers`, `GET /lawyers/:id` public | e2e never run → **TST-02** |
| AUD-02, AUD-03, AUD-04 | Logout redirect, card overflow, guest-first tests | None |
| FE-03 / FE-06 / FE-09 | Colours moved to `ColorScheme`, contrast tokens, gradients flattened on client home | Only the leftovers listed in §4 (P3) |

---

## 2. Duplicates and overlaps (fix once)

| Cluster | Items | Decision |
|---|---|---|
| Mock/unbuilt features | FE-01 residual, MISS-01, audit §F (AI, documents, chat, team, billing, saved signature, company_home mock parts) | One tracker: **FE-01b** (hide/label) now; real backends are separate roadmap phases (phases 4–8 of `docs/plans/roadmap.md`), not part of this plan |
| Reviews | AUD-05 (no UI), SEC-05 (leaks reviewer id, no verified gate), BIZ-03 (dup review → 500), BIZ-01 (reviews farmable via instant complete) | Fix **backend first** (SEC-05, BIZ-03, BIZ-01), **then** build the Flutter review feature (AUD-05) against the corrected contract |
| `consultations.service.ts` validation | BIZ-02, BIZ-01, BIZ-06, PERF-01 | One work package (**WP-CONS**), one set of integration specs |
| Room model | BIZ-04, AUD-06 (`/room/leave` never called), BIZ-06 | AUD-06 is only meaningful after BIZ-04's per-participant model; do together |
| Rate limiting | SEC-07 (in-memory), AUD-09 (public lawyers endpoints), SEC-04 (refresh throttle) | SEC-04's per-route throttle and AUD-09's stricter limit use the existing throttler now; SEC-07 (Redis) is the later store swap and does not block them |
| Account deletion | DB-03, SEC-10, DB-05, roadmap 1.6 | Single design: **DB-03**. SEC-10/DB-05 ride along |
| Docs drift | AUD-08 (wrong counts) | Resolved by `FULL_APPLICATION_AUDIT.md` superseding; one-line note in the old file only if you want it |
| Tests | TST-01, audit §I.1, TST-02 | One test programme: **TST-01** (includes the e2e additions) |
| Theme | FE-03 leftovers + FE-06 leftovers | Single parked UI package |

---

## 3. Dependency graph

```
OPS-01 (Postgres up, apply migrations incl. DB-01, run e2e)  ──┬─> TST-02 ─┐
                                                               ├─> every BE/DB item's DB-level verification
WIRE-01 (Dart models vs Nest DTOs, field by field) ────────────┴─> any contract change (SEC-05, BIZ-01/02/05, AUD-05)

BIZ-03 (P2002 → 409 in filter) ─┐
SEC-05 (drop reviewerUserId) ───┼─> AUD-05 (Flutter review UI)   [needs product decision D-1]
BIZ-01 (outcome rules)  ────────┘
BIZ-01 ──> payments/billing (future; blocks it)
BIZ-04 ──> AUD-06, BIZ-06, real media (roadmap 6.1)
DB-03 design ──> account deletion endpoint, SEC-10, DB-05
DB-02 purge job ──> needs a scheduler (new infra); also serves BIZ-01 auto-miss
SEC-07 (Redis) ──> multi-instance deployment;  SEC-06 (object storage) ──> multi-instance deployment
FE-02 (admin role) ──> independent
```

Execution order is in §5.

---

## 4. Issues

Convention: **Tables** use Prisma `@@map` names from the audit. **Endpoint** "—" means none.

### P0

#### REL-01 · Signed release build never exercised (follow-up to SEC-01)
- **Layer:** OPS / FL (Gradle) · **Screen:** none
- **Description:** The signing config is written but only the *refusal* path ran; no keystore existed. A release AAB has never been produced.
- **Files:** `android/app/build.gradle.kts`, `android/key.properties` (git-ignored, to be created)
- **Endpoint / tables:** — / —
- **Root cause:** Not a defect — verification gap (audit: "Signed-build path not exercised (no keystore)").
- **Solution:** Owner creates upload keystore + `key.properties`; run `flutter build appbundle --release`; confirm signature with `apksigner`/`jarsigner -verify`; back up the keystore; enable Play App Signing. Minify/R8 was in the original SEC-01 fix list — confirm whether it was enabled; if not, evaluate separately.
- **Testing:** release AAB builds; signature is not the debug cert; app launches with `API_BASE_URL` set; release build without it fails/aborts as intended.

#### OPS-01 · Nothing has been verified against a real database
- **Layer:** OPS / DB · **Screen:** all data-backed screens
- **Description:** No PostgreSQL on the audit machine: 13 migrations never applied, 6 e2e specs never run, DB-01 migration unapplied, `20261008090000_phone_sign_in` (a data migration) "not read in depth".
- **Files:** `backend/prisma/migrations/*`, `backend/prisma/schema.prisma`, `backend/test/*.e2e-spec.ts`
- **Endpoint / tables:** all / all 24 (esp. `refresh_tokens`, `users`, `availability_slots`)
- **Root cause:** Environment limitation (audit §G), not a code defect.
- **Solution:** Provision Postgres with `btree_gist`/`citext` (needed by the hand-written exclusion constraint); read `phone_sign_in` migration against realistic data; `prisma migrate deploy` on an empty DB and on a copy of production data; check row count of `refresh_tokens` before the DB-01 unique index; run all e2e specs; record results.
- **Testing:** migrate from zero succeeds; migrate on prod-copy succeeds; `prisma validate`; e2e 6/6 green; exclusion constraint rejects overlapping booked slots.
- **Gates:** TST-01, TST-02, every BE/DB item's verification.

#### DB-03 · Cascade deletes from `User` across business records; no account-deletion design
- **Layer:** DB + BE (+ FL later) · **Screen:** account (deletion not built)
- **Description:** Physically deleting a user cascades to consultations (the lawyer's history), reviews (rating basis changes without recomputation), contracts, signatures. Store policies require account deletion.
- **Files:** `backend/prisma/schema.prisma` (`Consultation.client`, `Review.reviewer`, `Contract`, `ContractSignature`), new migration; `auth.service.ts`
- **Endpoint:** none today (deletion not built) · **Tables:** `users`, `consultations`, `reviews`, `contracts`, `contract_signatures`, `lawyer_profiles`
- **Root cause (confirmed [CODE]):** `onDelete: Cascade` on those relations; `User.deletedAt` exists but unused.
- **Solution:** Needs decision **D-3** (legal retention of signed contracts). Then: soft-delete + anonymise, change business FKs to `Restrict`, recompute lawyer rating/`reviewsCount` aggregates. Delivered as an additive migration. Latent today (no delete path) — P0 because it is data-loss and blocks store submission.
- **Testing:** e2e: soft-delete a client with consultations/contract → rows retained, PII removed, lawyer history intact; hard delete of a user with business rows is rejected; migration safe on prod-copy.

#### FE-01b · Remaining mock exposure after the preview flag
- **Layer:** FL · **Screens:** chat_room, team_list, team_member_details, subscription_plans, invoices, payment_methods, saved_signature, company_home, help_support ("contact support" mock action), documents/AI (verify gating)
- **Description:** FE-01's fix covered AI/Documents tabs, analysis tile, vault banner, Ask-AI pill, scripted reply. Audit states lawyer/company shells and team/billing screens were **not gated**; chat messages are stored locally and never reach the other party; saved signature is lost on restart.
- **Files:** `lib/core/config/feature_flags.dart`, `lib/core/routing/routes/*.dart`, `lib/features/{messages,team,billing,company,documents}/...`, `*_data_source_provider.dart` (ai, documents, messages, team)
- **Endpoint / tables:** none exist / none
- **Root cause (confirmed [CODE]):** providers return mock data sources unconditionally; no flag check on those routes.
- **Solution:** Reuse the existing `previewFeatures` flag and the Account screen's "coming soon" labelling pattern — **no new design**. Hide or label entry points in release; make chat honestly "unavailable" rather than local-only (decision **D-2**). Do not delete mock data sources (debug builds and tests use them).
- **Testing:** extend `release_features_test`: with flag off, none of the listed routes/entry points reachable; with flag on, unchanged; router/shell tests updated.

### P1

#### BIZ-01 · Either party can set consultation outcome at any time
- **Layer:** BE (+ FL error mapping) · **Screens:** consultation_details, lawyer_requests, voice/video call
- **Files:** `backend/src/consultations/consultations.service.ts` (`complete`, `markMissed`, `markFailed`, ~198–214)
- **Endpoint:** `POST /consultations/:id/complete | miss | fail` · **Tables:** `consultations`, `consultation_room_sessions`, `consultation_participant_events`
- **Root cause (confirmed [CODE]):** only "is participant" and `status = confirmed` are checked.
- **Solution:** Needs **D-4** (who decides outcomes). Then time-window gate + room-session evidence server-side; optionally an auto-miss job (needs scheduler, see DB-02). Adds new 4xx → map in Flutter error localisation (existing error-code pattern).
- **Testing:** unit/integration: complete before start → 4xx; complete without room evidence → per rule; wrong actor → 403; concurrent calls remain atomic (conditional `where`).
- **Note:** must land before any payment work.

#### BIZ-02 · No time validation on slots, bookings, reschedule
- **Layer:** BE · **Screens:** lawyer_schedule, booking_datetime, consultation_details (reschedule)
- **Files:** `consultations.service.ts` (`addAvailabilitySlot` ~55, `book` ~83, `reschedule`)
- **Endpoint:** `POST /lawyers/me/availability`, `POST /consultations`, `POST /consultations/:id/reschedule` · **Tables:** `availability_slots`, `consultations`
- **Root cause (confirmed):** only `start < end` checked; DB exclusion constraint covers *booked* overlaps only.
- **Solution:** reject past start, cap duration, reject overlap with the lawyer's own other slots, reject booking/rescheduling to a past slot. Existing UI already surfaces server error codes.
- **Testing:** specs for each rejection; happy paths unchanged; the audit's `lawyer_schedule` "open slot" test must keep passing.

#### BIZ-03 · Concurrent duplicate review → HTTP 500
- **Layer:** BE · **Screen:** none yet (no review UI)
- **Files:** `backend/src/common/filters/*` (HttpExceptionFilter), `consultations.service.ts:~262` (`createReview`)
- **Endpoint:** `POST /consultations/:id/reviews` · **Tables:** `reviews` (unique `(consultationId, reviewerUserId)`)
- **Root cause (confirmed):** check-then-insert; unique index catches the race but the filter has no `P2002` mapping (re-verified: only `auth.service.ts` handles it).
- **Solution:** map `P2002` → 409 in the filter (generic, also protects other writes). Keep existing auth-specific handling untouched.
- **Testing:** concurrent double-submit → one 201, one 409; other endpoints' error shapes unchanged.

#### BIZ-04 · Room cannot support two participants
- **Layer:** BE (+ FL room data source) · **Screens:** consultation_waiting, voice_call, video_call
- **Files:** `backend/src/consultation-room/consultation-room.service.ts` (~18, 63), `lib/features/consultation_room/data/...`
- **Endpoint:** `POST …/room/join | connect | retry | end`, `PATCH …/room/metrics` · **Tables:** `consultation_room_sessions`, `consultation_room_tokens`, `consultation_participant_events`
- **Root cause (confirmed [CODE]):** `join` allowed only from `waiting`; first join moves the shared session to `ready`, so the second participant gets 400; mute/camera flags are per session.
- **Solution:** per-participant presence, session state derived from both. Likely a schema change (per-participant rows). Shares the work with roadmap 6.1 (real media) — scope decision **D-5**: do the state model now, media later.
- **Testing:** two-user e2e join in both orders; reconnect; metrics per participant; existing room tests stay green.

#### BIZ-05 · Contract stuck in `pendingSignature`; weak signature evidence
- **Layer:** BE + DB + FL · **Screens:** contract_preview, contract_details, contracts_list
- **Files:** `backend/src/contracts/contracts.service.ts`, `schema.prisma` (`contracts`, `contract_signatures`), Flutter contracts feature
- **Endpoint:** `POST /contracts/:id/generate | sign`, `PATCH/DELETE /contracts/:id` · **Tables:** `contracts`, `contract_signatures`
- **Root cause (confirmed [CODE]):** `update`/`remove` only on `draft`; `generate` has no way back; `sign` stores timestamp/IP/UA but no hash of `generatedContent`; only owner signs.
- **Solution:** add "revise" transition (pendingSignature → draft) and store a content hash at generate/sign (additive column). Counter-party signing needs **D-6** (legal definition of "signed"); keep out of scope until decided. New route → Flutter data source + a trigger in contract_details/preview **only if it fits the current layout** (otherwise UI-parked).
- **Testing:** revise then regenerate; hash changes with content; sign verifies hash; existing contracts e2e still passes.

#### FE-02 · Admin role cannot be parsed → login throws
- **Layer:** FL · **Screens:** login, splash (session restore)
- **Files:** `lib/features/auth/domain/entities/user_role.dart:12`, `lib/features/auth/.../auth_wire.dart:57`
- **Endpoint:** `POST /auth/login`, `GET /auth/me` · **Tables:** `users` (role enum)
- **Root cause (confirmed):** `UserRole.values.byName` throws `ArgumentError` for backend value `admin`, which the Dart enum lacks.
- **Solution:** reject non-app roles with a localised message (reuses the existing error/ARB flow; no new screen). Also covers splash restoring an admin session.
- **Testing:** unit: `fromWire('admin')` handled; login/splash widget tests with an admin payload show the message, no crash. Add ARB key in `app_ar.arb` + `app_en.arb`, regenerate.

#### SEC-05 · Reviews expose `reviewerUserId`; unverified lawyers' reviews readable
- **Layer:** BE + FL model · **Screen:** lawyer_details (reviews not rendered today)
- **Files:** `backend/src/lawyers/lawyers.service.ts:150,175`, Flutter lawyers models
- **Endpoint:** `GET /lawyers/:id/reviews` · **Tables:** `reviews`, `lawyer_profiles`
- **Root cause (confirmed):** raw id returned; profile endpoint applies the verified gate, reviews endpoint does not.
- **Solution:** drop id (or return display name/initial); apply verified gate. Flutter does not call this endpoint, so model impact is nil until AUD-05.
- **Testing:** response lacks the id; unverified lawyer → 404; verified lawyer unchanged. (Do **WIRE-01** check on this DTO.)

#### SEC-04 · Refresh rotation not atomic; refresh lightly throttled
- **Layer:** BE · **Screens:** splash (refresh), all authenticated screens (silent refresh)
- **Files:** `backend/src/auth/services/token.service.ts:~57`, `auth.controller.ts:~117`
- **Endpoint:** `POST /auth/refresh` · **Tables:** `refresh_tokens`
- **Root cause (confirmed):** read → check `revokedAt` → update without conditional `where: { revokedAt: null }`; only the global 120/min/IP limit applies.
- **Solution:** `updateMany({ where: { id, revokedAt: null } })` and require `count === 1`; add a moderate per-route throttle. **Depends on OPS-01** (concurrency must be tested on real Postgres).
- **Testing:** two parallel refreshes with one token → exactly one succeeds, replay revokes family; normal refresh unaffected; Flutter silent-refresh tests still green.

#### SEC-03 · Email change needs no re-authentication
- **Layer:** BE + FL · **Screens:** edit_profile
- **Files:** `backend/src/auth/auth.service.ts:~214` (`updateProfile`), update DTO, `lib/features/profile/...` edit-profile flow
- **Endpoint:** `PATCH /auth/me` · **Tables:** `users`
- **Root cause (confirmed):** any valid access token can set `email`.
- **Solution:** require current password (or OTP) when email changes. This adds an input to edit_profile → **UI-affecting; needs your approval (D-7)**. Backend part can ship first behind compatible DTO (optional field enforced only when email differs) — but then the current app would fail email edits until the field is added, so ship both together.
- **Testing:** email change without/with wrong password → rejected; correct → ok; other profile fields unaffected.

#### AUD-05 · No review UI (reviews cannot be created or read from the app)
- **Layer:** FL (+ BE prerequisites) · **Screens:** lawyer_details, consultation_details (after completion)
- **Endpoint:** `POST /consultations/:id/reviews`, `GET /lawyers/:id/reviews` · **Tables:** `reviews`, `lawyer_profiles`
- **Root cause (confirmed):** backend exists, the app has no feature for it; therefore `rating`/`reviewsCount` can never change from the app.
- **Solution:** product decision **D-1** (build now or defer). If yes: after SEC-05/BIZ-03/BIZ-01, add data source, repository, controller, and screens. **UI-affecting.**
- **Testing:** repository/controller unit tests; widget tests for submit/duplicate (409)/unverified; WIRE-01 on review models.

#### WIRE-01 · Dart wire models never compared field-by-field with Nest DTOs/Prisma view
- **Layer:** FL + BE (read-only first) · **Screens:** all API-backed
- **Description:** The audit matched method+path for 55 routes (0 missing) but explicitly did **not** compare request/response bodies, dates/timezones, decimals.
- **Files:** `lib/features/*/data/{models,datasources}/*`, `backend/src/*/dto/*`, `schema.prisma`
- **Root cause:** Unconfirmed — this is a verification gap.
- **Solution:** produce a per-endpoint comparison table (field, type, nullability, enum values, date format, Decimal-as-string/number). Open a separate fix item per mismatch found. A Swagger/OpenAPI contract test (also API-A) is the durable guard.
- **Testing:** contract test of every route's response vs OpenAPI; Flutter model tests using JSON captured from the real API.

#### TST-01 / TST-02 · Missing tests and CI for money-adjacent logic
- **Layer:** BE tests + OPS (CI) · **Files:** new specs for `ConsultationsService`, `ConsultationRoomService`, `LawyersService`, `GovProceduresService`, `TokenService`; new e2e for public `GET /lawyers[/:id]` and 401 on `/lawyers/me` (TST-02 = AUD-01 coverage); CI config (none tracked)
- **Root cause (confirmed):** specs absent; no CI file in repo.
- **Solution:** write specs alongside each fix (SEC-04, BIZ-01/02/03/04), not afterwards; CI runs `flutter analyze`, `flutter test`, backend lint/tsc/unit/e2e (Postgres service) and `npm audit --omit=dev`. **Depends on OPS-01.**
- **Testing:** CI green on main; deliberately broken change fails CI.

### P2

| ID | Layer | Description · root cause | Files | Endpoint / tables | Solution | Testing |
|---|---|---|---|---|---|---|
| **PERF-01** | BE (+FL paging) | `getAvailability` returns all slots ever; `GET /consultations` unpaginated (confirmed) | `consultations.service.ts` (~38, ~152); Flutter consultations/booking data sources | `GET /lawyers/:id/availability`, `GET /consultations` · `availability_slots`, `consultations` | Default `startAt >= now`; page/limit with `{data, meta}` like other lists; Flutter must request/handle meta (consultations_list, booking_datetime) — keep current list UI, add paging only if >1 page | Past slots excluded; page boundaries; Flutter list tests with meta. Part of **WP-CONS** |
| **DB-02** | BE/DB + scheduler | No retention: `refresh_tokens`, `verification_codes`, `consultation_participant_events`, old notifications (confirmed) | new scheduled job; `schema.prisma` possibly indexes | — · those tables | Scheduled purge (revoked/expired tokens 30–90 d; consumed/expired codes >24 h). Needs scheduler choice (**D-8**). Apply only after OPS-01 | Job unit test with fake clock; no live tokens/codes deleted |
| **SEC-06** | BE + OPS | Verification docs on local disk, unencrypted, no scan; re-submission leaves old files (confirmed) | `storage/file-storage.service.ts`, `lawyers/lawyer-verification.service.ts:~44` | `POST /lawyers/me/verification`, admin doc download · `lawyer_verification_documents` | S3-compatible implementation behind existing `FileStorageService`; delete superseded files; retention after decision. Infra decision **D-8** | Upload/replace/delete e2e; admin download still `attachment` |
| **SEC-07 / AUD-09** | BE + OPS | Throttler and `LoginAttemptsGuard` are in-memory; public lawyers endpoints only under global 120/min/IP (confirmed / AUD-09 is `[RISK]`) | `app.module.ts`, `lawyers.controller.ts`, guard | `GET /lawyers[/:id]` · — | Per-route stricter throttle + short cache for public endpoints (now); Redis storage when going multi-instance | 429 with `Retry-After`; limits survive restart only after Redis |
| **SEC-08** | BE | `main.ts` ~30–45: docs on, CORS `origin:true`+credentials, OTP dev codes logged if not `NODE_ENV=production` (`[RISK]` — safe if deployment sets it) | `backend/src/main.ts`, `config/env.validation.ts` | — | Startup assertion/deployment checklist. Unconfirmed in prod (server config not accessible) | Config unit test: refuses unsafe combination |
| **BIZ-06** | BE | `issueToken` only needs `confirmed`; `deleteMany`+`create` not in a transaction (confirmed) | `consultation-room.service.ts` | `POST …/room/token` · `consultation_room_tokens` | Window check + transaction. Part of **WP-CONS** with BIZ-04 | Outside window → 4xx; concurrent token issue yields one token |
| **BIZ-07** | BE | Verified lawyers edit bio/pricing without re-review (may be intended) | `lawyers.service.ts` `updateMine` | `PATCH /lawyers/me` · `lawyer_profiles` | **Product decision D-9**; do nothing until answered | n/a until decided |
| **AUD-06** | FL | `POST …/room/leave` never called; room only calls `end` (confirmed) | `lib/features/consultation_room/data/datasources/consultation_room_remote_data_source_impl.dart` | `POST /consultations/:id/room/leave` · session/participant events | Do **after BIZ-04** (semantics of leave depend on per-participant model) | Data-source + controller tests; no UI change |
| **AUD-07** | FL | Cold-start deep link to a protected route as guest → popup over blank background (`[RISK]`, not run) | `lib/core/routing/app_router.dart` | — | **Reproduce first.** Fix only if reproduced; changing behaviour but not design | Router test: guest cold-start deep link → home + popup, back stack sane |
| **MISS-01** | BE/DB/FL | Company/team domain has no backend; organizations created at registration then unused | n/a | — · `organizations`, `organization_members`, `organization_invitations` | Out of scope here (roadmap phases 4–8). Interim: FE-01b | — |
| **API-A** | BE tests | Envelope consistency only spot-checked; auth endpoints use their own shapes (`[RISK]`) | `backend/test` | all | Contract test vs OpenAPI (shared with WIRE-01) | New contract spec |
| **ENUM-01** | BE | Register returns 422 `PHONE_/EMAIL_ALREADY_REGISTERED` (account enumeration, low, accepted trade-off, strict-throttled) | `auth.service.ts` | `POST /auth/register` | Leave as is unless you decide otherwise (**D-10**) | — |
| **SEC-RT** | OPS | No runtime security probing was done (IDOR attempts, injection, upload fuzzing); IDOR conclusions are from code reading | — | all | Run after OPS-01 against a staging stack | Findings → new issues |

### P3

| ID | Layer | UI-affecting? | Description (source) | Proposed action |
|---|---|---|---|---|
| **FE-03r** | FL | Yes | `AppPreferences.themeMode` stored but never applied; dark mode not rendered on a device (`[RISK]`) | Verify visually first; wiring a theme switch adds UI → parked |
| **FE-04** | FL | Yes | No bundled typeface (`fontFamily = null`), single line-height for Arabic | Needs font choice; parked |
| **FE-05** | FL | Yes | Single-spinner loading, no skeletons | Parked |
| **FE-06r** | FL | Partly | Only 13 `Semantics` usages; no large-text tests (`[RISK]`) | Non-visual parts (semantics labels, text-scale tests) can proceed; any visual change parked |
| **FE-07** | FL | Yes | Weak tablet/large-screen layout, ~3 `maxWidth` constraints | Parked |
| **FE-08** | OPS | No | Root PNG screenshots, boilerplate README, placeholder `pubspec` name/description | Safe cleanup, but includes deleting/renaming → **needs your explicit OK** (you said no deletions) |
| **FE-10** | OPS | No | Noisy generated-plugin edits in working tree | Review `git diff`; don't hand-edit |
| **FMT-01** | OPS | No | `dart format` side effect (FULL audit §H): formatting-only changes in files with your uncommitted edits | Review `git diff` before any commit; do **not** commit mixed formatting with feature work |
| **DB-04** | DB/BE | No | `scheduledAt` duplicates slot `startAt`; reschedule updates both | Add a test that enforces it; no schema change |
| **DB-05** | DB | No | `User.twoFactorEnabled` unused; `User.phone` nullable for legacy | Fold into DB-03 migration if desired |
| **SEC-10** | BE | No | Suspended accounts work until access token expiry (latent; no suspend endpoint) | Do when suspend/role-change endpoints are built |
| **PERF-02/03** | BE/DB | No | Several DB reads per request; lawyer-name search unindexed | Measure first (no measurements exist); trigram index only if needed. Possible index `consultations(lawyer_profile_id, scheduled_at)` after measuring |
| **PERF-04** | BE | No | `bcryptjs` blocks event loop ~250 ms per login (`[RISK]`) | Measure; revisit at volume |
| **QUAL-01** | FL/BE | Partly | `ConsultationsService` oversized (split Availability/Reviews); near-duplicate voice/video call screens; stricter lints; 56 outdated packages | Refactors, behaviour-preserving; do **after** WP-CONS tests exist; screen merge is UI-adjacent → parked |
| **QA-01** | OPS | — | No screen rendered on device (light/dark/RTL/tablet); dialogs/bottom sheets individually unreviewed | Manual device pass after P0/P1 |
| **AUD-08** | Docs | No | Old audit counts wrong | Superseded; no work |
| **DATA-01** | FL/BE | No | lawyer_earnings is computed from consultations, not payments (by design until billing) | No change; note only |

---

## 5. Suggested execution order

| Phase | Items | Why this order |
|---|---|---|
| **A. Unblock verification** | OPS-01, REL-01, TST-02 (+ CI skeleton), WIRE-01 (read-only) | Everything else needs a real DB and a known contract |
| **B. Safe, small, independent** | FE-02, BIZ-03, SEC-05, SEC-04, FE-01b | Low risk, each with a clear test; FE-01b removes the biggest trust risk |
| **C. Consultation rules (WP-CONS)** | BIZ-02, PERF-01, BIZ-01 (after D-4), BIZ-06 | Same service/same specs |
| **D. Data lifecycle** | DB-03 (after D-3), DB-02 (after D-8), DB-05 | Schema decisions before more data accumulates |
| **E. Rooms and contracts** | BIZ-04 (D-5) → AUD-06; BIZ-05 (D-6) | Larger, need decisions |
| **F. Features/UI needing approval** | AUD-05 (D-1), SEC-03 (D-7), parked P3 UI items | Gated on you |
| **G. Hardening/infra** | SEC-06, SEC-07/AUD-09, SEC-08, SEC-RT, QA-01, QUAL-01 | After a stable base |

Each item: write the failing test → fix → run Regression suite → (BE/DB) run e2e against Postgres → update this file's status column and the audit.

---

## 6. Decisions needed from you

| # | Decision | Blocks |
|---|---|---|
| D-1 | Build the reviews UI now or defer? | AUD-05 |
| D-2 | Consultation chat in release: hide, or label "coming soon"? | FE-01b |
| D-3 | Legal retention policy for signed contracts on account deletion | DB-03 |
| D-4 | Who may complete/miss/fail a consultation (lawyer only? auto-miss?) | BIZ-01 |
| D-5 | BIZ-04: state model only now, media later? | BIZ-04, AUD-06 |
| D-6 | Legal meaning of "signed"; counter-party signing now or later | BIZ-05 |
| D-7 | Approve adding a password field to edit_profile when email changes (UI change) | SEC-03 |
| D-8 | Infra: scheduler, object storage, Redis | DB-02, SEC-06, SEC-07 |
| D-9 | Should verified lawyers need re-review after edits? | BIZ-07 |
| D-10 | Keep 422 on duplicate registration (accept enumeration)? | ENUM-01 |
| D-11 | OK to delete/rename repo-root screenshots and fix README/pubspec? | FE-08 |

---

## 7. Working features — do not modify unless an item above says so

Verified only by code reading and the 609 Flutter / 100 backend unit tests (nothing was run on a device or DB):

- **Auth:** splash, login, register, forgot password, OTP, reset, verify phone, sessions list/revoke, password change (15 routes).
- **Lawyers/availability:** lawyers_list, lawyer_details (public), lawyer_profile_edit, verification upload, schedule add/delete.
- **Consultations:** booking (type/datetime/details), list/details, accept/decline/cancel/reschedule — touched only by BIZ-02/PERF-01 validation, not restructured.
- **Contracts:** list/type selection/form/preview/details, generate, sign — touched only by BIZ-05.
- **Gov procedures, notifications, security_privacy, lawyer_dashboard, clients, earnings.**
- **Guest-first routing and client home** (AUD-01…04 fixes) — only AUD-07 may touch the router, and only if reproduced.
- **Security controls the audit rated sound:** IDOR/ownership scoping, bcrypt + burn, hashed rotating refresh tokens, OTP controls, upload magic-byte checks, DTO whitelisting. Preserve in every backend change.
- **Existing theme foundation, localisation (ARB), RTL-safe layout, reusable widgets.**
- **Partially working, change only as listed:** consultation_waiting / voice_call / video_call (state only, no media), account ("coming soon" rows), company_home (mixed).

Rules for any change: add ARB keys to both `app_ar.arb` and `app_en.arb`; keep the `{data, meta}` envelope; contract changes must update the Flutter model in the same change; migrations are additive and forward-only.

---

## 8. Issue count

P0: 4 (REL-01, OPS-01, DB-03, FE-01b) · P1: 12 (BIZ-01…05, FE-02, SEC-03, SEC-04, SEC-05, AUD-05, WIRE-01, TST-01/02) · P2: 13 · P3: 17. Duplicates merged: 9 clusters (§2). Parked pending approval: UI-affecting items and decisions D-1…D-11 (§6).
