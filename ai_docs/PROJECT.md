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
| Payments | Stripe (via `flutter_stripe`, Cloud Functions for server-side) |
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
| `checkout` | Purchase flow, Stripe payment integration |
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
| `payments` | `create-payment`, `reserve-offer`, `stripe-webhook` |
| `orders` | `cancel-order`, `expire-orders`, `update-order-status`, `on-order-status-changed` |
| `offers` | `daily-sync-offers` (generates offers from active items) |
| `merchant-onboarding` | Business verification and store creation |
| `triggers` | Firestore triggers for side-effects |

## Firestore Collections

| Collection | Description |
|---|---|
| `stores/{storeId}` | Store profiles |
| `stores/{storeId}/items/{itemId}` | Items (products) belonging to a store |
| `offers/{offerId}` | Published offers (public read, admin-only write via Cloud Functions) |
| `orders/{orderId}` | Orders (created by Cloud Functions only) |
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
2. `reserve-offer` Cloud Function reserves quantity (decrement) and creates payment intent
3. `create-payment` processes Stripe payment
4. `stripe-webhook` confirms payment, creates Order document
5. Store owner/staff moves order through statuses: preparing -> readyForPickup -> completed
6. `expire-orders` handles timeout for uncollected orders
