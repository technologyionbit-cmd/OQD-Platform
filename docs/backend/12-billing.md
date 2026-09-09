# Billing — Subscriptions, Payment Methods, Invoices

## 1. Entities

See [01-domain-model.md](01-domain-model.md) §9: `Subscription`, `PaymentMethod`, `Invoice`, `Transaction` (**new**).

## 2. Current state confirmed by audit

`lib/features/billing/**` has **no data/repository layer at all** — every entity is plain inline state inside Riverpod `Notifier`s (`SubscriptionController`, `InvoicesController`, `PaymentMethodsController`), with no `Result`/`Failure` error handling pattern, unlike every other feature. No payment provider (Stripe or otherwise) is referenced anywhere in the codebase or `pubspec.yaml`. `PaymentMethod` is explicitly documented in-code as "lightweight UI-only mock state, not a domain entity backed by a repository." This means billing has the least frontend-side architectural precedent of any module — the backend is defining real structure almost from scratch here, using the *UI's* expectations (screens, forms, price table) as the spec rather than any existing repository contract.

## 3. Subscription tiers/plans (from UI content, not from any entity)

`SubscriptionTier` enum: `basic, pro, enterprise`. `BillingCycle` enum: `monthly, sixMonths, annual`. Neither enum carries price/limit data itself — everything below is currently a hardcoded UI string/price table with **zero server-side enforcement** of any limit:

| Tier | Monthly | 6-Month | Annual | Advertised limits (display-only today) |
|---|---|---|---|---|
| Basic | 20 JOD | 40 JOD | 80 JOD | 5 contracts/month, 1 contract analysis, AI consultation, email support |
| Pro (marked "Most Popular") | 49 JOD | 99 JOD | 189 JOD | Unlimited contracts, unlimited analysis, 3 lawyer consultations/month, advanced e-signature, 24/7 support |
| Enterprise | 99 JOD | 199 JOD | 399 JOD | Everything in Pro, 12 lawyer consultations/month, personal account manager, monthly legal reports, custom integrations |

**Approved decision** (see [16-backend-roadmap.md](16-backend-roadmap.md) §Phase 0 Product Decisions (Approved) item 2): subscription limits are **real, backend-enforced quotas, not marketing-only copy**. The frontend never enforces them today (no quota-check logic references `SubscriptionTier` anywhere in `ContractsController`/`ConsultationsController`), and that is not carried forward — v1 introduces a `PlanLimit(tier, resourceType, monthlyLimit)` lookup table and a usage-counting check at the relevant create endpoints (`POST /v1/contracts`, `POST /v1/ai/analyses`, `POST /v1/consultations`), built in Phase 8 alongside the rest of billing (see [16-backend-roadmap.md](16-backend-roadmap.md) Phase 8). **The exact quota values enforced are exactly the "Advertised limits" column in the table above** — that table is the single source of truth for the numbers (e.g. Basic = 5 contracts/month, 1 contract analysis/month, unlimited AI consultation chat, etc.); no separate/different quota values should be introduced without a product decision to change the advertised copy itself.

Prices/limits move from hardcoded frontend strings into a `SubscriptionPlan` reference table (tier × cycle → price) plus the `PlanLimit` table above (tier → resourceType → monthlyLimit) so pricing/limit changes don't require a frontend release — this mirrors how `ContractTemplate` content is being moved from code into data in [08-contracts-documents-signatures.md](08-contracts-documents-signatures.md).

## 4. Subscription lifecycle

**New relative to the frontend**, which has no status concept at all — just a nullable `tier` (no active plan = `null`). Real `status` enum: `active, pastDue, cancelled, expired`. `subscribe(tier, cycle)` creates/updates a `Subscription` row with `currentPeriodStart`/`currentPeriodEnd` computed from `billingCycle`; a scheduled job (see [05-api-design.md](05-api-design.md) §6) handles renewal (create the next period's `Invoice`, attempt payment via the default `PaymentMethod`) and expiry (`pastDue` if payment fails, `expired` if unresolved past a grace period, `cancelled` if the user explicitly cancels — `cancelAtPeriodEnd` lets a cancellation take effect at period end rather than immediately, standard SaaS behavior with no frontend precedent either way).

## 5. Payment methods — real tokenization, not raw card storage

The frontend's `PaymentPanel` collects raw card number/expiry/CVV client-side (confirmed via `core/utils/validators.dart`'s card-shaped regexes) and never persists them beyond the in-memory `PaymentMethod` display fields (`brand, last4, holderName, isDefault`) — the mock never actually needed a real charge to succeed.

**This raw-card-collection pattern must not reach the backend or database as-is.** Real design: the client integrates the chosen payment provider's client-side SDK (e.g. Stripe Elements/PaymentSheet) directly, which tokenizes card data in the provider's own environment — the Aqd backend **never receives or stores raw card numbers/CVVs**, only the provider's opaque `providerPaymentMethodId` token plus the display metadata (`brand`, `last4`, `expiryMonth/Year`, `holderName`) the frontend already models. This is a required PCI-scope-avoidance decision, not optional — see [14-security.md](14-security.md).

`isDefault` toggle behavior is preserved from the frontend (`setDefault`/`remove`, new card becomes default only if the list was previously empty).

## 6. Invoices & the earnings/billing disconnect

Frontend `Invoice` only has `paid`/`pending` — backend expands to `draft, pending, paid, overdue, void` (matches typical invoice lifecycles and gives the overdue-reminder job in [05-api-design.md](05-api-design.md) §6 something to act on).

**A real, audit-worthy finding from the catch-all pass, not resolvable by copying frontend behavior**: the lawyer dashboard's "month earnings" figure is computed ad hoc client-side as `sum(completed consultations' price field this month)`, with **no connection at all** to the structurally separate `Invoice`/`Subscription` system. A real backend should reconcile these as two views of one ledger: every completed, paid consultation should produce an `Invoice`/`Transaction` row (`consultationId` FK, per [01-domain-model.md](01-domain-model.md) §9) so a lawyer's earnings figure and the platform's invoice/payout records are the same underlying data, not two disconnected computations as they are in the mock today. This is called out explicitly since a naive "just replicate the mock" approach would ship the same disconnect into production billing.

## 7. Polymorphic subject (user vs. organization)

`Subscription`/`PaymentMethod`/`Invoice` all use `(subjectType, subjectId)` since either an individual or a company account can hold a plan/card/invoice — matches both roles reaching the identical `SubscriptionPlansScreen`/`PaymentPanel` UI in the frontend from different shells. See [04-database-design.md](04-database-design.md) §4 for the recommended `billing_subjects` bridge-table pattern to keep this referentially clean in Postgres.

## 8. What is explicitly NOT built in this phase

No real payment provider integration, no webhook handlers for payment-provider events (charge succeeded/failed, subscription renewed), no actual card tokenization code — those are Phase 8 implementation, not Phase 0 specification (see [16-backend-roadmap.md](16-backend-roadmap.md)).

## 9. Endpoint table

| Method & path | Auth | Purpose |
|---|---|---|
| GET /v1/subscription-plans | 🔓 | Public price/limit table |
| GET /v1/billing/subscription | 🔒 | Current subject's active subscription |
| POST /v1/billing/subscription | 🔒 | Subscribe/change tier |
| POST /v1/billing/subscription/cancel | 🔒 | Cancel (immediate or at period end) |
| GET /v1/billing/payment-methods | 🔒 | List |
| POST /v1/billing/payment-methods | 🔒 | Add (client already holds a provider token from the SDK) |
| PATCH /v1/billing/payment-methods/{id}/default | 🔒 | Set default |
| DELETE /v1/billing/payment-methods/{id} | 🔒 | Remove |
| GET /v1/billing/invoices | 🔒 | Paginated history |
| GET /v1/billing/invoices/{id} | 🔒 | Detail |
| POST /v1/webhooks/payment-provider | 🔓 (provider-signature verified, not user-authenticated) | Charge/subscription lifecycle events from the provider |
