# Spec: Fix Offer/Item Creation & Management

Created: 2026-05-23
Status: refined

## Goal
Исправить UX и логику создания/управления айтемами: убрать нерелевантные табы для one-time items, добавить удаление Item (только без активных бронирований), добавить загрузку картинки при создании, и улучшить визуальный стиль формы создания.

## Background

### Текущее поведение
1. **Табы для one-time items**: При просмотре one-time item на `ItemScreen` показываются все 5 табов (Overview, Calendar, Schedule, Customer Ratings, Settings). Табы Schedule и Calendar не имеют смысла для одноразового item — Schedule показывает недельное расписание, Calendar — заглушку "Coming soon".
2. **Удаление Item**: Существует `ItemsRepository.deleteItem()` (`items_repository.dart:95-97`) — клиентский delete, который удаляет только Item doc без каскадного удаления офферов и картинки. Firestore rules уже разрешают delete для owner/staff. Нет UI кнопки удаления и нет Cloud Function для каскадного удаления.
3. **Картинка Item**: Модель `Item` уже имеет поле `imageUrl`. Загрузка картинки уже реализована в `ItemDetailsSettingsSection` (settings tab) через `ImageUploadRepository`. Но при **создании** Item (`CreateItemFormScreen`) нет возможности прикрепить картинку — только после создания, через settings.
4. **Стиль формы создания**: TextField-ы в `CreateItemFormScreen` имеют `fillColor: Colors.grey.shade100` и `borderSide: BorderSide.none` — нет обводки границ. Нужно сделать цвет фона как у scaffold и добавить обводку.

### Что нужно исправить
1. Для one-time items показывать только табы: Overview, Customer Ratings, Settings.
2. Добавить кнопку "Delete Item" (доступна только если нет активных бронирований).
3. Добавить image picker при создании Item.
4. Обновить стиль TextFields: фон совпадает с фоном экрана, добавлена обводка (OutlineInputBorder).

## User Flow

### Просмотр one-time item
1. Бизнес открывает one-time item из списка.
2. Видит только 3 таба: Overview, Customer Ratings, Settings.
3. Табы Schedule и Calendar отсутствуют.

### Удаление Item
1. Бизнес открывает Item → таб Settings.
2. Внизу `SettingsContent` (после обеих секций `ItemDetailsSettingsSection` и `ItemInstructionsSettingsSection`) видит кнопку "Delete item" (красная, деструктивная).
3. Нажимает кнопку.
4. Система проверяет наличие активных ордеров (`confirmed` / `preparing` / `readyForPickup`) по `itemId`.
5. **Если есть активные ордера** → AlertDialog с сообщением "Cannot delete: there are active reservations. Cancel or complete them first." Кнопка недоступна.
6. **Если нет** → AlertDialog "Are you sure you want to delete this item? This action cannot be undone."
7. При подтверждении: Cloud Function удаляет Item из Firestore, все связанные офферы удаляются, картинка из Storage удаляется.
8. Клиент вызывает `context.pop()` сразу после успешного ответа Cloud Function (до того как `itemStreamProvider` получит null). Это предотвращает мелькание "No item found".

### Загрузка картинки при создании Item
1. Бизнес открывает форму создания Item (`CreateItemFormScreen`).
2. В верхней части формы (перед полем Name) видит область для картинки — placeholder с иконкой камеры/галереи.
3. Нажимает → открывается `ImagePicker` (gallery).
4. Выбирает картинку → превью отображается в форме.
5. При submit: сначала загружается картинка в Storage (UUID path), затем `createItem()` вызывается с полученным `imageUrl`. Один вызов, без двухшагового create-then-update.

### Стиль формы создания
1. TextFields имеют прозрачный/scaffold-matching фон.
2. TextFields имеют обводку границ (OutlineInputBorder).
3. Контейнеры для date picker и time picker стилизованы аналогично.

## Requirements

### Must Have
- [ ] **T1**: `ItemScreen` фильтрует табы по `item.type` — для `oneTime` показывать только `[overview, customerRatings, settings]`, для `scheduled` — все 5. Router передаёт `ItemType` как query param, `ItemScreen` получает его в конструкторе для синхронного создания `TabController`.
- [ ] **T2**: `TabController.length` зависит от `filteredTabs` list. `initialIndex` вычисляется как `filteredTabs.indexOf(widget.initialTab)` с fallback на 0. TabBar итерирует `filteredTabs` (не `ItemTab.values`). `_buildTabContent` использует `filteredTabs[_tabController.index]`.
- [ ] **T3**: Кнопка "Delete item" в `SettingsContent` — красная, внизу виджета (после `ItemDetailsSettingsSection` и `ItemInstructionsSettingsSection`), не внутри подсекций
- [ ] **T4**: Перед удалением проверка активных ордеров: переиспользовать существующий `StoreOrdersRepository.hasActiveOrdersForItem()` (`orders_repository.dart:36-44`). Метод уже реализует нужный запрос. Примечание: метод проверяет глобально (без фильтра по storeId) — это корректно для delete flow.
- [ ] **T5**: AlertDialog подтверждения удаления ("Are you sure?")
- [ ] **T6**: Cloud Function `deleteItem` — удаляет Item doc + batch-delete всех офферов с `productId == itemId` + удаляет картинку из Storage
- [ ] **T7**: Удаление через Cloud Function с admin SDK — существующие Firestore rules уже разрешают client-side delete (`firestore.rules:66-71`), но Cloud Function предпочтительнее для каскадного удаления. Существующий `ItemsRepository.deleteItem()` НЕ использовать для этого flow — он удаляет только Item doc без каскада.
- [ ] **T8**: Image picker в `CreateItemFormScreen` — placeholder с возможностью выбрать картинку из галереи
- [ ] **T9**: При submit формы: если картинка выбрана, сначала загрузить через `ImageUploadRepository.uploadProductImage()` (UUID path: `stores/$storeId/items/$uuid.$ext`), получить URL, затем передать `imageUrl` в `createItem()`. Всё внутри `CreateItemFormController.submit()` — добавить параметр `Either<File, Uint8List>? image`. При ошибке `createItem()` после успешной загрузки картинки — попытаться удалить загруженную картинку через `ImageUploadRepository.deleteItemImage()`.
- [ ] **T10**: `_inputDeco()` в `CreateItemFormScreen`: заменить `fillColor: Colors.grey.shade100` на цвет scaffold background, заменить `borderSide: BorderSide.none` на видимую обводку (`OutlineInputBorder` с `borderSide`)
- [ ] **T11**: Контейнеры date/time picker стилизовать аналогично (обводка вместо filled grey)

### Nice to Have
- [ ] Анимация при удалении item (fade out из списка)
- [ ] Возможность кропнуть картинку перед загрузкой
- [ ] Drag-and-drop для картинки на web

## Technical Constraints

### Клиент (Flutter)

**Табы (T1-T2)**:
- `ItemScreen` (`item_screen.dart`): `TabController` создаётся в `initState` с `length: ItemTab.values.length`. Нужно вычислять filtered list на основе `item.type`.
- Проблема: `item` загружается через `itemStreamProvider` (async), а `TabController` создаётся в `initState` (sync). TabBar (`item_screen.dart:93`) рендерится вне `AsyncValueWidget`, поэтому тип item должен быть известен до первого build.
- **Решение (единственный рабочий вариант)**: передавать `ItemType` через router query param. Тип item известен на уровне списка items. `ItemScreen` получает `ItemType` в конструкторе → вычисляет `filteredTabs` в `initState` → `TabController.length = filteredTabs.length`.
- Lazy init TabController невозможен без значительного рефакторинга, т.к. TabBar рендерится вне async-блока.
- `initialIndex`: `filteredTabs.indexOf(widget.initialTab)`, fallback 0 если tab не найден в filtered list (edge case: deep link на `?tab=schedule` для oneTime item).
- `_buildTabContent`: заменить `ItemTab.values[_tabController.index]` на `filteredTabs[_tabController.index]`.
- TabBar: заменить `ItemTab.values.map(...)` на `filteredTabs.map(...)`.

**Удаление (T3-T7)**:
- Проверка ордеров: переиспользовать существующий `StoreOrdersRepository.hasActiveOrdersForItem()` (`orders_repository.dart:36-44`). Метод уже делает нужный запрос: `where('itemId', '==', itemId).where('status', whereIn: ['confirmed', 'preparing', 'readyForPickup']).limit(1)`. Новый метод создавать НЕ нужно.
- Composite index `(itemId, status)` для `orders` collection: вероятно уже существует, т.к. `hasActiveOrdersForItem()` уже работает в production. Проверить в Firebase console перед деплоем.
- Удаление через Cloud Function (admin SDK) — предпочтительнее, чем клиентский delete. Function удаляет Item doc + batch-delete всех офферов + удаляет картинку из Storage. Это гарантирует каскадность.
- Существующий `ItemsRepository.deleteItem()` (`items_repository.dart:95-97`) — клиентский delete без каскада. НЕ использовать для этого flow. Рассмотреть удаление/deprecation этого метода.
- Переиспользовать существующий паттерн callable function (как `createOneTimeOffer`, `sincItemOffers`).
- После успешного ответа Cloud Function — `context.pop()` немедленно, до обновления `itemStreamProvider`. Это предотвращает мелькание "No item found" в `AsyncValueWidget`.
- Кнопка "Delete item" размещается в `SettingsContent` (`settings_content.dart`) после обеих секций (`ItemDetailsSettingsSection` + `ItemInstructionsSettingsSection`), а не внутри подсекции.

**Картинка (T8-T9)**:
- Переиспользовать `ImageUploadRepository` (`image_upload_repository.dart`): `uploadProductImage(data, path)` и `deleteItemImage(imageUrl)`.
- Переиспользовать паттерн из `ItemDetailsSettingsSection._pickAndUploadImage()` (`image_picker`, `kIsWeb` check, `maxWidth: 1200, imageQuality: 85`).
- Storage path: `stores/$storeId/items/$uuid.$ext` — тот же паттерн что в `SettingsContentController.updateItemImage()` (`settings_content_controller.dart:46-47`).
- **Подход**: upload-first. В `CreateItemFormController.submit()`:
  1. Если есть image data → загрузить в Storage с UUID path → получить `imageUrl`
  2. Вызвать `ItemsRepository.createItem(storeId, imageUrl: imageUrl, ...)`
  3. При ошибке `createItem()` после успешной загрузки → `deleteItemImage(imageUrl)` в catch/finally (best-effort cleanup, orphaned images допустимы если cleanup упал)
- `CreateItemFormController.submit()` — добавить параметр `Either<File, Uint8List>? image`. Controller уже зависит от `itemsRepositoryProvider`; добавить зависимость от `imageUploadRepositoryProvider`.
- `CreateItemFormScreen` — хранить выбранный image в локальном state (`Either<File, Uint8List>?`), передавать в `submit()`.

**Стиль (T10-T11)**:
- `_inputDeco()` в `create_item_screen.dart` (метод `_inputDeco`) — точка изменения.
- `fillColor` → `Theme.of(context).scaffoldBackgroundColor` или `Colors.transparent`.
- `border` → `OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: ...)`.
- Контейнеры date picker (`_buildOneTimeSection`, `BoxDecoration(color: Colors.grey.shade100)`) и time picker (`_timeButton`, `BoxDecoration(color: Colors.grey.shade100)`) — заменить на `BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: ...)`.

### Сервер (Cloud Functions)
- Новая callable function `deleteItem`:
  1. Auth check (PARTNER/ADMIN)
  2. Verify ownership/staff
  3. Check active orders (`where('itemId', '==', itemId).where('status', 'in', ['confirmed', 'preparing', 'readyForPickup'])`)
  4. Delete Item doc: `stores/{storeId}/items/{itemId}`
  5. Batch delete offers: query `offers` where `productId == itemId`, delete all
  6. Delete image from Storage if `imageUrl` exists

### Firestore
- Composite index: `orders` collection → `(itemId ASC, status ASC)` — вероятно уже существует (метод `hasActiveOrdersForItem()` работает). Проверить в Firebase console.
- Удаление Item doc и offers через admin SDK в Cloud Function — не требует изменения security rules

## Edge Cases

- **Удаление Item с активными ордерами**: Кнопка заблокирована, показывается сообщение. Серверная функция также проверяет и отклоняет.
- **Удаление Item без офферов**: Работает штатно — просто удаляется Item doc.
- **Удаление Item с paused/expired офферами**: Допустимо — эти офферы не имеют активных бронирований, удаляются вместе.
- **Race condition при удалении**: Бизнес проверил — ордеров нет, но клиент бронирует в этот момент. Серверная функция делает re-check в транзакции перед удалением.
- **Картинка при создании — пользователь не выбрал**: Item создаётся без `imageUrl` (null), как сейчас. Placeholder в UI.
- **Картинка — большой файл**: `ImagePicker` уже ограничивает `maxWidth: 1200, imageQuality: 85` (паттерн из settings section).
- **Картинка — ошибка createItem после upload**: Попытка удалить загруженную картинку (best-effort). Если cleanup упал — orphaned image в Storage, допустимо.
- **One-time item — переход по deep link на tab "schedule"**: `filteredTabs.indexOf(ItemTab.schedule)` вернёт -1, fallback на index 0 (overview). Корректно.
- **Existing items без type field**: `Item.type` defaults to `ItemType.scheduled` — все существующие items продолжат показывать все 5 табов. Корректно.
- **Стиль — dark theme**: Использовать `Theme.of(context).scaffoldBackgroundColor` вместо hardcoded цвета — автоматически адаптируется.
- **Navigation after delete — itemStreamProvider emits null**: `context.pop()` вызывается сразу после успешного ответа Cloud Function, до того как stream обновится. Если по какой-то причине pop не сработал — `AsyncValueWidget` покажет "No item found".

## Out of Scope
- Удаление отдельного Offer (управляется через расписание)
- Редактирование типа Item (scheduled ↔ oneTime) после создания
- Bulk-delete нескольких Items
- Кроппинг/ресайз картинки на клиенте
- Изменение модели Offer (добавление type/source поля)
- Push-уведомления клиентам при удалении Item/Offer
- Удаление/deprecation существующего `ItemsRepository.deleteItem()` (отдельная задача)

## Definition of Done
- [ ] One-time items показывают только 3 таба (Overview, Customer Ratings, Settings)
- [ ] Scheduled items показывают все 5 табов (без регрессии)
- [ ] Router передаёт ItemType в ItemScreen
- [ ] Кнопка "Delete item" работает, с проверкой ордеров и confirmation dialog
- [ ] Cloud Function `deleteItem` удаляет Item + связанные офферы + картинку
- [ ] Image picker работает при создании Item (mobile + web), upload-first подход
- [ ] При ошибке createItem после upload — cleanup картинки (best-effort)
- [ ] TextFields в форме создания имеют обводку и scaffold background
- [ ] `flutter analyze` проходит без ошибок
- [ ] Ручное QA: создание scheduled/one-time item, загрузка картинки, удаление item, проверка табов
