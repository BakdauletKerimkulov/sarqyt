---
title: Fix item screen reservations flickering
status: done
date: 2026-07-12
type: fix
---

# Plan: Fix item screen reservations flickering

Source: `ai_specs/028-fix-offer-screen-bag-spec.md`

## Overview
Add `ref.keepAlive()` + 30-second `Timer` pattern to `ordersListForItemStreamProvider` and `ordersListStream` so cached `AsyncData` survives tab switches without triggering a fresh Firestore subscription.

**Spec:** `ai_specs/028-fix-offer-screen-bag-spec.md`

## Context
- **Structure:** feature-first (`lib/src/features/orders/data/`)
- **State management:** Riverpod codegen (`@riverpod`) — `lib/src/features/orders/data/orders_repository.dart:91–102`
- **Reference implementations:** `ordersRepositoryProvider` (keepAlive repo pattern, same file line 83–89); existing provider test at `test/src/features/orders/data/orders_repository_provider_test.dart`
- **Testing convention:** unit tests in `test/src/features/` mirroring `lib/src/features/`; `ProviderContainer` overrides for mocking repos (`ai_toolkit/riverpod.md` §Testing)
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:** none — spec is fully specified with exact code pattern

## Plan

### Phase 1 — Timed keepAlive on orders stream providers + regression test
**Goal:** Prove that both stream providers retain `AsyncData` across unmount/remount within 30 s, eliminating flickering.

- [x] TDD: `ordersListForItemStreamProvider` retains `AsyncData` when last watcher is removed and new watcher added within 30 s → then implement
- [x] TDD: `ordersListStream` retains `AsyncData` with same cache semantics → then implement
- [x] `lib/src/features/orders/data/orders_repository.dart` (lines 91–102) — add `ref.keepAlive()` + `Timer(30s, link.close)` + `ref.onDispose(timer.cancel)` to both `ordersListStream` and `ordersListForItemStreamProvider`
- [x] `test/src/features/orders/data/orders_stream_cache_test.dart` — create test: mock `StoreOrdersRepository` returning `StreamController.stream`, override in `ProviderContainer`, subscribe → emit data → unsubscribe → re-subscribe within 30 s → assert `AsyncData` (not `AsyncLoading`)
- [x] `dart run build_runner build --delete-conflicting-outputs` — regenerate `.g.dart` for modified providers
- [x] Verify: `flutter analyze && flutter test`

### Phase 2 — Documentation
**Goal:** Update toolkit with the timed-keepAlive pattern for future reference.

- [x] `ai_toolkit/riverpod.md` §Stream Providers — add "Timed keepAlive for family stream providers" subsection with pattern, when to use (family providers viewed repeatedly, not app-wide), and anti-pattern (permanent keepAlive on family providers leaks memory)
- [x] Verify: `flutter analyze && flutter test`

## Data layer changes
_None._

## External integrations
_None._

## Risks
- Timer-based disposal relies on `ref.onDispose` being called synchronously on provider disposal; Riverpod guarantees this — low risk.
- If the test framework cannot simulate time-based disposal (keepAlive link close), use `FakeAsync` from `package:fake_async` to advance time.

## Out of scope
- NOT restructuring tab content to stay mounted (IndexedStack)
- NOT modifying `AsyncValueWidget`
- NOT applying cache pattern to all stream providers project-wide
- NOT investigating Firestore-level stream instability
