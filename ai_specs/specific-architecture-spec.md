# Spec: Project-Specific Architecture Documentation

Created: 2026-05-11
Status: refined

## Goal

Create a set of `ai_docs/*.md` files that capture sarqyt-specific knowledge an AI assistant **cannot infer** from reading the code alone — hidden decisions, external service quirks, billing constraints, deployment gotchas, non-obvious conventions, and "why" behind architectural choices. These docs complement the universal patterns in `ai_toolkit/guidelines/` without repeating them.

## Background

The project already has:
- `ai_toolkit/guidelines/` — universal Flutter/Firebase/Riverpod patterns (architecture, code-style, firebase, flutter, riverpod)
- `ai_docs/PROJECT.md` — high-level project overview (tech stack, features, collections, user roles)

What's missing: project-specific decisions that look arbitrary from the code but have concrete reasons (billing, regional constraints, vendor limitations, scale assumptions, business rules). An AI assistant reading the codebase will make wrong assumptions without this context.

## Deliverables

### Files to create in `ai_docs/`

Each file should follow this structure:
- Short intro (1-2 sentences: what this file covers)
- Sections with **decision + why** format
- No universal patterns (those belong in `ai_toolkit/guidelines/`)
- Focus on things that would surprise an AI or cause it to suggest wrong solutions

#### 1. `ai_docs/EXTERNAL_SERVICES.md`
Non-obvious external service choices and configuration:
- [ ] Map provider: Stadia Maps (via flutter_map), not Google Maps — reason: billing/free tier
- [ ] Stripe region/currency setup (KZT specifics; keys via Firebase Secret Manager `STRIPE_SECRET_KEY` / `STRIPE_WEBHOOK_SECRET`, not hardcoded)
- [ ] Firebase Cloud Functions region split: **Firestore triggers** use `asia-south1` (set per-function), **callable/HTTPS functions** default to `us-central1` (no `setGlobalOptions` call). ⚠️ Do not suggest a global region change — it would break existing callable function URLs on the client.
- [ ] Firebase Hosting: single `firebase.json` hosting block pointing to `build/web` with no site target. Convention is to deploy business app only, but config is flavor-agnostic — the restriction is in the build/deploy process, not firebase.json.
- [ ] FCM push notification setup: token stored at `users/{uid}.fcmToken` via `set(merge: true)`, refreshed via `onTokenRefresh`
- [ ] API keys via `envied` with `obfuscate: true` in `lib/env.dart`: `STRIPE_PUBLISHABLE_KEY`, `STADIA_MAPS_API_KEY`, `SUPABASE_URL`. Generated file: `lib/env.g.dart`.
- [ ] Supabase: `SUPABASE_URL` is declared in env.dart. `TODO: ask maintainer` — document its purpose or confirm it's a leftover to remove.

#### 2. `ai_docs/FIRESTORE_GOTCHAS.md`
Non-obvious Firestore decisions that code alone doesn't explain:
- [ ] Why offers are a top-level collection (not subcollection of stores) — geo-query requirement
- [ ] Order write permissions: **creation** is server-only (`allow create: if false`), but **status updates** are allowed from both Cloud Functions and client (store staff can update `status`/`updatedAt` directly via Firestore rules). Document the distinction clearly.
- [ ] StoreShip composite ID pattern (`{storeId}_{userId}`) — why not auto-ID
- [ ] Two idempotency strategies in `stripeWebhook`: `payment_intent.succeeded` uses **deterministic order doc ID** (`order_${paymentIntent.id}`); `payment_intent.canceled` uses the **`_processedEvents` collection** with event ID dedup. Document both — an AI may assume one pattern applies everywhere.
- [ ] StoreDraft TTL: code sets `expiresAt = now + 3 days`; `cleanup-old-offers.ts` defers to Firestore native TTL policy on `expiresAt` field. `TODO: verify TTL policy is actually configured in Firebase console` — if not, drafts accumulate forever.
- [ ] `orderCounter` on stores — sequential order numbers per store (set via `onOrderCreated` trigger)
- [ ] Denormalized fields: **offers** snapshot `storeName` + `storeAddress` (patched on sync if store data changes); **orders** snapshot `storeName` only — `storeAddress` is NOT on the Order model.
- [ ] Geohash precision choice (4 = ~39km × 20km) — coverage vs query cost tradeoff for KZ cities
- [ ] Legacy price field: `Item` model has `_readEstimatedValueSource` fallback from old `originalPrice` field to new `estimatedValue`. Don't add yet another price field or break the fallback.

#### 3. `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md`
Non-obvious Cloud Functions decisions:
- [ ] Two order creation paths: `reserveOffer` (no payment, creates order directly in transaction) vs `createPayment` + `stripeWebhook` (Stripe flow, order created on `payment_intent.succeeded`) — when each is used
- [ ] Why `fakeVerifyBusiness` exists (simulates 25s government verification, sets `verificationStatus: "verified"`) and when to use/not use it
- [ ] `dailySyncOffers` timing (00:30 UTC) — why this time for Kazakhstan timezone
- [ ] `expireOrders` runs every 5 minutes — why not a Firestore TTL or longer interval
- [ ] Offer sync strategy: **2-day lookahead** (`DAYS_AHEAD = 2` in `build-expected-offers.ts`) for scheduled items, single offer for oneTime. ⚠️ Note: JSDoc comment in the same file incorrectly says "7 days" — the code uses 2. Fix the stale comment when touching this file.
- [ ] Refund retry logic in `cancelOrder` (3 attempts, exponential backoff: 1s, 2s delays) — on exhaustion sets `paymentStatus: "refund_failed"`. Why not a queue?
- [ ] Cloud Functions secrets (via `defineSecret`): `STRIPE_SECRET_KEY` (used by createPayment, stripeWebhook, cancelOrder), `STRIPE_WEBHOOK_SECRET` (stripeWebhook only). No `process.env` usage.
- ~~Auth triggers must be `us-central1`~~ — **Removed**: no auth triggers exist in this project. This is a universal Firebase constraint already documented in `ai_toolkit/guidelines/firebase.md`.

#### 4. `ai_docs/ROUTING_DECISIONS.md`
Non-obvious routing and app structure decisions:
- [ ] Two separate apps (client/business) sharing codebase — why not one app with role switching
- [ ] Business redirect has 8 layers — why sync-only, no async in redirect
- [ ] `StoreStartupWidget` scoped provider override pattern — why needed for multi-store
- [ ] Client app has 3 tabs, business has 5 branches — rationale
- [ ] Welcome/onboarding flow differences between client and business
- [ ] Firebase Hosting is a single config (`build/web`) — business-only is a deploy convention, not a config constraint. Document that the same `firebase.json` deploys whichever flavor was last built.

#### 5. `ai_docs/BUSINESS_RULES.md`
Domain rules that aren't encoded in code or are easy to miss:
- [ ] Order status state machine: `confirmed → [preparing, cancelled]`, `preparing → [readyForPickup, cancelled]`, `readyForPickup → [completed, cancelled]`. Terminal states: `completed`, `cancelled`, `expired`.
- [ ] One review per order: **intended but NOT enforced**. `hasReviewForOrder()` exists in repository but `submitReview` does not call it. No Firestore rule or Cloud Function guard. Document as design intent, flag as enforcement gap.
- [ ] Item schedule constraints: `maxQuantity = 30`, `maxWindowMinutes = 120` (2h max pickup window), start must be before end. Defined in `weekly_schedule.dart`.
- [ ] Offer visibility: `visibleFrom = startOfDay(pickupDate - 1 day, storeTimeZone)` — offer appears in discovery the day before pickup. `pickupStartTime` is the actual pickup window. Two fields serve distinct purposes: visibility embargo vs pickup scheduling.
- [ ] Price model: `price` (what customer pays) vs `estimatedValue` (retail value). `discountPercent = ((1 - price/estimatedValue) * 100).clamp(0, 100)`. Legacy: `Item` falls back to old `originalPrice` field via `_readEstimatedValueSource`.
- [ ] Currency handling: KZT only for now? Multi-currency planned?
- [ ] Store verification flow: `startMerchantOnboarding` → draft → `fakeVerifyBusiness` (dev) or real verification → `completeMerchantOnboarding` → creates Store + Business + StoreShip docs in batch + sets `role: PARTNER` custom claim. No visible "pending approval" state — flow goes directly from draft to active.
- [ ] Partner permissions: `StoreRole { owner, operator, employer }`. **owner**: full access including financials. **operator**: dashboard/performance/settings/help (no financials). **employer**: defined in enum but **not implemented** — zero UI or server enforcement. Server-side only distinguishes `ownerId` vs `staffIds` (flat list, no role-based checks).

### Update existing file

#### 6. `ai_docs/PROJECT.md`
- [ ] Add a "Non-Obvious Decisions" section pointing to the new files
- [ ] Add a "See Also" section linking to each new doc

## Requirements

### Must Have
- [ ] All 5 new documentation files created
- [ ] Each file contains only sarqyt-specific knowledge, not universal patterns
- [ ] Each decision has a "why" explanation (even if brief)
- [ ] `PROJECT.md` updated with cross-references
- [ ] Files are concise — bullet points and tables, not prose paragraphs

### Nice to Have
- [ ] Warnings about common AI mistakes (e.g., "Don't suggest Google Maps — we use Stadia for billing reasons")
- [ ] "If you're changing X, also update Y" cross-references between docs

## Technical Constraints

- Files go in `ai_docs/` directory (already exists)
- Format: Markdown (`.md`)
- Language: English
- Names should be descriptive and match content
- Keep each file focused — one topic per file
- Total combined size should stay reasonable (AI context window consideration)

## Edge Cases

- Some "why" answers may not be known — mark those as `TODO: ask maintainer` rather than guessing
- Some decisions may have changed since original implementation — verify against current code before documenting
- If a decision is already documented in `CLAUDE.md`, don't duplicate — reference it

## Out of Scope

- Rewriting `ai_toolkit/guidelines/` — those are universal and maintained separately
- Documenting every Firestore field — only non-obvious ones
- Writing code or making code changes
- API documentation or user-facing docs
- Deployment runbooks or CI/CD setup

## Definition of Done

- [ ] All 5 new `ai_docs/*.md` files created with sarqyt-specific decisions
- [ ] Each decision includes a "why" that would prevent an AI from making wrong suggestions
- [ ] `PROJECT.md` updated
- [ ] No duplication with `ai_toolkit/guidelines/`
- [ ] Files reviewed by maintainer for accuracy of "why" explanations

## Refine Notes (2026-05-11)

Findings applied from adversarial codebase review:

### Corrected assumptions
- **Region split**: No `setGlobalOptions`. Triggers use `asia-south1`, callables default to `us-central1`.
- **Offer sync**: 2-day lookahead (`DAYS_AHEAD = 2`), not 7. Stale JSDoc says 7.
- **Auth triggers**: Removed — no auth triggers exist in the project, and the constraint is already in `ai_toolkit/guidelines/firebase.md`.
- **Order writes**: Creation is server-only, but status updates are allowed from client (store staff).
- **Denormalized fields**: Orders have `storeName` only, NOT `storeAddress`.
- **Refund**: On exhaustion sets `paymentStatus: "refund_failed"`, delays are 1s/2s.

### Added missing details
- Supabase dependency in `env.dart` (purpose unknown, needs maintainer input).
- Two idempotency strategies in stripe webhook (deterministic doc ID vs `_processedEvents`).
- StoreDraft TTL needs console verification.
- `visibleFrom` formula: `startOfDay(pickupDate - 1 day, storeTimeZone)`.
- Legacy `originalPrice` → `estimatedValue` fallback in Item model.
- `employer` role: defined but not implemented.
- Review-per-order: design intent, not enforced.
- Verification flow: no pending state, draft → active directly.

### Open questions for maintainer
- What is `SUPABASE_URL` used for? Active dependency or leftover?
- Is Firestore TTL policy configured on `storeDrafts.expiresAt` in Firebase console?
- Should `ai_toolkit/guidelines/firebase.md` references to `ai_docs/FIRESTORE_SCHEMA.md` / `ai_docs/CLOUD_FUNCTIONS.md` be updated to match new file names (`FIRESTORE_GOTCHAS.md`, `CLOUD_FUNCTIONS_GOTCHAS.md`)?
