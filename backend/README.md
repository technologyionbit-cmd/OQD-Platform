# Aqd Backend

**Phase 1A — Backend Infrastructure Foundation.** NestJS/TypeScript, PostgreSQL
via Prisma, Redis, Docker Compose for local infrastructure. No business
modules, no authentication yet — see `docs/backend/16-backend-roadmap.md`
for what comes next (Phase 1B: auth) and beyond.

## Prerequisites

- Node.js ≥ 20 (developed against Node 24)
- Docker + Docker Compose (for local PostgreSQL/Redis)
- npm

## 1. Start local infrastructure

From `backend/`:

```bash
docker compose up -d
```

This starts PostgreSQL (`localhost:5432`) and Redis (`localhost:6379`) with
persistent named volumes (`aqd_postgres_data`, `aqd_redis_data`).

## 2. Configure environment

```bash
cp .env.example .env
```

The defaults in `.env.example` already match `docker-compose.yml`'s default
credentials/ports, so no edits are required for a first run. Never commit a
real `.env` file.

## 3. Install dependencies

```bash
npm install
```

## 4. Prisma

```bash
npm run prisma:generate   # generate the Prisma client
npm run prisma:validate   # validate prisma/schema.prisma
npm run prisma:migrate    # create/apply the initial migration (requires the DB from step 1)
```

`prisma/schema.prisma` currently defines only the Phase 1 identity/organization
foundation (`users`, `refresh_tokens`, `verification_codes`,
`lawyer_registration_details`, `organizations`, `organization_members`,
`organization_invitations`) — see `docs/backend/01-domain-model.md` §1–2 and
`docs/backend/16-backend-roadmap.md` Phase 1. No other domain tables exist yet.

> **Note**: `organization_members` needs a partial unique index
> (`UNIQUE (organization_id, lower(email)) WHERE status = 'invited'`) per
> `docs/backend/04-database-design.md` §4, which Prisma's schema DSL cannot
> express declaratively. After running `prisma migrate dev --create-only`
> for the first time, add that constraint by hand to the generated SQL
> before applying it.

## 5. Run the app

```bash
npm run dev
```

The app listens on `PORT` (default `3000`) with global prefix `/v1`.

## 6. Health check

```
GET /v1/health
```

Reports application, PostgreSQL, and Redis connectivity via
`@nestjs/terminus`. Returns `200` with `status: "ok"` when every dependency
is up, or `503` if any dependency is down.

## Tests

```bash
npm test           # unit tests — no external services required
npm run test:e2e   # e2e tests — requires `docker compose up -d` (step 1) first
```

## Lint / format / build

```bash
npm run lint
npm run format
npm run build
```

## Project structure

```
src/
  main.ts                 bootstrap: global prefix, CORS, validation, helmet, graceful shutdown
  app.module.ts
  config/                 centralized, namespaced configuration + env validation
  common/
    errors/                error codes + the API error envelope shape
    filters/                global exception filter
    interceptors/           request logging (method/path/status/duration/request id)
    pipes/                   validation error -> 422 envelope shaping
  health/                  GET /v1/health (Postgres + Redis indicators)
  prisma/                  PrismaService/PrismaModule (injectable, global)
  redis/                   RedisService/RedisModule (injectable, global)
prisma/
  schema.prisma            Phase 1 identity/organization tables only
test/                      e2e tests (require live Postgres/Redis)
```

## API conventions (foundation only)

- All routes are prefixed `/v1`.
- Success: `{ "data": ... }` (or `{ "data": [...], "meta": { "nextCursor", "hasMore" } }` for paginated lists — no paginated endpoints exist yet).
- Error: `{ "error": { "message", "code", "errors"? } }` — see `docs/backend/05-api-design.md` §4.
- Request validation is global (`whitelist`, `forbidNonWhitelisted`, `transform`); validation failures return `422` with `error.errors` keyed by field.

## Not implemented yet (by design — see docs/backend/16-backend-roadmap.md)

Authentication/JWT, users/lawyers/contracts/documents/consultations/messaging/
WebSockets/notifications/AI/billing/company-team/marketplace business logic,
rate limiting, and object storage all belong to later phases.
