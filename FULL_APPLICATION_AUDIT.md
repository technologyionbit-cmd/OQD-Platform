# Aqd (OQD-Platform) — Full Application Audit

Audit date: 2026-11-17 · Branch `main` · Builds on `COMPLETE_APPLICATION_AUDIT.md` (2026-11-12). That report's findings are not repeated here; this one re-verifies the numbers, traces every frontend call to its backend route, and records what changed today.

**Evidence labels:** **[RUN]** executed and output seen · **[CODE]** read in source, not executed · **[BLOCKED]** could not be performed here · **[NOT TESTED]** not done in this audit.

---

## A. Executive Summary

**Status: the real features are wired end to end in code; a third of the screens run on mock or local-only data; one integration bug (guest browsing vs. a protected API) was found and fixed during this audit.**

| Metric | Value |
|---|---|
| Screens (`*_screen.dart`) | **50** |
| Backend routes | **64** (the 2026-11-12 report said 49 — it undercounted) |
| Routes the Flutter app calls | **55** |
| Routes the app never calls | **9** (see C) |
| App calls with no matching backend route | **0** |
| Prisma models / enums | **24 / 19** (the earlier report said 28 models) |
| Migrations | 13 (not applied or run here) |
| Screens working against real backend data (traced in code) | **32** |
| Screens partially working | **5** |
| Screens on mock / static / local-only data | **13** |
| Screens broken at audit start | **1 flow** (guest browsing lawyers → 401), fixed |

### Check results [RUN]

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `flutter test` | **609 passed, 0 failed** (27 failures at the start of this session were traced to the guest-first change and fixed, see E) |
| Backend `tsc --noEmit` | exit 0 (also after today's controller change) |
| Backend `eslint` on the changed controller | exit 0 |
| Backend `jest` (unit) | 13 suites, **100 passed** |
| Backend e2e (6 specs) | **[BLOCKED]** — no PostgreSQL, `psql` or Docker on this machine |
| Anything touching a real database | **[BLOCKED]** — see D and G |

---

## B. Page-by-page audit

"API" = the screen's data comes through a remote data source that calls the backend. "DB" = that backend route reads/writes PostgreSQL through Prisma (read in code; **not executed**, see G). Status is from code tracing and tests; **no screen was rendered on a device in this audit**.

| Screen | API | DB | CRUD | Status | Issues |
|---|---|---|---|---|---|
| splash | ✅ `GET /auth/me`, `POST /auth/refresh` | ✅ | R | Working | — |
| onboarding | — (local flag) | — | — | Static by design | — |
| login | ✅ `POST /auth/login` | ✅ | C (session) | Working | — |
| register | ✅ `POST /auth/register` | ✅ | C | Working | Account enumeration via 422 (earlier audit) |
| forgot_password | ✅ `POST /auth/password/forgot` | ✅ | C | Working | — |
| otp_verification | ✅ `…/verify-otp` | ✅ | — | Working | — |
| reset_password | ✅ `…/reset` | ✅ | U | Working | — |
| verify_phone | ✅ `/auth/phone/verify`, `/resend` | ✅ | U | Working | — |
| client_home | ✅ lawyers, contracts, notifications | ✅ | R | Working | Guest variant added today (AUD-01/02) |
| lawyers_list | ✅ `GET /lawyers` | ✅ | R | Working | Was 401 for guests (AUD-01, fixed) |
| lawyer_details | ✅ `GET /lawyers/:id` | ✅ | R | Working | Was 401 for guests (AUD-01, fixed); no reviews shown (AUD-05) |
| lawyer_profile_edit | ✅ `GET/PATCH /lawyers/me`, `POST …/verification` | ✅ | R/U | Working | — |
| booking_type / booking_datetime / booking_details | ✅ availability + `POST /consultations` | ✅ | C | Working | No past-time validation server-side (BIZ-02) |
| consultations_list / consultation_details | ✅ | ✅ | R | Working | Unpaginated (PERF-01) |
| lawyer_requests | ✅ accept / decline | ✅ | U | Working | — |
| lawyer_schedule | ✅ availability add/delete | ✅ | C/D | Working | Past/overlapping slots accepted (BIZ-02) |
| consultation_waiting | ✅ room token/join/connect | ✅ | U | **Partial** | Room *state* is real; no media |
| voice_call / video_call | ✅ room end/metrics/retry | ✅ | U | **Partial** | No real audio/video (roadmap 6.1) |
| contracts_list / type_selection / form / preview / details | ✅ | ✅ | C R U D + generate + sign | Working | Contract can get stuck after generate (BIZ-05) |
| gov_documents_hub / gov_procedure_detail | ✅ `GET/PATCH /gov-procedures…` | ✅ | R/U | Working | — |
| notifications | ✅ list, read, read-all, delete | ✅ | R/U/D | Working | — |
| account | ✅ `/auth/me` | ✅ | R | **Partial** | Several rows are "coming soon" (labelled) |
| edit_profile | ✅ `PATCH /auth/me` | ✅ | U | Working | Email change needs no password (SEC-03) |
| security_privacy | ✅ sessions list/revoke, password change | ✅ | R/D | Working | — |
| lawyer_dashboard | ✅ profile, consultations, notifications | ✅ | R | Working | — |
| lawyer_clients / lawyer_client_details / lawyer_earnings | derived from `GET /consultations` | ✅ | R | Working | "Earnings" are computed from consultations, not payments |
| company_home | mixed | partial | R | **Partial** | Mixes real auth/consultations/contracts with mock team/documents |
| ai_chat / ai_analysis_select / ai_analysis_result | ❌ mock | ❌ | — | **Mock** | Hidden in release (preview flag) |
| documents | ❌ mock | ❌ | — | **Mock** | Hidden in release |
| chat_room | ❌ mock, local only | ❌ | — | **Mock** | Messages never reach the other party |
| team_list / team_member_details | ❌ mock | ❌ | — | **Mock** | No backend module |
| subscription_plans / invoices / payment_methods | ❌ local in-memory state | ❌ | — | **Mock** | No billing backend |
| saved_signature | ❌ local in-memory state | ❌ | — | **Mock** | Lost on restart |
| help_support | ❌ static FAQ | — | — | Static | "Contact support" is a mock action |

**Not inspected individually:** dialogs, bottom sheets and secondary tabs inside the screens above. Reading each one's handlers was not done; coverage there is whatever the 609 widget tests exercise. **[NOT TESTED]**

---

## C. API audit

Method and path were compared on both sides by reading the Dart data sources and the Nest controllers. **Request and response bodies were not compared field by field** (see G).

### Routes the app calls (55) — all exist in the backend [CODE]

| Area | Endpoints (frontend usage → backend exists) | DB | Status |
|---|---|---|---|
| Auth (15) | `POST register, login, refresh, logout, phone/verify, phone/resend, password/forgot, verify-otp, reset, change`; `GET/PATCH me`; `GET sessions`; `DELETE sessions/:id`, `DELETE sessions` | ✅ | Working |
| Lawyers (5) | `GET /lawyers`, `GET /lawyers/:id`, `GET/PATCH /lawyers/me`, `POST /lawyers/me/verification` | ✅ | Working; first two now public |
| Availability (3) | `GET /lawyers/:id/availability`, `POST/DELETE /lawyers/me/availability[/:slotId]` | ✅ | Working |
| Consultations (10) | `POST/GET /consultations`, `GET :id`, `POST :id/accept, decline, cancel, reschedule, complete, miss, fail` | ✅ | Working |
| Room (7) | `POST …/room/token, join, connect, retry, connection-lost, end`; `PATCH …/room/metrics` | ✅ | Working (state only) |
| Contracts (8) | `GET /contract-templates`; `GET/POST /contracts`; `GET/PATCH/DELETE :id`; `POST :id/generate, sign` | ✅ | Working |
| Gov procedures (3) | `GET /gov-procedures`, `GET :id/progress`, `PATCH :id/progress` | ✅ | Working |
| Notifications (4) | `GET`, `POST :id/read`, `POST read-all`, `DELETE :id` | ✅ | Working |

### Routes the app never calls (9) [CODE]

| Endpoint | Why it matters |
|---|---|
| `POST /consultations/:id/reviews` | **No review UI exists in the app** — the backend can store reviews, nothing can create one (AUD-05) |
| `GET /lawyers/:id/reviews` | Same — ratings are shown, the reviews behind them are not |
| `POST /consultations/:id/room/leave` | Room has an "end" but never calls "leave" (AUD-06) |
| `GET /gov-procedures/:id` | Detail is built from the list + progress calls; harmless |
| `GET /admin/lawyer-verifications`, `…/:id/documents/:docId`, `POST …/approve`, `…/reject` | No admin UI in the app, by design; verification can only be approved through the API directly |
| `GET /health` | Infrastructure probe |

### Mock APIs / static data
Five data sources are wired to in-memory mocks: AI, documents, messages, team (`*_data_source_provider.dart`), plus billing/saved-signature as local notifier state. Nothing is hard-coded to look like server data in the *real* feature paths.

---

## D. Database audit

Schema read from `backend/prisma/schema.prisma` (771 lines) and the migration list. **Nothing was executed against a database [BLOCKED].**

- **Tables (24):** users, lawyer_registration_details, refresh_tokens, verification_codes, organizations, organization_members, organization_invitations, gov_procedures, gov_required_documents, gov_procedure_steps, user_gov_procedure_progress, lawyer_profiles, lawyer_profile_specialties, lawyer_consultation_offerings, lawyer_verification_documents, reviews, availability_slots, consultations, consultation_room_sessions, consultation_room_tokens, consultation_participant_events, contracts, contract_signatures, notifications.
- **Public data exposure (new, checked today):** the lawyer view returned by the now-public endpoints contains only `id, fullName, specialties, bio, yearsOfExperience, rating, reviewsCount, consultationTypes, pricing, verificationStatus`. No user id, phone, email or bar-licence number. Only `verified` lawyers are returned. [CODE]
- Missing index, retention, cascade and constraint findings (DB-01…DB-05) are unchanged from the earlier report; DB-01 has a migration written but **not applied**.
- **Create/Update/Delete correctness, JOIN results, pagination, filtering, transactions, NULL handling:** read in code only. **[NOT TESTED]** against real rows.

---

## E. Bugs & issues found or confirmed in this audit

| ID | Area | File | Problem / root cause | Severity | Status |
|---|---|---|---|---|---|
| **AUD-01** | Guest browsing | `backend/src/lawyers/lawyers.controller.ts` | The whole controller had `@UseGuards(JwtAuthGuard)`, so a signed-out visitor opening the lawyers list or a profile got 401 → an error screen. The product requirement is that visitors can browse and only services require an account. | **High** | **Fixed.** `GET /lawyers` and `GET /lawyers/:id` are public; the guard now sits on `me`, `me/verification`, `:id/reviews` individually. tsc + eslint + 100 unit tests pass. **No e2e covers it [BLOCKED]** |
| **AUD-02** | Routing | `lib/core/routing/app_router.dart` | After logout on a signed-in-only screen, the redirect treated the user as a guest on a protected path and would show the "sign in required" popup over an empty screen. | Medium | **Fixed.** A just-signed-out flag sends the user to the public home. Covered by `app_shell_ui_test` |
| **AUD-03** | UI | `lib/features/home/.../client_home_screen.dart` | The redesigned service cards overflowed by 21 px (28 responsive tests failed) because the grid used a fixed aspect ratio. | Medium | **Fixed.** Fixed-extent grid. 112 responsive tests pass |
| **AUD-04** | Tests | `test/app/*`, `test/widget_test.dart`, onboarding, login, register, password-reset tests | 27+ tests encoded "signed out ⇒ login screen". | Medium | **Fixed.** Updated to the guest-first behaviour; added guest tests (lands on home, can browse lawyers, services show the popup, other-role route blocked). Shared helper `test/support/open_login.dart` |
| **AUD-05** | Missing integration | frontend (no review feature) | Backend review create/list endpoints exist; the app has no UI to leave or read reviews, so `rating`/`reviewsCount` on lawyers can never change from the app. | Medium | **Open** — product decision needed |
| **AUD-06** | Missing integration | `consultation_room_remote_data_source_impl.dart` | `POST …/room/leave` is never called. | Low | Open |
| **AUD-07** | Routing | `app_router.dart` | A cold-start deep link to a protected route as a guest replaces the stack, so the popup appears over a blank background. | Low | Open **[RISK, not run]** |
| **AUD-08** | Docs | `COMPLETE_APPLICATION_AUDIT.md` §2.5–2.6 | Route count (49) and model count (28) are wrong; actual 64 and 24. | Low | Open (this report supersedes it) |
| **AUD-09** | Abuse | `lawyers.controller.ts` | Public marketplace endpoints are protected only by the global 120 req/min/IP throttle; there is no stricter limit or caching. | Low | Open **[RISK]** |

Earlier open items (BIZ-01…BIZ-07, SEC-03…SEC-08, DB-02/03, PERF-01…03, TST-01, FE-02…FE-07) are unchanged and tracked in `COMPLETE_APPLICATION_AUDIT.md`. Fixed there: SEC-01, SEC-02, SEC-09, DB-01 (migration not applied), CFG-01, FE-01 (Appendix C).

---

## F. Missing integrations

- AI chat and contract analysis — mock only (hidden in release).
- Documents vault, saved signature — no backend.
- Consultation chat — local only, never delivered to the other party.
- Real voice/video media — room state only.
- Team / company management — no backend module (organizations are created at registration and then unused).
- Billing: plans, invoices, payment methods — local state only.
- Reviews — backend only (AUD-05).
- Admin console — API only, no UI.
- Push notifications, account deletion, phone change, help-desk — not built.

---

## G. Testing results

| | Count |
|---|---|
| Flutter tests executed / passed / failed | 609 / 609 / 0 (final run; one earlier run had 58 failures, all explained and fixed) |
| Backend unit tests executed / passed | 100 / 100 |
| Static checks passed | `flutter analyze`, `tsc`, `eslint` (changed file) |
| **Blocked** | Backend e2e (6 specs), every real-database check, `prisma migrate`, running the API, calling any endpoint |
| **Not tested** | Rendering on a device or emulator (light/dark/RTL/tablet); every dialog and bottom sheet individually; request/response **field-by-field model comparison** between Dart models and Nest DTOs/Prisma columns; date/timezone and decimal handling across the wire; runtime security probing (IDOR attempts, injection, upload fuzzing); performance, memory and slow-query measurements; the 13 migrations |

**Evidence for the one failure class found today:** before the fixes the full run reported `Some tests failed` with 28 failures in `app_shell_responsive_test` (RenderFlex overflow 21 px at `client_home_screen.dart`), 27 in login/register/password-reset (they expected the login screen and found the guest home, hence `find.byType(TextField).at(1)` range errors), and 3 router/shell/widget tests. After the fixes the full run ends `All tests passed!` with 609 tests.

**Security/IDOR statements** in this report (authorization on every route, ownership scoping) come from the earlier audit's reading of the controllers and from today's read of `lawyers.controller.ts`; they were **not** re-verified at runtime.

---

## H. Fix log (this session)

| Change | Files | Verified |
|---|---|---|
| Guest-first routing: splash/onboarding → client home; only Home, Lawyers and a lawyer profile are open to guests; other routes show a "sign in required" popup and return to the target after login | `app_router.dart`, `route_paths.dart`, `auth_routes.dart`, `client_routes.dart`, `app_shell.dart`, `login_required_dialog.dart`, ARB files | analyze, 609 tests |
| Tabs AI / Documents / Account ask guests to sign in instead of navigating | `client_routes.dart`, `app_shell.dart` | tests |
| Guest never fetches contracts; sees a sign-in card instead of "recent activity" | `client_home_screen.dart` | tests |
| Client home visual refresh; fixed-height service cards | `client_home_screen.dart` | analyze, responsive tests |
| Public `GET /lawyers`, `GET /lawyers/:id` | `lawyers.controller.ts` | tsc, eslint, 100 unit tests; **e2e blocked** |
| Updated and added tests for guest behaviour | `test/app/*`, `test/widget_test.dart`, onboarding/auth tests, `test/support/open_login.dart` | 609 pass |

**Side effect to review:** `dart format` was run over `lib/core` mid-session and changed the formatting of many files. Files that had no other changes were restored from git. Files that already had your uncommitted edits (theme, `app_button`, `app_text_field`, localization, `bootstrap`, `app_config`) keep some formatting-only changes, and a few untracked new files in `lib/core` were reformatted too. Review `git diff` before committing.

## I. Recommended next steps (priority order)

1. Run the backend e2e suite against a Postgres instance and add an e2e case for the public `GET /lawyers[/:id]` and for 401 on `/lawyers/me`.
2. Compare Dart wire models with the Nest DTOs/Prisma view field by field (the one major check this audit could not do).
3. Decide on reviews (AUD-05); wire `POST /consultations/:id/reviews` and `GET /lawyers/:id/reviews`.
4. Apply the DB-01 migration; then BIZ-01/02/03/05 and SEC-03/04 from the earlier report.
5. Render the key screens on a device in RTL, dark mode and tablet width.
6. Replace the remaining mock features as the roadmap delivers their backends.
