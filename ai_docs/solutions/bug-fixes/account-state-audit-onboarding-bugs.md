---
title: Account-state audit surfaces two live onboarding/verification bugs
date: 2026-07-31
work_type: bug
tags: [firebase, cloud-functions, firestore-rules, security, onboarding, idempotency]
confidence: medium
references: [ai_specs/039-fix-onboarding-idempotency-claims-spec.md, ai_specs/040-fix-business-verification-write-rule-spec.md, https://github.com/BakdauletKerimkulov/sarqyt/pull/17]
---

## Summary
A structured account-state audit (enumerate regressable conditions → trace
storage/recompute → find aggregate-vs-atomic auth gaps) surfaced two live
bugs in merchant onboarding/verification, both fixed and tested against real
Firestore + Auth emulators. The audit method itself — trace every client-side
gate to its backend enforcement and ask "does this check the live fact, or a
cached derivative?" — is the reusable part; the two bugs it found are
concrete instances.

## Reusable Insights

- **An idempotency guard that filters on a field nothing ever writes is dead code, not a no-op** — when adding a `where(...)` check-before-write guard, grep the actual document type/writers for that field first; a guard on a phantom field always returns empty and silently degrades to "no idempotency at all," which is worse than not having the check (retries fork duplicate state instead of just being redundant). _Example: `complete-merchant-onboarding.ts` filtered `storeShips` on `status == "active"`, a field no `StoreShipDoc` writer ever set._
- **Two side effects on different Google APIs (Firestore batch + Auth Admin claims) cannot be made atomic — design for idempotent recovery instead** — put the "did this already happen, and is every side effect actually applied" check in the retry/idempotent branch itself, not just an existence check on one of the two systems. _Example: `complete-merchant-onboarding.ts` idempotent branch now re-checks and re-applies custom claims, not just returns early on storeShip existence._
- **GoRouter (or any client router) redirect logic is a UX layer, not a security boundary** — when auditing "is this endpoint protected," trace the client gate to its Firestore-rules/Cloud-Function counterpart and confirm *that* checks a live document, not just the same cached JWT claim the router already used. A redirect-only fix without a matching backend rule is cosmetic.
- **Firebase custom claims in this codebase are additive-only — no code path ever downgrades or revokes `role`/`canCreateStore`** — this is a latent gap, not yet exploitable (no "remove partner" feature exists), but any future ban/removal/demotion feature must pair `setCustomUserClaims` downgrade with a forced token refresh or `revokeRefreshTokens`, or the coarse role gates (rules + GoRouter + Cloud Functions) will keep admitting the removed user indefinitely.
- **This repo's Cloud Function tests never mocked `admin.auth()` before** — extending the existing `vitest` + `firebase emulators:exec --only firestore,auth` pattern (already used for Firestore-only tests like `cancel-order.test.ts`) to also create real users and assert on real custom claims via the Auth emulator worked with zero extra setup — `firebase.json` already exposed the auth emulator on port 9099, just unused by any test until now.

## Decisions

- **Idempotent recovery over reordering or an outbox pattern** for the claims/batch non-atomicity — considered (a) reordering claims-before-batch, (b) an outbox/trigger pattern for guaranteed eventual claim-setting. Chose making the existing idempotent branch self-healing instead: smallest diff, stays inside `/fix` severity budget (S→M, one file), and the outbox pattern would have been `feat`-sized for a rare single-invocation race.
- **Rules-only fix over touching `business_repository.dart`** for the missing `businesses` write rule — the client already sent exactly one field (`verificationStatus`), so the new rule's `affectedKeys().hasOnly([...])` was written to match existing client behavior rather than changing the client to match a differently-shaped rule.

## Pitfalls

- **Bash `cd` persists across tool calls in the same session** — symptom: `git add functions/src/...` failed with "did not match any files" after an earlier command had `cd`'d into `functions/`. Cause: shell state (cwd) carries over between Bash invocations in this harness, unlike each call starting fresh. Fix: re-ran with `git -C <repo-root> add ...`. Avoid by: always use `-C <path>` or absolute paths for git commands once any earlier command in the session may have changed directory.
