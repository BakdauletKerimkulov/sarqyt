---
title: Fix missing businesses/{businessId} write rule for verification submit
status: done
date: 2026-07-31
type: fix
severity: S
references: []
---

## Symptom
`BusinessRepository.submitVerification()`
(`business_repository.dart:25-35`) performs
`update({'verificationStatus': 'submitted'})` directly against
`businesses/{id}`, but `firestore.rules` defined only `allow read` for this
collection — no write rule at all (deny by default). Against real deployed
rules (not admin SDK, not a rules-disabled test context), this update was
being rejected, meaning the "submit verification" step in the merchant
welcome flow silently failed to do anything server-side.

## Root cause
When the security model migrated to the `storeShips`/`business_membership`
composite-ID access pattern, only a `read` rule was written for
`businesses/{businessId}` — the `update` rule needed for the client-driven
verification submission step was never added.
`firestore.rules:115-119` (pre-fix).

## Fix
- **Files changed:** `firestore.rules`, `functions/test/firestore-rules.test.ts`
- **Failing test that catches the regression:** `functions/test/firestore-rules.test.ts::businesses — verification submit > allows a business member to submit verification (unverified -> submitted)`
- **`ai_toolkit/` rules applied:** `RULES-backend.md → Security rules` (deny by default; rules tested with the emulator as an authenticated non-privileged user), `firebase.md → Server-authoritative field guard / Field-level update validation` (the `affectedKeys().hasOnly([...])` pattern used here).
- **Toolkit deviations:** none.
- **Description:** Added a scoped `allow update` rule to `businesses/{businessId}` permitting only a business member (via the existing `hasBusinessMembership(businessId)`) to flip `verificationStatus` from `unverified` to `submitted`, and only that field — no other field may change in the same write, and no client write can ever set `verificationStatus: "verified"` (that transition remains exclusive to the `fakeVerifyBusiness` Cloud Function, which runs under the admin SDK and bypasses these rules entirely). Added four rules tests covering the allowed transition and three denial boundaries (direct `verified`, other-field tampering, non-member).
