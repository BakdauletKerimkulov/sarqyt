---
title: Fix broken idempotency guard and unrestored partner claims in completeMerchantOnboarding
status: done
date: 2026-07-31
type: fix
severity: M
references: []
---

## Symptom
Two related defects in `completeMerchantOnboarding` surfaced during an
account-state security audit of the merchant onboarding flow:

1. If `auth.setCustomUserClaims(uid, { role: PARTNER, canCreateStore: true })`
   fails after the Firestore batch (business/store/storeShip/membership) has
   already committed, a retry from the client
   (`verify_email_controller.dart:33`) leaves the user with a fully created
   business/store but no `role: partner` claim on their ID token — they hang
   on `/forbidden` (GoRouter `business_router.dart:127-130`, Layer 5) with no
   self-recovery path.
2. The idempotency guard meant to catch exactly this kind of retry
   (`.where("userId","==",uid).where("status","==","active")`) was dead code:
   `storeShips` documents never carry a `status` field anywhere in the schema
   or in any writer (`StoreShipDoc`, `invite-team-member.ts`), so the query
   always returned empty. Every retry — not just the claims-failure case —
   re-ran the full creation batch, generating a new random `businessId` each
   time (`db.collection(BUSINESSES).doc().id` is not derived from the draft)
   and orphaning the previous `businesses`/`business_membership` documents.

## Root cause
The idempotency guard filtered on a field (`status`) that no code path ever
writes to `storeShips` — the guard was unreachable by construction, so the
claims-restoration logic it was meant to gate never ran either.
`complete-merchant-onboarding.ts:31-41` (pre-fix).

## Fix
- **Files changed:** `functions/src/features/merchant-onboarding/functions/complete-merchant-onboarding.ts`, `functions/src/features/merchant-onboarding/functions/complete-merchant-onboarding.test.ts` (new)
- **Failing test that catches the regression:** `functions/src/features/merchant-onboarding/functions/complete-merchant-onboarding.test.ts::completeMerchantOnboarding > restores partner claims when the user already has a storeShip but a prior claim-set attempt failed`
- **`ai_toolkit/` rules applied:** `RULES-backend.md → Cloud Functions` ("every write function needs a documented idempotency strategy"), `RULES.md → Testing` ("a bugfix is not done without a regression test reproducing the bug"; real Firestore + Auth emulators, no mocked SDK client, following the `cancel-order.test.ts`/`expire-orders.test.ts` pattern).
- **Toolkit deviations:** none.
- **Description:** The idempotency query now matches on `userId` alone
  (existence of any `storeShip` for this uid is itself the completion
  signal, matching the real schema). Inside that now-reachable branch, the
  user's current custom claims are checked against the expected
  `{ role: partner, canCreateStore: true }` and re-applied via
  `auth.setCustomUserClaims` if they don't match, before returning — making a
  retry self-healing regardless of which of the two independent side effects
  (Firestore batch vs Auth Admin API call) failed on a prior attempt.
