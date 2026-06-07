# Plan: Favorite Restaurants

Source: `ai_specs/007-favorite-restaurants-spec.md`
Created: 2026-06-04
Status: draft

## Overview
Wire up a complete favorites UX: animated heart button (reusable widget with bounce via `AnimationController`), SnackBar feedback on toggle, heart in offer detail AppBar, a FavoritesScreen listing saved stores accessible from the profile tab. Data layer already exists (`FavoritesRepository`, Firestore rules, `favoriteStoreIdsProvider`). No new backend or schema changes needed.

**Spec:** `ai_specs/007-favorite-restaurants-spec.md`

## Context
- **Structure:** feature-first — `lib/src/features/{name}/{domain,data,application,presentation}/`
- **State management:** Riverpod codegen (`@riverpod`). Cited: `favorites_repository.dart` (keepAlive repo + auto-dispose stream provider)
- **Reference implementations:** `OfferCard` (`offer_card.dart:46-58` — heart icon), `DiscoverScreen._toggleFavorite` (`discover_screen.dart:107-116`), `AccountScreen` menu card (`account_screen.dart:71-90`)
- **Testing convention:** unit tests in `test/features/` mirroring `lib/`. Cited: `ai_toolkit/guidelines/architecture.md` testing section
- **Lint + test command:** `flutter analyze && flutter test`
- **Localization:** ARB-based (`lib/l10n/app_ru.arb`, `app_en.arb`, `app_kk.arb`) accessed via `context.loc.xxx`
- **Assumptions / Gaps:**
  - R9 navigation: spec says "latest active offer or StoreInfo if no active offers" — needs a provider to find the latest offer by storeId. Existing `offersWithDistanceStreamProvider` is global. May need a targeted query or filter.
  - `EmptyPlaceholderWidget` exists in `common_widgets/` but includes a "Go Home" button — FavoritesScreen empty state may want a simpler version (just icon + text, no CTA).

## Plan

### Phase 1 — AnimatedFavoriteButton + SnackBar on DiscoverScreen
**Goal:** Reusable animated heart widget, integrated into OfferCard with SnackBar feedback. Thin vertical slice proving the animation and toggle UX on the existing screen.

- [x] `lib/l10n/app_ru.arb`, `app_en.arb`, `app_kk.arb` — add keys: `addedToFavorites` ("{storeName} добавлен в избранное"), `removedFromFavorites` ("{storeName} удалён из избранного"), `failedToUpdateFavorites`, `favorites`, `noFavoriteRestaurants`, `addToFavorites`, `removeFromFavorites`. Run `flutter gen-l10n` if needed.
- [x] TDD: `AnimatedFavoriteButton` renders `Icons.favorite` when `isFavorite=true`, `Icons.favorite_border` when false; tap calls `onToggle`
- [x] `lib/src/common_widgets/animated_favorite_button.dart` — `StatefulWidget` with `AnimationController` for scale bounce (1.0→1.2→1.0 over 300ms). Props: `isFavorite`, `storeName`, `onToggle` callback. SnackBar responsibility moved to caller (DiscoverScreen). Icon styling: size 28, shadow, red/white per existing `offer_card.dart:49-56`.
- [x] `lib/src/features/offers/presentation/offer_list/offer_card.dart` — replace `GestureDetector`+`Icon` (lines 46-58) with `AnimatedFavoriteButton`. Pass `isFavorite`, `storeName: offer.storeName`, `onToggle: onFavoriteToggle`.
- [x] `lib/src/features/offers/presentation/offer_list/discover_screen.dart` — wrap `_toggleFavorite` to catch errors and show error SnackBar via `context.loc.failedToUpdateFavorites`. Pass `storeName` through to `OfferCard`.
- [x] Verify: `flutter analyze && flutter test`

### Phase 2 — Heart in OfferScreen AppBar
**Goal:** Favorite toggle with animation and SnackBar on the offer detail screen.

- [x] `lib/src/features/offers/presentation/offer_screen/offer_app_bar.dart` — add `isFavorite`, `storeName`, `onFavoriteToggle` props. Add `AnimatedFavoriteButton` to `actions` list next to share button.
- [x] `lib/src/features/offers/presentation/offer_screen/offer_screen.dart` — watch `favoriteStoreIdsProvider`, compute `isFavorite` from `offer.storeId`. Pass to `OfferSliverAppBar`. Add toggle handler with auth guard (`user == null` → return) and error SnackBar.
- [x] Verify: `flutter analyze && flutter test`

### Phase 3 — FavoritesScreen + routing + profile menu
**Goal:** Dedicated screen listing favorited stores, accessible from profile tab.

- [x] `lib/src/features/offers/data/favorites_repository.dart` — add `favoriteStoresProvider` that watches `favoriteStoreIdsProvider`, then watches `storeStreamProvider(id)` for each ID, combines into `AsyncValue<List<Store>>`. Filter out null stores (deleted).
- [x] TDD: `FavoritesScreen` shows empty placeholder when no favorites; shows store list when favorites present (override `favoriteStoresProvider`)
- [x] `lib/src/features/offers/presentation/favorites/favorites_screen.dart` — `ConsumerWidget` watching `favoriteStoresProvider`. Empty state: centered `Icons.favorite_border` + `context.loc.noFavoriteRestaurants`. List state: `ListView` of store cards (name, logo via `CircleAvatar`, `store.addressInfo`). Tap navigates to offer or store detail per R9.
- [x] `lib/src/routing/client_router.dart` — add `favorites` to `ClientRoute` enum. Add nested `GoRoute` under `/profile` branch: `path: 'favorites'`, builder → `FavoritesScreen`.
- [x] `lib/src/features/auth/presentation/account_screen/account_screen.dart` — add "Избранное" `ListTile` with `Icons.favorite_outline` between "Edit Profile" and "Settings" tiles. `onTap` → `context.pushNamed(ClientRoute.favorites.name)`.
- [x] Verify: `flutter analyze && flutter test`

## Data layer changes
_None._ Existing `users/{uid}/favorites/{storeId}` subcollection and `firestore.rules:127-129` are sufficient. No schema migration, no new indexes.

## External integrations
_None._

## Risks
- `favoriteStoresProvider` watching N individual `storeStreamProvider(id)` creates N Firestore listeners. Acceptable for <30 favorites (spec assumption), but monitor if users exceed that threshold.
- R9 navigation to "latest active offer" requires finding an active offer by storeId — may need a new query in `ClientOfferRepository` or a filter on the global offers stream. If complex, fall back to navigating to `StoreInfo` for all taps.

## Out of scope
- Offline cache for favorites (Firestore SDK handles natively)
- Push notifications for new offers from favorited stores
- Sort/filter within FavoritesScreen
- Favorites count badge on bottom nav
- Favorites data migration (no schema change)
