# Aqd (عقد / OQD-Platform) — Complete Application Audit

Audit date: 2026-11-12 · Branch `main` @ `0abfb50` · Scope: Flutter app (`lib/`, `test/`, platform folders), NestJS backend (`backend/`), Prisma schema and migrations, docs.

**Evidence labels used throughout**

| Label | Meaning |
|---|---|
| **[RUN]** | Verified by executing a tool in this audit (output seen). |
| **[CODE]** | Verified by reading the exact code; behavior not executed. |
| **[RISK]** | Plausible risk or recommendation; not proven in this environment. |

No application code was changed. The only side effects of the audit are two new files (this report and `FRONTEND_DESIGN_RECOMMENDATIONS.md`) and an untracked, git-ignored `backend/node_modules/` plus generated Prisma client created by running the backend checks.

---

## 1. Executive Summary

Aqd is a bilingual (Arabic/English, RTL-aware) legal-tech platform for Jordan: individual clients book consultations with verified lawyers, draft and sign contracts from templates, follow government-procedure checklists, and (planned) chat, call, use AI analysis and pay. A Flutter app talks to a NestJS + Prisma + PostgreSQL API.

**Overall condition: a well-engineered foundation for the parts that are real, but not launch-ready.** The real parts (auth, lawyers marketplace, booking, consultation room state, contracts, gov procedures, notifications, lawyer verification) are built with unusual discipline: server-side authorization on every route, ownership-scoped queries, conditional-update concurrency control, hashed tokens and OTPs, magic-byte upload validation, no raw SQL, and a clean design-token system. The blockers are about **what ships around them**.

### Verified results

| Check | Result |
|---|---|
| `flutter analyze` | **No issues found** [RUN] |
| `flutter test` | **599 passed, 0 failed** (69 test files) [RUN] |
| Backend `eslint` | exit 0 [RUN] |
| Backend `tsc --noEmit` | exit 0 [RUN] |
| Backend `jest` (unit) | **13 suites / 100 tests passed** [RUN] |
| Backend e2e (6 specs) | **Not run** — need a PostgreSQL instance not available here |
| `npm audit --omit=dev` | **7 vulnerabilities (4 high, 3 moderate)** [RUN] |
| Coverage percentages, runtime latency, bundle size | **Not measured** — no figures are claimed |

### The five things that matter most

1. **SEC-01 (Critical)** — Android release builds are signed with the debug key.
2. **FE-01 (Critical)** — Mock-backed features are shown to real users as real: the AI tab, the Documents tab, and a live-consultation chat that fabricates lawyer replies. For a legal product, canned "AI contract analysis" presented as real is the single biggest trust and liability risk.
3. **BIZ-01 (High)** — Either party can mark a confirmed consultation completed/missed/failed at any time, with no time or call evidence. Harmless today; a fraud vector the day payments land.
4. **DB-01 (High)** — `refresh_tokens.refresh_token_hash` has no index, so every token refresh is a table scan on a table that is never purged.
5. **CFG-01 (High)** — Default (including debug) app builds point at the **production** API `https://oqdjo.com/v1`.

### Issue counts by severity

| Severity | Count |
|---|---|
| Critical | 2 |
| High | 6 |
| Medium | 20 |
| Low | 10 |
| **Total** | **38** |

By area: Security 10 (SEC) · Business logic 7 (BIZ) · Database 5 (DB) · Performance 3 (PERF) · Frontend/UX 10 (FE) · Config, testing, missing features 3 (CFG-01, TST-01, MISS-01).

---

## 2. Project Architecture Overview

### 2.1 Stack

| Layer | Technology |
|---|---|
| Mobile/web client | Flutter (Dart SDK ^3.7.2), Material 3, `flutter_riverpod` 3, `go_router` 17, `dio` 5, `freezed`/`json_serializable`, `flutter_secure_storage`, `shared_preferences`, `intl` + ARB (ar, en), `image_picker`, `file_picker`, `url_launcher` |
| API | NestJS 11 (Express), `class-validator` + global `ValidationPipe` (whitelist, forbidNonWhitelisted), `@nestjs/throttler` (in-memory), `helmet`, `@nestjs/swagger`, `@nestjs/terminus` health, `joi` env validation, `bcryptjs`, `@nestjs/jwt` |
| Data | PostgreSQL via Prisma 6 (11 migrations; uses `citext`, `btree_gist` exclusion constraint, CHECK constraint) |
| External | NGT SMSPRO (OTP delivery by SMS). Nothing else is integrated. |
| Storage | Local disk (`UPLOADS_DIR`), private, served only via admin-checked API |
| Size | ~24.5k lines of hand-written Dart in `lib/`; ~4.5k lines of backend TS; 665 tracked files |

### 2.2 Frontend architecture [CODE]

Feature-first clean architecture: `lib/features/<feature>/{data,domain,presentation}` plus `lib/core/{app,config,errors,localization,network,providers,routing,security,storage,theme,utils,widgets}`.

- **DI/state:** Riverpod providers. Each feature has exactly one `*_data_source_provider.dart` that decides mock vs remote. Repositories return a typed `Result`/`Failure`.
- **Routing:** single `GoRouter` with one `_redirect` as the only auth + role gate (`app_router.dart`). Three role shells (client, lawyer, company) with bottom bar, switching to `NavigationRail` ≥ 700 px.
- **Networking:** one `Dio`; `AuthInterceptor` adds the bearer token, coalesces concurrent 401s into one refresh, retries once, and distinguishes "refresh rejected" (sign out) from "refresh unreachable" (connectivity error). Redacting logger only outside release.
- **Security of client storage:** tokens in Keychain/Keystore, `first_unlock_this_device`, fresh-install guard clears leftover iOS Keychain, Android `allowBackup=false`, HTTPS-only network security config in release.

### 2.3 Backend architecture [CODE]

Modules: `auth`, `lawyers` (+ verification), `consultations` (+ availability), `consultation-room`, `contracts`, `gov-procedures`, `notifications`, `admin`, `health`, `storage`, `prisma`, `config`, `common` (error envelope, filter, interceptor, OpenAPI).

Global: prefix `/v1`, `ThrottlerGuard` (120 req/min/IP, stricter on auth), `HttpExceptionFilter` (uniform error envelope with machine-readable `code`), `LoggingInterceptor` (request id; never logs bodies). Guards: `JwtAuthGuard` (checks the session row, so logout-everywhere is immediate), `AdminGuard` (role re-read from DB), `PhoneVerifiedGuard`, `LoginAttemptsGuard` (per-phone brute-force limit independent of IP).

### 2.4 Roles and authorization model

Roles: `client`, `lawyer`, `company`, `admin` (DB enum). Authorization is enforced in services, not just routes: ownership-scoped queries (contracts return 404 for others' records), participant checks (consultations, rooms), role checks (booking = client only; lawyer profile = lawyer only), admin guard for verification review.

### 2.5 API surface (49 routes) [CODE]

| Area | Endpoints |
|---|---|
| Auth | `POST register, login, refresh, logout, phone/verify, phone/resend, password/forgot, password/verify-otp, password/reset, password/change` · `GET/PATCH me` · `GET/DELETE sessions[/:id]` |
| Lawyers | `GET /lawyers`, `GET/PATCH /lawyers/me`, `POST /lawyers/me/verification` (multipart), `GET /lawyers/:id`, `GET /lawyers/:id/reviews` |
| Availability | `GET /lawyers/:id/availability`, `POST/DELETE /lawyers/me/availability[/:slotId]` |
| Consultations | `POST/GET /consultations`, `GET :id`, `POST :id/{accept,decline,cancel,reschedule,complete,miss,fail,reviews}` |
| Room | `POST /consultations/:id/room/{token,join,connect,retry,connection-lost,leave,end}`, `PATCH …/metrics` |
| Contracts | `GET /contract-templates`, `GET/POST /contracts`, `GET/PATCH/DELETE :id`, `POST :id/{generate,sign}` |
| Gov | `GET /gov-procedures[/:id[/progress]]`, `PATCH :id/progress` |
| Notifications | `GET`, `POST read-all`, `POST :id/read`, `DELETE :id` |
| Admin | `GET /admin/lawyer-verifications`, `GET …/:id/documents/:docId`, `POST …/:id/{approve,reject}` |
| Health | `GET /health` |

### 2.6 Database [CODE]

28 models: users, refresh tokens, verification codes, organizations (+members, invitations), gov procedures (+docs, steps, progress), lawyer profiles (+specialties, offerings, verification docs), reviews, availability slots, consultations, room sessions/tokens/events, contracts, contract signatures, notifications.

### 2.7 What is real vs mock (from code and `docs/plans/roadmap.md`)

| Real (remote data source) | Mock (in-memory fake data) |
|---|---|
| Auth, lawyers, consultations & booking, consultation-room **state**, contracts, gov procedures, notifications, lawyer verification | **AI** chat + analysis, **documents**, **messages/chat**, **team**, **billing** (plans, invoices, payment methods), company home, saved signature |

---

## 3. Frontend Audit

### What works well [RUN]/[CODE]
- 599 widget/unit tests pass; analyzer is clean.
- **Zero** hard-coded `Color(0x…)` outside `core/theme`; spacing/radii tokens used consistently.
- RTL-safe: **no** `Alignment.centerLeft`, `EdgeInsets.only(left/right)`, `Positioned(left/right)` or `TextAlign.left` anywhere in `lib/`.
- Reusable widget set (`AppButton`, `AppTextField`, `AppCard`, `EmptyState`, `ErrorView`, `ConfirmationDialog`, `AppBottomSheet`, `StepIndicator`, `StatusBadge`).
- Localization is generated from ARB; hard-coded user-visible strings are essentially absent.
- Single role/auth gate in the router; role is explicitly documented as UX-only, not authorization.

### Issues

**FE-01 · Critical · Mock features presented to real users as real** [CODE]
- Where: `lib/core/routing/routes/client_routes.dart:43,45` (AI and Documents are primary bottom-nav tabs); `lib/features/ai/data/datasources/ai_data_source_provider.dart:10` (`AiMockDataSource()`); `.../documents/.../documents_data_source_provider.dart:8`; `.../messages/.../messages_data_source_provider.dart:9`; `.../team/.../team_data_source_provider.dart:6`; `lib/features/messages/presentation/screens/chat_room_screen.dart:217,303` (`_scheduleMockLawyerReply` fires when a client sends a message).
- Problem: a release build gives users an AI tab that returns canned analyses, a Documents vault that stores nothing, and a consultation chat where the "lawyer" auto-replies with scripted text. Only the Account screen tags mock rows "coming soon". No `kReleaseMode` guard, no "preview" labelling on the tabs.
- Why it matters: legal advice-adjacent output and fake counter-party messages are a trust, consumer-protection and liability problem; app-store reviewers also treat fake functionality as a rejection reason.
- Fix: until each backend exists, hide the entry points in release (feature flag), or show a clear "coming soon" state; delete the auto-reply from the production path. Roadmap steps 4.2, 5.1, 6.2 are the real fixes.
- Effort: S (hide/flag, 1–2 days) · real implementations are the roadmap's L items.
- Risk: removing tabs changes navigation/tests (`client_routes`, shell tests).

**FE-02 · Medium · Admin role cannot be parsed by the app** [CODE]
- `lib/features/auth/domain/entities/user_role.dart:12` uses `UserRole.values.byName(...)`; the enum has no `admin`, the backend enum does. An admin logging in throws `ArgumentError` inside auth wiring (`auth_wire.dart:57`).
- Fix: either explicitly reject non-app roles with a localized "use the admin console" message, or add an admin shell. Effort S. Risk: none.

**FE-03 · Medium · Dark theme incomplete; saved theme preference never applied** [CODE]
- `app_theme.dart:73,102,105` hard-code the *light* `AppColors.border` into card/input borders for both themes; disabled button color and nav-bar unselected color are light-theme constants too. `AppPreferences.themeMode` (`app_preferences.dart:24`) is stored but `app.dart` never sets `themeMode`, so the UI simply follows the OS and there is no switch.
- Effect (potential, screens not rendered in dark mode here **[RISK]**): low-contrast borders/labels in dark mode.
- Fix: derive borders/disabled/nav colors from `ColorScheme`/`AppStatusColors`; wire `themeMode` or remove the dead preference. Effort M.

**FE-04 · Medium · No bundled typeface; Arabic typography depends on device fallback** [CODE]
- `app_typography.dart:4` `fontFamily = null`; one fixed `height: 1.4` for Arabic and Latin. Arabic glyph weights/shapes will differ across Android OEMs, iOS, and web. See design doc for the recommended pairing.
- Effort S–M. Risk: asset size (~300–600 KB).

**FE-05 · Medium · Loading states are a single spinner; no skeletons** [CODE]
- `core/widgets/loading_view.dart`; 0 skeleton/shimmer widgets in the codebase; 7 full-page spinners. Lists (lawyers, consultations, contracts, notifications) jump from spinner to content.
- Effort M. Risk: none.

**FE-06 · Medium · Accessibility gaps** [CODE + computed]
- Only 13 `Semantics(...)` usages across 24k lines; icon-only buttons rely on `tooltip` where present (16 files).
- Computed contrast (WCAG): `textDisabled #A1A7AE` on white ≈ **2.4:1** (used as disabled-button fill, `app_theme.dart:~58`); `secondary #C98A0E` on white ≈ **3.0:1** (fails for text; fine for decorative stars). Primary `#0078C0` with white text ≈ 4.7:1 (passes AA).
- No `TextScaler` clamping or large-text overflow tests (**[RISK]** for the `configChanges … fontScale` manifest flag + fixed-height rows).
- Effort M.

**FE-07 · Medium · Weak large-screen layout** [CODE]
- Breakpoints and `NavigationRail` exist, but only ~3 real `maxWidth` constraints in `lib/`; forms and lists will stretch edge-to-edge on tablets/web. Linux/macOS/Windows/web scaffolds exist though the product is phone-first.
- Effort M.

**FE-09 · Medium · Palette and decoration drift from a restrained, premium direction** [CODE]
- `app_colors.dart` defines `purpleAccent #7C4DFF`, `violet #6A3FBF`, `violetLight`, `cyanAccent`, and 15 gradient usages (home service tiles, headers, earnings, account). Details and the replacement system are in `FRONTEND_DESIGN_RECOMMENDATIONS.md`.
- Effort M. Risk: brand recognition — the navy + blue core is kept.

**FE-08 · Low · Repo hygiene** [CODE]
- Three PNG screenshots (1.4 MB + 90 KB + 116 KB) committed at repo root; at least `screen2.png` is stale (shows an email-based login; the app now signs in by phone).
- Root `README.md` is the Flutter boilerplate and ends with a stray UTF-16-encoded line (`# ion-aqd-app`); `pubspec.yaml` description and package name (`aqd_ionbit`) are placeholders.
- Effort S.

**FE-10 · Low · Generated-file noise** [CODE]
- Working tree has uncommitted edits to Linux/macOS/Windows `generated_plugin*` files; `.freezed.dart` and generated localization files are committed (acceptable, but it makes diffs noisy). Effort S.

### Screens
This audit **did not render screens** (no emulator driven here), so visual findings are limited to code, theme, and the one committed screenshot. The screen-by-screen design review in `FRONTEND_DESIGN_RECOMMENDATIONS.md` is based on code structure and must be validated visually before implementation.

---

## 4. Backend Audit

### What works well [CODE]
- Every controller except `health` and the public auth endpoints is behind `JwtAuthGuard`; **IDOR checks are present at service level** (consultation participant check, contract `ownerUserId` scoping with uniform 404, room participant check, notification `userId` scoping on read/delete, admin role re-read from DB).
- Concurrency control is deliberate: slot claim via conditional `updateMany`, status transitions via `where: {status: <seen>}`, OTP attempts reserved atomically, contract state transitions conditional, DB-level exclusion constraint for overlapping *booked* slots.
- Auth: bcrypt with timing-equalised "burn" for unknown phones, per-phone and per-IP limits, refresh tokens are 48 random bytes stored only as SHA-256, rotation with replay detection that revokes the whole family, password reset revokes all sessions, OTPs hashed + attempt-limited + resend cooldown/hourly cap, uniform 204 for known/unknown numbers.
- Uploads: magic-byte detection (not the client MIME or name), 10 MB × 3 limit, server-generated storage keys validated by regex (no path traversal), `0o600`, `wx` flag, served as `attachment` only to admins.
- No raw SQL anywhere; Prisma parameterises everything. DTOs whitelist + forbid unknown fields; `ParseUUIDPipe` on ids.

### Issues

**SEC-02 · High · Vulnerable production dependencies** [RUN]
- `npm audit --omit=dev`: 7 findings (4 high, 3 moderate): `@nestjs/platform-express` → `multer` (DoS via pending async fileFilter after request teardown — reachable on the authenticated upload route `POST /lawyers/me/verification`), `body-parser` (DoS via trailing bytes after compressed body), `joi` (quadratic `string().email({multiple:true})`), `qs`, `js-yaml` (moderate, via swagger).
- Fix: `npm audit fix` / bump Nest platform packages; re-run unit + e2e. Effort S. Risk: minor-version behaviour changes; run e2e.

**SEC-03 · Medium · Email change needs no re-authentication** [CODE]
- `auth.service.ts:214` `updateProfile` lets any valid access token change `email`. Email is not the login identifier now (phone is), which limits impact, but it is the recovery/notification contact. Roadmap item 1.2 ("email change asks for password") is marked in-progress.
- Fix: require current password (or OTP). Effort S.

**SEC-04 · Medium · Refresh rotation is not atomic; refresh not strictly throttled** [CODE]
- `token.service.ts:57-` reads the token, checks `revokedAt`, then updates in a transaction without a conditional `where: {revokedAt: null}`. Two concurrent refreshes with the same token can both succeed and each mint a child, weakening reuse detection. `POST /auth/refresh` (`auth.controller.ts:117`) has only the global 120/min/IP limit.
- Fix: `updateMany({where:{id, revokedAt:null}})` and require `count===1`; apply a medium throttle. Effort S.

**SEC-05 · Medium · Reviews expose reviewer user IDs; reviews of unverified lawyers are readable** [CODE]
- `lawyers.service.ts:150,175` returns `reviewerUserId` (internal UUID) to every authenticated user, and does not check that the lawyer is verified (the profile endpoint does).
- Fix: drop the id (or return a display name/initial); apply the same verified gate. Effort S. Risk: client model change in `lawyers` feature.

**SEC-06 · Medium · Verification documents: local disk, no cleanup, no retention** [CODE]
- `file-storage.service.ts`, `lawyer-verification.service.ts:44`: files live on the API host's disk (breaks on a second instance), not encrypted at rest, no malware scan, and re-submission after rejection leaves the previous files and rows in place indefinitely. These are ID/licence documents (PII).
- Fix: object storage with server-side encryption, delete superseded files, retention policy after decision. Effort M.

**SEC-07 · Medium · In-memory rate limiting** [CODE]
- `app.module.ts` throttler and `LoginAttemptsGuard` use process memory. Restarts reset counters and multiple instances multiply the limits. `docs/backend/14-security.md` already acknowledges this. Effort M (Redis storage).

**SEC-08 · Medium · Unsafe defaults if `NODE_ENV` is not `production`** [RISK]
- `main.ts:30-45`: API docs on and CORS `origin:true` with `credentials:true` when not production and no origins are configured; OTP dev codes are logged when SMS credentials are absent. Safe if deployment always sets `NODE_ENV=production` (env validation enforces SMS credentials then). Add a startup assertion or a deployment checklist item. Effort S.

**SEC-09 · Low · SMS gateway account name from another project committed** [CODE]
- `backend/.env.example:53` contains a concrete gateway login name and sender id with a comment saying they belong to a different project. No password is committed (value empty). Replace with placeholders and rotate if it is a live account. Effort S.

**SEC-10 · Low · Suspended accounts keep working until the access token expires** [CODE]
- `jwt-auth.guard.ts:19` checks session liveness but not `User.status`; `role` is read from the JWT claim (≤ 15 min stale). There is no suspend/role-change endpoint today, so this is latent. Effort S when those endpoints appear.

### Business logic

**BIZ-01 · High · Consultation outcome can be set by either side at any time** [CODE]
- `consultations.service.ts:198,208,214` `complete`/`markMissed`/`markFailed` only require "participant" and status `confirmed`. No check that the scheduled time has passed, that a room session was active, or who may declare what. A client can complete an accepted booking instantly (unlocking a review), or either party can mark the other "missed".
- Why: when payments/payouts (roadmap phase 7) attach to `completed`, this is a direct fraud/dispute vector; today it already lets reviews be farmed.
- Fix: gate by time window and room-session evidence (or lawyer-only completion + auto-miss job); server-side. Effort M. Risk: needs product decision on who decides outcomes.

**BIZ-02 · Medium · No time validation on slots and bookings** [CODE]
- `addAvailabilitySlot` (`:55`) only checks `start < end` — past, overlapping, and multi-day slots are accepted (the DB exclusion constraint covers only *booked* overlaps). `book` (`:83`) finds the slot by `startAt` and never checks it is in the future. `reschedule` has the same gap.
- Fix: reject past starts, cap duration, reject overlaps with the lawyer's other slots. Effort S.

**BIZ-03 · Medium · Concurrent duplicate review returns 500** [CODE]
- `createReview` (`:262`) does check-then-insert; the unique index `(consultationId, reviewerUserId)` catches the race but `HttpExceptionFilter` has no Prisma `P2002` handling (grep confirms), so the loser gets a 500. Fix: catch `P2002` → 409. Effort S.

**BIZ-04 · Medium · Consultation room cannot support two participants as written** [CODE]
- `consultation-room.service.ts:18,63`: `join` is allowed only from state `waiting`; after the first participant joins the shared session becomes `ready`, so the second participant's `join` returns 400. Mute/camera flags are per session, not per participant. The service header says real media is not implemented yet, so this is a design gap that blocks roadmap 6.1 rather than a regression.
- Fix: model per-participant presence; derive session state from both. Effort M–L.

**BIZ-05 · Medium · Contract can get stuck in `pendingSignature`** [CODE]
- `contracts.service.ts`: `update` and `remove` only act on `draft`; `generate` moves to `pendingSignature` with no way back. A user who generated text with a typo can only sign it or abandon it forever. Also `sign` stores timestamp/IP/UA but **no hash of `generatedContent`**, and only the owner ever signs, so evidentiary value is weak for a "legal" product.
- Fix: "revise" transition (pendingSignature → draft), store a content hash at generate/sign, define counter-party signing before calling it a signed contract. Effort M. Risk: legal review of what "signed" means.

**BIZ-06 · Low · Room opens outside the booking window** [CODE]
- `issueToken` only requires `confirmed` status; token issue is `deleteMany` + `create` outside a transaction. Effort S.

**BIZ-07 · Low · Verified lawyers can edit profile/pricing without re-review** [CODE]
- `updateMine` changes bio/specialties/prices on a verified profile freely. May be intended. Effort S if moderation is wanted.

### Missing

**MISS-01 · Medium · Entire company/team domain has no backend** [CODE]
- Registration creates `Organization` + owner member, but there is no module, endpoint, or non-mock UI for it; company users can neither book nor manage a team. Same for billing, messaging, AI, documents (see FE-01). Tracked in roadmap phases 4–8.

---

## 5. API Audit [CODE]

Good: versioned prefix, OpenAPI via Swagger (disabled in production by default), one error envelope with stable `code` values the app localizes, consistent `{ data, meta }` for lists, `204` for commands, `Retry-After` on 429, request id header.

Notes:
- **API-A (Low, [RISK])** Envelope consistency was spot-checked (lawyers, consultations, contracts, notifications use `{data}`); auth endpoints return their own shapes. A one-time contract test for all 49 routes against the OpenAPI document would lock this down.
- **PERF-01 (Medium)** below: unbounded list endpoints (`GET /consultations`, `GET /lawyers/:id/availability`).
- Public marketplace (`GET /lawyers`) requires authentication; fine, but means no unauthenticated SEO/preview.
- **Contract impact of any fix above:** SEC-05 removes `reviewerUserId` from `GET /lawyers/:id/reviews`; BIZ-01/02 add new 4xx responses to existing endpoints; BIZ-05 adds a route. All are additive or tightening and need the Flutter models updated together.

---

## 6. Database Audit [CODE]

Strengths: UUID PKs, `timestamptz`, `citext` email, `Decimal(10,2)` prices, CHECK on rating 1–5, unique indexes for double-booking and duplicate reviews, GiST exclusion constraint for overlapping booked slots, price/name snapshots on `Consultation` (history is stable).

**DB-01 · High · No index on `refresh_tokens.refresh_token_hash`** [CODE]
- `migrations/20260909165333_init/migration.sql:64,146` creates only `refresh_tokens_user_id_idx`. `TokenService.rotate` (`token.service.ts:59`) looks up by hash with `findFirst`; every refresh and every logout is a sequential scan.
- Fix: new migration `CREATE UNIQUE INDEX CONCURRENTLY` on `refresh_token_hash` (and `@unique` in schema). Safe on production data (additive). Effort S. Risk: create concurrently to avoid locking; hashes are random so uniqueness will hold.

**DB-02 · Medium · No retention/purge for growing tables** [CODE]
- `refresh_tokens` (one row per login and per rotation, never deleted), `verification_codes`, `consultation_participant_events`, notifications beyond the 100 returned. Add a scheduled purge (revoked/expired > 30–90 days; consumed/expired codes > 24 h). Effort S–M.

**DB-03 · High · `onDelete: Cascade` from `User` across business records, with no account-deletion design** [CODE]
- `schema.prisma` (e.g. `Consultation.client`, `Review.reviewer`, `Contract`, `ContractSignature`): physically deleting a user cascades to consultations (the lawyer's history), reviews (changing the lawyer's rating basis without recomputation) and signed contracts. Roadmap step 1.6 (mandatory account deletion for Apple/Google) is not started.
- Fix: soft-delete/anonymise (`deletedAt` already exists on `User`), `Restrict` on business FKs, recompute aggregates. Effort M. Risk: legal retention requirements for signed contracts need a policy decision.

**DB-04 · Low · Denormalised `scheduledAt`** — duplicates the slot's `startAt`; reschedule currently updates both, any future code path must too. Effort S.

**DB-05 · Low · Dead/legacy columns** — `User.twoFactorEnabled` unused; `User.phone` nullable only for legacy rows. Effort S.

**Migrations (safety):** 11 forward-only migrations with hand-written SQL for the exclusion and CHECK constraints (needs `btree_gist`). The `20261008090000_phone_sign_in` data migration was **not** read in depth — review it before applying to production data **[not verified]**. No migration in this audit was executed.

Missing indexes worth adding after measuring: `consultations(lawyer_profile_id, scheduled_at)` (lists sorted by time), trigram index for lawyer name search **[RISK]** (see PERF-03).

---

## 7. Security Audit (consolidated)

| Control | Status |
|---|---|
| Server-side authorization on every endpoint | ✅ Verified by reading all 10 controllers/services |
| IDOR | ✅ No instance found; contracts/consultations/rooms/notifications are owner/participant scoped |
| SQL injection | ✅ None (Prisma only, no `$queryRaw`) |
| Password storage | ✅ bcrypt (12 rounds default), burn on unknown user, password rules |
| Token handling | ✅ short JWT + hashed rotating refresh; ⚠ SEC-04 race |
| Session management | ✅ list/revoke sessions, revoke-all on reset |
| Brute force | ✅ per-IP + per-phone; ⚠ in-memory (SEC-07) |
| Input validation | ✅ whitelist/forbid-unknown, length caps seen on notes/comments/reasons |
| File upload | ✅ strong; ⚠ SEC-06 retention/location |
| Secrets in repo | ⚠ SEC-09 (gateway account name); no passwords/keys found in tracked files by inspection of `.env.example` and config |
| Transport/headers | ✅ helmet, HTTPS-only release network config, no backups |
| Dependency hygiene | ❌ SEC-02 |
| Release signing | ❌ SEC-01 |

**SEC-01 · Critical · Android release signed with the debug keystore** [CODE]
- `android/app/build.gradle.kts:47-48` (`// TODO … signingConfig = signingConfigs.getByName("debug")`). A debug-signed AAB cannot be published to Google Play, and any APK distributed this way can be re-signed by anyone with the public debug key.
- Fix: create an upload keystore, `key.properties` (already gitignored per `.gitignore` comments), release `signingConfig`, enable R8/minify. Effort S. Risk: keystore loss is unrecoverable — back it up, use Play App Signing.

**Account enumeration (Low, [CODE])**: `register` answers 422 `PHONE_ALREADY_REGISTERED` / `EMAIL_ALREADY_REGISTERED` (throttled by the strict limiter). Common trade-off; password reset and login are correctly uniform.

---

## 8. UI/UX Design Audit

Summary only — full direction in `FRONTEND_DESIGN_RECOMMENDATIONS.md`.

- **Strong base:** coherent navy + blue identity, token discipline, RTL-correct, localized.
- **Drift:** violet/purple/cyan accents and gradient tiles on the client home push toward the generic "AI app" look the brief wants to avoid; surfaces use cards everywhere with identical radii.
- **Missing states:** skeletons (FE-05), dark-mode completeness (FE-03), tablet layouts (FE-07).
- **Information architecture issue:** client bottom nav = Home · AI · Documents · Lawyers · Account. Two of five tabs are mock-backed (FE-01), while the most valuable real flows (consultations list, contracts) are reached from Home cards rather than tabs.
- **Honest labelling:** the Account screen already tags unbuilt rows "coming soon" — a good pattern that should be extended, not removed.

---

## 9. Performance Audit

No runtime measurements were taken; findings are from code and schema.

**PERF-01 · Medium · Unbounded lists** [CODE]
- `consultations.service.ts:38` `getAvailability` returns every slot ever created (past included); `:152` `list` returns all consultations with no pagination. Contracts, lawyers and reviews are paginated; these two are not. Fix: filter `startAt >= now` by default, add page/limit. Effort S. Risk: client paging.

**PERF-02 · Low · Several DB reads per request** [CODE]
- Each authenticated request does one session lookup (primary key); admin and verified-phone guards add one each; room actions call `consultationForParticipant` → `getById` → lawyer profile lookup. Fine at current scale; cache if needed.

**PERF-03 · Low · Lawyer search** [CODE]
- `contains … mode: insensitive` on `fullName` plus `orderBy rating` without supporting indexes. Fine for hundreds of lawyers; revisit (pg_trgm / full-text, Arabic normalisation) at thousands.

Frontend: 35 non-lazy `ListView(` children lists vs 16 builder lists — acceptable for short forms; check long lists. Riverpod providers + 136 `setState` calls coexist; no memory-leak pattern found (22 files create controllers, 31 files call `dispose`; counts are consistent but not exhaustively matched **[RISK]**).

Dependencies: backend uses `bcryptjs` (pure JS) — acceptable for current load; the 12-round hash blocks the event loop ~250 ms per login. Consider native `bcrypt`/`argon2` or a worker if login volume grows **[RISK]**.

---

## 10. Code Quality Audit

- Architecture/separation of concerns is good on both sides; comments explain *why* and reference design docs.
- `ConsultationsService` is the one oversized service (availability + booking + lifecycle + reviews, 405 lines); consider splitting `AvailabilityService` and `ReviewsService`.
- Large Flutter screens: `video_call_screen.dart` 774, `chat_room_screen.dart` 712, `ai_chat_screen.dart` 647, `voice_call_screen.dart` 600 lines — near-duplicate call UIs.
- Duplication: voice/video call screens; mock data sources duplicate domain rules that now live on the server (they will rot — remove as each feature goes real).
- Lint: backend eslint clean; Flutter analyzer clean (`flutter_lints` 5 only — consider stricter rules such as `prefer_const_constructors`, `avoid_print`, `unawaited_futures`).
- Dependency drift: `flutter pub get` reports 56 packages with newer incompatible versions; `file_picker ^13.1.0` and similar pins should be reviewed **[not verified for each]**.

---

## 11. Testing Coverage

| Area | State |
|---|---|
| Flutter | 69 test files, **599 passing** [RUN]. Widget + controller tests for auth, account, schedule, chat, etc. |
| Backend unit | 13 suites, **100 passing** [RUN]: DTOs, guards (login attempts, phone-verified), OTP, password, SMS client, filter, config, contract fields, verification-file sniffing, health, prisma service |
| Backend e2e | 6 specs (app, auth, contracts, health, lawyer-verification, notifications). **Not run here** (needs Postgres) |
| Coverage numbers | **Not measured** |

**TST-01 · High · The most complex and money-adjacent logic has no tests** [CODE]
- No spec exists for `ConsultationsService` (booking concurrency, state machine, reschedule, reviews), `ConsultationRoomService`, `LawyersService`, `GovProceduresService`, or `TokenService` (rotation, replay detection). Admin approve/reject is covered only through the lawyer-verification e2e. No CI configuration, Dockerfile, or deployment definition is tracked, so nothing enforces the test suite before release.
- Fix: add integration specs for the above first (they cover SEC-04, BIZ-01/02/03, DB constraints); add CI running `flutter analyze`, `flutter test`, backend lint/tsc/unit/e2e (with a Postgres service), and `npm audit`. Effort M.

**CFG-01 · High · Default builds target the production API** [CODE]
- `lib/core/config/app_config.dart:35`: with no `--dart-define`, every debug run, widget-test-adjacent manual run and CI smoke build talks to `https://oqdjo.com/v1`. A developer registering test users or booking test consultations writes to production. There are no flavors (comment says so deliberately).
- Fix: default to a local/staging URL in debug; require `API_BASE_URL` for release (assert in `AppConfig.resolve`). Effort S.

---

## 12. Critical Bugs / Blockers

| ID | Summary |
|---|---|
| SEC-01 | Release signed with debug key |
| FE-01 | Mock features (AI, documents, chat auto-replies) presented as real |

No crash-level defect was found in the real flows by test or code reading. Functional defects of note: FE-02 (admin login throws), BIZ-04 (second participant cannot join), BIZ-05 (contract stuck), BIZ-03 (duplicate review → 500).

## 13. Technical Debt

Mock data sources (to be deleted as features go live); duplicated call screens; placeholder repo metadata (FE-08); dead preference/column (FE-03, DB-05); in-memory throttling (SEC-07); local-disk storage (SEC-06); one-build config (CFG-01); noise in generated files (FE-10).

## 14. Missing Features / Incomplete Implementations

Account deletion (roadmap 1.6, store-mandatory), phone change (1.3), help & support (1.5), documents backend (4.2), saved signature backend (4.3), realtime messaging (5.1), push notifications (5.2), real voice/video (6.1), AI (6.2), billing and payouts (7.x), company/team backend (8.x), admin console UI, release pipeline/CI.

---

## 15. Recommended Design System
See `FRONTEND_DESIGN_RECOMMENDATIONS.md` (palette, type, spacing, elevation, component specs, screen-by-screen notes).

## 16. Recommended Architecture Improvements

1. **Feature flags for unfinished features** (compile-time `--dart-define` + server-provided capabilities) so mock-backed flows cannot ship by accident (FE-01).
2. **Environment strategy:** `dev`/`staging`/`prod` via `--dart-define-from-file`; no production default (CFG-01).
3. **State-machine module** shared by consultations/room with explicit actors and time guards (BIZ-01/04).
4. **Redis** for throttling, login-attempt counters and (later) websocket fan-out (SEC-07, roadmap 5.1).
5. **Object storage** abstraction already shaped by `FileStorageService` — add an S3-compatible implementation (SEC-06).
6. **Scheduled jobs** (Nest schedule or external cron): purge tables, auto-mark missed consultations, expire stale pending bookings (DB-02, BIZ-01).
7. **Soft-delete and anonymisation** policy before account deletion (DB-03).
8. **Contract tests** generated from the OpenAPI document against Flutter wire parsing.
9. **Observability:** structured JSON logs, error tracking (Sentry or similar), basic metrics; none exist today.

---

## 17. Prioritized Improvement Roadmap

Effort key: S ≤ 2 days · M ≈ 3–8 days · L > 8 days (one engineer, rough).

### P0 — Production blockers (do before any public release)

| Order | ID | Action | Effort |
|---|---|---|---|
| 1 | SEC-01 | Upload keystore, release signing config, minify/R8 | S |
| 2 | FE-01 | Hide or clearly label AI, Documents, Team, chat auto-reply in release | S |
| 3 | CFG-01 | Safe default API URL; mandatory `API_BASE_URL` in release | S |
| 4 | SEC-02 | `npm audit fix`, re-run unit + e2e | S |
| 5 | DB-01 | Concurrent unique index on `refresh_token_hash` | S |
| 6 | SEC-09 | Remove foreign gateway account name from `.env.example`; rotate if live | S |
| 7 | DB-03 / roadmap 1.6 | Design account deletion + change cascades to restrict/soft-delete | M |

### P1 — Major functional bugs and important UX

| ID | Action | Effort |
|---|---|---|
| BIZ-01 | Time/evidence gating for outcome transitions | M |
| BIZ-02 | Validate slot/booking times; overlap rejection | S |
| BIZ-03 | Map `P2002` → 409 (filter-level) | S |
| BIZ-05 | Contract revise transition + content hash | M |
| SEC-03, SEC-04 | Re-auth for email change; atomic refresh rotation + throttle | S |
| SEC-05 | Remove reviewer id; verified-only reviews | S |
| FE-02 | Handle `admin` role gracefully | S |
| TST-01 | Integration tests for consultations/room/token + CI pipeline | M |
| PERF-01 | Paginate / future-filter availability and consultations | S |
| DB-02 | Purge job for tokens/codes/events | S–M |

### P2 — UI/UX and performance

| ID | Action | Effort |
|---|---|---|
| FE-09 | Apply the restrained palette and flatten gradients/tiles | M |
| FE-04 | Bundle Arabic + Latin typefaces; tune Arabic line-height | S–M |
| FE-05 | Skeleton loaders for list/detail screens | M |
| FE-03 | Complete dark theme from `ColorScheme`; wire theme mode setting | M |
| FE-06 | Contrast fixes, semantics on icon buttons, large-text tests | M |
| FE-07 | Max-width containers and two-pane layouts ≥ 700 px | M |
| SEC-06, SEC-07 | Object storage + Redis | M each |
| SEC-08 | Production-config startup assertions | S |

### P3 — Refactoring and long-term

Split `ConsultationsService`; merge voice/video call UI shells; stricter lint set; remove mock data sources as features go real; BIZ-04 per-participant room model (with roadmap 6.1); MISS-01 company/team backend; BIZ-06/07, DB-04/05, PERF-02/03, FE-08, FE-10, SEC-10 cleanups; observability stack.

---

## Appendix A — Not Verified in This Audit

- Backend e2e suites (need PostgreSQL); no migration was applied; `20261008090000_phone_sign_in` not read in depth.
- Any runtime performance number (latency, startup, bundle/APK size, memory); no profiling was done.
- Visual rendering of screens in light/dark/RTL/tablet; only one stale screenshot was viewed.
- iOS `Info.plist`/entitlements, web build, desktop builds.
- Production server configuration (nginx, `NODE_ENV`, TLS, backups) — not accessible.
- NGT SMS delivery against the real gateway.
- Per-file memory-leak analysis (counts only).

## Appendix B — Modification log

No application files were modified. Created: `COMPLETE_APPLICATION_AUDIT.md`, `FRONTEND_DESIGN_RECOMMENDATIONS.md`. Side effects: `backend/node_modules/` installed via `npm ci` and Prisma client generated (both git-ignored).

## Appendix C — Remediation log (P0 batch, 2026-11-12)

| ID | Change | Files | Verification |
|---|---|---|---|
| SEC-09 | Removed the foreign SMS gateway login name and sender id; placeholders only | `backend/.env.example` | Prisma/config unaffected; backend unit tests pass |
| DB-01 | Unique index on `refresh_tokens.refresh_token_hash` (additive migration, plain `CREATE UNIQUE INDEX`; check row count first on a large production table) | `backend/prisma/schema.prisma`, `backend/prisma/migrations/20261112120000_refresh_token_hash_unique/` | `prisma validate` ok; **migration not applied to any database** |
| SEC-02 | `npm audit fix` (lockfile only, no `package.json` change) | `backend/package-lock.json` | `npm audit --omit=dev`: 0 vulnerabilities; lint, tsc, `nest build`, 100 unit tests pass; `npm ci --dry-run` ok. Dev-only advisories remain (31, not shipped) |
| CFG-01 | Debug/profile builds default to `http://10.0.2.2:3000/v1`; release keeps production; `--dart-define=API_BASE_URL` still overrides | `lib/core/config/app_config.dart` | New `app_config_test`; full suite |
| SEC-01 | Release signing from git-ignored `android/key.properties`; `bundleRelease` refuses to run without it; `assembleRelease` still falls back to debug key for local `flutter run --release` | `android/app/build.gradle.kts` | `flutter build appbundle --release` fails with the intended message. **Signed-build path not exercised (no keystore)** |
| FE-01 | Preview flag (`FeatureFlags.previewFeatures`, on in debug, off in release, `--dart-define=SHOW_PREVIEW_FEATURES=true` to opt in): hides AI and Documents tabs, contract-analysis tile, vault banner, "Ask AI" pill, and the scripted lawyer reply | `lib/core/config/feature_flags.dart`, `app_router.dart`, `client_routes.dart`, `client_home_screen.dart`, `chat_room_screen.dart`, `test/support/role_test_harness.dart` | New `release_features_test` (3 tests); `flutter test`: 603 pass; `flutter analyze`: clean |

Known remaining gap for FE-01: consultation chat messages are still stored locally only (never delivered to the other party) until roadmap 5.1; lawyer and company shells and team/billing screens were not gated in this batch.

## Appendix D — Frontend redesign log

| Step | Change | Files | Verification |
|---|---|---|---|
| Foundation (FE-03, FE-06) | `textSecondary` #5B6472, `textDisabled` #8A919B, lighter status backgrounds, md radius 12→10, button height 52→48, disabled buttons use a muted fill; borders, dividers, nav and hint colors now come from `ColorScheme` (new dark border/surface-variant tokens) instead of light-theme constants | `app_colors.dart`, `app_radii.dart`, `app_theme.dart`, `app_button.dart` | analyze clean, 603 tests pass. **Not rendered on a device** |
| Login | No layout change needed; it already follows the restrained direction and inherits the foundation changes | — | — |
| Client home (FE-09) | Service tiles and the vault banner are now flat bordered surfaces with a tinted icon square instead of violet/cyan/amber gradients; unused tokens (`purpleAccent`, `violet`, `violetLight`, `cyanAccent`, `amberLight`) and the four service gradients removed | `client_home_screen.dart`, `app_colors.dart`, `app_gradients.dart` | analyze clean, 603 tests pass. **Not rendered on a device** |

Not done yet: bundled font (needs choosing a family and adding font assets), theme-mode setting, skeleton loaders.
