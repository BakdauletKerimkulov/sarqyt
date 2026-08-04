---
title: Specific Architecture
status: done
date: 2026-05-11
type: feature
---

# Plan: Project-Specific Architecture Documentation

Source: `ai_specs/specific-architecture-spec.md`

## Overview

Create 5 documentation files in `ai_docs/` capturing sarqyt-specific decisions that an AI cannot infer from code alone, then update `PROJECT.md` with cross-references. Each file documents decisions in "what + why" format, verified against the current codebase during the refine step. No code changes — documentation only.

## Stages

### Stage 1: EXTERNAL_SERVICES.md

**Goal:** Document all external service choices, configuration quirks, and environment variable conventions.

**Files to create/modify:**
- `ai_docs/EXTERNAL_SERVICES.md` — new file

**Steps:**
- [x] Document Stadia Maps choice over Google Maps (billing reason), tile URL pattern, API key via envied
- [x] Document Stripe setup: KZT currency, keys via Firebase Secret Manager (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`), `flutter_stripe` client-side
- [x] Document Firebase Cloud Functions region split: triggers = `asia-south1` (per-function), callables = `us-central1` (default). Include warning not to add `setGlobalOptions`
- [x] Document Firebase Hosting: single `build/web` config, business-only is a deploy convention not a config constraint
- [x] Document FCM: token at `users/{uid}.fcmToken`, `set(merge: true)`, `onTokenRefresh` listener
- [x] Document envied setup: `lib/env.dart` with `obfuscate: true`, three keys (`STRIPE_PUBLISHABLE_KEY`, `STADIA_MAPS_API_KEY`, `SUPABASE_URL`), generated `env.g.dart`
- [x] Add `TODO: ask maintainer` for Supabase URL purpose

**Verification:** Read file, confirm each item has a "why" or "how", no universal patterns duplicated from `ai_toolkit/guidelines/firebase.md`.

---

### Stage 2: FIRESTORE_GOTCHAS.md

**Goal:** Document non-obvious Firestore schema decisions, ID patterns, and denormalization choices.

**Files to create/modify:**
- `ai_docs/FIRESTORE_GOTCHAS.md` — new file

**Steps:**
- [x] Document offers as top-level collection (geo-query requirement via geoflutterfire_plus)
- [x] Document order write permissions: creation = server-only (`allow create: if false`), status updates = client allowed for store staff
- [x] Document StoreShip composite ID `{storeId}_{userId}` and why (direct lookup without query)
- [x] Document two idempotency strategies in stripeWebhook: deterministic order doc ID vs `_processedEvents` collection
- [x] Document StoreDraft TTL: `expiresAt = now + 3 days`, relies on Firestore native TTL policy. Add `TODO: verify TTL configured in console`
- [x] Document `orderCounter` on stores (set via `onOrderCreated` trigger), `orderNumber` on orders
- [x] Document denormalized fields: offers have `storeName` + `storeAddress` (patched on sync); orders have `storeName` only
- [x] Document geohash precision 4 (~39km x 20km) for KZ city coverage
- [x] Document legacy `originalPrice` → `estimatedValue` fallback in Item model

**Verification:** Each item references the actual collection/field names. Cross-check against `firestore.rules` and domain models.

---

### Stage 3: CLOUD_FUNCTIONS_GOTCHAS.md

**Goal:** Document non-obvious Cloud Functions decisions, schedules, and retry logic.

**Files to create/modify:**
- `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` — new file

**Steps:**
- [x] Document two order creation paths: `reserveOffer` (no payment, direct order) vs `createPayment` + `stripeWebhook` (Stripe flow)
- [x] Document `fakeVerifyBusiness`: purpose (dev-only gov verification sim), 25s delay, what it sets
- [x] Document `dailySyncOffers` at 00:30 UTC (06:30 Almaty time — after midnight, before morning orders)
- [x] Document `expireOrders` every 5 minutes (why not Firestore TTL: need status transition + notification side effects)
- [x] Document offer sync: 2-day lookahead (`DAYS_AHEAD = 2`), single offer for oneTime. Flag stale JSDoc claiming 7 days
- [x] Document refund retry in `cancelOrder`: 3 attempts, exponential backoff (1s, 2s), `refund_failed` on exhaustion
- [x] Document secrets: `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` via `defineSecret`, no `process.env`

**Verification:** Each schedule/constant matches the actual code values verified during refine.

---

### Stage 4: ROUTING_DECISIONS.md

**Goal:** Document app structure, routing patterns, and scoped provider decisions.

**Files to create/modify:**
- `ai_docs/ROUTING_DECISIONS.md` — new file

**Steps:**
- [x] Document two-app architecture: `main.dart` (business) vs `main_client.dart` (client), separate routers, why not role-switching in one app
- [x] Document business redirect: 8 sync-only layers in `businessRedirect()`, why no async (GoRouter redirect must be synchronous)
- [x] Document `StoreStartupWidget` scoped provider override: wraps navigation in `ProviderScope` with `currentStoreShipProvider`, `currentBusinessProvider`, `currentBusinessStreamProvider`
- [x] Document tab/branch counts: client = 3 (Discover, Orders, Profile), business = 5 (Dashboard, Performance, Financials, Settings, HelpCentre)
- [x] Document Firebase Hosting as deploy convention (flavor-agnostic config)

**Verification:** Tab/branch counts match actual router files. Provider override names match code.

---

### Stage 5: BUSINESS_RULES.md

**Goal:** Document domain rules, state machines, and enforcement gaps.

**Files to create/modify:**
- `ai_docs/BUSINESS_RULES.md` — new file

**Steps:**
- [x] Document order status state machine with transition table and terminal states
- [x] Document review-per-order: design intent, NOT enforced. `hasReviewForOrder()` exists but not called by `submitReview`
- [x] Document item schedule constraints: `maxQuantity = 30`, `maxWindowMinutes = 120`, start < end
- [x] Document offer visibility: `visibleFrom = startOfDay(pickupDate - 1 day, storeTimeZone)` vs `pickupStartTime`
- [x] Document price model: `price` vs `estimatedValue`, `discountPercent` formula, legacy `originalPrice` fallback
- [x] Document store verification flow: draft → fakeVerify/realVerify → complete → Store + Business + StoreShip + partner claim. No pending state.
- [x] Document partner permissions: owner (full), operator (no financials), employer (defined, not implemented). Server-side: `ownerId` vs `staffIds` only.

**Verification:** State machine transitions match `update-order-status.ts`. Permission gating matches `scaffold_with_nested_navigation.dart`.

---

### Stage 6: Update PROJECT.md

**Goal:** Add cross-references to the 5 new docs so they're discoverable.

**Files to create/modify:**
- `ai_docs/PROJECT.md` — modify existing file

**Steps:**
- [x] Add "Non-Obvious Decisions" section after "Order & Payment Flow" pointing to new files with one-line descriptions
- [x] Add "See Also" section at the bottom linking each `ai_docs/` file and `ai_toolkit/guidelines/`

**Verification:** All 5 new file paths are correct and files exist. No content duplication — only pointers.

## Firestore Changes

None. This is documentation only.

## Cloud Functions

None. This is documentation only.

## Test Coverage

Not applicable — no code changes. Verification is manual review of documentation accuracy.

## Risks

| Risk | Mitigation |
|------|------------|
| "Why" answers may be wrong or incomplete for some decisions | Mark uncertain items as `TODO: ask maintainer` rather than guessing |
| Stale information if code changes after docs are written | Each doc should be treated as a snapshot; include last-verified date |
| File naming mismatch with `ai_toolkit/guidelines/firebase.md` references (`FIRESTORE_SCHEMA.md` / `CLOUD_FUNCTIONS.md`) | Open question from refine — decide whether to align names or update guideline references |
| Three open questions from refine need maintainer input | Supabase purpose, StoreDraft TTL console config, guideline file name references |

## Out of Scope

- Rewriting `ai_toolkit/guidelines/` — universal, maintained separately
- Documenting every Firestore field — only non-obvious ones
- Writing code or making code changes
- API documentation or user-facing docs
- Deployment runbooks or CI/CD setup
