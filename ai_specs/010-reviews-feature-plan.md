# Plan: Reviews Feature — Display, Aggregation & Reading

Source: `ai_specs/010-reviews-feature-spec.md`
Created: 2026-06-10
Status: in-progress (phase 1 complete)

## Overview
Complete the partially-implemented reviews feature: rename `foodRating` → `offerRating`, add Cloud Function aggregation (`onReviewWritten`), display real store ratings on offer cards and detail screens, and build a store reviews list screen. Phase 1 proves the critical path end-to-end: rename + aggregation + rating visible on cards.

**Spec:** `ai_specs/010-reviews-feature-spec.md`

## Context
- **Structure:** Feature-first (`features/review/{domain,data,application,presentation}`)
- **State management:** Riverpod codegen (`@riverpod`), AsyncNotifier controllers — cited: `lib/src/features/review/presentation/review_controller.dart`
- **Reference implementations:**
  - Trigger pattern: `functions/src/features/triggers/orders.ts` (onDocumentCreated, transaction, region asia-south1)
  - Stream provider: `lib/src/features/review/data/review_repository.dart` (`watchStoreReviews()` exists but has no provider)
  - Offer materialization: `functions/src/features/offers/types/offer-sync.ts` (`MaterializedOfferFields`) + `build-expected-offers.ts`
- **Testing convention:** Mirror `lib/` structure in `test/`, `group()` + `test()`, mock repos for controllers, domain model unit tests — cited: `ai_toolkit/architecture.md:529-567`
- **Lint + test command:** `flutter analyze && flutter test` (Dart); CF tests via `npm test` in `functions/`
- **Assumptions / Gaps:**
  - `daily-sync-offers` copies store fields into `MaterializedOfferFields` during materialization — adding `storeAvgRating`/`storeReviewCount` requires updating `MaterializedOfferFields` interface + `buildMaterializationTemplate()` + `buildExpectedOffers()`
  - `onDocumentWritten` (not just `onDocumentCreated`) needed for R3 to handle create/update/delete — `orders.ts` only uses `onDocumentCreated`, so reviews trigger will differ slightly
  - Firestore rules for stores currently allow update for admin/owner — `serverFieldsUnchanged` guard needs to be added to the existing `allow update` rule

## Plan

### Phase 1 — Data foundation + Cloud Function aggregation
**Goal:** Rename foodRating → offerRating with backward compat, add reviewCount to Store, deploy CF that computes avgRating/reviewCount. Proves: submit review → CF fires → Store doc updated → RatingIcon shows real data on cards.

- [x] TDD: `test/features/review/review_model_test.dart` — review model parses `offerRating`; falls back to `foodRating` for old docs; `averageRating` computation correct
- [x] `lib/src/features/review/domain/review.dart` — rename `foodRating` → `offerRating`, add `@JsonKey(readValue: ...)` fallback for `foodRating`
- [x] `lib/src/features/review/data/review_repository.dart` — write `'offerRating'` in `submitReview()`; rename param; add optional `int? limit` to `watchStoreReviews()`
- [x] `lib/src/features/review/presentation/review_controller.dart` + `review_screen.dart` — rename `foodRating` → `offerRating`, update label to `howWasTheOffer`
- [x] TDD: `test/features/store/store_model_test.dart` — store model parses `reviewCount` with and without field present
- [x] `lib/src/features/store/domain/store.dart` — add `@Default(0) int reviewCount`
- [x] `functions/src/features/triggers/reviews.ts` — `onReviewWritten` using `onDocumentWritten` on `reviews/{reviewId}`, region `asia-south1`, transaction: query all reviews for storeId, compute avgRating + reviewCount, write to store doc. Read `offerRating` with fallback to `foodRating`
- [x] `functions/src/index.ts` — export `onReviewWritten`
- [x] `lib/l10n/app_en.arb`, `app_ru.arb`, `app_kk.arb` — rename `howWasTheFood` → `howWasTheOffer`
- [x] Verify: `flutter analyze && dart run build_runner build --delete-conflicting-outputs && flutter test`

### Phase 2 — Display ratings on cards + reviews preview on offer detail
**Goal:** Real ratings visible on OfferCard. Offer detail screen shows reviews section with last 3 reviews.

- [ ] `lib/src/features/offers/domain/offer.dart` — add `@Default(0.0) double storeAvgRating`, `@Default(0) int storeReviewCount`
- [ ] `lib/src/features/offers/presentation/offer_list/offer_card.dart` — pass `offer.storeAvgRating` to `RatingIcon(rating: ...)`; show "New" badge when 0
- [ ] `lib/src/features/review/application/store_reviews_provider.dart` — `@riverpod` stream provider parameterized by storeId, uses `reviewRepository.watchStoreReviews(storeId, limit: limit)`
- [ ] `lib/src/features/review/presentation/widgets/review_card.dart` — single review display: star ratings, comment snippet, relative date. Reused in preview and full list
- [ ] `lib/src/features/review/presentation/widgets/reviews_section.dart` — RatingIcon + "{avg} / 5.0 ({count})" + last 3 reviews via `storeReviewsProvider(storeId, limit: 3)`. If >3 reviews: "All reviews" button. If 0: "No reviews yet"
- [ ] `lib/src/features/offers/presentation/offer_screen/offer_screen.dart` — mount `ReviewsSection` in `OfferSliverContent` after store info divider (around line 185)
- [ ] Delete `lib/src/features/offers/presentation/offer_screen/rating_information.dart` — dead code, replaced by `ReviewsSection`
- [ ] Verify: `flutter analyze && dart run build_runner build --delete-conflicting-outputs && flutter test`

### Phase 3 — Full reviews list + routing + daily-sync + security
**Goal:** Navigate to full store reviews screen, daily-sync populates rating on Offer docs, security rules protect server fields.

- [ ] `lib/src/features/review/presentation/store_reviews_screen.dart` — full-screen list of reviews for a store; AppBar with store name; uses `storeReviewsProvider(storeId, limit: 50)`; reuses `ReviewCard`
- [ ] `lib/src/routing/client_router.dart` — add `storeReviews` to `ClientRoute` enum; add `GoRoute` at path `/store-reviews/:storeId` with `storeName` query param; deep link fallback shows generic "Reviews" title
- [ ] `functions/src/features/offers/types/offer-sync.ts` — add `storeAvgRating` (number) and `storeReviewCount` (number) to `MaterializedOfferFields`
- [ ] `functions/src/features/offers/services/build-expected-offers.ts` — copy `avgRating` → `storeAvgRating` and `reviewCount` → `storeReviewCount` from `StoreDoc` into materialized offer fields
- [ ] `lib/l10n/app_en.arb`, `app_ru.arb`, `app_kk.arb` — add `noReviewsYet`, `allReviews`, `reviewCount` (parameterized), review date format; remove dead keys: `addHighlights`, `quickCollection`, `friendlyStaff`, `basedOnRatings`
- [ ] `firestore.rules` — add `serverFieldsUnchanged(['avgRating', 'reviewCount'])` to `stores/{storeId}` update rule
- [ ] Verify: `flutter analyze && dart run build_runner build --delete-conflicting-outputs && flutter test`

## Data layer changes
- **Store document:** add `reviewCount` (int, default 0). `avgRating` already exists. Both server-authoritative via CF.
- **Offer document:** add `storeAvgRating` (double, default 0), `storeReviewCount` (int, default 0). Populated by daily-sync from Store doc.
- **Review document:** new submissions write `offerRating`. CF + Dart model read both `offerRating` and `foodRating` (fallback). No migration of old docs.
- **MaterializedOfferFields (TS):** add `storeAvgRating`, `storeReviewCount`.
- **Security rules:** `avgRating` and `reviewCount` on Store protected from client writes.

## External integrations
_None._ All within Firebase ecosystem.

## Risks
- `onDocumentWritten` trigger on `reviews/{reviewId}` may fire on unrelated field changes — mitigate by always recomputing from full query, making it idempotent.
- `daily-sync-offers` runs once per day — newly aggregated ratings won't appear on existing Offer docs until next sync. Acceptable for MVP; real-time update would require an additional CF trigger on Store doc changes (deferred).
- Removing `rating_information.dart` while `Rating` model in `offers/domain/rating.dart` remains — `Rating` is used by `Item` model and must not be deleted.

## Out of scope
- Review filters or "best reviews" display
- Business-side review dashboard
- Review edit/delete UI
- Highlight tags (quick collection, friendly staff, etc.)
- Pagination for reviews list (limit 50 sufficient for MVP)
- Validating in security rules that reviewer has a completed order
- Preventing multiple reviews per user per store (per-order check exists)
- Cleaning up `offer_review_bar.dart`
- Fixing `cloud_firestore` import in `review/domain/review.dart` (pre-existing violation)
