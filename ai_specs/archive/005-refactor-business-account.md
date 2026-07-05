---
title: Refactor Business Account
status: done
date: 2026-05-23
type: refactor
---

# Feature Request: Remove one-time mode from Item, keep Item as a pure recurring offer template

## Background

Sarqyt is a Flutter + Firebase food-rescue marketplace (Too Good To Go model) for the Kazakhstani market. There are no real users yet — this is a sandbox refactor and destructive changes are acceptable.

The codebase has two-level domain:
- `Item` — recurring offer template, stored at `stores/{storeId}/items/{itemId}`, with `WeeklySchedule`. A daily cron (`dailySyncOffers`) materializes `Offer` documents from active items.
- `Offer` — materialized instance for a specific day, stored at `offers/{offerId}`, with snapshots of name/price/store info.

Currently, `Item` has a dual personality: it can be `type: "scheduled"` (recurring, used by cron) or `type: "oneTime"` (used once, then deactivated). The cron's `syncOneTimeItem()` branch handles the one-time case by creating a single offer and turning the item off.

There is also a separate callable Cloud Function `createOneTimeOffer` that writes directly to `offers/` without involving `Item` at all — this is the path used by the "flash offer" UI.

This duality is the problem.

## Goal

Remove the `oneTime` mode from `Item` entirely. After this refactor:

- `Item` represents only a recurring offer template, always tied to a `WeeklySchedule`.
- The cron `dailySyncOffers` only processes scheduled items — no one-time branching.
- One-time / flash offers are created exclusively through the existing `createOneTimeOffer` callable]`, which writes directly to `offers/`. This path is already in production-ready shape and is **not in scope** to change here.

## Why this matters

- Mixed responsibilities in `Item` leak into the UI (a "scheduled or one-time" toggle that complicates the create form).
- Cron does extra work iterating one-time items that have no future runs.
- The `oneTime*` fields (`oneTimeDate`, `oneTimeStartHour`, etc.) are always either all-null or all-set, but the compiler can't enforce this — every reader has to guard with `type === "oneTime"`.
- We already have a clean direct-write path for flash offers. The Item-based one-time path is a redundant second way to do the same thing.

## Constraints

- Sandbox mode: no data migration needed. Existing Firestore documents can be wiped.
- Do **not** modify the `Offer` Dart model in this slice. A separate refactor will add `templateId`, split `quantity` into total/remaining, and expand `OfferStatus` (`soldOut`, `cancelled`). Keep that out of scope here.
- Do **not** modify `createOneTimeOffer` callable. It currently uses `productId: "flash"` as a marker — that's a known wart, to be addressed in the same future Offer slice.
- Do **not** rename `Item` to `OfferTemplate` in this slice, even though it would be more honest. That's a follow-up.
- Architecture follows Andrea Bizzotto's feature-first pattern. Domain models stay framework-agnostic; Firestore-specific conversion lives in the data layer.

## What success looks like

- No references to `ItemType`, `oneTime*` fields, or `type === "oneTime"` anywhere in Dart or TypeScript code.
- `dailySyncOffers` has a single code path: iterate active items, call `buildExpectedOffers` + `diffAndApply`.
- The "create item" UI in the partner-facing Flutter app has no scheduled-vs-onetime toggle — only the recurring schedule form.
- The "flash offer" UI continues to work unchanged via the existing callable.
- `flutter analyze` and `npm run build` in `functions/` both pass.

## Open questions for the agent to investigate before writing the spec

These are the things I want the agent to figure out by reading the codebase, not by asking me:

- Which Flutter screens, controllers, and providers currently branch on `ItemType` or read `oneTime*` fields?
- Are there Firestore security rules that reference `type` field on Item documents?
- Are there analytics events, logs, or any backend code outside `daily-sync-offers.ts` that depend on `type` or `oneTime*`?
- Is there a UI flow today where the user creates a "one-time Item" instead of a "flash offer"? If so, where does it lead, and should we delete the screen or redirect it to the flash-offer flow?

## Questions the agent should ask me

After researching the codebase, ask me about:

- Anything ambiguous about UI flow (e.g., whether to delete a one-time creation screen entirely vs. keep it as alias for flash offer).
- Anything that looks like it could be a partial migration in progress that I forgot about.
- Anything where removing `oneTime` mode would break a feature I might have forgotten exists.

## Reference files

Primary files to inspect:
- `lib/src/features/items/domain/item.dart`
- `functions/src/features/offers/types/item-doc.ts`
- `functions/src/features/offers/functions/daily-sync-offers.ts`
- `functions/src/features/offers/functions/create-one-time-offer.ts` (read-only context — DO NOT modify)
- `functions/src/features/offers/functions/on-item-status-changed.ts` (likely unaffected, verify)
- `functions/src/features/offers/services/build-expected-offers.ts` (likely unaffected, verify)
- Flutter `lib/src/features/items/presentation/` (find affected screens)

Out of scope (mention only if found relevant, do not modify):
- `lib/src/features/offers/domain/offer.dart`
- `functions/src/features/offers/functions/update-offer-quantity.ts`
- Any payment / Stripe code