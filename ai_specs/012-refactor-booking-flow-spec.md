# Spec: Fix Booking Flow & Remove Online Payment

Created: 2026-06-14
Status: refined
Refined: 2026-06-14
Source request: Проанализировать флоу бронирования заказа, исправить серьёзные баги, покрыть случаи (отмена, истечение, отмена магазином). Затем: полностью удалить Stripe и пока убрать онлайн-оплату — оплата на месте через терминал заведения.

## Goal
Сделать reserve-флоу постоянным и корректным каналом бронирования и убрать незавершённую онлайн-оплату. Stripe удаляется полностью; оплата происходит офлайн на стороне заведения (свой терминал). Параллельно чинятся серьёзные дефекты текущего флоу: нерабочая идемпотентность бронирования (риск дублей заказов и двойного списания `quantity`), дыра в security rules (магазин может писать `status` напрямую в обход Cloud Functions), отсутствие отмены магазином, невозможность отмены в `readyForPickup`, отсутствие валидации окна выдачи и индикации «распродано».

## Background

### Stack & conventions (`ai_toolkit/`)
- **Feature-first слои** `data/domain/application/presentation`; доступ к Firebase только из репозиториев/сервисов, виджеты и контроллеры не ходят в Firestore/Functions напрямую (`ai_toolkit/architecture.md`).
- **Riverpod 3 codegen** (`@riverpod`), async-данные через `AsyncValue` + `AsyncValueWidget` (`ai_toolkit/riverpod.md`, `architecture.md`).
- **Domain immutable** (freezed); `.g.dart`/`.freezed.dart` не редактировать вручную — только codegen (`ai_toolkit/code-style.md`).
- **Firestore**: форма документов стабильна, предпочтительно добавлять опциональные поля, server timestamps пишутся на сервере; не менять пути коллекций и security rules без явного запроса — здесь запрос явный (`ai_toolkit/firebase.md`, `CLAUDE.md`).
- **Заказы создаются только Cloud Functions**; клиентский create запрещён правилами (`firestore.rules:168-169`).
- **Ранние возвраты, маленькие функции, никакого мёртвого кода/неиспользуемых импортов** (`ai_toolkit/code-style.md`).

### Project context (текущее поведение)
Активный путь бронирования — резерв без оплаты, Stripe-флоу закомментирован:
- Клиент: `PaymentPage` (`lib/src/features/checkout/presentation/payment_page.dart`) → `CheckoutController.pay()` (`checkout_service.dart:43-62`) → `PaymentRepository.reserveOffer()` (`payment_repository.dart:27-42`) → callable `reserveOffer`.
- Сервер `reserveOffer` (`functions/src/features/payments/functions/reserve-offer.ts`): в транзакции проверяет оффер, декрементит `offer.quantity`, создаёт `orders/{uid}_{idempotencyKey}` со `status: "confirmed"`, `paymentStatus: "paid"`.
- Магазин ведёт статусы через `updateOrderStatus` (`functions/.../update-order-status.ts`), переходы `confirmed → preparing → readyForPickup → completed`.
- Отмена `cancelOrder` (`functions/.../cancel-order.ts`): отмена для `confirmed`/`preparing`, восстановление `quantity`, рефанд Stripe с ретраями и статусами `refund_pending/refunded/refund_failed`.
- Истечение `expireOrders` (`functions/.../expire-orders.ts`): каждые 5 минут переводит просроченные (по `pickupEndTime`) активные заказы в `expired`, восстанавливает `quantity`.
- Stripe-флоу (выключен): `createPayment` + `stripeWebhook` (`functions/src/features/payments/functions/*`), `stripe-client.ts`, flutter `payment_sheet_repository.dart`, `app_bootstrap_stripe.dart`, закомментированный `payWithStripe` (`checkout_service.dart:64-114`), deps `flutter_stripe`/`flutter_stripe_web` (`pubspec.yaml:82-83`), env `STRIPE_PUBLISHABLE_KEY` (`lib/env.dart:7-8`), секрет `STRIPE_WEBHOOK_SECRET`/`stripeSecretKey`.

### Найденные дефекты (что чиним)
1. **#1 Идемпотентность сломана.** `PaymentRepository.reserveOffer` генерирует `idempotencyKey: const Uuid().v4()` на **каждый** вызов (`payment_repository.dart:38`). ID заказа `${uid}_${idempotencyKey}` каждый раз новый → при таймауте (30с) или ретрае, когда функция уже отработала, создаётся **второй заказ и повторно списывается `quantity`**.
2. **#2 Дыра в security rules.** `firestore.rules:172-175` разрешает магазину прямую запись с `affectedKeys().hasOnly(['status','updatedAt'])`, но не валидирует значение/легальность перехода. Магазин может выставить `cancelled` без восстановления `quantity`, сделать недопустимый переход или произвольную строку статуса в обход `updateOrderStatus`/`cancelOrder`.
3. **#3 Нет отмены магазином в UI.** Бэкенд `cancelOrder` поддерживает отмену со стороны магазина (`assertStoreAccess`), но `business_orders_screen.dart` показывает только кнопку следующего статуса.
4. **#4 Нельзя отменить `readyForPickup`.** `cancelOrder` разрешает только `confirmed`/`preparing` (`cancel-order.ts:66-70`), клиентская кнопка — тоже (`order_detail_screen.dart:200-204`). Если магазин преждевременно пометил «готов», нет пути отмены.
5. **#5 `reserveOffer` не валидирует окно выдачи.** Проверяются только `status==active` и `quantity`, но не `pickupEndTime > now` — можно зарезервировать оффер с уже прошедшим окном, он сразу попадёт под `expireOrders`.
6. **#6 Оффер не «распродан» при `quantity==0`.** `reserveOffer` оставляет `status: active`; листинги фильтруют по `status==active` (`client_offer_repository.dart:46,81,109`), поэтому распроданный оффер показывается с «0 доступно».

### Why now / why this approach
Онлайн-оплата (Stripe) не запущена и держится закомментированной; поддержка двух путей бронирования создаёт риск (особенно неверный `unitPrice` в webhook и удержание `quantity` без таймаута резерва). Решение: оставить **единственный** путь — резерв без онлайн-оплаты, оплата на месте через терминал заведения. Это упрощает модель и устраняет латентные Stripe-баги вместе с кодом. Возврат к онлайн-оплате — отдельная будущая работа.

## User Flow

### Happy path
1. Клиент открывает оффер → экран бронирования (`PaymentPage`). Видит магазин, окно выдачи, селектор количества, текст «Оплата при получении».
2. Жмёт «Забронировать». Кнопка переходит в loading, повторные тапы заблокированы.
3. `reserveOffer` со **стабильным** `idempotencyKey` создаёт `orders/{uid}_{key}` (`status: confirmed`), декрементит `offer.quantity`. При `quantity==0` оффер переводится в `soldOut`.
4. Клиент попадает на `OrderDetailScreen`: статус `confirmed`, таймер до конца окна, строка «Оплата при получении».
5. Магазин в `business_orders_screen` ведёт `confirmed → preparing → readyForPickup → completed` через `updateOrderStatus`.
6. Клиент забирает заказ, оплачивает на месте через терминал заведения; магазин жмёт «Завершить» → `completed`. Клиент видит кнопку «Оставить отзыв».

### Alternative flows
- **Отмена клиентом.** В `OrderDetailScreen` для `confirmed`/`preparing`/`readyForPickup` есть кнопка «Отменить заказ» → подтверждение → `cancelOrder` → `status: cancelled`, `quantity` восстановлен, оффер возвращён в `active` (если окно ещё открыто).
- **Отмена магазином.** В `business_orders_screen` для `confirmed`/`preparing`/`readyForPickup` есть кнопка «Отменить заказ» → диалог с обязательной причиной → `cancelOrder({orderId, reason})`. Заказ `cancelled`, на нём сохраняются `cancellationReason` и `cancelledBy: "store"`. Клиент в `OrderDetailScreen` видит причину отмены. Если клиент просматривает заказ в момент отмены, экран обновляется реактивно (существующий stream); пуш-уведомление (N2) — отдельное улучшение.
- **Истечение окна.** `expireOrders` каждые 5 минут переводит непросроченные-но-истёкшие активные заказы в `expired`, восстанавливает `quantity`.

### Error & recovery flows
- **Сеть упала / таймаут при бронировании.** Клиент повторяет бронирование. Благодаря стабильному `idempotencyKey` повторный вызов попадает в тот же `orders/{uid}_{key}`; транзакция видит существующий заказ и возвращает успех без второго списания `quantity`.
- **Оффер стал неактивен/распродан между открытием экрана и бронированием.** `reserveOffer` бросает `failed-precondition` («Offer is not active» / «Only N available»); клиент видит alert (`payment_page.dart` listener) и остаётся на экране.
- **Окно выдачи закрылось.** `reserveOffer` бросает `failed-precondition` («Pickup window has closed»); бронирование не создаётся.
- **Отмена магазином без причины.** Диалог не даёт подтвердить с пустой причиной (валидация на границе контроллера/диалога).
- **Магазин пытается недопустимый переход статуса.** `updateOrderStatus` бросает `failed-precondition`; прямая запись `status` из клиента запрещена правилами.

### Edge cases
- **Empty state:** нет заказов — экраны показывают существующие empty-state (без изменений).
- **First-time use:** незарегистрированный клиент проходит регистрацию в `CheckoutScreen` (sub-route register) перед бронированием — без изменений.
- **Very large dataset:** `customerOrdersStream`/`watchOrdersListForStore` без лимита — вне охвата (см. Out of Scope).
- **Concurrent edits / races:**
  - Двойной тап «Забронировать» → стабильный `idempotencyKey` + транзакция → один заказ.
  - Отмена и истечение одновременно → обе функции внутри транзакции перечитывают статус; `quantity` не восстанавливается дважды (cancel пропускает уже `cancelled`, expire пропускает не-активный статус).
  - Восстановление `quantity` и перевод оффера обратно в `active` атомарны в той же транзакции, что и смена статуса заказа.
- **Offline / poor connectivity:** callable падает с ошибкой — показывается alert, заказ не создаётся; ретрай идемпотентен.

## Requirements
Functional decisions. Каждое требование — одно проверяемое поведение.

### Must Have
- [ ] **R1 (#1):** `idempotencyKey` генерируется **один раз при первом нажатии «Забронировать»** и переиспользуется при ретраях. Ключ хранится в `CheckoutController` и **инвалидируется при изменении `quantity`** (при смене количества генерируется новый ключ, чтобы избежать ситуации, когда сервер возвращает старый заказ с другим количеством — `reserve-offer.ts:77-78` делает `if (orderSnap.exists) return` без проверки совпадения `quantity`). Ключ передаётся в `pay()` → `reserveOffer`. Verifiable: два последовательных вызова `pay()` для одной попытки используют один ключ → создаётся один документ `orders/{uid}_{key}`, `offer.quantity` уменьшается один раз; смена количества и повторный тап создаёт новый заказ (unit-тест контроллера + ручной ретрай).
- [ ] **R2 (#2):** Прямая клиентская запись `orders.status` запрещена. `firestore.rules` для `match /orders/{id}`: `allow update: if isAdmin()` (все переходы — через Cloud Functions с admin SDK, которые обходят правила). Verifiable: эмулятор — попытка магазина обновить `status` клиентским SDK получает `PERMISSION_DENIED`; `updateOrderStatus`/`cancelOrder` продолжают работать.
- [ ] **R3 (#3):** В `business_orders_screen.dart` добавлена кнопка «Отменить заказ» для статусов `confirmed`/`preparing`/`readyForPickup`. Нажатие открывает диалог с **обязательным** полем причины. Подтверждение вызывает `StoreOrdersRepository.cancelOrder(orderId, reason)`. Verifiable: widget-тест — кнопка видна только для активных статусов; пустая причина не даёт подтвердить; вызывается callable `cancelOrder` с `reason`.
- [ ] **R4 (#3):** `cancelOrder` принимает опциональные `reason: string` и фиксирует `cancelledBy: "customer" | "store"` (по тому, customer это или store-доступ). Поля `cancellationReason`/`cancelledBy` пишутся на заказ. Клиентский `OrderDetailScreen` показывает причину, если `status == cancelled && cancelledBy == "store"`. Verifiable: после отмены магазином документ заказа содержит оба поля; на экране клиента отображается текст причины.
- [ ] **R5 (#4):** `cancelOrder` разрешает отмену из `readyForPickup` (в дополнение к `confirmed`/`preparing`) для клиента и магазина (`cancel-order.ts:70-75` — расширить список). Клиентская кнопка отмены в `OrderDetailScreen` показывается и для `readyForPickup` (`order_detail_screen.dart:200-204`). Verifiable: отмена заказа в `readyForPickup` обеими сторонами проходит, `quantity` восстанавливается.
- [ ] **R6 (#5):** `reserveOffer` отклоняет бронирование, если `offer.pickupEndTime <= now` (`failed-precondition`, «Pickup window has closed»). Проверка в транзакции после проверки `status`. Verifiable: unit/эмулятор — оффер с прошедшим окном не бронируется.
- [ ] **R7 (#6):** В `OfferStatus` добавлен `soldOut`. `reserveOffer` при достижении `quantity == 0` пишет `status: "soldOut"`. `cancelOrder` и `expireOrders` при восстановлении `quantity` заменяют текущий `FieldValue.increment` на `tx.get(offerRef)` + условное обновление: возвращают оффер в `active`, **если** текущий статус `soldOut` **и** окно выдачи ещё открыто (`pickupEndTime > now`), иначе оставляют статус как есть (паттерн уже используется в `expire-orders.ts:47-56`). Verifiable: бронирование последней единицы → `soldOut`; отмена до конца окна → снова `active` и оффер виден в листинге.
- [ ] **R8 (Stripe removal — functions):** Удалить `create-payment.ts`, `stripe-webhook.ts`, `shared/helpers/stripe-client.ts`; убрать их экспорты из `functions/src/index.ts:19-21` (оставить `reserveOffer`); удалить определения секретов `STRIPE_WEBHOOK_SECRET`/`stripeSecretKey`. Verifiable: `npm run build` в `functions/` проходит без ссылок на Stripe; `grep -ri stripe functions/src` пуст.
- [ ] **R9 (Stripe removal — cancel-order):** Из `cancel-order.ts` убрать всю Stripe-логику (рефанд, ретраи, секрет, обновление `paymentStatus`). **Убрать `{ secrets: [stripeSecretKey] }` из опций `onCall`** (`:22-23`) и импорт `stripe-client` (`:8`), иначе деплой сломается после удаления `stripe-client.ts`. Остаётся: проверка доступа, транзакция (смена статуса + восстановление `quantity` + возврат оффера в `active`), запись `reason`/`cancelledBy`. Verifiable: функция не импортирует Stripe; `npm run build` проходит; отмена восстанавливает `quantity` без обращений к платёжке.
- [ ] **R10 (Stripe removal — flutter):** Удалить `lib/src/features/checkout/data/payment_sheet_repository.dart` (+`.g.dart`), `lib/src/app_bootstrap_stripe.dart`; из `payment_repository.dart` удалить `createPayment`/`CreatePaymentResult` (оставить `reserveOffer`); из `checkout_service.dart` удалить закомментированный `payWithStripe` (`:68-110`); из `main_client.dart` убрать импорт и вызов `setupStripe()` (`:6,14`); из `lib/env.dart` убрать `stripePublishableKey` (`:7-8`); из `pubspec.yaml` убрать `flutter_stripe`/`flutter_stripe_web` (`:82-83`). Verifiable: `flutter pub get` + `flutter analyze` без ошибок; `grep -ri stripe lib` пуст; приложение собирается и бронирование работает.
- [ ] **R11 (payment status):** `PaymentStatus`-флоу убран из активной модели. Поле `Order.paymentStatus` делается опциональным (`PaymentStatus?`, nullable) и больше не пишется при создании заказа; refund-статусы (`refundPending/refundFailed/refunded`) не используются. `OrderDetailScreen` вместо строки статуса оплаты показывает статичный текст «Оплата при получении». `reserveOffer` перестаёт писать `paymentStatus`. **Все потребители `order.paymentStatus` обновляются для обработки null** (в т.ч. `order_detail_screen.dart`, `business_orders_screen.dart` и любые другие экраны/виджеты, отображающие статус оплаты). Verifiable: новые заказы не содержат `paymentStatus`; экран показывает «Оплата при получении»; codegen для `Order` пересобран; `flutter analyze` проходит без ошибок. Существующие старые заказы с `paymentStatus` читаются без ошибок (backward-compatible).

### Nice to Have
- [ ] **N1:** Пресет-причины отмены для магазина (например, «нет товара», «закрылись раньше») + опциональный комментарий, вместо свободного текста.
- [ ] **N2:** Пуш-уведомление клиенту при отмене магазином с текстом причины (`on-order-status-changed.ts` уже шлёт `cancelled` — добавить причину в body).
- [ ] **N3:** Бейдж «Распродано» на карточке оффера для `soldOut` (вместо скрытия из листинга).

### Non-functional
- **Performance:** изменения не добавляют новых запросов в hot-path бронирования; проверка окна выдачи — внутри уже существующей транзакции.
- **i18n:** все новые строки («Оплата при получении», «Отменить заказ», заголовок/валидация диалога причины, «Распродано», причина отмены) — через `context.loc` / `string_hardcoded`, как в остальном проекте; KZT/₸ без изменений.
- **Security:** статусы заказа меняются только через Cloud Functions; клиентский SDK не может писать `status`.

## Technical Constraints

**Files to create:**
- (опционально) `lib/src/features/orders/presentation/business/widgets/cancel_order_button.dart` — кнопка+диалог причины для магазина, если выносить из `business_orders_screen.dart`.

**Files to modify:**
- `lib/src/features/checkout/data/payment_repository.dart` — стабильный `idempotencyKey` (параметр метода `reserveOffer`), удалить `createPayment`/`CreatePaymentResult`.
- `lib/src/features/checkout/application/checkout_service.dart` — пробросить `idempotencyKey` из `pay()`; удалить закомментированный `payWithStripe`.
- `lib/src/features/checkout/presentation/payment_page.dart` — генерация/хранение `idempotencyKey` на попытку; текст «Оплата при получении».
- `functions/src/features/payments/functions/reserve-offer.ts` — валидация `pickupEndTime > now`; `soldOut` при `quantity==0`; прекратить писать `paymentStatus`; добавить `updatedAt: serverTimestamp()` в создание заказа (сейчас отсутствует, нарушает `ai_toolkit/firebase.md`).
- `functions/src/features/orders/functions/cancel-order.ts` — убрать Stripe/рефанд; добавить `reason`/`cancelledBy`; разрешить `readyForPickup`; возврат оффера в `active` при восстановлении `quantity`.
- `functions/src/features/orders/functions/expire-orders.ts` — возврат оффера в `active` при восстановлении `quantity` (если окно открыто); иначе без изменений.
- `functions/src/index.ts` — убрать экспорты `createPayment`, `stripeWebhook`.
- `lib/src/features/orders/data/client_orders_repository.dart` — `cancelOrder` без изменений сигнатуры (reason опционален для клиента) либо добавить опциональный `reason`.
- `lib/src/features/orders/data/orders_repository.dart` — `updateOrderStatus` без изменений; `cancelOrder(orderId, reason)` (новый метод для магазина).
- `lib/src/features/orders/presentation/business/business_orders_screen.dart` — кнопка «Отменить заказ» + диалог причины.
- `lib/src/features/orders/presentation/client/order_detail_screen.dart` — кнопка отмены для `readyForPickup`; показ причины отмены; «Оплата при получении».
- `lib/src/features/orders/domain/order.dart` — `paymentStatus` → nullable (`PaymentStatus?`); добавить `String? cancellationReason` и `CancelledBy? cancelledBy` (новый `enum CancelledBy { customer, store }`).
- `lib/src/features/offers/domain/offer.dart` — `OfferStatus.soldOut` + парсинг.
- `lib/main_client.dart`, `lib/env.dart`, `pubspec.yaml` — удаление Stripe (R10).
- `firestore.rules` — `orders` update → `isAdmin()`.

**Files to delete:**
- `functions/src/features/payments/functions/create-payment.ts`
- `functions/src/features/payments/functions/stripe-webhook.ts`
- `functions/src/shared/helpers/stripe-client.ts`
- `lib/src/features/checkout/data/payment_sheet_repository.dart` (+ `.g.dart`)
- `lib/src/app_bootstrap_stripe.dart`

**Patterns to follow (with citations):**
- Стиль fix-спеки и каскадных изменений — `ai_specs/004-fix-offer-creating-spec.md`.
- Транзакционное восстановление `quantity` + проверка статуса внутри транзакции — существующий `cancel-order.ts` и `expire-orders.ts:39-66`.
- Переходы статусов через callable — `orders_repository.dart:62-65` (`updateOrderStatus`).
- Проверка активных заказов / запросов офферов — `orders_repository.dart:46-54`, `client_offer_repository.dart:46`.

**Anti-patterns / avoid:**
- Не оставлять закомментированный Stripe-код «на будущее» — удалять целиком (история в git).
- Не валидировать переходы статусов в виджетах — только в Cloud Functions (граница controller/service).
- Не редактировать `.g.dart`/`.freezed.dart` вручную — пересобрать через `dart run build_runner build --delete-conflicting-outputs`.
- Не плодить вторую кнопку отмены — переиспользовать стиль/диалог, где возможно.

**Data layer changes:**
- `orders`: новые опциональные поля `cancellationReason: string`, `cancelledBy: "customer" | "store"` (в Dart: `enum CancelledBy { customer, store }`); `paymentStatus` становится опциональным и больше не пишется (backward-compatible, без миграции старых документов).
- `offers`: новое допустимое значение `status: "soldOut"`.
- `firestore.rules`: `orders` update — только admin (CF).
- Секреты Cloud Functions: удалить `STRIPE_WEBHOOK_SECRET`, `stripeSecretKey`.

**External integrations:**
- Полностью удаляется интеграция Stripe (callable, webhook, customer/ephemeral keys, payment sheet). Внешних платёжных вызовов в флоу не остаётся. Оплата — офлайн на терминале заведения, вне приложения.

## Edge Cases
См. User Flow → Edge cases. Ключевое: идемпотентный ретрай бронирования, отсутствие двойного восстановления `quantity` при гонке cancel/expire, корректный возврат оффера `soldOut → active` только при открытом окне выдачи.

## Out of Scope
- **Любая онлайн-оплата (Stripe/Kaspi/прочее)** — удаляется сейчас, повторная интеграция — отдельная будущая спека.
- **Частичная отмена/возврат отдельных позиций заказа** — отмена только целиком.
- **Учёт офлайн-оплаты в дашборде/финансах заведения** — оплата вне приложения, не трекается.
- **Пагинация/лимиты в `customerOrdersStream` и `watchOrdersListForStore`** — производительность списков заказов, отдельная задача.
- **Резервный таймаут для удержанного `quantity`** — был актуален только для Stripe-флоу, который удаляется.
- **«Order confirmed» пуш при создании** (`on-order-status-changed` — это `onDocumentUpdated`, создание идёт через `set`) — отдельное улучшение нотификаций.

## Validation

**Automated tests:**
- Unit (`functions/`): `reserveOffer` — повторный вызов с тем же `idempotencyKey` не создаёт второй заказ и не списывает `quantity` дважды; отклоняет оффер с прошедшим `pickupEndTime`; пишет `soldOut` при нуле.
- Unit (`functions/`): `cancelOrder` — отмена из `readyForPickup`; запись `reason`/`cancelledBy`; восстановление `quantity` и возврат оффера в `active`; нет Stripe-вызовов.
- Rules-тест (эмулятор): магазин не может писать `orders.status` клиентским SDK (`PERMISSION_DENIED`); `cancelOrder`/`updateOrderStatus` работают.
- Widget (`flutter`): `business_orders_screen` — кнопка отмены видна для активных статусов, пустая причина блокирует подтверждение; `OrderDetailScreen` — кнопка отмены для `readyForPickup`, отображение причины отмены, текст «Оплата при получении».
- Repo-тест (`flutter`): `PaymentRepository.reserveOffer` использует переданный стабильный `idempotencyKey`, а не генерирует новый.

**Manual QA scenarios:**
1. Бронирование последней единицы → оффер исчезает из листинга (`soldOut`); отмена до конца окна → оффер снова в листинге.
2. Бронирование, выключить сеть на ответе, повторить → один заказ, `quantity` списан один раз.
3. Магазин отменяет `preparing`-заказ с причиной → клиент видит `cancelled` + причину; `quantity` восстановлен.
4. Клиент и магазин по очереди отменяют `readyForPickup` (на разных заказах) → оба проходят.
5. Попытка зарезервировать оффер с прошедшим окном → ошибка, заказ не создан.
6. Полный путь оплаты на месте: бронь → магазин ведёт до `completed` → клиент видит «Оплата при получении» и кнопку отзыва.

**Expected behavior under edge conditions:**
- Offline → callable падает, alert, заказ не создан; ретрай идемпотентен.
- Backend error (`failed-precondition`) → alert на reserve-экране, клиент остаётся на месте.
- Empty data → существующие empty-state без изменений.

## Definition of Done
- [ ] Все Must Have (R1–R11) покрыты автотестами/проверками.
- [ ] Все Manual QA сценарии проходят (Android + iOS, при наличии — web).
- [ ] `grep -ri stripe lib functions/src` пуст; `flutter pub get`, `flutter analyze`, `dart run build_runner build --delete-conflicting-outputs` и `npm run build` (в `functions/`) проходят без ошибок.
- [ ] Нет новых lint-warnings; соответствует `ai_toolkit/` стилю; `.g.dart`/`.freezed.dart` пересобраны, не правлены вручную.
- [ ] `firestore.rules` обновлены и протестированы в эмуляторе; деплой правил согласован.
- [ ] Старые заказы с `paymentStatus` читаются без ошибок (backward-compatible).
- [ ] Спека прилинкована в описании PR.