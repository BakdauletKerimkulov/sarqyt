# Plan: Rework Offers Schedule Validation

Source: ai_specs/003-rework-offers-schedule-spec.md
Created: 2026-05-23

## Overview
Закрыть дыры в валидации расписания офферов на сервере и клиенте, добавить `visibleFrom` для one-time офферов, и заблокировать "Not ready yet" когда есть активные ордера или идёт pickup. Работа разбита на 4 стадии: серверная валидация scheduled items, серверная доработка one-time offers, клиентская валидация one-time offers, и UX-блокировка "Not ready yet".

## Stages

### Stage 1: Server — Scheduled Item Validation (V3, V4)
**Goal:** Консолидировать всю серверную валидацию расписания в `validateDaySchedule()`, добавить недостающие проверки, убрать дублирование.
**Files to modify:**
- `functions/src/features/offers/helpers/offer-values.ts` — добавить проверки `startInMinutes >= endInMinutes` и `duration > 120`
- `functions/src/features/offers/services/build-expected-offers.ts` — убрать дублирующую проверку `pickupEnd <= pickupStart` (lines 112-117), т.к. она уже будет в `validateDaySchedule()` который вызывается раньше (line ~97)
**Steps:**
- [x] В `validateDaySchedule()` (offer-values.ts:57-104) добавить: вычислить `startInMinutes = startHour * 60 + startMinute`, `endInMinutes = endHour * 60 + endMinute`
- [x] Добавить проверку: `if (startInMinutes >= endInMinutes)` → throw AppError "Schedule for {dateKey} has invalid pickup window: start must be before end"
- [x] Добавить проверку: `if (endInMinutes - startInMinutes > 120)` → throw AppError "Schedule for {dateKey} exceeds maximum 120-minute window"
- [x] В `build-expected-offers.ts` убрать дублирующий блок `if (pickupEnd <= pickupStart)` (lines 112-117), т.к. `validateDaySchedule()` вызывается раньше в том же flow (line ~97)
**Verification:** `cd functions && npm run build` — компиляция без ошибок. Ручной тест: вызвать `daily-sync-offers` с item у которого schedule 10:00–13:00 — должен получить ошибку "exceeds maximum 120-minute window".

### Stage 2: Server — One-Time Offer `visibleFrom` + Duration (V5a, V6)
**Goal:** Добавить серверную проверку длительности и вычисление `visibleFrom` для one-time офферов.
**Files to modify:**
- `functions/src/features/offers/functions/create-one-time-offer.ts` — добавить проверку длительности и поле `visibleFrom`
**Steps:**
- [x] После существующей проверки `pickupEnd <= pickupStart` (line 81) добавить: вычислить `durationMs = pickupEnd.getTime() - pickupStart.getTime()`, `if (durationMs > 120 * 60 * 1000)` → throw AppError "Pickup window cannot exceed 2 hours"
- [x] Вычислить `visibleFrom`: определить является ли дата оффера "сегодня" в timezone магазина. Если дата > сегодня → `visibleFrom = startOfDay(date - 1, tz)` (переиспользовать `startOfDay` и `addDaysToLocalDate` из `build-expected-offers.ts`). Если дата == сегодня → `visibleFrom = null`
- [x] Добавить `visibleFrom` в документ оффера (lines 100-119): `visibleFrom: visibleFrom ? Timestamp.fromDate(visibleFrom) : null`
**Verification:** `cd functions && npm run build`. Ручной тест: создать one-time offer на завтра — проверить что документ в Firestore содержит `visibleFrom` = начало сегодняшнего дня. Создать на сегодня — `visibleFrom` должен быть `null`.

### Stage 3: Client — One-Time Offer Validation + Verify Existing (V1, V2, V5b, V7)
**Goal:** Добавить клиентскую проверку длительности в one-time offer dialog и верифицировать существующие валидации.
**Files to modify:**
- `lib/src/features/offers/presentation/business/create_one_time_offer_dialog.dart` — добавить проверку max duration в `_validate()`
**Steps:**
- [x] В `_validate()` (create_one_time_offer_dialog.dart:42-62) после проверки `endMinutes <= startMinutes` (line 50) добавить: `if (endMinutes - startMinutes > 120) return 'Window cannot exceed 2 hours';`
- [x] Верифицировать V1: убедиться что `DaySchedule.validationError` в `weekly_schedule.dart:48-56` ловит midnight-crossing (проверка `startInMinutes >= endInMinutes` уже есть)
- [x] Верифицировать V2: убедиться что `DaySchedule.validationError` проверяет `durationMinutes > maxWindowMinutes` (уже есть)
- [x] Верифицировать V7: убедиться что `client_offer_repository.dart:56` фильтрация `visibleFrom == null || !visibleFrom!.isAfter(now)` корректно пропускает one-time офферы с `visibleFrom = null`
- [x] Запустить `flutter analyze`
**Verification:** `flutter analyze` без ошибок. В UI: создать one-time offer с окном 10:00–13:00 — должна появиться ошибка "Window cannot exceed 2 hours".

### Stage 4: Client — "Not Ready Yet" Blocking (V8, V9, V10)
**Goal:** Заблокировать кнопку "Not ready yet" во время pickup window и при наличии активных ордеров, показать причину блокировки.
**Files to create/modify:**
- `lib/src/features/orders/data/orders_repository.dart` — добавить метод `hasActiveOrdersForItem()`
- `lib/src/features/items/presentation/items_list/start_selling_dialog_controller.dart` — добавить проверку ордеров перед `stopSelling()`
- `lib/src/features/items/presentation/items_list/item_card.dart` — скрыть/заблокировать кнопку во время pickup window (V8), показать причину (V10)
- `lib/src/features/items/presentation/items_list/sliver_items_grid.dart` — передать результат проверки ордеров в UI
- `firestore.indexes.json` — добавить composite index `(itemId, status)` для коллекции `orders`
**Steps:**
- [x] В `orders_repository.dart` добавить метод: `Future<bool> hasActiveOrdersForItem(ItemID itemId)` — запрос `orders.where('itemId', '==', itemId).where('status', 'whereIn', ['confirmed', 'preparing', 'readyForPickup']).limit(1).get()`, вернуть `docs.isNotEmpty`
- [x] В `firestore.indexes.json` добавить composite index: collection `orders`, fields `itemId ASC` + `status ASC`
- [x] В `item_card.dart`: использовать существующий `_isSellingNow` (lines 37-42) для V8 — если `_isSellingNow == true`, скрыть кнопку "Not ready yet" (она уже не показывается в этом состоянии, т.к. показывается "Selling Now" badge; верифицировать)
- [x] В `start_selling_dialog_controller.dart` метод `stopSelling()`: перед вызовом `setItemActive(false)` вызвать `hasActiveOrdersForItem(itemId)`. Если есть активные ордера — установить state в `AsyncError` с сообщением "Есть активные бронирования. Отмените бронирования перед паузой." и вернуть `false`
- [x] В `sliver_items_grid.dart` или `item_card.dart`: при ошибке от `stopSelling()` показать inline текст или SnackBar с причиной блокировки (V10) — уже обрабатывается через `ref.listen(startSellingDialogControllerProvider, showAlertDialogOnError)` в `sliver_items_grid.dart:26-29`
- [x] Запустить `flutter analyze`
**Verification:** `flutter analyze` без ошибок. Ручной QA: (1) при активном pickup — кнопка "Not ready yet" не видна; (2) при наличии confirmed/preparing/readyForPickup ордера — нажатие "Not ready yet" показывает предупреждение и не паузит; (3) без ордеров — паузит нормально.

## Firestore Changes
- **Новый composite index** в коллекции `orders`: `itemId ASC` + `status ASC` — для запроса активных ордеров по item.
- **Поле `visibleFrom`** в коллекции `offers` — уже существует в модели, начинаем заполнять для one-time офферов. Изменений схемы не требуется.

## Cloud Functions
- **`validateDaySchedule()`** в `offer-values.ts` — расширение: добавляются 2 новые проверки (end > start, duration ≤ 120).
- **`create-one-time-offer.ts`** — расширение: проверка duration ≤ 120, вычисление и запись `visibleFrom`.
- **`build-expected-offers.ts`** — удаление дублирующей проверки `pickupEnd <= pickupStart`.

## Risks
- **TOCTOU в V9**: между проверкой ордеров и вызовом `setItemActive(false)` может прийти новый ордер. Принято как допустимое — блокировка является UX safeguard, серверный trigger паузит офферы в любом случае, ордера не теряются.
- **Импорт утилит в `create-one-time-offer.ts`**: функции `startOfDay` и `addDaysToLocalDate` используются в `build-expected-offers.ts` — нужно убедиться что они экспортированы из helpers или вынести в общий модуль.
- **Existing one-time offers**: уже созданные one-time офферы останутся без `visibleFrom`. Это корректно — `visibleFrom = null` означает "виден сразу", что совпадает с текущим поведением.

## Out of Scope
- Изменение модели расписания (добавление новых полей, multiple pickup windows per day).
- Изменение структуры документов Firestore (кроме заполнения уже существующего `visibleFrom`).
- Автоматическая отмена ордеров при паузе оффера.
- Уведомления клиентам о паузе/отмене оффера.
- Midnight-crossing pickup windows (осознанно не поддерживаем).
