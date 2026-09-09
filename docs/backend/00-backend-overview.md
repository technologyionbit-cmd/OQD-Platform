# Backend Overview — Phase 0 (Architecture & Specification Only)

## Purpose of this document set

The Flutter frontend (`lib/`) was built and frozen as a **fully mocked UI/UX prototype** — every feature is backed by an in-memory `*MockDataSource`, there is no real network I/O, no persistence beyond auth tokens/preferences, and no multi-tenant data isolation. This document set reverse-engineers that frozen frontend into a complete backend domain model, architecture, and implementation roadmap.

**Nothing in `docs/backend/` is implementation.** No migrations, no server code, no API handlers exist yet. This is Phase 0: analysis and specification, meant to give Phase 1+ a single source of truth so backend work does not have to re-derive frontend intent from scratch.

## How the frontend was audited

Seven parallel deep-reads covered every feature folder under `lib/features/`, `lib/core/`, and `lib/app/routing/`:

1. Auth, profile, security, routing/role-guards
2. Contracts, documents, saved signatures
3. Consultations, consultation room (call/session state), lawyers marketplace
4. Messages, notifications
5. AI (chat + contract analysis)
6. Billing, company, team
7. Government documents, home dashboards, core infrastructure (network/errors/storage), test coverage map

Every domain entity, enum, repository method signature, mock-datasource seeding behavior, and role-based UI restriction referenced in these documents was read directly from source, not inferred from screenshots or specs. File:line references appear throughout [01-domain-model.md](01-domain-model.md) and the feature-specific documents.

## What the frontend actually is, architecturally

- **Framework**: Flutter (Dart SDK ^3.7.2), Riverpod 3 for state, `go_router` for navigation, `dio` for HTTP (configured but **never actually called** — every datasource today is a mock), `freezed`/`json_serializable` for typed models, `flutter_secure_storage` for tokens.
- **Layering**: strict Clean Architecture per feature — `domain/` (entities, repository interfaces), `data/` (datasources — mock today, remote-datasource interfaces already written to mirror a future REST contract — and repository implementations), `presentation/` (Riverpod providers/controllers, screens, widgets).
- **Every mock datasource is a deliberate, documented stand-in.** Comments across the codebase (`auth_data_source_provider.dart`, `ai_mock_data_source.dart`, `team_mock_data_source.dart`, etc.) consistently state the same intent: swapping the datasource implementation is meant to be the *only* change needed when a real backend arrives — repositories, controllers, and screens should not need to change. This is the foundation of the migration strategy in [15-mock-to-real-migration.md](15-mock-to-real-migration.md).
- **No real multi-tenancy exists.** `Contract`, `Document`, `Consultation` and others carry no owner/tenant foreign keys at all in the frontend model — role-based restriction today is enforced purely at the UI layer (which screens/buttons are shown), never at the data layer. This is the single most important gap the backend must close; see [03-multi-tenancy.md](03-multi-tenancy.md).
- **No payment provider, no AI provider, no media/WebRTC provider, no push provider is integrated or referenced anywhere** (verified by dependency and grep audits). These are all real integration decisions the backend introduces from scratch — the frontend gives us behavior/UX expectations only, never a vendor choice.

## Document map

| Doc | Covers |
|---|---|
| [01-domain-model.md](01-domain-model.md) | Every backend entity: fields, types, enums, relationships, ownership, lifecycle |
| [02-auth-and-authorization.md](02-auth-and-authorization.md) | Registration, login, tokens, verification, RBAC design |
| [03-multi-tenancy.md](03-multi-tenancy.md) | Ownership model, workspace/organization design, data isolation |
| [04-database-design.md](04-database-design.md) | DB technology, schema, ERD, indexes, constraints |
| [05-api-design.md](05-api-design.md) | REST/WebSocket architecture, per-module endpoint tables |
| [06-consultations.md](06-consultations.md) | Booking, availability, lifecycle state machine, room sessions |
| [07-messaging-realtime.md](07-messaging-realtime.md) | Chat persistence, real-time transport, presence/typing |
| [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md) | Templates, fields, signing lifecycle, document storage |
| [09-lawyers-marketplace.md](09-lawyers-marketplace.md) | Lawyer profiles, verification, search, reviews |
| [10-notifications.md](10-notifications.md) | Notification taxonomy, routing, delivery |
| [11-ai.md](11-ai.md) | AI conversations, contract analysis jobs |
| [12-billing.md](12-billing.md) | Subscriptions, payment methods, invoices |
| [13-company-team.md](13-company-team.md) | Organization/workspace, membership, invitations |
| [14-security.md](14-security.md) | Security checklist across every module |
| [15-mock-to-real-migration.md](15-mock-to-real-migration.md) | Mock → remote datasource cutover strategy, per feature |
| [16-backend-roadmap.md](16-backend-roadmap.md) | Phased implementation plan with acceptance criteria |

## Critical frontend gaps this backend design must resolve

These are not backend "nice to haves" — they are things the frontend UI already expects but has no data model or backend call for. Each is discussed in the relevant document.

1. **No `clientId` on `Consultation`** — only `clientName` (denormalized string). The mock hardcodes `kDemoClientUserId` everywhere a "who is the other party" lookup is needed. See [06-consultations.md](06-consultations.md).
2. **No ownership fields on `Contract`/`Document`** at all — no `ownerId`, `clientId`, `companyId`, `lawyerId`. See [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md) and [03-multi-tenancy.md](03-multi-tenancy.md).
3. **No `Organization`/`Company` entity** — `UserRole.company` is just an account-type enum value; `TeamMember` has no `organizationId` foreign key (single implicit company in the mock). See [13-company-team.md](13-company-team.md).
4. **Lawyer's auth identity and marketplace profile are disconnected** (`kDemoLawyerUserId` vs `kDemoLawyerId`) — the backend must decide the real relationship (1:1 `LawyerProfile.userId`). See [09-lawyers-marketplace.md](09-lawyers-marketplace.md).
5. **No `changePassword`, 2FA, biometric, or session-list/revoke backend calls** despite full UI for all four in `SecurityPrivacyScreen`. See [02-auth-and-authorization.md](02-auth-and-authorization.md).
6. **`commercialRegistrationNumber` (company) and `barLicenseNumber`/`mainSpecialty` (lawyer)** are captured at registration but discarded by the mock — no field persists them anywhere. See [02-auth-and-authorization.md](02-auth-and-authorization.md) and [09-lawyers-marketplace.md](09-lawyers-marketplace.md).
7. **No `ContractParticipant`/`ContractSignature` entity** — contract "parties" are free-text strings, and "signing" is a single unconditional status flip with no per-party record and no role check (a lawyer can currently tap Sign — likely an oversight). See [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md).
8. **No `Review` entity** — `LawyerProfile.rating`/`reviewsCount` are aggregate-only numbers; the "Reviews" UI section is hardcoded static content. See [09-lawyers-marketplace.md](09-lawyers-marketplace.md).
9. **Backend error-envelope shape is explicitly unfinalized** in the frontend's own code (`ApiErrorMapper` comments) — this spec fixes that shape. See [05-api-design.md](05-api-design.md).
10. **No offline/local persistence layer** beyond auth tokens and simple preferences — every feature list is refetched fresh each session. The backend can assume an always-online client for v1.
11. **AI processing is synchronous in the mock** — no job/status concept. A real AI provider integration needs an async job model the frontend doesn't yet anticipate in its data shapes (though the UI's loading states tolerate latency fine). See [11-ai.md](11-ai.md).
12. **Consultation double-booking is not prevented anywhere in the mock** — purely a UI-disabled-slot affordance. The backend must own atomic slot reservation. See [06-consultations.md](06-consultations.md).

## Recommended backend stack

Full comparison and rationale would normally get its own document; it's kept here since it's a single decision that every other document already assumes rather than re-derives.

**Recommendation: Node.js (TypeScript) + NestJS, PostgreSQL, Redis, an S3-compatible object store, and a Postgres-backed job queue (e.g. `graphile-worker` or BullMQ-on-Redis).**

Why this over the realistic alternatives:

| Option | Assessment |
|---|---|
| **Node/TypeScript + NestJS** (recommended) | Same language family as the frontend's tooling ecosystem (npm/JS/TS), making it easiest for the existing team to context-switch into; NestJS's module/DI structure maps naturally onto the frontend's own Clean-Architecture-by-feature layout (a `ContractsModule`, `ConsultationsModule`, etc. mirroring `lib/features/contracts`, `lib/features/consultations`), which keeps the mental model consistent across the stack and makes the migration mapping in [15-mock-to-real-migration.md](15-mock-to-real-migration.md) easy to reason about 1:1. Mature ecosystem for everything this spec needs: Postgres (via Prisma/TypeORM), WebSockets (native `@nestjs/websockets`), job queues, S3 SDKs, and payment/AI provider SDKs are all first-class here. |
| Python (FastAPI/Django) | Strong for the AI module specifically (richest ML/AI tooling), but the rest of this domain (contracts, billing, consultations) doesn't lean on Python's strengths, and it fragments the team's language surface for no clear net gain over TypeScript given the AI work here is calling an external provider API, not running local models. |
| Go | Excellent performance/concurrency, well-suited to the WebSocket/real-time layer specifically, but has the weakest ORM/ecosystem maturity of the three for the amount of relational-schema-heavy CRUD this domain has (contracts, billing, org membership) — would mean more hand-rolled plumbing for comparatively little benefit at this project's realistic scale. |
| Ruby on Rails | Very productive for CRUD-heavy domains like this one, but weaker native WebSocket/real-time story than Node, and a smaller hiring pool than TypeScript for a team likely already Dart/Flutter-adjacent. |

None of these is a bad choice; TypeScript/NestJS wins on **ecosystem fit for the full breadth of this spec** (real-time, payments, file storage, background jobs) plus the lowest context-switching cost for a team already working in a strongly-typed, DI-friendly language (Dart/Riverpod) on the frontend.

- **Database**: PostgreSQL, per [04-database-design.md](04-database-design.md).
- **Cache/pub-sub**: Redis — backs WebSocket pub/sub fan-out across server instances ([07-messaging-realtime.md](07-messaging-realtime.md)) and rate-limiting counters ([14-security.md](14-security.md)).
- **Object storage**: any S3-compatible store (AWS S3, Cloudflare R2, MinIO for local dev) for documents/attachments/signatures ([04-database-design.md](04-database-design.md) §5).
- **Job queue**: Postgres-backed (`graphile-worker`) if minimizing infrastructure surface is preferred, or Redis-backed (BullMQ) if Redis is already present for the reasons above — either satisfies the jobs enumerated in [05-api-design.md](05-api-design.md) §6.
- **Media provider** (voice/video): deliberately not chosen here — an integration decision for Phase 7, see [06-consultations.md](06-consultations.md) §5.
- **Payment provider**: deliberately not chosen here — Phase 8, see [12-billing.md](12-billing.md).
- **AI provider**: deliberately not chosen here — Phase 7, see [11-ai.md](11-ai.md) §6.

## Non-goals of this phase (per explicit instruction)

No migrations, no ORM models, no server source code, no API controllers, no WebSocket handlers, no Firebase/payment/AI provider integration code. No changes to `lib/`, `test/`, `pubspec.yaml`, or platform folders were made while producing this document set.
