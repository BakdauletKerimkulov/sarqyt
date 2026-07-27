---
title: Order flow notifications
status: refined
date: 2026-07-27
type: feature
---

# Spec: Order flow notifications

Source request:

> Добавить уведомления для бизнес и клиентской частей приложения для оффер флоу.
> 1. Появился заказ, уведомление: кто-то сделал заказ для {название оффера}
> 2. При подтверждении заказа заведением, приходит уведомление для юзера: в заведении кто-то увидел ваш заказ.
> **3. Затем также уведомления с предупреждениями: когда остается несколько минут до начала окна забора, когда остается несколько минут до конца забора, также добавить в середине, типа "вы не забыли что у вас заказ?"
> 4. Также когда юзер забрал заказ и получение завершено, надо бы добавить уведомления обеим сторонам: заказ благополучно передан клиенту. А клиенту: приятного аппетита.
> 5. Уведомление для клиента оставить отзыв для магазина и оффера.
> Также может быть моменты которые я не учел или добавил лишнее, проанализируй

## Goal

Покрыть push-уведомлениями весь жизненный цикл заказа для обеих сторон. Сегодня уведомления односторонние: `onOrderStatusChanged` шлёт клиенту англоязычные строки, а команда магазина не узнаёт о новом заказе вообще — сотрудник обязан держать бизнес-приложение открытым. Клиент, в свою очередь, забывает про окно забора и не оставляет отзыв. Фича добавляет: уведомление команде магазина о новом заказе, русские тексты на все переходы статусов, три напоминания по окну забора, парные уведомления о выдаче заказа, отложенный запрос отзыва и переход в нужный экран по тапу.

## Background

**Stack & conventions:**
- `ai_toolkit/firebase.md` → Cloud Functions Structure: тонкий handler + чистые модули в `core/`. Побочные эффекты (push) — вне транзакций. Каждая write-функция обязана иметь стратегию идемпотентности (Strategy 3: status/flag check before transition). `firebase.md:9` требует хранить регион в константе — в проекте этого **нет**: регион прописан инлайном в каждом триггере (`on-order-status-changed.ts:20`, `triggers/orders.ts:7`), `setGlobalOptions` в `index.ts` отсутствует, а эталонный `expireOrders` (`expire-orders.ts:15`) регион вообще не задаёт и деплоится в `us-central1`. Новые функции обязаны задать `region: "asia-south1"` явно; вынос региона в константу — отдельная задача, не в этой спеке.
- `ai_toolkit/firebase.md` → Composite Indexes: любой compound-запрос требует записи в `firestore.indexes.json`; эмулятор индексы не проверяет.
- `ai_toolkit/architecture.md` → слои: `data/` — единственный слой, знающий Firebase SDK; навигация только через GoRouter, никогда `Navigator.push`.
- `ai_toolkit/code-style.md` → строки UI через `context.loc`, не хардкод; логирование через `AppLogger`/`log()`, не `print()`; файлы ≤300 строк.
- `ai_toolkit/riverpod.md` → сервисы-слушатели с `keepAlive: true`, инициализируются в `app_bootstrap`; фоновая работа ловит свои ошибки и логирует их, не пробрасывает.
- `ai_toolkit/testing.md` → чистые функции Cloud Functions покрываются юнит-тестами (`functions/src/app/error.test.ts` — единственный существующий пример).

**Project context:**
- `functions/src/features/orders/functions/on-order-status-changed.ts` — существующий `onDocumentUpdated`-триггер: при смене `status` читает `users/{customerId}.fcmToken` и шлёт один push с англоязычной строкой из `statusLabels` (строки 8–15). Уведомление получает только клиент; текстов для магазина нет.
- `functions/src/features/payments/functions/reserve-offer.ts:119` — **единственное место, создающее заказ**: `tx.set(orderRef, { status: "confirmed", ... })` с детерминированным id `${uid}_${idempotencyKey}`, без оплаты. Функции `stripe-webhook` в `functions/src` не существует (`grep -rn stripe functions/src` — пусто); строка про неё в `ai_docs/PROJECT.md:104` устарела и правится в рамках этой задачи.
- `functions/src/features/triggers/orders.ts` — `onOrderCreated` присваивает `orderNumber` через транзакцию со счётчиком в `stores/{storeId}.orderCounter`. Push не шлёт. `orderNumber` в снапшоте события отсутствует (он пишется этой же транзакцией) — для текста push использовать `nextNumber` из транзакции, а не перечитанный документ. В файле используется `console.error` (строка 15) вместо `logError` — исправить при правке.
- `functions/src/features/orders/functions/expire-orders.ts` — эталон scheduled-функции: `onSchedule("every 5 minutes")`, запрос `status == X && pickupEndTime <= now`, `limit(500)`, транзакция с повторной проверкой статуса (защита от гонки).
- `functions/src/features/orders/functions/update-order-status.ts` — переходы статусов: `confirmed → preparing → readyForPickup → completed`. Отмена идёт отдельной функцией `cancelOrder`, истечение — `expireOrders`. Доступ проверяется `assertStoreAccess`. Транзакция пишет **только** `{ status, updatedAt }` (строка 73): поля `completedAt` в проекте не существует (`grep -rn completedAt functions/src lib/src` — пусто), поэтому запрос отзыва (R7) требует его добавления.
- `functions/src/shared/helpers/assert-store-access.ts` + `functions/src/shared/types/store-ship-doc.ts` — команда магазина живёт в `storeShips/{storeId}_{uid}` с полями `userId`, `role` (`owner | operator | employer`), `permissions`. Есть fallback на legacy `stores/{storeId}.ownerId`.
- `lib/src/features/notifications/data/push_notification_service.dart` — запрашивает permission, на iOS берёт APNs-токен, сохраняет `users/{uid}.fcmToken` через `set(merge: true)`, подписывается на `onTokenRefresh`. Все три обработчика входящих сообщений (`onMessage`, `onMessageOpenedApp`, `getInitialMessage`) только вызывают `log()` — навигации по тапу нет. Слушатели регистрируются **внутри** `initialize()` (строки 51–57), а сам `initialize()` вызывается из `initPushNotificationsProvider` на каждый эмит `authStateChanges` — сейчас это безобидно (только `log()`), но с навигацией даст дублирующиеся переходы.
- `lib/src/app_bootstrap.dart:23` — `container.listen(initPushNotificationsProvider, (_, __) {})`; общий bootstrap для обоих entry point (`lib/main.dart:17`, `lib/main_client.dart:24`), значит `fcmToken` пишется и для бизнес-пользователей — **в одно и то же поле** `users/{uid}.fcmToken` (см. E10).
- Роутеров два — `clientRouter` (`lib/src/routing/client_router.dart`) и `businessRouter` (`lib/src/routing/business_router.dart:177`), оба `keepAlive`. Сервис в `data/` не может ссылаться ни на один из них напрямую.
- `lib/src/features/orders/domain/order.dart` — `OrderStatus { confirmed, preparing, readyForPickup, completed, cancelled, expired }`, поля `pickupStartTime`, `pickupEndTime`, `orderNumber`, `itemName`, `storeName`, `itemQuantity`, `customerId`, `storeId`.
- `lib/src/features/review/domain/review.dart` — отзыв привязан к заказу (`orderId`) и содержит `storeRating` + `offerRating`; экран отзыва — `ClientRoute.review`, вложен в `/orders/:orderId/review` (`lib/src/routing/client_router.dart:217`). Экран **требует query-параметров** `storeId` и `storeName` (`client_router.dart:220-222`, дефолт — пустая строка); единственный существующий вызов передаёт их явно (`order_detail_screen.dart:216-222`). Отзыв с пустым `storeId` ломает агрегацию рейтинга (`functions/src/features/triggers/reviews.ts:15-18`).
- `lib/src/features/review/data/review_repository.dart:35` — `hasReviewForOrder(orderId)` уже реализует запрос `reviews.where('orderId','==',id).limit(1)`; серверная проверка для R7 повторяет его один-в-один.
- `firestore.indexes.json` уже содержит индекс `orders (status ASC, pickupEndTime ASC)` — его достаточно для планировщика напоминаний по окну забора. Для запроса отзыва (`status == completed` + `completedAt`) нужен **новый** индекс.
- `ai_docs/PROJECT.md` упоминает коллекцию `_processedEvents` для дедупликации, но в `functions/src` она **не используется** (grep не находит ни одного обращения). Поэтому идемпотентность строится на флагах внутри документа заказа, а не на этой коллекции.

**Why now / why this approach:**
- Заказ, о котором заведение не знает, — прямая потеря еды и негативный отзыв; это единственный шаг флоу, где нет ни одного канала оповещения.
- Тексты пишутся на сервере по-русски (решение владельца продукта): локаль пользователя нигде не хранится, а добавление `users/{uid}.locale` — отдельная миграция схемы.
- Никакой новой коллекции: выбран вариант «только push», поэтому изменение схемы ограничено одним обратно совместимым вложенным полем на документе заказа.

## User Flow

### Happy path

1. Клиент бронирует оффер → `reserveOffer` создаёт `orders/{orderId}` (детерминированный id `${uid}_${idempotencyKey}`, статус `confirmed`) → триггер `onOrderCreated` присваивает `orderNumber` и после коммита транзакции шлёт push **всем членам команды магазина**: «Новый заказ» / «{itemName} ×{itemQuantity} — заказ №{orderNumber}». Тап открывает дашборд магазина.
2. Сотрудник в бизнес-приложении переводит заказ `confirmed → preparing` → клиент получает: «{storeName}» / «Заведение приняло ваш заказ и готовит его».
3. Сотрудник переводит `preparing → readyForPickup` → клиент получает: «{storeName}» / «Заказ №{orderNumber} готов к выдаче».
4. За 15 минут до `pickupStartTime` планировщик шлёт клиенту: «Скоро можно забрать» / «Забор в {HH:mm}–{HH:mm} в {storeName}».
5. В середине окна забора (если заказ ещё не `completed`): «Не забыли про заказ?» / «Заказ №{orderNumber} ждёт вас до {HH:mm}».
6. За 15 минут до `pickupEndTime`: «Осталось 15 минут» / «Успейте забрать заказ №{orderNumber} до {HH:mm}».
7. Сотрудник переводит `readyForPickup → completed` (`updateOrderStatus` дополнительно пишет `completedAt`) → **два** push: клиенту «Приятного аппетита!» / «Заказ №{orderNumber} получен. Спасибо, что спасаете еду»; команде магазина «Заказ передан» / «Заказ №{orderNumber} благополучно передан клиенту».
8. Через 2 часа после `completedAt`, если отзыва на этот заказ нет, клиент получает: «Как всё прошло?» / «Оцените {storeName} и {itemName}». Тап открывает экран отзыва по имени маршрута `ClientRoute.review` c `orderId` в path и `storeId` + `storeName` в query (эквивалент `/orders/{orderId}/review?storeId=…&storeName=…`).

### Alternative flows

- Заведение отменяет заказ (`cancelOrder`) → клиент получает «Заказ отменён» + причину, если она есть; команда магазина push не получает (действие инициировано ими самими).
- Клиент отменяет заказ (`cancelOrder`, `cancelledBy == customer`) → команда магазина получает «Заказ №{orderNumber} отменён клиентом»; клиенту push не шлётся.
- Заказ не забрали, `expireOrders` ставит `expired` → клиент: «Окно забора закрылось» / «Заказ №{orderNumber} не был получен»; команда магазина: «Заказ №{orderNumber} не забрали».
- Заказ переведён в `completed` до начала окна забора (клиент пришёл раньше) → все ещё не отправленные напоминания отменяются, флаги проставляются как отправленные без отсылки.
- Клиент уже оставил отзыв до истечения 2 часов → напоминание об отзыве не отправляется.

### Error & recovery flows

- **Нет токена у получателя** (не дал permission / веб-сессия): отправка этому получателю пропускается, пишется `logInfo` с `uid`; остальные получатели уведомляются. Отсутствие токена никогда не роняет функцию.
- **FCM вернул `messaging/registration-token-not-registered` или `invalid-argument`**: токен считается протухшим, поле `fcmToken` удаляется у пользователя (`FieldValue.delete()`), чтобы следующий проход не тратил вызов.
- **Прочая ошибка FCM/сети**: логируется через `logError` с `orderId` и типом уведомления, функция завершается успешно — push никогда не откатывает бизнес-операцию (перевод статуса уже закоммичен).
- **Ретрай триггера Firestore**: ретрай воспроизводит **тот же** payload события, поэтому проверка `before.status !== after.status` пройдёт снова, а у `onDocumentCreated` before/after нет вовсе — «естественной» защиты от дубля здесь **не существует**. Принятое решение: для v2-триггеров ретраи по умолчанию выключены (`retry` не включается ни в одной функции проекта), поэтому редкий дубль push допускается и **не** покрывается флагами; флаги (`remindersSent`) защищают только повторные прогоны планировщика, который запускается каждые 5 минут и без них слал бы дубли гарантированно. Явно не включать `retry: true` для этих триггеров.
- **Пользователь отклонил permission**: приложение работает как раньше, экран заказа остаётся источником правды; повторный запрос permission не навязывается.
- **Тап по push при разлогине / неготовом магазине**: маршрут кладётся в pending-deep-link провайдер и применяется после того, как роутер прошёл свои redirect-гарды (бизнес-роутер уводит на `/login` или `/stores`, пока `businessRedirectState` не готов). Если через 30 секунд роутер так и не принял маршрут — deep link отбрасывается, пользователь остаётся на стартовом экране.
- **Неизвестный `type` в payload** (старая сборка приложения, новый тип уведомления): навигация не выполняется, пишется `log`, пользователь остаётся там, где был. Переход на несуществующий маршрут (например, бизнес-маршрут в клиентском приложении) запрещён — см. E10.

### Edge cases

- **E1. Заказ без `pickupStartTime`/`pickupEndTime`** (поля nullable в `Order`): напоминания для такого заказа не планируются, шаги 3–5 пропускаются, флаги не выставляются.
- **E2. Очень короткое окно забора** (< 30 минут): напоминание «за 15 минут до старта» и «середина окна» могут совпасть по времени с «за 15 до конца». Правило: за один прогон планировщика по одному заказу отправляется **максимум одно** напоминание — самое позднее из подходящих; остальные помечаются отправленными.
- **E3. Окно забора уже началось в момент создания заказа**: напоминание «до старта» помечается отправленным без отсылки.
- **E4. Функция простояла дольше окна** (деплой, инцидент): напоминания с истёкшим временем не отправляются задним числом — помечаются отправленными.
- **E5. Команда магазина пуста** (нет ни одного `storeShips`, только legacy `stores/{storeId}.ownerId`): используется fallback на `ownerId`, как в `assertStoreAccess`.
- **E6. Большая команда**: fan-out ограничен 20 получателями на магазин (`limit(20)` на запрос `storeShips`), отправка одним вызовом `sendEachForMulticast`.
- **E7. Сотрудник сам нажал «Выдан»** и получает push «Заказ передан» — считается допустимым: в триггере Firestore нет uid актора.
- **E8. Один пользователь — сотрудник в нескольких магазинах**: получает уведомления по всем своим магазинам, дедупликация не нужна (заказы разные).
- **E9. Оффлайн-устройство**: FCM держит сообщение в очереди и доставляет при появлении сети; протухшие по TTL уведомления о напоминаниях бесполезны — всем напоминаниям ставится `ttl: 3600s`, чтобы «успейте за 15 минут» не пришло на следующий день.
- **E10. Один `fcmToken` на пользователя, два приложения**: `users/{uid}.fcmToken` пишется общим bootstrap и из клиентского, и из бизнес-приложения — у партнёра, залогиненного в оба, сохраняется токен того приложения, что зарегистрировалось последним. Следствие: push «Новый заказ» может прийти в клиентское приложение, где маршрута `/stores/{storeId}/dashboard` не существует. Решение в этой спеке: **разделить поля токена** — `fcmTokenClient` и `fcmTokenBusiness` (см. Data layer changes); резолверы получателей читают поле, соответствующее аудитории. Обратная совместимость: при отсутствии нового поля читается legacy `fcmToken`.
- **E11. Приложение открыто на неподходящем маршруте / неизвестный `type`**: обработчик тапа не навигирует «наугад» — неизвестный тип игнорируется с логом.

## Requirements

### Must Have

- [ ] **R1**: При создании документа `orders/{orderId}` (пишет `reserveOffer`) каждый член команды магазина с сохранённым бизнес-токеном получает push с заголовком «Новый заказ» и телом, содержащим `itemName`, `itemQuantity` и `orderNumber`. `orderNumber` берётся из результата транзакции нумерации в `onOrderCreated`, а не из снапшота события; push отправляется после коммита транзакции. Verifiable by: юнит-тест на чистую функцию сборки текста + ручной сценарий QA-1.
- [ ] **R2**: Все тексты уведомлений — на русском, вынесены в один модуль констант `functions/src/features/notifications/core/messages.ts` как чистые функции без обращений к Firestore. Verifiable by: юнит-тесты вызывают каждую функцию текста напрямую, без эмулятора; grep по `functions/src` не находит англоязычных `statusLabels`.
- [ ] **R3**: Переход `confirmed → preparing` шлёт клиенту push «Заведение приняло ваш заказ». Verifiable by: тест перехода статусов в эмуляторе + QA-2.
- [ ] **R3b**: Переход `preparing → readyForPickup` шлёт клиенту push «Заказ №{orderNumber} готов к выдаче» — паритет с существующим `statusLabels.readyForPickup`. Ни один переход, который уведомлял клиента до этой фичи (`preparing`, `readyForPickup`, `completed`, `cancelled`, `expired`), не должен потерять уведомление. Verifiable by: юнит-тест «для каждого статуса из `statusLabels` в `messages.ts` есть функция текста» + QA-2b.
- [ ] **R4**: Переход в `completed` шлёт **два** уведомления: клиенту («Приятного аппетита») и команде магазина («Заказ передан клиенту»). Verifiable by: QA-4; лог `logInfo` содержит две записи с разными `audience`.
- [ ] **R5**: Scheduled-функция `sendOrderReminders` (`onSchedule({ schedule: "every 5 minutes", region: "asia-south1" })`) отправляет клиенту до трёх напоминаний на заказ: за 15 минут до `pickupStartTime`, в середине окна (`start + (end - start) / 2`), за 15 минут до `pickupEndTime`. Отправляется только для статусов `confirmed | preparing | readyForPickup`. Выборка: `status in [...]` + `pickupEndTime >= now` + `pickupEndTime <= now + 12h` (окно просмотра `kReminderLookaheadHours = 12`), `limit(500)`. Следствие, принимаемое сознательно: у заказов с окном забора длиннее 12 часов напоминание «за 15 минут до старта» не отправляется. Verifiable by: юнит-тесты на чистую функцию `dueReminders(order, now)` для всех комбинаций времени + QA-3.
- [ ] **R6**: Каждое напоминание отправляется не более одного раза за жизнь заказа. Идемпотентность обеспечивается флагами `remindersSent.beforeStart | midWindow | beforeEnd` на документе заказа, выставляемыми в транзакции с повторной проверкой флага. Verifiable by: прогон планировщика дважды подряд в эмуляторе даёт ровно один вызов FCM.
- [ ] **R7**: Через 2 часа после перехода в `completed` клиент получает напоминание оставить отзыв — только если в `reviews` нет документа с этим `orderId`. Требует нового серверного поля `completedAt`: `updateOrderStatus` пишет `completedAt: serverTimestamp()` при переходе в `completed`. Запрос планировщика: `status == "completed"` + `completedAt <= now - 2h` + `completedAt >= now - 24h`, `limit(500)` — требует **нового** композитного индекса `orders (status ASC, completedAt ASC)`. Заказы, завершённые до деплоя (без `completedAt`), напоминание не получают. Реализуется тем же планировщиком, флаг `remindersSent.reviewPrompt`. Verifiable by: QA-5 и негативный сценарий «отзыв уже оставлен».
- [ ] **R8**: `cancelled` и `expired` шлют push стороне, которая **не** инициировала переход: при `cancelledBy == store` — клиенту, при `cancelledBy == customer` — команде магазина, при `expired` — обеим сторонам. Verifiable by: QA-6, QA-7.
- [ ] **R9**: Каждое уведомление содержит `data`-payload с полями `type`, `orderId`, `storeId`, `storeName` (для `review_prompt`). Путь строкой в payload **не передаётся** (`ai_toolkit/gorouter.md:129` — навигация только по имени маршрута). Приложение маппит `type` → имя маршрута и параметры:
  - клиент, `new_status | reminder` → `ClientRoute.orderDetail`, `pathParameters: {orderId}`;
  - клиент, `review_prompt` → `ClientRoute.review`, `pathParameters: {orderId}`, `queryParameters: {storeId, storeName}` (обязательны: без них экран отзыва получает пустой `storeId`, `client_router.dart:220-222`);
  - бизнес, `new_order | order_completed | order_cancelled | order_expired` → `BusinessRoute.dashboard`, `pathParameters: {storeId}`.
  Неизвестный `type` игнорируется (E11). Verifiable by: юнит-тест чистой функции маппинга `type + data → (routeName, pathParams, queryParams)` + QA-8 (тап из background и из terminated state).
- [ ] **R13**: Уведомления, чувствительные ко времени (все три напоминания по окну забора), отправляются с `android: { priority: "high", ttl: 3_600_000, notification: { channelId: "order_updates" } }` и `apns: { headers: { "apns-priority": "10", "apns-expiration": <now+3600> } }`, чтобы Doze/App Standby не задерживал их за пределы полезности. Канал `order_updates` создаётся на Android-стороне. Verifiable by: юнит-тест сборщика payload + QA-3 на физическом Android-устройстве в режиме ожидания.
- [ ] **R14**: Тап по push обрабатывается ровно один раз: слушатели `onMessage` / `onMessageOpenedApp` регистрируются один раз за жизнь приложения (не внутри `initialize()`, который вызывается на каждый эмит `authStateChanges`), подписки снимаются через `ref.onDispose`. Маршрут из холодного старта (`getInitialMessage`) кладётся в pending-deep-link провайдер и применяется, когда роутер готов. Verifiable by: тест «двойная инициализация сервиса → один переход» + QA-8.
- [ ] **R10**: Отсутствие токена, протухший токен или ошибка FCM не приводят к падению функции и не откатывают бизнес-операцию; протухший токен удаляется из `users/{uid}`. Verifiable by: юнит-тест обработчика ошибок отправки + ручная проверка с заведомо невалидным токеном.
- [ ] **R11**: Получатели бизнес-стороны — все документы `storeShips` с `storeId == order.storeId` (лимит 20), с fallback на `stores/{storeId}.ownerId`, если ни одного `storeShip` нет. Токен берётся из `users/{uid}.fcmTokenBusiness` с fallback на legacy `fcmToken`; для клиента — `fcmTokenClient` с тем же fallback (E10). Verifiable by: юнит-тест резолвера получателей: storeShips-путь, legacy-ownerId-путь, новый токен, legacy-токен.
- [ ] **R12**: Новое поле `remindersSent` — необязательное вложенное поле документа заказа; существующие заказы без него обрабатываются корректно (отсутствие == не отправлено). Миграция данных не требуется. Verifiable by: тест планировщика на документе заказа без поля `remindersSent`.
- [ ] **R15**: Клиентское приложение пишет токен в `users/{uid}.fcmTokenClient`, бизнес-приложение — в `users/{uid}.fcmTokenBusiness` (флаг приложения прокидывается в `PushNotificationService` из entry point). Legacy-поле `fcmToken` продолжает писаться до полной раскатки, чтобы старые сборки не остались без уведомлений. Verifiable by: ручная проверка документа `users/{uid}` после логина в каждое приложение.

### Nice to Have

- [ ] **N1**: Уведомление магазину «через 30 минут закрывается окно забора, N заказов ещё не выданы» — сводка вместо пер-заказных пингов.
- [ ] **N2**: `collapseKey` на напоминаниях, чтобы устройство после долгого оффлайна схлопывало пачку пингов по одному заказу в одно (`ttl` перенесён в Must Have — R13).

### Non-functional

- Performance: планировщик обрабатывает до 500 заказов за прогон (`limit(500)`, как `expireOrders`), фан-аут на магазин — один `sendEachForMulticast` вместо N вызовов `send`.
- Стоимость: планировщик читает только заказы с `pickupEndTime` в ближайшем окне; полный скан коллекции `orders` запрещён.
- Accessibility: тексты уведомлений — законченные предложения без эмодзи-заменителей смысла (эмодзи допустимы как дополнение, не как носитель информации).
- i18n: тексты сервера — русский; никаких новых ARB-ключей для тела push. ARB-ключи требуются только если появится UI-текст в приложении (в этой спеке — нет).

## Technical Constraints

**Files to create:**
- `functions/src/features/notifications/core/messages.ts` — чистые функции текстов (`newOrderMessage`, `orderAcceptedMessage`, **`orderReadyMessage`**, `pickupSoonMessage`, `midWindowMessage`, `pickupEndingMessage`, `orderCompletedCustomerMessage`, `orderCompletedStoreMessage`, `orderCancelledMessage`, `orderExpiredMessage`, `reviewPromptMessage`). Без импортов Firestore.
- `functions/src/features/notifications/core/reminders.ts` — чистая функция `dueReminders({ pickupStartTime, pickupEndTime, status, completedAt, remindersSent }, now): ReminderKind[]` со всей логикой E2–E4.
- `functions/src/features/notifications/core/messages.test.ts`, `functions/src/features/notifications/core/reminders.test.ts` — юнит-тесты чистых функций.
- `functions/src/features/notifications/helpers/recipients.ts` — `getCustomerToken(uid)` (`fcmTokenClient` → fallback `fcmToken`), `getStoreTeamTokens(storeId)` (запрос `storeShips` + fallback на `ownerId`; `fcmTokenBusiness` → fallback `fcmToken`).
- `functions/src/features/notifications/helpers/send-push.ts` — `sendToTokens(tokens, payload)`: мультикаст, разбор ответа, удаление протухших токенов, логирование, проставление `android`/`apns` блоков (R13). Единственное место, вызывающее `getMessaging()`.
- `functions/src/features/notifications/functions/send-order-reminders.ts` — `onSchedule({ schedule: "every 5 minutes", region: "asia-south1" })`, запрос активных заказов (окно `kReminderLookaheadHours = 12`) + запрос завершённых заказов по `completedAt` (R5, R7).
- `lib/src/features/notifications/application/push_deep_link.dart` — pending-deep-link провайдер (`keepAlive`) + чистая функция маппинга `type + data → (routeName, pathParameters, queryParameters)`; тестируется без Firebase (R9, R14).
- `test/src/features/notifications/push_deep_link_test.dart` — юнит-тесты маппинга: каждый `type`, неизвестный `type`, отсутствующие параметры.

**Files to modify:**
- `functions/src/features/orders/functions/on-order-status-changed.ts` — заменить англоязычный `statusLabels` на вызовы `messages.ts` (включая `readyForPickup`, R3b); добавить ветки для команды магазина (`completed`, `cancelled by customer`, `expired`); отправка через `send-push.ts`; payload по R9 (`type`/`orderId`/`storeId`/`storeName`, без `route`).
- `functions/src/features/orders/functions/update-order-status.ts` — при переходе в `completed` дописать `completedAt: serverTimestamp()` в той же транзакции (R7).
- `functions/src/features/triggers/orders.ts` — после транзакции нумерации отправить push команде магазина с `orderNumber` из результата транзакции (побочный эффект вне транзакции, `ai_toolkit/firebase.md`); заменить `console.error` на `logError`.
- `functions/src/index.ts` — экспорт `sendOrderReminders`.
- `lib/src/features/notifications/data/push_notification_service.dart` — вынести регистрацию слушателей из `initialize()` (R14); `onMessageOpenedApp` / `getInitialMessage` пишут маршрут в pending-deep-link провайдер; писать токен в поле, зависящее от приложения (R15). Сервис остаётся в `data/`, бизнес-логики маппинга в нём нет.
- `lib/src/app_client.dart` / `lib/src/app_business.dart` — применение pending deep link после готовности роутера (`goNamed`/`pushNamed` по имени маршрута).
- `firestore.indexes.json` — добавить `orders (status ASC, completedAt ASC)` (R7).
- `firestore.rules` — заказ остаётся server-only на запись (`create: if false`, `update: if isAdmin()`, `firestore.rules:169-172`), поэтому `remindersSent` и `completedAt` клиенту недоступны — изменений не требуется, только подтвердить.
- `ai_docs/PROJECT.md` — раздел Cloud Functions: добавить `sendOrderReminders` и модуль `notifications`; отметить поля `orders.remindersSent` и `orders.completedAt`; **исправить устаревшую строку** про `stripe-webhook` в таблице `payments` и в разделе Order & Payment Flow (заказ создаёт `reserveOffer`).
- `ai_docs/EXTERNAL_SERVICES.md` — раздел «FCM Push Notifications: Token in Firestore»: описать разделение `fcmTokenClient` / `fcmTokenBusiness` и legacy-fallback.

**Patterns to follow (with citations):**
- Scheduled-функция + транзакционная проверка «состояние не изменилось» — по образцу `functions/src/features/orders/functions/expire-orders.ts`.
- Резолв доступа к магазину и fallback на legacy `ownerId` — по образцу `functions/src/shared/helpers/assert-store-access.ts`.
- Логирование — `logInfo` / `logWarn` / `logError` из `functions/src/app/logger.ts`; `db`, `serverTimestamp` — из `functions/src/app/firebase.ts`. Не создавать новых экземпляров Firestore.
- Регион — `asia-south1`, задаётся **явно** в каждой новой функции (`{ document: ..., region: "asia-south1" }`, `{ schedule: ..., region: "asia-south1" }`). Не копировать `expireOrders` в этой части: там регион не указан вовсе.
- Разделение «тонкий handler + чистое ядро» — `ai_toolkit/firebase.md` → Cloud Functions Structure; тестируемая логика (`dueReminders`, тексты) не должна знать про Firestore.

**Anti-patterns / avoid:**
- Не добавлять новых зависимостей: `firebase-admin/messaging` уже используется в `on-order-status-changed.ts`, локального пакета уведомлений (`flutter_local_notifications`) в этой спеке нет.
- Не дублировать логику получателей: `getStoreTeamTokens` — единственное место, знающее про `storeShips` и legacy `ownerId`.
- Не вызывать `getMessaging().send` напрямую из триггеров — только через `send-push.ts`.
- Не отправлять push внутри транзакции (`ai_toolkit/firebase.md`: побочные эффекты после commit).
- Не использовать `DateTime.now()` в Dart-слое для логики (`ai_toolkit/riverpod.md` → Injectable Clock); всё время считает сервер.
- Не хардкодить строки UI в Dart — но тексты push живут на сервере и в ARB не попадают.
- Не превращать `push_notification_service.dart` в место с бизнес-логикой: маппинг `type` → маршрут живёт в `application/`, навигация — через GoRouter.
- Не навигировать по строке пути (`context.go('/orders/...')`) — только `goNamed`/`pushNamed` по имени маршрута (`ai_toolkit/gorouter.md:129`).
- Не включать `retry: true` на Firestore-триггерах уведомлений — это превратит редкий дубль в гарантированный.

**Data layer changes:**
- `orders/{orderId}` получает необязательное вложенное поле:
  ```
  remindersSent: {
    beforeStart:  boolean,  // отправлено/подавлено напоминание за 15 мин до старта
    midWindow:    boolean,
    beforeEnd:    boolean,
    reviewPrompt: boolean,
  }
  ```
  Пишется только Cloud Functions. Обратно совместимо: отсутствие поля == все `false`. Dart-модель `Order` **не меняется** — поле серверное, приложению не нужно (json_serializable игнорирует незнакомые ключи).
- `orders/{orderId}.completedAt: Timestamp?` — пишется `updateOrderStatus` при переходе в `completed` (R7). Необязательное, обратно совместимое; у заказов, завершённых до деплоя, отсутствует → напоминание об отзыве им не отправляется. Dart-модель `Order` не меняется.
- `users/{uid}` получает два необязательных поля: `fcmTokenClient: string?`, `fcmTokenBusiness: string?` (E10, R15). Legacy `fcmToken` продолжает писаться и читаться как fallback; удаление legacy-поля — отдельная задача Phase 2 после раскатки обеих сборок.
- Индексы: **нужен один новый** — `orders (status ASC, completedAt ASC)` для запроса напоминаний об отзыве. Напоминания по окну забора используют существующий `orders (status ASC, pickupEndTime ASC)`: `status in [...]` покрывается тем же индексом, что и равенство; середина окна досчитывается в памяти. Запрос отзыва — `reviews.where('orderId', '==', id).limit(1)`, одиночное поле, индекс не нужен.
- Security rules: изменений не требуется. `firestore.rules:169-172` — `orders`: `allow create: if false`, `allow update: if isAdmin()`, поэтому `remindersSent` и `completedAt` клиенту недоступны. `users/{uid}` пишется владельцем (`firestore.rules:129`) — новые поля токенов пишет само приложение, как и сейчас.

**External integrations:**
- FCM (`firebase-admin/messaging`). Лимит `sendEachForMulticast` — 500 токенов за вызов; наш лимит 20 на магазин.
- Ошибки, которые обязаны обрабатываться: `messaging/registration-token-not-registered`, `messaging/invalid-argument`, `messaging/quota-exceeded` (первые два → удалить токен, третья → залогировать и не ретраить в этом прогоне).
- APNs: на iOS обязателен APNs-токен до FCM-токена — уже реализовано в `push_notification_service.dart`.

## Out of Scope

- **Лента/центр уведомлений и бейджи непрочитанных** — по решению владельца продукта объём ограничен push; коллекция `notifications` не создаётся.
- **Локализация по языку пользователя** — нет поля `users/{uid}.locale`; добавление = миграция схемы + таблица переводов. Тексты RU на сервере.
- **Web push для бизнес-приложения** — бизнес-приложение хостится на Firebase Hosting, но `getToken()` в вебе требует VAPID-ключ и `firebase-messaging-sw.js`, которых в проекте нет. Уведомления бизнеса работают на мобильных сборках; веб — отдельная задача.
- **Мультидевайс** — `users/{uid}.fcmToken` остаётся одним полем; сотрудник с двумя устройствами получит уведомление на последнее авторизованное. Переход на массив/подколлекцию токенов — отдельная миграция.
- **Настройки уведомлений** (что получать, тихие часы) — отдельная фича; сейчас единственный переключатель — системный permission.
- **Подавление push для сотрудника, инициировавшего переход** — в Firestore-триггере нет uid актора; потребовало бы записи `lastUpdatedBy` в `updateOrderStatus` (E7).
- **Локальные (in-app) уведомления и звук/баннер в открытом приложении** — `onMessage` остаётся логированием, системный баннер в foreground не показывается.
- **Уведомления вне флоу заказа** (маркетинг, новые офферы рядом, напоминания магазину о публикации оффера) — другой домен.

## Validation

**Automated tests:**
- Unit (`functions/src/features/notifications/core/reminders.test.ts`): `dueReminders` возвращает `beforeStart` ровно в окне `[start-15м, start)`; `midWindow` — после середины; `beforeEnd` — в окне `[end-15м, end)`; ничего для заказа без `pickupStartTime`/`pickupEndTime` (E1); максимум одно напоминание за прогон при коротком окне (E2); ничего задним числом (E4); ничего для `completed | cancelled | expired`.
- Unit (`.../messages.test.ts`): каждая функция текста возвращает непустые `title`/`body` на русском и подставляет `orderNumber`, `itemName`, `storeName`, время в формате `HH:mm`; регрессионный тест — для каждого статуса из старого `statusLabels` (`confirmed`, `preparing`, `readyForPickup`, `completed`, `cancelled`, `expired`) существует функция текста (R3b).
- Unit (`test/src/features/notifications/push_deep_link_test.dart`): маппинг `type + data` → имя маршрута и параметры для каждого типа; `review_prompt` даёт непустые `storeId`/`storeName` в query; неизвестный `type` не даёт маршрута (R9, E11).
- Unit (`.../send-push.test.ts` с замоканным `getMessaging`): пустой список токенов → ни одного вызова FCM; ответ с `registration-token-not-registered` → вызов удаления токена; прочая ошибка → логирование без throw.
- Integration (Firebase Emulator): создание документа заказа вызывает `onOrderCreated` и одну попытку отправки; двойной прогон `sendOrderReminders` даёт ровно один push (R6).

**Manual QA scenarios:**
1. **QA-1**: Дано: сотрудник авторизован в бизнес-приложении на телефоне, permission выдан. Когда клиент оплачивает оффер этого магазина. Тогда телефон сотрудника получает push «Новый заказ — {название} ×1» в течение ~10 секунд.
2. **QA-2**: Дано: активный заказ в статусе `confirmed`. Когда сотрудник жмёт «В работу». Тогда клиент получает «Заведение приняло ваш заказ».
2b. **QA-2b**: Дано: заказ в статусе `preparing`. Когда сотрудник жмёт «Готов к выдаче». Тогда клиент получает «Заказ №N готов к выдаче» (паритет с поведением до фичи).
3. **QA-3**: Дано: заказ с окном забора через 20 минут. Когда проходит 5 минут (прогон планировщика в пределах `start-15м`). Тогда клиент получает ровно одно напоминание «Скоро можно забрать»; повторных за следующие прогоны нет.
4. **QA-4**: Когда сотрудник жмёт «Выдан». Тогда клиент получает «Приятного аппетита», сотрудник — «Заказ передан клиенту».
5. **QA-5**: Дано: заказ завершён 2 часа назад (`completedAt` проставлен), отзыв не оставлен. Тогда клиент получает «Как всё прошло?»; тап открывает экран отзыва этого заказа **с заполненным названием магазина** (проверка, что `storeId`/`storeName` доехали), отзыв успешно отправляется. Повтор сценария с уже оставленным отзывом — push не приходит.
   Предусловие: отправка отзыва из приложения работает. Текущее правило `firestore.rules:142-147` требует поле `rating`, которого `ReviewRepository.submitReview` не пишет — если QA-5 падает на отправке, это отдельный существующий баг, а не регресс этой фичи; завести отдельный `/fix`.
6. **QA-6**: Клиент отменяет заказ → push приходит команде магазина, клиенту не приходит.
7. **QA-7**: Заказ не забрали, окно закрылось → `expireOrders` ставит `expired` → push получают обе стороны.
8. **QA-8**: Тап по push при свёрнутом приложении и при полностью закрытом открывает нужный экран (детали заказа / отзыв / дашборд магазина), а не главный экран, и ровно один раз (без «двойного» перехода после повторного логина).
9. **QA-9**: Партнёр залогинен в оба приложения на одном устройстве. Новый заказ → push приходит в бизнес-приложение; статусные уведомления по его собственным заказам → в клиентское (проверка разделения токенов, E10/R15).

**Expected behavior under edge conditions:**
- Оффлайн у получателя → сообщение доставляется при появлении сети; напоминания с истёкшим `ttl` (1 час) отбрасываются, а не приходят с опозданием.
- Ошибка FCM → бизнес-операция (смена статуса, создание заказа) уже завершена и не откатывается; в логах `logError` с `orderId`.
- Нет токена (permission не выдан) → тишина, ошибок в логах уровня error нет, только `logInfo`.
- Пустые данные (`storeShips` нет, `ownerId` отсутствует) → `logWarn` «no recipients», функция завершается успешно.

## Definition of Done

- [ ] Все Must Have требования (R1–R15, включая R3b) реализованы, чистые функции покрыты юнит-тестами, тесты зелёные (`cd functions && npm test` — vitest, `flutter test` для Dart-маппинга)
- [ ] Все ручные QA-сценарии (QA-1…QA-9) пройдены на Android или iOS сборке обоих приложений
- [ ] `flutter analyze` и `dart run custom_lint` без новых предупреждений; `npm run lint` в `functions/` зелёный
- [ ] Изменения соответствуют `ai_toolkit/firebase.md` (идемпотентность, побочные эффекты вне транзакций, регион константой) и `ai_toolkit/architecture.md` (навигация через GoRouter)
- [ ] `ai_docs/PROJECT.md` обновлён: новая функция `sendOrderReminders`, модуль `notifications`, поля `orders.remindersSent` и `orders.completedAt`, исправлена устаревшая строка про `stripe-webhook`; `ai_docs/EXTERNAL_SERVICES.md` — разделение токенов по приложениям
- [ ] `firestore.indexes.json` содержит новый индекс `orders (status ASC, completedAt ASC)` и он задеплоен (`firebase deploy --only firestore:indexes`); правила подтверждены как не позволяющие клиенту писать `remindersSent`/`completedAt`
- [ ] Спека указана в описании PR
