# Spec: Reviews Feature — Display, Aggregation & Reading

Created: 2026-06-10
Status: refined
Refined: 2026-06-10
Source request: ai_specs/010-reviews-feature-impl.md

## Goal

Complete the partially-implemented reviews feature: connect rating aggregation via Cloud Functions, display real store ratings on offer cards and detail screens, and let customers read reviews for any store. Rename `foodRating` to `offerRating` for clarity.

## Background

**Stack & conventions:** Flutter + Riverpod codegen (`@riverpod`), Freezed models, feature-first structure with `domain/data/application/presentation` layers. Firebase Cloud Functions (TypeScript) for server-side logic. Firestore triggers in `asia-south1`, callable functions default `us-central1`. All user-visible strings in ARB files (`ai_toolkit/architecture.md`, `ai_toolkit/riverpod.md`, `ai_toolkit/firebase.md`).

**Project context:** Sarqyt is a TGTG-style surplus food marketplace. The review feature is ~40% complete:
- **Working:** Review domain model (`lib/src/features/review/domain/review.dart`), submission form (`review_screen.dart`), controller (`review_controller.dart`), repository with `submitReview()` + `hasReviewForOrder()` + `watchStoreReviews()`, route in `client_router.dart`, security rules, localization keys.
- **Incomplete/Missing:** No rating aggregation (Store has `avgRating` field at line 21 but it's never computed). `RatingIcon` widget passes no data (`offer_card.dart:86`). `RatingInformation` widget exists (`rating_information.dart`) but is not mounted anywhere on the offer screen — dead code with hardcoded highlight tags. `watchStoreReviews()` has no Riverpod provider. No review list screen. `flutter_rating_bar` package installed but unused.
- **Note:** `Rating` model in `offers/domain/rating.dart` is **not** unused — it is actively used by the `Item` model (`item.dart:47`) for item-level aggregate ratings and by `RatingInformation`. It is a separate concept from per-review `Review` ratings and must not be deleted or confused with review aggregation.

**Why now:** Reviews are a core marketplace trust signal. The submission path works but ratings are invisible to users — the feature is essentially dormant.

## User Flow

### Happy path

1. Customer completes an order -> on order detail screen, taps "Leave a review" (already works).
2. Customer rates store (1-5 stars) and offer (1-5 stars, renamed from "food"), optionally writes a comment -> submits -> review saved to Firestore (already works).
3. Cloud Function `onReviewWritten` trigger fires -> recalculates `avgRating` and `reviewCount` on the Store document.
4. Customer browses offers on home screen -> each `OfferCard` shows the store's `avgRating` via `RatingIcon` with real data. Stores with 0 reviews show "New" badge.
5. Customer taps an offer -> offer detail screen shows store rating in `RatingIcon` + last 3 reviews preview in a section below store info.
6. Customer taps "All reviews" -> navigates to `StoreReviewsScreen` with a scrollable list of all store reviews.

### Alternative flows

- If a store has 0 reviews, the reviews section on offer detail screen shows empty state: "No reviews yet" message.
- If a store has 1-3 reviews, all are shown inline without "All reviews" button.

### Error & recovery flows

- If `watchStoreReviews` stream fails, the reviews section shows a generic error with retry.
- If Cloud Function aggregation fails, `avgRating`/`reviewCount` remain stale. No user-facing error — the UI reads from the Store document directly.

### Edge cases

- Empty state: Store with 0 reviews -> "New" badge on cards, "No reviews yet" on detail screen.
- First review: After submitting the first review, Cloud Function sets `avgRating` and `reviewCount = 1` on Store.
- Large dataset: `watchStoreReviews()` already orders by `createdAt desc`. Full list screen should use a reasonable `.limit()` (e.g. 50) to avoid unbounded reads. Pagination deferred.
- Concurrent reviews: Cloud Function uses transaction to read current aggregates and recompute from all reviews.

## Requirements

### Must Have

- [ ] R1: Rename `foodRating` -> `offerRating` in Review model (`review.dart`), repository (`review_repository.dart`), controller (`review_controller.dart`), and screen (`review_screen.dart`). Update ARB key `howWasTheFood` -> `howWasTheOffer` in all 3 locales. Backward compatibility: (a) In `review.dart`, use `@JsonKey(readValue: ...)` or a custom read function that reads `offerRating` with fallback to `foodRating` for old docs. (b) In `submitReview()`, write `'offerRating'` as the new Firestore field name (not `'foodRating'`). (c) Cloud Function in R3 must also read both `offerRating` and `foodRating` (fallback) when computing aggregates. Verifiable by: `flutter analyze` passes, new submissions write `offerRating`, old docs with `foodRating` still parse correctly.
- [ ] R2: Add `reviewCount` field to Store model (`store.dart`) with `@Default(0) int reviewCount`. Update `Store.fromMap()` and `toMap()`. Verifiable by: model parses docs with and without `reviewCount`.
- [ ] R3: Cloud Function `onReviewWritten` — Firestore onWrite trigger on `reviews/{reviewId}`, region `asia-south1` (matching existing Firestore triggers per `EXTERNAL_SERVICES.md`). On create/update/delete, query all reviews for `storeId`, compute `avgRating` (average of all `averageRating` values, i.e. `(storeRating + offerRating) / 2` — read `offerRating` with fallback to `foodRating` for old docs) and `reviewCount`, write to `stores/{storeId}`. Use transaction. Check that store document exists before writing. Verifiable by: create a review in emulator -> Store doc `avgRating` and `reviewCount` update.
- [ ] R4: Pass real `avgRating` to `RatingIcon` in `OfferCard`. Strategy: add `storeAvgRating` (double, default 0) and `storeReviewCount` (int, default 0) fields to the Offer model (`offer.dart`). These are denormalized from the Store document and populated by the `daily-sync-offers` Cloud Function (see R4b). `OfferCard` passes `offer.storeAvgRating` to `RatingIcon`. `RatingIcon` MVP behavior: when `rating` > 0, show star icon + numeric text (e.g. "4.2"); when `rating` is 0 or null, show "New" badge. Verifiable by: offer cards show real rating or "New".
- [ ] R4b: Update `daily-sync-offers` Cloud Function to copy `avgRating` -> `storeAvgRating` and `reviewCount` -> `storeReviewCount` from the Store document to each generated Offer document. Verifiable by: after daily-sync runs, Offer docs contain correct store rating data.
- [ ] R5: Create `storeReviewsProvider` — a `@riverpod` stream provider parameterized by `StoreID`, using `reviewRepository.watchStoreReviews(storeId)`. Verifiable by: provider emits list of reviews for a given store.
- [ ] R6: Delete `RatingInformation` widget (`rating_information.dart`) — it is dead code, not mounted on any screen. Replace with `ReviewsSection` widget (see R7). The new widget shows: `RatingIcon` with real `avgRating`, text "{average} / 5.0 ({reviewCount})", and a preview of the last 3 reviews (each showing star rating, comment snippet, date). Verifiable by: offer detail screen shows real review data.
- [ ] R7: Add reviews preview section to `OfferSliverContent` (`offer_screen.dart`) — after the store info divider, show `RatingIcon` + last 3 reviews. If > 3 reviews, show "All reviews" button. If 0 reviews, show "No reviews yet". Verifiable by: visible on offer detail screen with test data.
- [ ] R8: Create `StoreReviewsScreen` — full-screen list of all reviews for a store, with `AppBar` showing store name. Each review card shows: star ratings (store + offer), comment text, relative date. Note: the Review model stores `userId` but no user name — show anonymous reviews without names (no avatar/initials needed for MVP). Use `watchStoreReviews` stream with `limit: 50`. Verifiable by: navigating from "All reviews" shows complete list.
- [ ] R9: Add `storeReviews` value to `ClientRoute` enum and add corresponding `GoRoute` to `client_router.dart`. Navigate via `context.pushNamed(ClientRoute.storeReviews.name, pathParameters: {'storeId': storeId}, queryParameters: {'storeName': storeName})`. Path: `/store-reviews/:storeId` as a standalone route. Deep link fallback: if `storeName` query param is missing, fetch store name from the Store document (or show a generic "Reviews" title). Verifiable by: both `pushNamed` navigation and deep link work.
- [ ] R10: Add missing ARB keys for new UI elements in all 3 locales (en, ru, kk): `howWasTheOffer`, `noReviewsYet`, `allReviews`, `reviewCount` (parameterized), review date format. Remove dead ARB keys from deleted `RatingInformation`: `addHighlights`, `quickCollection`, `friendlyStaff`, `basedOnRatings`. Verifiable by: `flutter gen-l10n` succeeds, no hardcoded strings, no dead keys.
- [ ] R11: Update Firestore security rules for `stores/{storeId}` to protect `avgRating` and `reviewCount` from client writes. Use the `serverFieldsUnchanged(['avgRating', 'reviewCount'])` pattern from `ai_toolkit/firebase.md`. Verifiable by: client-side update attempt to `avgRating` is rejected in emulator.

### Nice to Have

- [ ] N1: Show a proportionally filled star icon (e.g. 3.7/5 shows star 73% filled) instead of a simple badge. Can use `flutter_rating_bar` (already in `pubspec.yaml`) in read-only mode.

### Non-functional

- Performance: Reviews preview on offer screen should use the first 3 items from the stream, not a separate query. Full list screen limits to 50 documents per load.
- Accessibility: Star icons must have semantic labels (e.g. "4.2 out of 5 stars"). Review cards must be readable by screen reader.
- i18n: All new user-visible strings in ARB files. No hardcoded Russian/Kazakh in Dart.

## Technical Constraints

**Files to create:**

- `lib/src/features/review/application/store_reviews_provider.dart` — `@riverpod` stream provider for store reviews
- `lib/src/features/review/presentation/store_reviews_screen.dart` — full list of reviews for a store
- `lib/src/features/review/presentation/widgets/review_card.dart` — single review display widget (reused in preview and full list)
- `lib/src/features/review/presentation/widgets/reviews_section.dart` — preview section for offer detail screen (RatingIcon + last 3 reviews + "All reviews" button)
- `functions/src/features/triggers/reviews.ts` — `onReviewWritten` Cloud Function

**Files to modify:**

- `lib/src/features/review/domain/review.dart` — rename `foodRating` -> `offerRating`, add `@JsonKey(readValue: ...)` or custom read function to read `offerRating` with fallback to `foodRating` for old docs
- `lib/src/features/review/data/review_repository.dart` — write `'offerRating'` in `submitReview()`, add optional `int? limit` param to `watchStoreReviews()` (null = unlimited, preview passes 3, full list passes 50)
- `lib/src/features/review/presentation/review_screen.dart` — rename `_foodRating` -> `_offerRating`, update label to `howWasTheOffer`
- `lib/src/features/review/presentation/review_controller.dart` — rename `foodRating` param -> `offerRating`
- `lib/src/features/store/domain/store.dart` — add `reviewCount` field
- `lib/src/features/offers/domain/offer.dart` — add `storeAvgRating` and `storeReviewCount` fields (optional, default 0)
- `lib/src/features/offers/presentation/offer_list/offer_card.dart` — pass `offer.storeAvgRating` to `RatingIcon`
- `lib/src/features/offers/presentation/offer_screen/offer_screen.dart` — add `ReviewsSection` widget to `OfferSliverContent`
- `lib/src/features/offers/presentation/offer_screen/rating_information.dart` — delete (dead code, not mounted anywhere; replaced by `ReviewsSection`)
- `lib/src/routing/client_router.dart` — add `storeReviews` route
- `lib/l10n/app_en.arb`, `app_ru.arb`, `app_kk.arb` — add/update keys
- `functions/src/index.ts` — export `onReviewWritten`
- `functions/src/features/offers/functions/daily-sync-offers.ts` — copy `avgRating` -> `storeAvgRating` and `reviewCount` -> `storeReviewCount` from Store to Offer docs (R4b)
- `firestore.rules` — add `serverFieldsUnchanged(['avgRating', 'reviewCount'])` to `stores/{storeId}` update rule (R11)

**Patterns to follow (with citations):**

- Follow the Firestore trigger pattern in `functions/src/features/triggers/orders.ts` for `onReviewWritten`.
- Follow the stream provider pattern in `lib/src/features/offers/data/client_offer_repository.dart` for `storeReviewsProvider`.
- Follow `OfferCard` (`offer_card.dart`) for how `RatingIcon` is positioned.
- Follow `ReviewScreen` (`review_screen.dart`) for `_StarRow` widget pattern (or switch to `flutter_rating_bar` in read-only mode for display).

**Anti-patterns / avoid:**

- Do not add a new dependency — `flutter_rating_bar` is already in `pubspec.yaml`.
- Do not duplicate review aggregation logic on the client — Cloud Function is the single source of truth.
- Do not read all reviews on the client to compute avg — use the denormalized `avgRating` on Store/Offer.
- Do not create a separate Firestore collection for aggregated ratings — store on the Store document.
- Do not modify or delete the `Rating` model in `offers/domain/rating.dart` — it is actively used by the `Item` model for item-level aggregate ratings. It is a separate concept from review-based store ratings.

**Data layer changes:**

- Store document: add fields `avgRating` (double, default 0) and `reviewCount` (int, default 0). Both are server-authoritative — written only by Cloud Functions.
- Offer document: add fields `storeAvgRating` (double, default 0) and `storeReviewCount` (int, default 0). Populated during daily-sync from Store doc.
- Review document: new submissions write `offerRating`. Backward compatibility: Cloud Function and Dart model must read both `offerRating` and `foodRating` (fallback) for existing docs. Old docs are not migrated.
- Composite index on `reviews`: `storeId` ASC + `createdAt` DESC — already exists in `firestore.indexes.json` (verified).
- Security rules: `avgRating` and `reviewCount` on Store must be protected from client writes via `serverFieldsUnchanged`.

**External integrations:** None. All within Firebase ecosystem.

## Edge Cases

See User Flow -> Edge cases above. Additionally:
- Old reviews with `foodRating` field must still be readable after rename.
- Store with deleted reviews: `onReviewWritten` handles delete event, recomputes aggregates.
- Review for a store that no longer exists: Cloud Function should check store exists before writing aggregates.

## Out of Scope

- **NOT** implementing review filters or "best reviews" display — explicitly deferred per request.
- **NOT** adding business-side review dashboard — deferred per user decision.
- **NOT** adding review edit/delete UI — security rules allow it, but no UI needed now.
- **NOT** adding highlight tags (quick collection, friendly staff, etc.) — removing the placeholder.
- **NOT** adding pagination for reviews list — initial limit of 50 is sufficient for MVP.
- **NOT** validating in security rules that reviewer has a completed order — deferred.
- **NOT** preventing multiple reviews per user per store — only per-order check exists, sufficient for now.
- **NOT** cleaning up `offer_review_bar.dart` (bar widget in review feature presentation layer) — out of scope.
- **NOT** fixing the `cloud_firestore` import in `review/domain/review.dart` (architecture violation: domain layer should be pure Dart). Pre-existing pattern also present in `offers/domain/offer.dart`. Should not be worsened but is out of scope to fix here.

## Validation

**Automated tests:**

- Unit: `review_model_test.dart` — verify `offerRating` rename, `averageRating` computation still correct.
- Unit: `store_model_test.dart` — verify `reviewCount` parsing from map with and without field.
- Unit (CF): `on-review-written.test.ts` — verify aggregation logic (create/update/delete scenarios).

**Manual QA scenarios:**

1. Given a store with 0 reviews, when viewing its offer card on home screen, then `RatingIcon` shows "New" badge.
2. Given a completed order, when submitting a review with storeRating=4 and offerRating=5, then review appears in Firestore, Store `avgRating` updates to 4.5, `reviewCount` updates to 1.
3. Given a store with 5 reviews, when opening offer detail screen, then reviews section shows `RatingIcon` with correct avg, 3 review cards, and "All reviews" button.
4. Given the "All reviews" button, when tapping it, then navigates to `StoreReviewsScreen` showing all 5 reviews ordered by newest first.
5. Given a store with 1 review, when viewing offer detail screen, then 1 review card shown inline, no "All reviews" button.
6. Given old review docs with `foodRating` field, when loading reviews, then they parse correctly (backward compat).

**Expected behavior under edge conditions:**

- Offline -> Reviews section shows cached data or loading state; submission queued by Firestore SDK.
- Backend error (CF fails) -> `avgRating`/`reviewCount` stale but no user-facing error; reviews list still works via direct Firestore read.
- Empty data -> "New" badge on cards, "No reviews yet" on detail screen.

## Definition of Done

- [ ] All Must Have requirements (R1-R11) pass automated tests
- [ ] All 6 Manual QA scenarios pass on iOS simulator and Android emulator
- [ ] `flutter analyze` passes with no new warnings
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds
- [ ] `flutter gen-l10n` succeeds
- [ ] Cloud Function deploys and triggers correctly in emulator
- [ ] No new lint warnings; matches `ai_toolkit/` style guide
- [ ] Spec file linked in the PR description
