# Spec: Remove one-time mode from Item

Created: 2026-05-23
Status: refined

## Goal

Remove the dual `scheduled`/`oneTime` personality from `Item` so it becomes a pure recurring offer template tied to `WeeklySchedule`. One-time / flash offers remain handled exclusively by the existing `createOneTimeOffer` callable. This simplifies the domain model, the cron, and the partner UI.

## Background

`Item` currently supports two modes via `enum ItemType { scheduled, oneTime }`. The one-time path is incomplete: items can be created with `type: "oneTime"` and `oneTime*` fields, but they cannot be properly managed — the item card shows 0 quantity (reads `schedule.maxDayQuantity` which is empty for one-time), there is no "Start Selling" for one-time items, and no offer auto-creation works for them. Meanwhile, flash offers already have a clean, independent creation path via the `createOneTimeOffer` callable that writes directly to `offers/`. The Item-based one-time path is a redundant, broken second way to do the same thing.

Note: `create_item_dialog.dart` (`CreateItemTypeDialog`) is already dead code — defined but never imported or instantiated. The actual creation flow uses `CreateItemFormScreen` via routing. Deleting it is pure cleanup.

## User Flow

After this refactor, the partner-facing "create item" flow is:

1. Partner taps "Create new" on the items dashboard.
2. Full-screen form opens with: name, description, price, image, and **weekly schedule** (7-day grid with start/end times and quantity per day). No type toggle.
3. Partner fills in the form and submits.
4. Item is saved to `stores/{storeId}/items/{itemId}` with `WeeklySchedule`.
5. Daily cron `dailySyncOffers` materializes `Offer` documents from active scheduled items.

Flash offers continue unchanged: partner uses the separate flash offer UI which calls `createOneTimeOffer` directly.

## Requirements

### Must Have

- [ ] Remove `enum ItemType` from Dart model (`item.dart`)
- [ ] Remove all `oneTime*` fields from `Item` freezed model: `oneTimeDate`, `oneTimeStartHour`, `oneTimeStartMinute`, `oneTimeEndHour`, `oneTimeEndMinute`, `oneTimeQuantity`
- [ ] Remove `type` field from `Item` freezed model
- [ ] Remove `type` and `oneTime*` fields from TypeScript `ItemDoc` (`item-doc.ts`)
- [ ] Remove `syncOneTimeItem()` function and the `type === "oneTime"` branch from `daily-sync-offers.ts`; cron iterates active items with a single code path: `buildExpectedOffers` + `diffAndApply`
- [ ] Delete `create_item_dialog.dart` entirely (already dead code — never imported)
- [ ] Remove all one-time UI from `create_item_screen.dart`: `SegmentedButton`, `_oneTimeDate/Start/End/Quantity` state, `_buildOneTimeSection()`, conditional validation
- [ ] Remove `type` and `oneTime*` parameters from `create_item_form_controller.dart` `submit()` method
- [ ] Remove `type` and `oneTime*` parameters from `items_repository.dart` `createItem()` method, including the unconditional `'type': type` Firestore write and all conditional `oneTime*` writes
- [ ] Delete `tabsForItemType()` function from `item_tab.dart`; always use `ItemTab.values`
- [ ] Update `item_screen.dart`: remove `itemType` constructor param, always show all 5 tabs
- [ ] Update `item_action_dialog.dart`: remove `ItemType` import and `tabsForItemType` call, remove `'type'` from navigation query params
- [ ] Update `business_router.dart`: remove `type` query param parsing and `ItemType` import
- [ ] Delete `oneTime` localization string from ARB source files (en, ru, kk) and regenerate. **Keep `scheduled`** — it is used in `item_card.dart` as an offer-timing badge label, unrelated to `ItemType`
- [ ] Remove item model test `"default type is scheduled"` from `test/features/items/item_model_test.dart`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `.freezed.dart` and `.g.dart`
- [ ] `flutter analyze` passes
- [ ] `npm run build` in `functions/` passes

### Nice to Have

- [ ] Remove dead `ItemType` references from any analytics/logging if found

## Technical Constraints

- **Do NOT modify** `create-one-time-offer.ts` — flash offer callable is out of scope
- **Do NOT modify** `offer.dart` or Offer domain model — separate future refactor
- **Do NOT modify** `on-item-status-changed.ts` (`functions/src/features/offers/functions/on-item-status-changed.ts`) — verified clean, only uses `schedule`
- **Do NOT modify** `build-expected-offers.ts` (`functions/src/features/offers/services/build-expected-offers.ts`) — verified clean, only uses `schedule`
- **Do NOT modify** Firestore security rules — verified clean, no `type` references
- **Do NOT delete** `scheduled` localization key — used by `item_card.dart` for offer-timing badge
- Sandbox mode: no data migration needed, existing documents can be wiped
- Architecture: feature-first layers (domain / data / presentation), Riverpod codegen, freezed models
- Localization: update ARB source files and regenerate; or hand-edit generated files if ARB sources are not present

## Files to Modify

| File | Action |
|------|--------|
| `lib/src/features/items/domain/item.dart` | Remove `ItemType` enum, `type` field, all `oneTime*` fields |
| `lib/src/features/items/domain/item.freezed.dart` | Regenerate via build_runner |
| `lib/src/features/items/domain/item.g.dart` | Regenerate via build_runner |
| `lib/src/features/items/data/items_repository.dart` | Remove `type` param, `oneTime*` params, and their Firestore writes from `createItem()` |
| `lib/src/features/items/presentation/item_create/create_item_screen.dart` | Remove type toggle, one-time state/UI/validation |
| `lib/src/features/items/presentation/item_create/create_item_form_controller.dart` | Remove `type` and `oneTime*` params from `submit()` |
| `lib/src/features/items/presentation/items_list/create_item_dialog.dart` | **Delete** (dead code) |
| `lib/src/features/items/presentation/item_tab.dart` | Delete `tabsForItemType()`, simplify |
| `lib/src/features/items/presentation/item_screen/item_screen.dart` | Remove `itemType` param, always show all tabs |
| `lib/src/features/items/presentation/items_list/item_action_dialog.dart` | Remove `ItemType` usage, remove `'type'` from navigation query params |
| `lib/src/routing/business_router.dart` | Remove `type` query param parsing |
| `lib/l10n/app_*.arb` + generated `app_localizations*.dart` | Delete `oneTime` string only; **keep `scheduled`** |
| `test/features/items/item_model_test.dart` | Remove type-related test |
| `functions/src/features/offers/types/item-doc.ts` | Remove `type` and `oneTime*` fields |
| `functions/src/features/offers/functions/daily-sync-offers.ts` | Delete `syncOneTimeItem()`, remove type branching |

## Edge Cases

- **Existing one-time Item documents in Firestore**: sandbox mode — wipe them manually or ignore; the cron will skip them (no `schedule` to process) or they'll fail gracefully since `buildExpectedOffers` only reads `schedule`.
- **Deep links with `?type=oneTime`**: after removing type param parsing, the router ignores the param; item screen shows all tabs regardless. No crash.
- **Flash offer flow**: completely unaffected — uses `createOneTimeOffer` callable which writes directly to `offers/` without touching `Item`.
- **Item card quantity display**: currently shows `schedule.maxDayQuantity` — after this change all items have a real schedule, so display is always correct.
- **`loc.scheduled` in item_card.dart**: this badge label means "has an upcoming offer but not selling yet" — unrelated to `ItemType`. No change needed.

## Out of Scope

- Renaming `Item` to `OfferTemplate` (follow-up)
- Adding `templateId` to `Offer` model (separate Offer refactor)
- Splitting `quantity` into total/remaining on Offer (separate Offer refactor)
- Expanding `OfferStatus` with `soldOut`, `cancelled` (separate Offer refactor)
- Modifying `createOneTimeOffer` callable or its `productId: "flash"` marker
- Any payment / Stripe code changes
- Adding `createdAt`/`updatedAt` server timestamps to `createItem()` (pre-existing gap, separate fix)

## Definition of Done

- [ ] No references to `ItemType`, `oneTime*` fields, or `type === "oneTime"` anywhere in Dart or TypeScript code
- [ ] `dailySyncOffers` has a single code path: iterate active items → `buildExpectedOffers` + `diffAndApply`
- [ ] "Create item" UI has no scheduled-vs-onetime toggle — only the recurring schedule form
- [ ] `create_item_dialog.dart` is deleted
- [ ] Flash offer UI continues to work unchanged via existing callable
- [ ] Item detail screen always shows all 5 tabs
- [ ] `loc.scheduled` in `item_card.dart` still works (not deleted)
- [ ] `flutter analyze` passes
- [ ] `npm run build` in `functions/` passes
- [ ] Codegen (build_runner) completes without errors
