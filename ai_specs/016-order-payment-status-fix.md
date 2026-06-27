---
title: Order paymentStatus deserialization crash on unknown value
date: 2026-06-28
type: fix
severity: S
references: []
---

## Symptom
The "Reservations" section on the business dashboard crashes with `Invalid argument(s): 'expired' is not one of the supported values: paid, refunded, refundPending, refundFailed` when any Firestore order document contains a `paymentStatus` value not in the `PaymentStatus` enum.

## Root cause
The `Order` model's `paymentStatus` field used `$enumDecodeNullable` without an `unknownValue` fallback. While `$enumDecodeNullable` returns null for null input, it throws `ArgumentError` for non-null values not in the enum map. When a Firestore document has `paymentStatus: 'expired'` (or any other unknown value), deserialization of the entire orders stream fails. File: `lib/src/features/orders/domain/order.dart:35`.

## Fix
- **Files changed:** `lib/src/features/orders/domain/order.dart`, `lib/src/features/orders/domain/order.g.dart` (regenerated)
- **Failing test that catches the regression:** `test/features/orders/order_model_test.dart::handles unknown paymentStatus gracefully (e.g. "expired")`
- **`ai_toolkit/` rules applied:** `architecture.md` (freezed models, codegen), `code-style.md` (JsonKey annotations)
- **Toolkit deviations:** none
- Added `@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)` to `paymentStatus`, making unknown values deserialize as `null` instead of throwing. Also added `// ignore_for_file: invalid_annotation_target` for freezed constructor param lint.
