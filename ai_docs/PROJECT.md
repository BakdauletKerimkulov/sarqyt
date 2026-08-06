# Sarqyt — Project Overview

## What is Sarqyt?

Sarqyt is a **Too Good To Go (TGTG)-style marketplace** for surplus food in Kazakhstan. Stores (restaurants, bakeries, cafes) list surprise bags or specific items at a discount, and customers buy and pick them up during a time window.

Currency: **KZT (Kazakhstani Tenge, symbol: ₸)**.

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart 3.9+), multi-platform (Android, iOS, Web) |
| State management | Riverpod 3 with codegen (`@riverpod`) |
| Models | Freezed + json_serializable for immutable domain models |
| Backend | Firebase (Firestore, Auth, Storage, Cloud Functions, Messaging, Crashlytics) |
| Payments | None — reserve-only, customer pays offline at the store's terminal |
| Maps | flutter_map + latlong2 + geolocator + geoflutterfire_plus (geo-queries) |
| Cloud Functions | TypeScript (Node.js), located in `functions/` |
| Hosting | Firebase Hosting (business web app at `build/web`) |

## Two Apps, One Codebase

The project has **two entry points** sharing the same codebase:

- **`main_client.dart`** — Customer-facing app (`MyAppClient`). Browse offers on map, purchase surprise bags, track orders.
- **`main.dart`** — Business-facing app (`MyAppBusiness`). Manage store, items, offers, view orders/reservations, dashboard.
- **`main_fakes_client.dart`** — Client app with fake data for development.

Each app has its own router (`client_router.dart` / `business_router.dart`).

## Feature Modules

Located in `lib/src/features/`:

| Feature | Purpose |
|---|---|
| `auth` | Firebase Auth, sign-in (email/password), profile editing, settings |
| `store` | Store domain model, store data layer |
| `items` | Item (product/surprise bag) CRUD — scheduled or one-time, with weekly schedule |
| `offers` | Published offers with quantity, pickup window, geo-location, badges, ratings |
| `orders` | Order lifecycle: confirmed -> preparing -> readyForPickup -> completed/cancelled/expired |
| `checkout` | Reservation flow — quantity selection and `reserveOffer`; no payment step |
| `map` | Map view with clustered markers for nearby offers |
| `review` | Customer reviews and ratings |
| `business_console` | Business dashboard, store verification (3-step), financials, settings |
| `onboarding` | New user onboarding flow |
| `notifications` | Push notifications via Firebase Messaging |

Each feature follows **feature-first** structure with layers: `domain/`, `data/`, `application/`, `presentation/`.

## Cloud Functions (TypeScript)

Located in `functions/src/features/`:

| Module | Key Functions |
|---|---|
| `payments` | `reserve-offer` (no separate payment-confirmation function exists) |
| `orders` | `cancel-order`, `expire-orders`, `update-order-status`, `on-order-status-changed` |
| `offers` | `daily-sync-offers` (generates offers from active items) |
| `merchant-onboarding` | Business verification and store creation |
| `notifications` | Push notifications for the order lifecycle: `on-order-created`/`on-order-status-changed` triggers (via `triggers/`) send FCM pushes through `helpers/send-push.ts`; `sendOrderReminders` (`onSchedule`, every 5 minutes) sends up to three pickup-window reminders plus a delayed review request. Texts live in `core/messages.ts`, scheduling logic in `core/reminders.ts` — both pure and unit-tested |
| `triggers` | Firestore triggers for side-effects |

## Firestore Collections

| Collection | Description |
|---|---|
| `stores/{storeId}` | Store profiles |
| `stores/{storeId}/items/{itemId}` | Items (products) belonging to a store |
| `offers/{offerId}` | Published offers (public read, admin-only write via Cloud Functions) |
| `orders/{orderId}` | Orders (created by Cloud Functions only). `completedAt: Timestamp?` set on transition to `completed`; `remindersSent: { beforeStart, midWindow, beforeEnd, reviewPrompt }` (all optional booleans, absence == `false`) tracks which notifications the scheduler already sent |
| `payments/{paymentId}` | Payment records (Cloud Functions only) |
| `users/{uid}` | User profiles |
| `users/{uid}/favorites/{storeId}` | Favorited stores |
| `reviews/{reviewId}` | Customer reviews |
| `storeDrafts/{draftId}` | Merchant onboarding drafts |
| `storeShips/{shipId}` | User-to-store binding (staff/owner) |
| `businesses/{businessId}` | Business entities |
| `business_membership/{id}` | User-to-business membership |
| `_processedEvents/{id}` | Idempotency dedup (internal) |

## User Roles

Managed via Firebase Auth custom claims:

- **Customer** (default) — browse offers, purchase, leave reviews
- **Partner** (`role: 'partner'`) — manage their store(s), view orders
- **Admin** (`role: 'admin'`) — full access

Partners can create stores if `canCreateStore` custom claim is `true`.

## Key Domain Models

- **Item** — a product template with price, schedule (weekly or one-time), dietary type, packaging option
- **Offer** — a published instance of an item with quantity, pickup window, geolocation, status (active/paused/expired)
- **Order** — a purchase record with status flow: `confirmed -> preparing -> readyForPickup -> completed | cancelled | expired`
- **Store** — business location with address, logo, rating, currency

## Order & Payment Flow

1. Customer selects offer and quantity
2. `reserve-offer` Cloud Function reserves quantity (decrement) and creates the `orders/{orderId}` document directly (status `confirmed`) — there is no payment step of any kind; the customer pays at the store on pickup
3. `triggers/onOrderCreated` assigns `orderNumber` and pushes the new order to the store team
4. Store owner/staff moves order through statuses: preparing -> readyForPickup -> completed, each transition notified via `on-order-status-changed`
5. `expire-orders` handles timeout for uncollected orders; `sendOrderReminders` sends pickup-window reminders and, 2h after `completedAt`, a review request if none was left

## Non-Obvious Decisions

Project-specific rationale that can't be inferred from reading the code alone — read before touching these areas:

- [`ai_docs/FIRESTORE_GOTCHAS.md`](FIRESTORE_GOTCHAS.md) — schema decisions, ID patterns, denormalization, known security-rule gaps
- [`ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md`](CLOUD_FUNCTIONS_GOTCHAS.md) — schedules, region split, idempotency, retry logic
- [`ai_docs/ROUTING_DECISIONS.md`](ROUTING_DECISIONS.md) — two-app structure, redirect layers, scoped providers
- [`ai_docs/BUSINESS_RULES.md`](BUSINESS_RULES.md) — order state machine, permissions, enforcement gaps

## See Also

- [`ai_docs/GLOSSARY.md`](GLOSSARY.md) — canonical domain vocabulary
- [`ai_docs/EXTERNAL_SERVICES.md`](EXTERNAL_SERVICES.md) — third-party service choices and config quirks
- [`ai_docs/FIRESTORE_GOTCHAS.md`](FIRESTORE_GOTCHAS.md), [`ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md`](CLOUD_FUNCTIONS_GOTCHAS.md), [`ai_docs/ROUTING_DECISIONS.md`](ROUTING_DECISIONS.md), [`ai_docs/BUSINESS_RULES.md`](BUSINESS_RULES.md) — see above
- [`ai_docs/solutions/`](solutions/) — accumulated bug-fix, refactor, and tooling lessons
- `ai_toolkit/RULES.md` — universal engineering rules (Flutter, Riverpod, GoRouter, Firebase) this project follows
