# Binding Rules — Backend Index (Firebase)

_Часть общей базы agentic-coding-toolkit. Правь в базе, не в проекте — локальные правки затрёт sync._

**Read this file in full** together with `RULES.md`. `→ firebase.md` holds the full patterns, examples, and edge cases — read it whenever you touch Firestore, Cloud Functions, rules, or indexes.

Project-specific collections, fields, regions, and function contracts → `ai_docs/`, never here.

---

## Documents

- Every document carries `id` (equal to the doc ID), `createdAt`, `updatedAt`. No exceptions.
- Timestamps are **`FieldValue.serverTimestamp()` only** — never a client `DateTime.now()`. `createdAt` is set once and never updated; `updatedAt` is bumped on every write.
- `TimestampConverter` belongs on the DTO, never on the domain model.

## Security rules

- **Deny by default.** Open only what is needed.
- Never trust client-sent data for prices, scores, quantities, or permissions.
- Server-authoritative fields are blocked from client writes via `serverFieldsUnchanged([...])` / `affectedKeys().hasOnly([...])`.
- `createdAt` immutability is enforced on update.
- Every `list` rule caps `request.query.limit`. No unbounded queries.
- Audit/log collections get `allow create` only — no update, no delete.
- No client-side delete for critical data (orders, payments).
- Team/membership collections: read rules use an `exists()`-based `hasAccess(parentId)`, not `isOwner(parentId)` — otherwise non-owner roles cannot list their own team.
- Rules are tested with the emulator, as an ordinary authenticated user and as an anonymous one.

## Cloud Functions

- Thin handler in `{action}.ts`, pure business logic in `core/{domain}.ts` with unit tests. No Firestore imports in `core/`.
- Every callable follows: `assertAuth` → validate input → business logic (transaction if multi-doc) → side effects **outside** the transaction.
- Extract anything reusable or conceptually distinct — `assertAuth`, `validateX`, `computePrice`, `decrementQuantity` are shared, not inlined.
- **Every write function needs a documented idempotency strategy**: check-before-write, deterministic doc ID + `set({merge:true})`, or a status guard. Payment functions always check before charging.
- Secrets via `defineSecret` only. Region from a project constant — never hardcoded per file. Auth triggers (`beforeCreate`, `beforeSignIn`) must be `us-central1` — platform constraint.
- Never leak stack traces or upstream errors to the client; log server-side with context.

## Transactions & races

- Read → compute → write **always** needs `runTransaction`. So does any multi-document consistent write and any guarded status transition.
- Unconditional counter bumps use `FieldValue.increment` (no transaction). But checking a value before decrementing **requires** a transaction.
- No API calls, no slow computation, no notifications inside a transaction. Reads before writes. Max 500 writes.
- Auth check goes **before** the transaction (it reads a different doc); re-read the business document **inside** it for TOCTOU safety.

## Indexes

- Every compound query (2+ `where`, or `where` + `orderBy` on another field) needs an entry in `firestore.indexes.json` **in the same PR**.
- An existing similar index does not cover a new field combination — `(storeId, createdAt)` ≠ `(storeId, itemId, createdAt)`.
- **The emulator does not enforce composite indexes.** A green emulator run proves nothing; audit `firestore.indexes.json` against the code.
- Symptom of a missing index: `failed-precondition` with an index link, and (under Riverpod's automatic retry) a ~1 s loading ↔ data flicker before the error settles. Check the raw error before debugging provider lifetimes.

## Client side

- Repository injects `FirebaseFirestore` / `FirebaseFunctions`, maps to domain models, never exposes `DocumentSnapshot` / `QuerySnapshot` / `Map`.
- Writes that must be authoritative go through a Cloud Function, not a direct client write.
- `FirebaseErrorMapper` maps SDK errors to the `AppException` hierarchy (`architecture.md` → Error Handling) in `data/`.
- Crashlytics is guarded with `kIsWeb`.

## Migrations & deprecation

- Access-control migration to composite IDs is two-phase: shared `assert*Access` helper trying new-then-legacy, `newCheck(id) || legacyCheck(id)` in rules, `@JsonKey(readValue:)` on renamed model fields — then a **separate** task backfills and removes the fallback.
- Removing a field from a shared TS interface: mark `@deprecated` + optional → migrate consumers → only then remove. Never create and remove in the same stage.

---

<!-- digest-of: firebase.md -->
