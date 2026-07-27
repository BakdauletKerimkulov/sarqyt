---
title: Order flow notifications
status: in-progress
date: 2026-07-27
type: feature
---

# Plan: Order flow notifications

Source: `ai_specs/034-order-flow-notifications-spec.md`

## Overview

Push-уведомления на весь жизненный цикл заказа для обеих сторон. Серверная часть — новый модуль `functions/src/features/notifications/` (чистое ядро текстов и расписания + тонкие хелперы отправки и резолва получателей), подключаемый к существующим триггерам `onOrderCreated` / `onOrderStatusChanged` и к новому планировщику `sendOrderReminders`. Клиентская часть — разделение FCM-токена по приложениям, вынос слушателей из `initialize()` и чистый маппинг `data.type` → имя маршрута GoRouter. Никаких новых коллекций и зависимостей: два необязательных поля на `orders`, два — на `users`, один новый композитный индекс.

**Spec:** `ai_specs/034-order-flow-notifications-spec.md`

## Context

- **Structure:** feature-first в обоих слоях. Dart — `lib/src/features/{feature}/{domain,data,application,presentation}` (`ai_toolkit/architecture.md`). Functions — `functions/src/features/{feature}/{functions,helpers,services,core,types}` + `functions/src/app/` (`firebase.ts`, `logger.ts`, `error.ts`).
- **State management:** Riverpod codegen; сервисы-слушатели `@Riverpod(keepAlive: true)` — образец `lib/src/features/notifications/data/push_notification_service.dart:73-89`; регистрация в `lib/src/app_bootstrap.dart:23` через `container.listen`.
- **Reference implementations:**
  - Scheduled + транзакционная перепроверка статуса: `functions/src/features/orders/functions/expire-orders.ts`
  - Firestore-триггер + транзакция со счётчиком: `functions/src/features/triggers/orders.ts`
  - Резолв доступа к магазину + legacy-fallback на `ownerId`: `functions/src/shared/helpers/assert-store-access.ts`
  - Текущая отправка push: `functions/src/features/orders/functions/on-order-status-changed.ts`
- **Testing convention:** `ai_toolkit/testing.md` → чистые функции покрываются юнит-тестами; тесты functions — vitest рядом с исходником (`functions/src/app/error.test.ts` — единственный существующий пример, `functions/package.json` → `"test": "vitest run"`). Dart-тесты — `test/src/features/...`, зеркалят `lib/` (`test/src/features/orders/...`).
- **Lint + test command:**
  - functions: `cd functions && npm run lint && npm test`
  - Flutter: `flutter analyze && flutter test --exclude-tags golden && dart run custom_lint`
- **Assumptions / Gaps:**
  - **G1 (R13, Android-канал):** спека требует `channelId: "order_updates"`, но канал на Android создаётся плагином, а `flutter_local_notifications` спекой запрещён. Принимаемое решение: канал объявляется через `AndroidManifest.xml` meta-data `com.google.firebase.messaging.default_notification_channel_id`; фактическое создание канала — FCM SDK. Если канал не появится на устройстве — эскалировать как отдельную задачу, не расширять эту.
  - **G2 (integration-тесты):** «Validation → Integration (Firebase Emulator)» в спеке не имеет в репозитории harness'а (есть только vitest-юниты и dev-зависимость `@firebase/rules-unit-testing`, нигде не используемая). План покрывает эти сценарии ручным QA; постройка эмулятор-harness — отдельная задача.
  - **G3 (регион):** `expireOrders` деплоится в `us-central1` (регион не задан). Новый `sendOrderReminders` задаёт `asia-south1` явно, как требует спека — две scheduled-функции окажутся в разных регионах. Осознанное расхождение; вынос региона в константу — вне этой спеки.
  - **G4 (QA-5):** `firestore.rules:142-147` требует поле `rating`, которого `ReviewRepository.submitReview` не пишет — предсуществующий баг, блокирует финальный шаг QA-5. Заводится отдельным `/fix`, в плане не чинится.

## Plan

### Phase 1 — Thin vertical slice: новый заказ → push команде магазина

**Goal:** Доказать сквозной путь Dart-токен → Firestore → триггер → резолв получателей → FCM → устройство сотрудника (R1, R2 частично, R10, R11, R15).

- [x] TDD: `functions/src/features/notifications/core/messages.test.ts` — `newOrderMessage` возвращает непустые русские `title`/`body` с подстановкой `itemName`, `itemQuantity`, `orderNumber` → затем реализовать (already implemented)
- [x] `functions/src/features/notifications/core/messages.ts` — чистая функция `newOrderMessage`; ноль импортов Firestore/messaging (already implemented)
- [x] TDD: `functions/src/features/notifications/helpers/send-push.test.ts` (мок `getMessaging`) — пустой список токенов → ни одного вызова FCM; `registration-token-not-registered` → удаление токена у пользователя; прочая ошибка → `logError` без throw → затем реализовать
- [x] `functions/src/features/notifications/helpers/send-push.ts` — `sendToTokens(tokens, payload)`: `sendEachForMulticast`, разбор ответа, `FieldValue.delete()` протухших токенов, логирование через `logInfo`/`logError`. Единственное место в проекте, вызывающее `getMessaging()`
- [x] TDD: `functions/src/features/notifications/helpers/recipients.test.ts` — `getStoreTeamTokens`: путь через `storeShips` (limit 20), fallback на `stores/{storeId}.ownerId`, `fcmTokenBusiness` приоритетнее legacy `fcmToken`, пустой результат → `logWarn` без throw → затем реализовать
- [x] `functions/src/features/notifications/helpers/recipients.ts` — `getCustomerToken(uid)` + `getStoreTeamTokens(storeId)`; использует `db` из `app/firebase.ts` и `FirestoreCollections`
- [x] `functions/src/features/triggers/orders.ts` — после коммита транзакции нумерации отправить push команде магазина, `orderNumber` берётся из возврата транзакции (`nextNumber`), не из снапшота; заменить `console.error` (строка 15) на `logError`; `retry` не включать
- [x] `lib/src/features/notifications/data/push_notification_service.dart` — параметр «аудитория приложения» в конструкторе/`initialize`; `_saveToken` пишет `fcmTokenClient` **или** `fcmTokenBusiness` **и** legacy `fcmToken` (R15); `lib/main.dart` → business, `lib/main_client.dart` → client (прокинуть через `app_bootstrap.dart`)
- [ ] Verify: `cd functions && npm run lint && npm test` + `flutter analyze && flutter test --exclude-tags golden && dart run custom_lint` + ручной QA-1 и QA-9 _blocked: автоматика зелёная (`npm run lint`, vitest 13/13 по notifications, `flutter analyze`, `flutter test --exclude-tags golden`, `dart run custom_lint`); ручные QA-1 и QA-9 требуют устройства и не выполнялись._

### Phase 2 — Русские тексты и парные уведомления на переходах статусов

**Goal:** Ни один переход не теряет уведомление; `completed`/`cancelled`/`expired` уведомляют вторую сторону (R2, R3, R3b, R4, R8, R9-payload).

- [ ] TDD: `functions/src/features/notifications/core/messages.test.ts` — регрессия: для каждого статуса из старого `statusLabels` (`confirmed`, `preparing`, `readyForPickup`, `completed`, `cancelled`, `expired`) существует функция текста; каждая даёт непустые RU `title`/`body` → затем реализовать
- [ ] `functions/src/features/notifications/core/messages.ts` — добавить `orderAcceptedMessage`, `orderReadyMessage`, `orderCompletedCustomerMessage`, `orderCompletedStoreMessage`, `orderCancelledMessage`, `orderExpiredMessage`
- [ ] `functions/src/features/orders/functions/on-order-status-changed.ts` — удалить англоязычный `statusLabels`; отправка только через `send-push.ts`; ветки аудитории: клиент на `preparing`/`readyForPickup`, обе стороны на `completed` и `expired`, `cancelled` по `cancelledBy` (store → клиент, customer → команда магазина)
- [ ] `functions/src/features/orders/functions/on-order-status-changed.ts` — `data`-payload по R9: `type`, `orderId`, `storeId`, `storeName`; поле пути **не** передавать
- [ ] `functions/src/features/orders/functions/update-order-status.ts` — при переходе в `completed` дописать `completedAt: serverTimestamp()` в той же транзакции (строка ~73)
- [ ] Verify: `cd functions && npm run lint && npm test` + ручной QA-2, QA-2b, QA-4, QA-6, QA-7

### Phase 3 — Планировщик напоминаний по окну забора

**Goal:** До трёх напоминаний клиенту на заказ, ровно по одному разу (R5, R6, R12, R13).

- [ ] TDD: `functions/src/features/notifications/core/reminders.test.ts` — `dueReminders(order, now)`: `beforeStart` в `[start-15м, start)`; `midWindow` после середины; `beforeEnd` в `[end-15м, end)`; пусто без `pickupStartTime`/`pickupEndTime` (E1); максимум одно напоминание за прогон, остальные подавляются (E2); ничего задним числом (E4); ничего для `completed | cancelled | expired`; документ без `remindersSent` == все `false` (R12) → затем реализовать
- [ ] `functions/src/features/notifications/core/reminders.ts` — чистая `dueReminders`, тип `ReminderKind`, константа `kReminderLookaheadHours = 12`. Без импортов Firestore
- [ ] TDD: `functions/src/features/notifications/core/messages.test.ts` — `pickupSoonMessage`, `midWindowMessage`, `pickupEndingMessage` подставляют время в формате `HH:mm` → затем реализовать в `messages.ts`
- [ ] `functions/src/features/notifications/helpers/send-push.ts` — блоки `android` (`priority: high`, `ttl: 3_600_000`, `channelId: order_updates`) и `apns` (`apns-priority: 10`, `apns-expiration: now+3600`) для чувствительных ко времени уведомлений (R13, см. G1)
- [ ] `functions/src/features/notifications/functions/send-order-reminders.ts` — `onSchedule({ schedule: "every 5 minutes", region: "asia-south1" })`; запрос `status in [confirmed, preparing, readyForPickup]` + `pickupEndTime >= now` + `pickupEndTime <= now + 12h`, `limit(500)`; пер-заказная транзакция с повторной проверкой флага перед `remindersSent.{kind} = true` (образец `expire-orders.ts`); отправка после коммита
- [ ] `android/app/src/main/AndroidManifest.xml` — meta-data `default_notification_channel_id = order_updates` (G1)
- [ ] `functions/src/index.ts` — экспорт `sendOrderReminders`
- [ ] Verify: `cd functions && npm run lint && npm test` + ручной QA-3 на физическом Android-устройстве в режиме ожидания

### Phase 4 — Отложенный запрос отзыва

**Goal:** Через 2 часа после `completedAt`, если отзыва нет (R7).

- [ ] TDD: `functions/src/features/notifications/core/reminders.test.ts` — `reviewPrompt` возвращается только при `status == completed`, `completedAt <= now - 2h` и незаполненном флаге; ничего при отсутствующем `completedAt` → затем реализовать в `reminders.ts`
- [ ] TDD: `functions/src/features/notifications/core/messages.test.ts` — `reviewPromptMessage` подставляет `storeName` и `itemName` → затем реализовать в `messages.ts`
- [ ] `functions/src/features/notifications/functions/send-order-reminders.ts` — второй запрос: `status == "completed"` + `completedAt <= now - 2h` + `completedAt >= now - 24h`, `limit(500)`; проверка `reviews.where('orderId','==',id).limit(1)` перед отправкой; флаг `remindersSent.reviewPrompt` в транзакции
- [ ] `firestore.indexes.json` — новый композитный индекс `orders (status ASC, completedAt ASC)`
- [ ] Verify: `cd functions && npm run lint && npm test`; `firebase deploy --only firestore:indexes`; ручной QA-5 (с оговоркой G4)

### Phase 5 — Клиент: тап по push открывает нужный экран

**Goal:** Однократная регистрация слушателей и навигация по имени маршрута из background и terminated (R9, R14, E11).

- [ ] TDD: `test/src/features/notifications/push_deep_link_test.dart` — маппинг `type + data` → `(routeName, pathParameters, queryParameters)`: `new_status`/`reminder` → `ClientRoute.orderDetail` c `orderId`; `review_prompt` → `ClientRoute.review` c непустыми `storeId`/`storeName` в query; `new_order`/`order_completed`/`order_cancelled`/`order_expired` → `BusinessRoute.dashboard` c `storeId`; неизвестный `type` → `null`; отсутствующие обязательные параметры → `null` → затем реализовать
- [ ] `lib/src/features/notifications/application/push_deep_link.dart` — чистая функция маппинга + `@Riverpod(keepAlive: true)` pending-deep-link провайдер. Без импортов Firebase
- [ ] `lib/src/features/notifications/data/push_notification_service.dart` — вынести `onMessage` / `onMessageOpenedApp` из `initialize()` (строки 51-57) в однократную регистрацию за жизнь приложения; подписки снимать через `ref.onDispose`; `onMessageOpenedApp` и `getInitialMessage` пишут payload в pending-deep-link провайдер, маппинг в сервисе не делается
- [ ] TDD: `test/src/features/notifications/push_deep_link_test.dart` — двойной вызов `initialize()` даёт ровно один pending deep link (R14) → затем реализовать
- [ ] `lib/src/app_client.dart` / `lib/src/app_business.dart` — применение pending deep link после готовности роутера через `goNamed`/`pushNamed` по имени маршрута; таймаут 30 секунд → отбросить deep link; аудитория чужого приложения игнорируется (E10/E11)
- [ ] Verify: `flutter analyze && flutter test --exclude-tags golden && dart run custom_lint` + ручной QA-8

### Phase 6 — Документация и приёмка

**Goal:** Доки не расходятся с кодом; DoD закрыт.

- [ ] `ai_docs/PROJECT.md` — добавить `sendOrderReminders` и модуль `notifications` в раздел Cloud Functions; поля `orders.remindersSent` и `orders.completedAt`; исправить устаревшую строку про `stripe-webhook` (строка ~104) и раздел Order & Payment Flow — заказ создаёт `reserveOffer`
- [ ] `ai_docs/EXTERNAL_SERVICES.md` — раздел «FCM Push Notifications: Token in Firestore»: разделение `fcmTokenClient` / `fcmTokenBusiness`, legacy-fallback, срок удаления legacy-поля
- [ ] `firestore.rules` — подтвердить (без правок), что `orders` остаётся server-only на запись (`firestore.rules:169-172`), клиент не может писать `remindersSent`/`completedAt`
- [ ] Прогнать QA-1…QA-9 на сборках обоих приложений; расхождения — в отдельные `/fix`
- [ ] Verify: `cd functions && npm run lint && npm test` + `flutter analyze && flutter test --exclude-tags golden && dart run custom_lint`

## Data layer changes

- `orders/{orderId}.remindersSent: { beforeStart, midWindow, beforeEnd, reviewPrompt }` — необязательное вложенное поле, только Cloud Functions. Отсутствие == все `false`. Миграция не нужна. Dart-модель `Order` не меняется.
- `orders/{orderId}.completedAt: Timestamp?` — пишет `updateOrderStatus` при переходе в `completed`. Заказы, завершённые до деплоя, поля не имеют → запрос отзыва их не находит. Dart-модель `Order` не меняется.
- `users/{uid}.fcmTokenClient: string?`, `users/{uid}.fcmTokenBusiness: string?` — пишет приложение; legacy `fcmToken` продолжает писаться и читаться как fallback. Удаление legacy — отдельная задача после раскатки.
- Индексы: один новый — `orders (status ASC, completedAt ASC)`. Напоминания по окну забора покрываются существующим `orders (status ASC, pickupEndTime ASC)`.
- Security rules: изменений нет. `orders` — `create: if false`, `update: if isAdmin()`; `users/{uid}` пишет владелец.

## External integrations

- FCM через `firebase-admin/messaging` (уже в зависимостях). `sendEachForMulticast` — лимит 500 токенов за вызов, наш лимит 20 на магазин.
- Обязательная обработка кодов: `messaging/registration-token-not-registered` и `messaging/invalid-argument` → удалить токен; `messaging/quota-exceeded` → залогировать, не ретраить в прогоне.
- APNs: на iOS APNs-токен запрашивается до FCM-токена — уже реализовано.

## Risks

- **Дубль push при ретрае Firestore-триггера** — `retry` нигде не включается, дубль редкий и принят; явно не ставить `retry: true` на триггерах уведомлений.
- **Разъезд регионов scheduled-функций** (`expireOrders` в `us-central1`, `sendOrderReminders` в `asia-south1`) — задокументировать в `ai_docs/PROJECT.md`, вынос региона в константу отдельной задачей (G3).
- **Отсутствие индекса `orders (status, completedAt)` в проде** — запрос отвалится с `failed-precondition`, эмулятор индексы не проверяет; деплоить индекс до включения Phase 4.
- **Android-канал `order_updates` не создастся без local-notifications плагина** (G1) — напоминания придут в дефолтный канал; проверяется QA-3 на реальном устройстве.
- **Дублирующая навигация по deep link** при повторных эмитах `authStateChanges` — снимается однократной регистрацией слушателей (R14) и тестом на двойную инициализацию.
- **QA-5 блокируется предсуществующим багом `firestore.rules` ↔ `submitReview`** (G4) — не расширять эту задачу, завести отдельный `/fix`.

## Out of scope

- Лента/центр уведомлений, бейджи непрочитанных; коллекция `notifications` не создаётся.
- Локализация по языку пользователя (`users/{uid}.locale`) — тексты RU на сервере.
- Web push для бизнес-приложения (нет VAPID-ключа и `firebase-messaging-sw.js`).
- Мультидевайс — одно поле токена на приложение, без массива/подколлекции.
- Настройки уведомлений (что получать, тихие часы).
- Подавление push для сотрудника, инициировавшего переход (нет uid актора в триггере, E7).
- Локальные (in-app) уведомления, баннер/звук в foreground — `onMessage` остаётся логированием.
- Уведомления вне флоу заказа (маркетинг, новые офферы рядом, напоминания о публикации).
- N1 (сводка магазину о закрывающемся окне) и N2 (`collapseKey`) — Nice to Have, не планируются.
