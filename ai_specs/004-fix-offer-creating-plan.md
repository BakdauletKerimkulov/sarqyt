# Plan: Fix Offer/Item Creation & Management

Source: ai_specs/004-fix-offer-creating-spec.md
Created: 2026-05-23

## Overview
Четыре независимых улучшения Item-модуля: (1) фильтрация табов по типу item, (2) каскадное удаление Item через Cloud Function, (3) image picker при создании Item, (4) обновление стиля формы создания. Стадии выстроены так, что каждая завершается независимо проверяемым результатом; стиль и табы не зависят от серверных изменений.

## Stages

### Stage 1: TextField & Picker Style Update (T10-T11)
**Goal:** Обновить визуальный стиль формы создания Item — outlined borders вместо filled grey.
**Files to modify:**
- `lib/src/features/items/presentation/item_create/create_item_screen.dart` — `_inputDeco()` (line 410-420), date/time picker containers в `_buildOneTimeSection` (lines 343-407)

**Steps:**
- [x] В `_inputDeco()` (line 410): заменить `fillColor: Colors.grey.shade100` на `Theme.of(context).scaffoldBackgroundColor`. Заменить `borderSide: BorderSide.none` на `BorderSide(color: Colors.grey.shade300)`. Убедиться что `border` и `enabledBorder` используют `OutlineInputBorder`.
- [x] Передать `BuildContext` в `_inputDeco` (сейчас метод без context — нужно добавить параметр или сделать его instance-методом с доступом к context).
- [x] Date picker container (line ~350-361): заменить `BoxDecoration(color: Colors.grey.shade100)` на `BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(Sizes.p8))` с transparent/scaffold фоном.
- [x] Time picker buttons (lines ~366-377): аналогичная замена `BoxDecoration`.
- [x] Запустить `flutter analyze`.

**Verification:** Открыть CreateItemFormScreen, переключиться на oneTime тип — все поля ввода, date и time пикеры имеют видимую обводку и прозрачный/scaffold фон. Scheduled mode — то же самое для text fields.

---

### Stage 2: Filter Tabs by Item Type (T1-T2)
**Goal:** Для one-time items показывать только 3 таба (Overview, Customer Ratings, Settings), для scheduled — все 5.
**Files to modify:**
- `lib/src/routing/business_router.dart` — GoRoute для ItemScreen (line 306-321): добавить query param `type`
- `lib/src/features/items/presentation/item_screen/item_screen.dart` — конструктор, `initState`, TabBar, `_buildTabContent`
- `lib/src/features/items/presentation/item_tab.dart` — добавить helper для фильтрации

**Steps:**
- [x] В `item_tab.dart`: добавить static method или top-level function `filteredTabs(ItemType type)` — возвращает `[overview, customerRatings, settings]` для `oneTime`, `ItemTab.values` для `scheduled`.
- [x] В `item_screen.dart`: добавить параметр `ItemType itemType` в конструктор `ItemScreen`.
- [x] В `initState` (line 38-48): вычислять `_filteredTabs = filteredTabs(widget.itemType)`. Заменить `ItemTab.values.length` на `_filteredTabs.length`. Заменить `widget.initialTab.index` на `_filteredTabs.indexOf(widget.initialTab)` с fallback `clamp(0, _filteredTabs.length - 1)`.
- [x] В TabBar (line 93): заменить `ItemTab.values.map(...)` на `_filteredTabs.map(...)`.
- [x] В `_buildTabContent` (line 117): заменить `ItemTab.values[_tabController.index]` на `_filteredTabs[_tabController.index]`.
- [x] В `business_router.dart` (line 306-321): парсить query param `type` (`ItemType.values.byName(...)` с default `scheduled`), передавать в `ItemScreen(itemType: ...)`.
- [x] Найти все места навигации на ItemScreen (поиск по `BusinessRoute.item` / `item/:itemId`) и добавить query param `type` из известного item.type.

**Verification:** Открыть scheduled item — видны все 5 табов. Открыть one-time item — видны только 3 таба (Overview, Customer Ratings, Settings). Deep link с `?tab=schedule` для oneTime — открывается на Overview (fallback).

---

### Stage 3: Cloud Function `deleteItem` (T6-T7)
**Goal:** Серверная функция для каскадного удаления Item: документ + офферы + картинка из Storage.
**Files to create/modify:**
- `functions/src/features/items/functions/delete-item.ts` — новая callable function
- `functions/src/index.ts` — экспорт новой функции

**Steps:**
- [x] Создать `functions/src/features/items/functions/delete-item.ts` по паттерну существующих callable functions (как `createOneTimeOffer`).
- [x] Auth check: caller должен быть PARTNER или ADMIN. Проверить ownership/staff через `stores/{storeId}` doc.
- [x] Re-check active orders: запрос `orders` коллекции с `where('itemId', '==', itemId).where('status', 'in', ['confirmed', 'preparing', 'readyForPickup'])`. Если есть — throw HttpsError('failed-precondition', 'Active orders exist').
- [x] Удалить Item doc: `stores/{storeId}/items/{itemId}`.
- [x] Batch-delete offers: запрос `offers` где `productId == itemId`, batch delete всех найденных.
- [x] Delete image from Storage: если `imageUrl` существует в Item doc, удалить файл из Storage (best-effort, игнорировать ошибку если файл не найден).
- [x] Экспортировать из `functions/src/index.ts`.

**Verification:** Деплой функции. Вызов через Firebase CLI/curl с тестовым item без активных ордеров — item, его офферы и картинка удалены. Вызов с item с активными ордерами — ошибка `failed-precondition`.

---

### Stage 4: Delete Item UI (T3-T5)
**Goal:** Кнопка "Delete item" в Settings с проверкой ордеров и confirmation dialog.
**Files to modify:**
- `lib/src/features/items/presentation/item_screen/settings_content.dart` — добавить кнопку Delete
- `lib/src/features/items/presentation/item_screen/settings_content_controller.dart` — добавить метод `deleteItem`

**Steps:**
- [x] В `settings_content_controller.dart`: добавить метод `deleteItem(StoreID storeId, ItemID itemId)`. Внутри: вызвать `ordersRepositoryProvider` → `hasActiveOrdersForItem(itemId)`. Если есть — throw exception с сообщением. Если нет — вызвать Cloud Function `deleteItem` через `FirebaseFunctions.instance.httpsCallable('deleteItem')`. Возвращать `AsyncValue`.
- [x] В `settings_content.dart` (line 29-45): после `ItemInstructionsSettingsSection` (line 43) добавить `gapH24` и кнопку "Delete item". Стиль: красный текст, outlined или text button, полная ширина.
- [x] При нажатии кнопки: сначала проверить `hasActiveOrdersForItem`. Если есть активные — показать AlertDialog "Cannot delete: there are active reservations. Cancel or complete them first." с одной кнопкой OK.
- [x] Если нет активных — показать confirmation AlertDialog "Are you sure you want to delete this item? This action cannot be undone." с кнопками Cancel / Delete.
- [x] При подтверждении: вызвать Cloud Function, при успехе — `context.pop()` немедленно.
- [x] Добавить loading state на кнопку во время операции.
- [x] Запустить `flutter analyze`.

**Verification:** Открыть item без активных ордеров → Settings → Delete item → подтвердить → item удалён, возврат на предыдущий экран. Открыть item с активными ордерами → Delete item → показывается сообщение о невозможности удаления.

---

### Stage 5: Image Picker in Create Item Form (T8-T9)
**Goal:** Добавить выбор картинки при создании Item с upload-first подходом.
**Files to modify:**
- `lib/src/features/items/presentation/item_create/create_item_screen.dart` — добавить image picker UI
- `lib/src/features/items/presentation/item_create/create_item_form_controller.dart` — добавить image upload в submit

**Steps:**
- [x] В `create_item_screen.dart`: добавить state переменную `Either<File, Uint8List>? _selectedImage` и `Uint8List? _imagePreviewBytes` (для отображения превью на обеих платформах).
- [x] Перед полем Name добавить image picker area: GestureDetector/InkWell с placeholder (Container с иконкой камеры, outlined border, ~200px высота). Если картинка выбрана — показать превью через `Image.memory(_imagePreviewBytes!)`.
- [x] Реализовать `_pickImage()`: переиспользовать паттерн из `ItemDetailsSettingsSection._pickAndUploadImage()` — `ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85)`, обработка `kIsWeb` для `File` vs `Uint8List`.
- [x] В `create_item_form_controller.dart`: добавить параметр `Either<File, Uint8List>? image` в `submit()`. Добавить зависимость от `imageUploadRepositoryProvider`.
- [x] В `submit()`: если `image != null` — сгенерировать UUID path `stores/$storeId/items/$uuid.$ext`, загрузить через `imageUploadRepository.uploadProductImage(data: image, path: path)`, получить `imageUrl`. Передать в `createItem(imageUrl: imageUrl)`.
- [x] При ошибке `createItem()` после успешной загрузки — `imageUploadRepository.deleteItemImage(imageUrl)` в catch (best-effort, игнорировать ошибку cleanup).
- [x] В `create_item_screen.dart` `_submit()`: передать `_selectedImage` в controller.submit().
- [x] Запустить `flutter analyze`.

**Verification:** Создать item без картинки — работает как раньше. Создать item с картинкой — картинка загружена в Storage, item создан с imageUrl, превью показывается в форме перед submit.

---

## Firestore Changes
- **Composite index** `orders` collection: `(itemId ASC, status ASC)` — вероятно уже существует (метод `hasActiveOrdersForItem()` работает в production). Проверить в Firebase console перед деплоем Stage 3.
- Новых коллекций, полей или security rules не требуется.

## Cloud Functions
- **Новая**: `deleteItem` (callable) — каскадное удаление Item + offers + Storage image. Создаётся в Stage 3.
- Auth: PARTNER/ADMIN с проверкой ownership.
- Re-check active orders на сервере (защита от race condition).

## Test Coverage
- Ручное QA по каждой стадии (verification section).
- `flutter analyze` после каждой стадии.
- E2E тест: создание scheduled item → проверка 5 табов → создание one-time item с картинкой → проверка 3 табов → удаление item → возврат на список.

## Risks
- **Composite index**: если `(itemId, status)` index не существует, `hasActiveOrdersForItem()` вызов из Cloud Function потребует создания index. Firestore покажет ссылку для создания в логах ошибки.
- **Race condition при удалении**: между проверкой на клиенте и вызовом Cloud Function может появиться новый ордер. Серверный re-check в функции защищает от этого, но не в транзакции (query + delete не atomic в Firestore). Риск минимален — окно гонки очень маленькое.
- **Orphaned images**: если `createItem` упал после upload, cleanup best-effort. Orphaned images в Storage допустимы.
- **Navigation after delete**: `context.pop()` вызывается до обновления stream. Если pop не сработал — `AsyncValueWidget` покажет error/empty state.

## Out of Scope
- Удаление отдельного Offer (управляется через расписание)
- Редактирование типа Item (scheduled ↔ oneTime) после создания
- Bulk-delete нескольких Items
- Кроппинг/ресайз картинки на клиенте
- Изменение модели Offer (добавление type/source поля)
- Push-уведомления клиентам при удалении Item/Offer
- Удаление/deprecation существующего `ItemsRepository.deleteItem()` (отдельная задача)
- Анимация при удалении item из списка
- Drag-and-drop для картинки на web
