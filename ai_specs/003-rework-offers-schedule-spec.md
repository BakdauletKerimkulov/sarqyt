# Spec: Rework Offers Schedule Validation

Created: 2026-05-23
Status: refined

## Goal
Устранить дыры в валидации расписания офферов и времени pickup, обеспечить корректное поведение кнопок "Start selling" / "Not ready yet", добавить `visibleFrom` для one-time офферов и выровнять клиентскую и серверную валидацию.

## Background

### Текущее поведение
- **Время**: пользователь может выбрать startHour/endHour в диапазоне 0–23, но если endTime <= startTime (например, 23:00–01:00), сервер падает с ошибкой `"Schedule has invalid pickup window"`. UI никак не предупреждает.
- **One-time offers**: создаются со `status: "active"` и без поля `visibleFrom` — клиенты видят их мгновенно. Scheduled offers, напротив, получают `visibleFrom` = начало предыдущего дня, и клиенты видят их заранее.
- **"Not ready yet"**: бизнес может нажать в любой момент — даже если уже есть активные бронирования (ордера). Проверки на наличие ордеров нет.
- **Серверная валидация**: `validateDaySchedule()` в `offer-values.ts` проверяет диапазоны часов (0–23) и минут (0–59), количество > 0, целочисленность — но **не проверяет максимальную длительность окна** (120 мин). Flutter-сторона проверяет, сервер — нет.

### Что нужно исправить
1. Запретить midnight-crossing: все окна pickup — строго в пределах одного календарного дня (максимум до 23:59).
2. Добавить `visibleFrom` для one-time офферов, чтобы завтрашний оффер был виден пользователю сегодня.
3. Ограничить "Not ready yet": доступна только до начала pickup window и только если нет активных бронирований.
4. Добавить серверную проверку максимальной длительности окна (120 мин).

## User Flow

### Создание/редактирование расписания (Scheduled Item)
1. Бизнес открывает Schedule tab или Create Item screen.
2. Для каждого дня недели выбирает start time и end time.
3. **Валидация на клиенте**:
   - Start time < end time (без midnight-crossing).
   - Максимальное окно — 120 минут.
   - Максимальный end time — 23:59.
   - Если нарушено — inline-ошибка у поля.
4. Сохраняет расписание.
5. **Валидация на сервере** (при sync): дублирует те же проверки + отклоняет некорректные данные.

### Создание One-Time Offer
1. Бизнес открывает Create One-Time Offer dialog.
2. Выбирает дату (сегодня — +7 дней), start/end time, цену, количество.
3. **Валидация на клиенте**:
   - End time > start time, окно ≤ 120 мин, end time ≤ 23:59.
   - Если дата — сегодня, end time не в прошлом.
4. Сервер создаёт оффер с `visibleFrom`:
   - Если оффер на завтра или позже → `visibleFrom = начало предыдущего дня` (как у scheduled).
   - Если оффер на сегодня → `visibleFrom = null` (виден сразу).
5. Клиенты видят оффер заранее и могут его забронировать.

### "Start Selling" (isActive = true)
1. Бизнес нажимает "Start selling" на карточке item.
2. Появляется confirmation dialog с деталями расписания.
3. При подтверждении: `isActive = true` → Cloud Function создаёт офферы на today + tomorrow.
4. Офферы становятся видны клиентам (с учётом `visibleFrom`).

### "Not Ready Yet" (isActive = false)
1. Бизнес нажимает "Not ready yet" на карточке item.
2. **Проверка**:
   - Если текущее время уже внутри pickup window (pickupStartTime ≤ now < pickupEndTime) → кнопка скрыта / неактивна. Нельзя паузить во время активного pickup.
   - Если есть хотя бы одна активная бронь (order со статусом `confirmed` / `preparing` / `readyForPickup`) на оффер этого item → показать предупреждение: "Есть активные бронирования. Отмените бронирования перед паузой." Кнопка заблокирована. _(Это UX-предупреждение на клиенте; серверный trigger не может отклонить update, поэтому паузит офферы в любом случае, а ордера остаются и обрабатываются отдельно.)_
3. Если проверка пройдена → `isActive = false` → Cloud Function паузит все активные офферы.

## Requirements

### Must Have
- [ ] **V1**: Flutter `showTimePicker()` уже ограничен 0:00–23:59 нативно (`TimeOfDay`); `DaySchedule.validationError` уже проверяет `startInMinutes >= endInMinutes` что ловит midnight-crossing. **Verify only** — убедиться что существующая валидация работает корректно
- [ ] **V2**: `DaySchedule.validationError` показывает ошибку при `durationMinutes > 120`  _(уже реализовано в Flutter, убедиться что работает)_
- [ ] **V3**: Серверная `validateDaySchedule()` в `offer-values.ts` добавляет проверку: `endInMinutes - startInMinutes > 120` → ошибка
- [ ] **V4**: Серверная `validateDaySchedule()` проверяет `startInMinutes >= endInMinutes` → ошибка (уже есть в `build-expected-offers.ts:112`, но перенести в `validateDaySchedule` для единой точки)
- [ ] **V5a**: `create-one-time-offer.ts` добавляет серверную проверку длительности окна ≤ 120 мин
- [ ] **V5b**: `CreateOneTimeOfferDialog._validate()` в `create_one_time_offer_dialog.dart` добавляет клиентскую проверку длительности окна ≤ 120 мин (сейчас проверяет только `end > start` и `not in past`, max duration отсутствует)
- [ ] **V6**: `create-one-time-offer.ts` вычисляет `visibleFrom` для офферов: если дата > сегодня → `visibleFrom = startOfDay(date - 1, tz)`, иначе → `null`
- [ ] **V7**: Клиентская фильтрация `visibleFrom` уже работает в `client_offer_repository.dart:56` — убедиться что one-time офферы тоже проходят этот фильтр (сейчас `visibleFrom == null` → всегда виден, что корректно для "сегодня")
- [ ] **V8**: "Not ready yet" заблокирована если текущее время внутри pickup window любого активного оффера этого item
- [ ] **V9**: "Not ready yet" заблокирована если есть активные ордера (`confirmed` / `preparing` / `readyForPickup`) на офферы этого item. Проверка выполняется в `startSellingDialogController.stopSelling()` перед вызовом `setItemActive(false)`. Запрос ордеров по `itemId` напрямую: `where('itemId', '==', itemId).where('status', 'in', ['confirmed', 'preparing', 'readyForPickup'])`
- [ ] **V10**: UI показывает причину блокировки кнопки (tooltip или inline текст)

### Nice to Have
- [ ] В `create_one_time_offer_dialog.dart` ограничить time picker шагом 15 минут для удобства
- [ ] Показать preview `visibleFrom` в confirmation dialog ("Клиенты увидят этот оффер начиная с ...")

## Technical Constraints

### Клиент (Flutter)
- Валидация расписания уже сосредоточена в `DaySchedule.validationError` (`weekly_schedule.dart:48-56`) — расширить эту точку.
- Time picker: используется стандартный `showTimePicker()` — ограничить выбор endTime чтобы не превышать startTime + 120 мин нельзя нативно, но можно валидировать после выбора.
- Для проверки наличия ордеров при "Not ready yet": запрос в Firestore `orders` по `itemId` + статус `confirmed`/`preparing`/`readyForPickup`. Проще запросить по `itemId` напрямую (поле есть в Order), чем сначала собирать offerIds. Добавить метод в orders repository, вызывать из `startSellingDialogController.stopSelling()`. Требуется composite index на `(itemId, status)`.

### Сервер (Cloud Functions)
- `validateDaySchedule()` в `functions/src/features/offers/helpers/offer-values.ts` — единая точка серверной валидации расписания **для scheduled items**. Все проверки scheduled-расписания добавлять сюда.
- `create-one-time-offer.ts` — отдельная точка валидации для one-time офферов (не использует `DaySchedule` объекты, а работает с raw hours/minutes через `buildPickupTime()`). Добавить `visibleFrom` и проверку длительности. **Примечание**: две параллельные точки валидации неизбежны из-за разных моделей данных.
- `build-expected-offers.ts:112-116` — проверка `pickupEnd <= pickupStart` дублируется с тем что должно быть в `validateDaySchedule`. После переноса в `validateDaySchedule` — убрать дублирование.
- `syncOneTimeItem()` в `daily-sync-offers.ts` — не проверяет `end > start` для one-time items. Допустимый gap, т.к. единственный путь создания — через `create-one-time-offer.ts` который валидирует.
- Для проверки ордеров при stop selling: серверный trigger (`onItemStatusChanged`) **не может отклонить update** — он паузит офферы в любом случае. Проверка ордеров — только на клиенте (UX safeguard) в `startSellingDialogController.stopSelling()` перед вызовом `setItemActive(false)`.

### Firestore
- Коллекция `offers`: поле `visibleFrom` уже существует в модели и используется для scheduled offers. Для one-time достаточно начать его заполнять.
- Коллекция `orders`: запрос `where('itemId', '==', itemId).where('status', 'in', ['confirmed', 'preparing', 'readyForPickup'])` для проверки активных бронирований. Требуется composite index `(itemId, status)`.

## Edge Cases

- **Сегодняшний one-time оффер**: `visibleFrom = null` → виден сразу. Корректно.
- **Завтрашний one-time оффер в 23:50**: создаётся с `visibleFrom = startOfDay(сегодня)` → виден сразу (сегодня уже наступил). Корректно.
- **"Not ready yet" нажата после того как pickup уже начался**: кнопка скрыта/disabled. Бизнес не может паузить во время активных продаж.
- **"Not ready yet" при наличии бронирований**: кнопка заблокирована с пояснением (UX safeguard — серверный trigger не может reject). Бизнесу нужно сначала отменить/обработать бронирования.
- **Бизнес ставит время 23:00–23:30**: допустимо, end ≤ 23:59, duration = 30 мин ≤ 120.
- **Бизнес ставит время 23:00–00:30**: отклонено на клиенте ("Start time must be before end time") — 00:30 < 23:00 в рамках одного дня.
- **Бизнес ставит время 10:00–13:00**: отклонено ("Window cannot exceed 2 hours").
- **Race condition**: бизнес открыл экран без бронирований, клиент бронирует, бизнес жмёт "Not ready yet". **Митигация**: re-fetch ордеров перед `setItemActive(false)` в `startSellingDialogController.stopSelling()`, показать ошибку если появились. Это TOCTOU (time-of-check-time-of-use), но полностью устранить нельзя без серверной блокировки. Серверный trigger паузит офферы в любом случае — ордера остаются и обрабатываются отдельно. Это допустимо: блокировка — UX safeguard, а не hard constraint.

## Out of Scope
- Изменение модели расписания (добавление новых полей, multiple pickup windows per day).
- Изменение структуры документов Firestore (кроме заполнения уже существующего `visibleFrom`).
- Автоматическая отмена ордеров при паузе оффера.
- Уведомления клиентам о паузе/отмене оффера.
- Midnight-crossing pickup windows (осознанно не поддерживаем — окна строго в пределах одного дня).

## Definition of Done
- [ ] Все Must Have требования (V1–V10) реализованы
- [ ] Flutter validation в `DaySchedule` и UI корректно обрабатывает все edge cases
- [ ] Серверная валидация в `validateDaySchedule()` и `create-one-time-offer.ts` выровнена с клиентской
- [ ] One-time офферы на завтра+ видны клиентам заранее (visibleFrom)
- [ ] "Not ready yet" заблокирована во время pickup и при наличии бронирований
- [ ] `flutter analyze` проходит без ошибок
- [ ] Ручное QA: создание scheduled item, one-time offer, start/stop selling, проверка видимости
