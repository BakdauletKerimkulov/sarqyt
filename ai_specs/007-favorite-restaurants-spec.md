# Spec: Favorite Restaurants

Created: 2026-06-04
Status: refined
Refined: 2026-06-04
Source request: Написать фичу добавления ресторанов в любимые. Документ хранить в субколлекции пользователя. Настроить firestore.rules для безопасности. Учесть идемпотентность set/delete. Показать какой путь будет у документа. Настроить анимацию/показ кнопки сердечка и показывать снекбар для результата.

## Goal

Complete the existing favorites infrastructure into a full user-facing feature: add a scale-bounce heart animation on toggle, show a SnackBar with the store name, wire the heart button into the offer detail screen, and build a dedicated "Favorites" screen accessible from the profile tab.

## Background

**Stack & conventions:** Flutter + Riverpod codegen (`@riverpod`), Freezed models, feature-first structure with domain/data/application/presentation layers. Repositories encapsulate all Firestore access; widgets never touch Firebase directly. UI strings in Russian using `context.loc.xxx` localization extension (dominant codebase pattern, 203 occurrences across 48 files). See `ai_toolkit/guidelines/architecture.md`, `ai_toolkit/guidelines/riverpod.md`, `ai_toolkit/guidelines/code-style.md`.

**Project context:** Sarqyt is a TGTG-style surplus food marketplace in Kazakhstan. The favorites repository, Firestore rules, and offer card heart button already exist:
- `lib/src/features/offers/data/favorites_repository.dart` — `FavoritesRepository` with `addFavorite`/`removeFavorite` using idempotent `set`/`delete`. Provider `favoriteStoreIdsProvider` streams a `Set<String>` of store IDs.
- `firestore.rules:127-129` — `users/{uid}/favorites/{storeId}` subcollection, read/write only by the owning user.
- `lib/src/features/offers/presentation/offer_list/offer_card.dart:39-58` — `OfferCard` renders a heart icon with `isFavorite` / `onFavoriteToggle` props.
- `lib/src/features/offers/presentation/offer_list/discover_screen.dart:29,91-116` — `DiscoverScreen` watches `favoriteStoreIdsProvider` and passes state down.
- `lib/src/features/offers/presentation/offer_screen/offer_app_bar.dart` — `OfferSliverAppBar` has a share button but no favorite button.

**Firestore document path:** `/users/{uid}/favorites/{storeId}` with a single field `addedAt: Timestamp` (server timestamp). The document ID equals the store ID, making `set` idempotent (same doc overwritten) and `delete` idempotent (deleting non-existent doc is a no-op).

**Why now:** The data layer is ready; the UX gap is the missing animation feedback, SnackBar confirmation, detail-screen button, and a way for users to view their saved restaurants.

## User Flow

### Happy path
1. User is on DiscoverScreen, sees offer cards with heart icons. Taps the heart on an offer card.
2. Heart icon animates with a scale bounce (grows ~20% over 150ms, returns to normal over 150ms). Icon changes from `Icons.favorite_border` (white) to `Icons.favorite` (red).
3. SnackBar appears: "{storeName} добавлен в избранное".
4. User navigates to offer detail screen (`OfferScreen`). Heart button is visible in the SliverAppBar next to the share button, reflecting the current favorite state.
5. User taps heart in AppBar — same bounce animation and SnackBar.
6. User goes to Profile tab → taps "Избранное" menu item → sees `FavoritesScreen` with a list of favorited stores showing store name, logo, and address.
7. User taps a store card → navigates to that store's latest active offer via `OfferScreen`. If the store has no active offers, the card is still shown but tap is disabled (or navigates to `StoreInfo` if a standalone store detail route is available).

### Alternative flows
- If user taps heart again (already favorited): icon animates back to outline, SnackBar shows "{storeName} удалён из избранного".
- If user is not authenticated: heart tap is ignored (no crash, no SnackBar) on both `DiscoverScreen` and `OfferScreen`. Current behavior in `DiscoverScreen._toggleFavorite` already guards with `if (user == null) return`; the same guard must be applied in `OfferScreen` toggle handler.

### Error & recovery flows
- If Firestore write fails (network error): SnackBar shows "Не удалось обновить избранное" with a generic error message. Heart state reverts on next stream emission (optimistic UI not required — the stream drives state).
- If favorites stream errors: `AsyncValueWidget` handles error state with retry.

### Edge cases
- Empty state: `FavoritesScreen` with no favorites shows a centered placeholder: "У вас пока нет избранных ресторанов" with an icon.
- Rapid double-tap: Firestore `set`/`delete` are idempotent. Two rapid taps may fire two writes, but the final state converges correctly because the stream re-emits the canonical state.
- Store deleted after being favorited: The favorites screen queries stores by ID; missing stores are silently filtered out of the list.
- Very large favorites list: Unlikely in practice (users don't favorite 1000+ stores), but the stream returns all docs in the subcollection. No pagination needed for MVP.

## Requirements

### Must Have
- [ ] R1: Heart button in `OfferSliverAppBar` (offer detail screen) next to the share button, reflecting `isFavorite` state from `favoriteStoreIdsProvider`. Verifiable by: open offer detail, see heart icon matching the favorite state from discover list.
- [ ] R2: Scale bounce animation on heart toggle — icon scales to 1.2x over 150ms then back to 1.0x over 150ms, on both OfferCard and OfferSliverAppBar. Verifiable by: tap heart, observe visual bounce effect.
- [ ] R3: SnackBar on successful add: "{storeName} добавлен в избранное". Verifiable by: tap heart on non-favorited offer, see SnackBar with store name.
- [ ] R4: SnackBar on successful remove: "{storeName} удалён из избранного". Verifiable by: tap heart on favorited offer, see SnackBar with store name.
- [ ] R5: SnackBar on error: "Не удалось обновить избранное". Verifiable by: simulate Firestore write failure, see error SnackBar.
- [ ] R6: "Избранное" menu item in `AccountScreen` (profile tab) with `Icons.favorite_outline` leading icon. Tapping navigates to `FavoritesScreen`. Verifiable by: see menu item in profile, tap it, arrive at favorites screen.
- [ ] R7: `FavoritesScreen` displays a list of favorited stores with their name, logo, and address. Verifiable by: favorite 2+ stores, open favorites screen, see both stores listed.
- [ ] R8: Empty state on `FavoritesScreen` when no favorites exist — centered icon + text. Verifiable by: remove all favorites, see placeholder.
- [ ] R9: Tapping a store in `FavoritesScreen` navigates to the store's latest active offer via `OfferScreen`. If the store has no active offers, tap is disabled or navigates to `StoreInfo`. Verifiable by: tap store in favorites, arrive at offer/store screen.
- [ ] R10: Unauthenticated users cannot toggle favorites (no crash, no SnackBar). Verifiable by: sign out, tap heart, nothing happens.

### Nice to Have
- [ ] N1: Unfavorite action directly from `FavoritesScreen` via swipe-to-dismiss or trailing icon button.
- [ ] N2: Badge or indicator on the profile tab when user has new offers from favorited stores.

### Non-functional
- Performance: Heart toggle should feel instant (<100ms perceived latency). The Firestore write is fire-and-forget; the stream updates the UI.
- Accessibility: Heart button has semantic label ("Добавить в избранное" / "Убрать из избранного"). Minimum 48x48 tap target.
- i18n: All new strings use `context.loc.xxx` localization extension (the dominant codebase pattern). Add new localization keys for: `addedToFavorites`, `removedFromFavorites`, `failedToUpdateFavorites`, `favorites`, `noFavoriteRestaurants`.

## Technical Constraints

**Files to create:**
- `lib/src/features/offers/presentation/favorites/favorites_screen.dart` — Screen showing list of favorited stores.
- `lib/src/common_widgets/animated_favorite_button.dart` — Reusable animated heart button widget (used by both OfferCard and OfferSliverAppBar). Placed in `common_widgets/` to match existing project convention for shared widgets.

**Files to modify:**
- `lib/src/features/offers/presentation/offer_list/offer_card.dart` — Replace inline heart `GestureDetector`+`Icon` (lines 47-58) with `AnimatedFavoriteButton`.
- `lib/src/features/offers/presentation/offer_screen/offer_app_bar.dart` — Add `AnimatedFavoriteButton` to `actions` list. Requires `isFavorite`, `storeName`, and `onFavoriteToggle` callback props. The `onFavoriteToggle` handler must include the same `user == null` auth guard as DiscoverScreen.
- `lib/src/features/offers/presentation/offer_screen/offer_screen.dart` — Watch `favoriteStoreIdsProvider`, pass favorite state to `OfferSliverAppBar`, handle SnackBar on toggle.
- `lib/src/features/offers/presentation/offer_list/discover_screen.dart` — Add SnackBar feedback to `_toggleFavorite`, wrap heart with `AnimatedFavoriteButton`.
- `lib/src/features/auth/presentation/account_screen/account_screen.dart` — Add "Избранное" `ListTile` in the menu card (between "Edit Profile" and "Settings").
- `lib/src/routing/client_router.dart` — Add `favorites` to `ClientRoute` enum and a nested route under `/profile/favorites` pointing to `FavoritesScreen`.
- `lib/src/features/offers/data/favorites_repository.dart` — Add a new **provider** (not a repository method) that combines `favoriteStoreIdsProvider` with `storeStreamProvider` from `store_repository.dart:70` to produce the store list for FavoritesScreen. This keeps each repository focused on its own Firestore collection and avoids cross-feature imports in the data layer.

**Patterns to follow (with citations):**
- Follow the `OfferCard` heart button pattern (`offer_card.dart:39-58`) for icon styling (size 28, shadow, red/white colors).
- Follow the `DiscoverScreen._toggleFavorite` pattern (`discover_screen.dart:107-116`) for toggle logic (read auth, read repo, call add/remove).
- Follow the `AccountScreen` menu card pattern (`account_screen.dart:72-90`) for the new "Избранное" list tile.
- Follow the `OfferSliverAppBar` actions pattern (`offer_app_bar.dart:22-32`) for adding the heart button next to share.
- Use `ScaffoldMessenger.of(context).showSnackBar()` pattern used throughout the app (e.g., `create_item_screen.dart:90-92`).

**Anti-patterns / avoid:**
- Do not create a separate controller/notifier for favorite toggle — the existing `FavoritesRepository` with fire-and-forget `addFavorite`/`removeFavorite` is sufficient. No `AsyncNotifier` needed for a simple set/delete.
- A `ConsumerStatefulWidget` with a short-lived `AnimationController` (forward + reverse on tap) is acceptable for the bounce animation — Riverpod guidelines classify animation progress as ephemeral/local state. Keep the controller lifecycle minimal: create in `initState`, dispose in `dispose`, trigger on tap. Avoid creating a Riverpod provider for animation state.
- Do not duplicate the toggle logic in multiple places — centralize in `AnimatedFavoriteButton` or a shared helper.

**Data layer changes:**
- Firestore rules: Already configured at `firestore.rules:127-129`. No changes needed.
- Document path: `/users/{uid}/favorites/{storeId}` — document ID = store ID, single field `addedAt: Timestamp`.
- No new indexes required (subcollection queried without filters).
- For `FavoritesScreen`, create a provider that combines `favoriteStoreIdsProvider` with `storeStreamProvider(storeId)` per ID to produce `Stream<List<Store>>`. This avoids cross-feature coupling in the repository layer. The existing `storeStreamProvider` in `store_repository.dart:70` already watches individual store docs.

**External integrations:** None.

## Edge Cases

See User Flow → Edge cases above. Key points:
- Idempotency: `set` overwrites, `delete` on missing doc is no-op.
- Race condition: Stream-driven UI converges to correct state after rapid toggles.
- Deleted stores: Filtered out silently from favorites list.

## Out of Scope

- NOT building offline cache for favorites — Firestore SDK handles local cache natively; no custom offline logic needed.
- NOT sending push notifications for new offers from favorited stores — separate feature, requires Cloud Function trigger.
- NOT adding sort/filter within the favorites screen — simple list is sufficient for MVP.
- NOT adding favorites count badge on the bottom navigation bar — deferred to a future iteration.
- NOT migrating existing favorites data — there is no schema change; the existing `addedAt` field is retained.

## Validation

**Automated tests:**
- Unit: `AnimatedFavoriteButton` widget test — verify icon changes between `Icons.favorite` and `Icons.favorite_border` based on `isFavorite` prop.
- Unit: `FavoritesRepository.addFavorite` / `removeFavorite` — verify correct Firestore path and idempotent behavior (mock Firestore).
- Widget: `FavoritesScreen` — verify empty state placeholder is shown when no favorites exist; verify list renders when favorites are present (override `favoriteStoreIdsProvider`).

**Manual QA scenarios:**
1. Given unauthenticated user, when tapping heart on OfferCard, then nothing happens (no crash, no SnackBar).
2. Given authenticated user with no favorites, when tapping heart on OfferCard, then heart animates to filled red, SnackBar shows "{storeName} добавлен в избранное".
3. Given authenticated user with a favorited store, when tapping heart again, then heart animates to outline, SnackBar shows "{storeName} удалён из избранного".
4. Given authenticated user on offer detail screen, when tapping heart in AppBar, then same animation + SnackBar behavior as OfferCard.
5. Given user navigates DiscoverScreen → OfferScreen for a favorited offer, then heart in AppBar is already filled red.
6. Given user with 3 favorited stores, when opening FavoritesScreen from profile, then all 3 stores appear in the list with name, logo, and address.
7. Given user with no favorites, when opening FavoritesScreen, then empty placeholder is shown.
8. Given user taps a store in FavoritesScreen, then navigates to the store's active offer or store detail.
9. Given network error on favorite toggle, then error SnackBar "Не удалось обновить избранное" appears.

**Expected behavior under edge conditions:**
- Offline → Firestore SDK queues the write; heart state updates locally via SDK cache; SnackBar still shown.
- Backend error → Error SnackBar shown; heart state stays as per last successful stream emission.
- Empty data → FavoritesScreen shows placeholder widget.

## Definition of Done

- [ ] All Must Have requirements (R1-R10) implemented and pass manual QA
- [ ] Heart animation is smooth and consistent on both OfferCard and OfferSliverAppBar
- [ ] SnackBar shows correct store name for add and remove actions
- [ ] FavoritesScreen accessible from profile, shows stores or empty state
- [ ] No new lint warnings; `flutter analyze` passes
- [ ] Matches `ai_toolkit/` style guide (no deprecated APIs, proper spacing constants, `context.loc.xxx` strings)
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds if codegen files changed
- [ ] Spec file linked in the PR description
