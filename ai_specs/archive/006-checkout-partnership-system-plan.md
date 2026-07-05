---
title: Checkout Partnership System
status: done
date: 2026-05-26
type: feature
---

# Plan: Аудит и доработка системы партнёрства

Source: ai_specs/006-checkout-partnership-system-spec.md

## Overview

Разделить `businessId` и `storeId`, перевести все auth checks с `staffIds`/`ownerId` на `storeShips`, реализовать `business_membership`, обновить Dart-модели, добавить Cloud Functions для создания второго магазина и приглашения в команду, создать UI для управления командой и добавления магазина. Всё в рамках двухфазной стратегии миграции (Фаза 1 — код с fallback на старые поля, Фаза 2 — out of scope).

## Stages

### Stage 1: TypeScript interfaces и shared auth helper

**Goal:** Создать/обновить TypeScript интерфейсы и общий helper `assertStoreAccess`, чтобы все последующие стадии могли его использовать.

**Files to create/modify:**
- `functions/src/features/shared/interfaces/store-ship-doc.ts` — новый `StoreShipDoc` interface
- `functions/src/features/shared/interfaces/business-membership-doc.ts` — новый `BusinessMembershipDoc` interface
- `functions/src/features/shared/interfaces/store-doc.ts` — обновить `StoreDoc` (добавить `id`, `businessId`, `storeType`, `isVisible`, `createdAt`, `updatedAt`; убрать `staffIds`)
- `functions/src/features/shared/helpers/assert-store-access.ts` — новый helper `assertStoreAccess(uid, storeId): Promise<StoreShipDoc>`

**Steps:**
- [x] Создать `StoreShipDoc` interface: `id`, `storeId`, `businessId`, `userId`, `role` (`"owner" | "operator" | "employer"`), `permissions: string[]`, `name`, `logoUrl?`, `welcomeCompleted`, `hasFirstItem`, `createdAt`, `updatedAt`
- [x] Создать `BusinessMembershipDoc` interface: `id`, `businessId`, `userId`, `role` (`"owner" | "admin"`), `createdAt`, `updatedAt`
- [x] Обновить `StoreDoc`: добавить `id`, `businessId`, `storeType`, `isVisible`, `createdAt`, `updatedAt`. `staffIds` помечен `@deprecated` (не удалён — существующие функции ещё используют его, будет убран в Stage 2)
- [x] Создать `assertStoreAccess(uid, storeId)` — читает `storeShips/${storeId}_${uid}`, при отсутствии бросает `permission-denied`. Fallback: если storeShip не найден, проверить `stores/${storeId}.ownerId === uid` (совместимость Фаза 1). Возвращает `StoreShipDoc`
- [x] Re-exports не требуются — существующие consumers импортируют файлы напрямую

**Verification:** `npm run build` в `functions/` компилируется без ошибок.

---

### Stage 2: Миграция Cloud Functions auth checks на assertStoreAccess

**Goal:** Заменить все `ownerId + staffIds` проверки в существующих Cloud Functions на `assertStoreAccess`.

**Files to modify:**
- `functions/src/features/offers/functions/create-one-time-offer.ts`
- `functions/src/features/offers/functions/update-offer-quantity.ts`
- `functions/src/features/offers/services/load-offer-sync-context.ts`
- `functions/src/features/orders/functions/update-order-status.ts`
- `functions/src/features/orders/functions/cancel-order.ts`
- `functions/src/features/items/functions/delete-item.ts`

**Steps:**
- [x] В каждой из 6 функций заменить блок чтения store + проверки `ownerId`/`staffIds` на вызов `assertStoreAccess(uid, storeId)`
- [x] В `cancel-order.ts` сохранить двойную проверку: customer (по `order.customerId === uid`) ИЛИ store access (через `assertStoreAccess`), без изменения бизнес-логики
- [x] В `load-offer-sync-context.ts` — адаптировать возвращаемый контекст: store doc теперь читается отдельно от auth check
- [x] Убрать `staffIds` из всех мест где он читается в auth checks
- [x] Убедиться что `ownerId` остаётся в store doc для запросов (denormalized), но НЕ используется для auth

**Verification:** `npm run build` компилируется. Ручной тест: существующий owner магазина может создать offer, обновить order status, отменить order.

---

### Stage 3: Обновление completeMerchantOnboarding — разделение businessId/storeId и business_membership

**Goal:** Новые регистрации создают отдельные `businessId` и `storeId`, документ `business_membership`, и storeShip с полем `role` (вместо `storeRole`).

**Files to modify:**
- `functions/src/features/merchant-onboarding/functions/complete-merchant-onboarding.ts`

**Steps:**
- [x] Генерировать отдельный `businessId` (`db.collection('businesses').doc().id`) и `storeId` (из draft, уже есть)
- [x] В batch write: business doc с собственным `businessId`, store doc с `businessId` ссылкой, без `staffIds`
- [x] В batch write: создать `business_membership/${businessId}_${uid}` с `role: "owner"`, `businessId`, `userId`, `createdAt`, `updatedAt`
- [x] В storeShip: записывать `role: "owner"` (новое поле) вместе с `storeRole: "owner"` (backward compat для Фазы 1)
- [x] Удалить запись `staffIds: []` из store document creation
- [x] Удалить запись `onboardingStatus` из storeShip (оставить `welcomeCompleted: false`, `hasFirstItem: false`)

**Verification:** `npm run build`. Ручной тест: зарегистрировать нового партнёра, проверить что в Firestore создались отдельные business и store docs с разными ID, business_membership doc, storeShip с полем `role`.

---

### Stage 4: Cleanup — удаление skipOptionalOnboarding и onboardingStatus

**Goal:** Убрать мёртвый код: `skipOptionalOnboarding` Cloud Function и `onboardingStatus` из storeShip.

**Files to modify/delete:**
- `functions/src/features/merchant-onboarding/functions/skip-optional-onboarding.ts` — удалить
- `functions/src/index.ts` (или где экспортируется) — убрать export
- Dart: `lib/src/features/store/domain/store_ship.dart` — убрать backward-compat parsing `onboardingStatus`
- Dart: `lib/src/features/store/domain/store_ship.freezed.dart` — regenerate

**Steps:**
- [x] Удалить файл `skip-optional-onboarding.ts`
- [x] Убрать его export из index (найти и удалить)
- [x] В Dart `StoreShip` model: убрать `_readWelcomeCompleted` fallback function и `onboardingStatus` parsing. `welcomeCompleted` и `hasFirstItem` остаются как обычные поля
- [x] Запустить `dart run build_runner build --delete-conflicting-outputs`

**Verification:** `npm run build` в functions. `flutter analyze` в корне.

---

### Stage 5: Обновление Firestore rules и Storage rules

**Goal:** Перевести все security rules с `isStoreOwner`/`isStoreStaff` на storeShips-based проверки.

**Files to modify:**
- `firestore.rules`
- `storage.rules`

**Steps:**
- [x] Добавить helper functions: `hasStoreAccess(storeId)` (exists check), `hasStoreRole(storeId, role)` (get + role check), `isStoreOwnerViaShip(storeId)`, `hasBusinessMembership(businessId)` (exists check)
- [x] Заменить `isStoreOwner(storeId)` и `isStoreStaff(storeId)` на `hasStoreAccess(storeId)` во всех правилах для: stores, items subcollection, offers, orders
- [x] Обновить storeShips read rules: заменить `isStoreOwner(resource.data.storeId)` на `isStoreOwnerViaShip(resource.data.storeId)` — избежать циклической зависимости
- [x] Обновить businesses rules: добавить `hasBusinessMembership(businessId)` как альтернативу `ownerId` check
- [x] Обновить business_membership rules: read доступен для admin или пользователя с matching `userId` (already existed, no change needed)
- [x] Storage rules: заменить `isStoreOwner`/`isStoreStaff` на `hasStoreAccess` (из storeShips, а не store doc)
- [x] Оставить fallback на `isStoreOwner(storeId)` (через `ownerId`) для старых документов (Фаза 1): `hasStoreAccess(storeId) || isStoreOwner(storeId)`

**Verification:** Firebase emulator tests (если есть). Ручной тест: owner может CRUD items, offers; неавторизованный пользователь не может.

---

### Stage 6: Обновление Dart моделей и репозиториев

**Goal:** Обновить Dart domain models (`Store`, `StoreShip`, `BusinessMembership`) и репозитории для соответствия новой архитектуре.

**Files to modify:**
- `lib/src/features/store/domain/store.dart` — добавить `businessId`
- `lib/src/features/store/domain/store_ship.dart` — переименовать `storeRole` → `role` с fallback
- `lib/src/features/store/data/store_repository.dart` — обновить `watchStoresList`
- `lib/src/features/store/data/store_ship_repository.dart` — при необходимости

**Files to create:**
- `lib/src/features/business_console/domain/business_membership.dart` — новая модель
- `lib/src/features/business_console/data/business_membership_repository.dart` — новый репозиторий

**Steps:**
- [x] `Store` model: добавить `String? businessId` (nullable для backward compat со старыми документами). Обновить `fromMap`/`toMap` (hand-written, не codegen)
- [x] `StoreShip` model: переименовать `storeRole` → `role` в Dart. В `fromJson` читать `role` с fallback на `storeRole` (Фаза 1) через `_readRole` JsonKey readValue. Обновить `StoreRole` enum (уже есть: owner, operator, employer)
- [x] Создать `BusinessMembership` freezed model: `id`, `businessId`, `userId`, `role` (enum: owner, admin), `createdAt`, `updatedAt`
- [x] Создать `BusinessMembershipRepository`: `watchMembership(businessId, userId)`, `watchBusinessMembers(businessId)`. Provider с `@riverpod` codegen
- [x] Обновить `StoreRepository.watchStoresList`: оставить query по `ownerId`, добавить comment что для полного списка нужно дополнить storeIds из storeShips (реализовать в Stage 8 при UI)
- [x] Запустить `dart run build_runner build --delete-conflicting-outputs`

**Verification:** `flutter analyze` проходит. Codegen без ошибок.

---

### Stage 7: Cloud Functions — fakeVerifyBusiness, createAdditionalStore, inviteTeamMember

**Goal:** Добавить проверку ownership в `fakeVerifyBusiness`, создать две новые Cloud Functions.

**Files to modify:**
- `functions/src/features/merchant-onboarding/functions/fake-verify-business.ts` — добавить business_membership check

**Files to create:**
- `functions/src/features/stores/functions/create-additional-store.ts`
- `functions/src/features/stores/functions/invite-team-member.ts`

**Steps:**
- [x] `fakeVerifyBusiness`: после проверки `role === 'partner'`, добавить проверку `business_membership/${businessId}_${uid}` exists с role `"owner"`. Если нет — `permission-denied`
- [x] `createAdditionalStore`: callable function, принимает `{ name, storeType, address, phone, businessId }`. Проверки: auth, role partner, canCreateStore claim, business_membership exists для businessId. Batch: создать store doc + storeShip doc. Возвращает `storeId`
- [x] `inviteTeamMember`: callable function, принимает `{ storeId, email, role, permissions }`. Проверки: auth, assertStoreAccess (owner или operator). Найти user по email (query `users` where `email == email`). Если не найден — вернуть ошибку `not-found`. Создать `storeShips/${storeId}_${inviteeUid}` с ролью и permissions. Если invitee не partner — обновить custom claims на `role: partner`
- [x] Экспортировать новые функции из index
- [x] Добавить Firestore composite index для `storeShips` по полю `storeId` в `firestore.indexes.json`

**Verification:** `npm run build`. Ручной тест: создать второй магазин через `createAdditionalStore`, пригласить сотрудника через `inviteTeamMember`.

---

### Stage 8: UI — Team Management и Add Store

**Goal:** Создать UI для управления командой магазина и добавления второго магазина.

**Files to create:**
- `lib/src/features/business_console/presentation/team/team_list_screen.dart` — список членов команды
- `lib/src/features/business_console/presentation/team/invite_member_dialog.dart` — диалог приглашения
- `lib/src/features/business_console/presentation/stores/add_store_screen.dart` — форма создания магазина

**Files to modify:**
- `lib/src/features/business_console/presentation/store_list_screen.dart` — добавить кнопку "Добавить магазин"
- Router/navigation — добавить маршруты для team и add-store
- `lib/src/features/store/data/store_ship_repository.dart` — добавить `watchStoreShipsByStoreId(storeId)` для team list

**Steps:**
- [x] `StoreShipRepository`: добавить `watchStoreShipsByStoreId(storeId)` — stream query storeShips where storeId == param (нужен composite index из Stage 7)
- [x] Team List Screen: watches storeShips по storeId, отображает имя, роль, permissions каждого member. Кнопка "Пригласить"
- [x] Invite Member Dialog: текстовое поле email, выбор роли (operator/employer), кнопка "Пригласить" → вызов `inviteTeamMember` Cloud Function
- [x] Add Store Screen: переиспользовать форму из onboarding (name, type, address, phone). Автоматически привязать к существующему бизнесу (если один). Кнопка "Создать" → вызов `createAdditionalStore` Cloud Function
- [x] Store List Screen: добавить FAB или кнопку "Добавить магазин" → навигация на Add Store Screen
- [x] Добавить маршруты в GoRouter: `/stores/:storeId/team`, `/stores/add`
- [x] Обновить storeShips read rules в firestore.rules: разрешить query по storeId для owner/operator (через `hasStoreAccess`)

**Verification:** `flutter analyze`. Ручной QA: открыть team tab → увидеть owner → пригласить сотрудника → сотрудник появляется в списке. Добавить магазин → магазин появляется в store list.

## Firestore Changes

### Новые коллекции/документы
- `business_membership/{businessId}_{uid}` — связь user-business, поля: `id`, `businessId`, `userId`, `role`, `createdAt`, `updatedAt`

### Изменения полей
- `stores/{storeId}`: добавлено `businessId`, `storeType`, `isVisible`, `createdAt`, `updatedAt`; удалено `staffIds`
- `storeShips/{id}`: добавлено `role` (заменяет `storeRole`); удалено `onboardingStatus`, `status`
- `businesses/{id}`: `businessId` теперь генерируется отдельно от `storeId`

### Новые indexes
- `storeShips`: composite index на `storeId` (ascending) для query team list

### Security rules
- Новые helpers: `hasStoreAccess(storeId)`, `hasStoreRole(storeId, role)`, `isStoreOwnerViaShip(storeId)`, `hasBusinessMembership(businessId)`
- `isStoreOwner`/`isStoreStaff` → deprecated, fallback only (Фаза 1)

## Cloud Functions

### Изменённые
- `completeMerchantOnboarding` — раздельные ID, business_membership, role вместо storeRole
- `fakeVerifyBusiness` — добавлена проверка business_membership
- `create-one-time-offer`, `update-offer-quantity`, `update-order-status`, `cancel-order`, `delete-item`, `load-offer-sync-context` — auth через `assertStoreAccess`

### Новые
- `createAdditionalStore` — создание второго магазина
- `inviteTeamMember` — приглашение сотрудника по email

### Удалённые
- `skipOptionalOnboarding` — dead code

## Test Coverage

- **Cloud Functions**: `npm run build` компилируется для всех стадий
- **Flutter**: `flutter analyze` проходит для стадий с Dart-изменениями
- **Firestore rules**: тесты на emulator (если есть инфраструктура), иначе ручной QA
- **E2E ручной QA**: полный flow регистрации → создание магазина → dashboard → приглашение сотрудника → второй магазин

## Risks

| Риск | Mitigation |
|---|---|
| Старые документы без storeShip для owner → потеря доступа | Fallback в `assertStoreAccess` на `ownerId`, fallback в rules `hasStoreAccess \|\| isStoreOwner` |
| Переименование `storeRole` → `role` ломает Dart parsing старых docs | Dart читает оба поля с fallback |
| `business_membership` query без index | Composite ID `{businessId}_{uid}` — прямой get, не query |
| `inviteTeamMember` находит user по email — query на users collection | Убедиться что email индексирован (Firestore автоматически индексирует single fields) |
| Concurrent storeShip create/delete race | Cloud Functions используют transaction/set с composite ID |
| `fakeVerifyBusiness` — dev-only, но security hole | Добавить business_membership check в Stage 7 |

## Out of Scope

- Создание нового бизнеса для существующего партнёра (один бизнес на пользователя)
- Transfer ownership бизнеса
- Invite link (приглашение по ссылке)
- Роли и permissions на уровне UI (permission-based UI gating)
- Уведомления при приглашении (push/email)
- Аудит-лог действий команды
- Миграция существующих данных (Фаза 2 — отдельная задача)
- Изменение потока верификации бизнеса
- `removeTeamMember` Cloud Function (nice to have)
