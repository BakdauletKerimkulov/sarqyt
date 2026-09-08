---
title: Экран заказов в бизнес-приложении
status: draft
size: L
date: 2026-09-08
type: feature
---

# Plan: Экран заказов в бизнес-приложении

Source: `ai_specs/049-business-orders-screen-spec.md`

## Overview

Шестая ветка `StatefulShellRoute` на `/stores/:storeId/orders` с четырьмя вкладками по группам статусов. Один существующий `ordersListStreamProvider(storeId)`, фильтрация в памяти, выбранная вкладка — в query-параметре `tab`. Порядок фаз продиктован зависимостью: `BusinessOrderCard` вытаскивается из `business_orders_screen.dart` **первым**, потому что и новый экран, и превью на дашборде используют его, а сам файл переписывается целиком. Дашборд переезжает на превью только в фазе 3 — до этого он продолжает работать через нетронутый `SliverBusinessOrders`.

**Spec:** `ai_specs/049-business-orders-screen-spec.md`

## Context

- **Structure:** feature-first, `lib/src/features/{feature}/{domain,data,application,presentation}/`; маршрутизация вынесена в `lib/src/routing/`
- **State management:** Riverpod codegen. Поток заказов — `@riverpod Stream<List<Order>> ordersListStream(Ref, StoreID)` с `ref.keepAlive()` + 30-секундным таймером (`lib/src/features/orders/data/orders_repository.dart:93-100`). Индекс вкладки — эфемерный, живёт в `State`, провайдера под него нет (`ai_toolkit/riverpod.md:32,56,63`)
- **Reference implementations:**
  - `lib/src/features/items/presentation/item_tab.dart` + `item_screen/item_screen.dart:36-62` — enum-вкладка, `param`/`label`/`fromParam`, `TabController` в `State`, `didUpdateWidget` для ре-синхронизации с URL
  - `lib/src/routing/business_router.dart:352-364` — маршрут `item/:itemId`, разбирающий `?tab=` в билдере и отдающий `initialTab` в конструктор
  - `lib/src/routing/business_router.dart:372-411` — форма `StatefulShellBranch` с собственным `navigatorKey`
- **Test seams** (все существующие, новых не вводится — spec § Validation):
  - `ordersListStreamProvider(storeId).overrideWith((_) => Stream.value(orders))` — `test/src/features/orders/presentation/business/sliver_business_orders_test.dart:26-30`
  - `currentStoreShipProvider.overrideWithValue(ship)` — `test/features/business_console/store_settings_border_test.dart:27`
  - `ordersRepositoryProvider` — для проверки, что действие карточки зовёт `updateOrderStatus` / `cancelOrder`
  - `AppLocalizations.localizationsDelegates` в harness — обязательны для любого экрана с `context.loc` (`ai_toolkit/flutter.md`, `RULES.md:83`)
- **Testing convention:** `ai_toolkit/testing.md` — `domain/` без моков, `presentation/` виджет-тестами по критическим флоу. Отступление от Robot pattern зафиксировано в spec § Validation с причиной; новых роботов эта фича не заводит. `test/` зеркалит `lib/`, **кроме** существующего разъезда дерева заказов по двум корням (`test/features/orders/` и `test/src/features/orders/`) — фича его не чинит
- **Lint + test command:** `./scripts/gate.sh --fast` внутри фазы (format · analyze · custom_lint · flutter test), `./scripts/gate.sh` целиком в конце — только полный прогон пишет `.gate/approved_sha`, без которого хук блокирует коммит
- **Assumptions / Gaps:**
  - **[L6 deferred]** экран деталей заказа не решён. Действия остаются кнопками на карточке. Если в фазе 1 всплывёт, что карточке нужен переход на детали — это стоп и вопрос человеку, а не решение по ходу
  - **Открыто с refine, требует ответа человека до фазы 2:** L1 Constraints («`OrdersScreen` не трогаются») против L5 Constraints («одно место в `domain/`»). Спека выбрала L5 и правит `client/orders_screen.dart:17`. Фаза 4 упирается в этот выбор — DoD-греп `_activeStatuses` без него не станет пустым
  - `allowedRoles` не читается ни одной строкой кода; R2 это учитывает и роль в критерий не берёт. Фильтрацию по ролям не реализовывать — spec § Out of Scope
  - kk-значение для ключа `expired` в спеке — «Мерзімі өткен», предложено агентом, носителем языка не проверено

## Plan

### Phase 1 — Тонкий вертикальный срез: маршрут → экран → вкладки

**Goal:** По `/stores/:storeId/orders?tab=cancelled` открывается новый экран с четырьмя вкладками и правильно отфильтрованным списком. Дашборд при этом продолжает работать по-старому.

- [ ] `lib/src/features/orders/domain/order.dart` — TDD: `Order.isActive` и `OrderStatusX.isActive` истинны для `confirmed`/`preparing`/`readyForPickup` и ложны для `completed`/`cancelled`/`expired` (тест → `test/features/orders/order_model_test.dart`, файл существует именно там, без `src/`) → затем реализовать геттер + расширение на enum [R9]
- [ ] `lib/src/features/orders/presentation/business/widgets/business_order_card.dart` — вынести `_BusinessOrderCard` (`business_orders_screen.dart:76-266`) как публичный `BusinessOrderCard` без изменения поведения; его собственный `_activeStatuses` (`:90`, используется в `:181`) заменить на `order.isActive`; диалог `_showCancelReasonDialog` (`:268-320`) переехать вместе с ним [R10, R9]
- [ ] `test/src/features/orders/presentation/business/pickup_window_gate_test.dart` — перенацелить с `SliverBusinessOrders(storeId: 'store-1')` (`:42`) на `BusinessOrderCard`, смонтированный напрямую; тест обязан остаться зелёным без правки ожиданий — он и есть регрессионный якорь переноса (`command-conventions.md` C8)
- [ ] `lib/src/features/orders/presentation/business/order_tab.dart` + `lib/l10n/app_{ru,kk,en}.arb` — TDD: `OrderTabX.fromParam` для `active|completed|cancelled|expired`, для `null` и для мусорной строки даёт `OrderTab.active`; `matches` раскладывает шесть статусов ровно по одной вкладке → затем реализовать enum + расширение (`param`, `label(AppLocalizations)`, `matches`, статический `fromParam`) и добавить ключ `expired` (ru «Просроченные» — без ё) [R3, R5, R14]
- [ ] `lib/src/routing/business_router.dart` — `BusinessRoute.orders` в enum, шестая ветка с `_ordersNavigatorKey`, `GoRoute(path: 'orders', name: BusinessRoute.orders.name)`; билдер разбирает `OrderTabX.fromParam(state.uri.queryParameters['tab'])` и отдаёт `initialTab` в конструктор — форма один-в-один с маршрутом `item/:itemId` (`:352-364`). Существующие `branchIndex` 0…4 не двигать [R1]
- [ ] `lib/src/features/orders/presentation/business/business_orders_screen.dart` — TDD: без `?tab=` открыта «Активные» и виден активный заказ, но не завершённый; с `?tab=cancelled` — наоборот → затем переписать `BusinessOrdersScreen` (мёртвый, `:16-77`) как `TabBar` + `TabBarView` поверх одного `ordersListStreamProvider(storeShip.storeId)` с фильтрацией в памяти, `TabController` в `State`, `didUpdateWidget` по образцу `item_screen.dart:55-62`, ленивый билдер списка. `SliverBusinessOrders` в этом же файле пока **не трогать** — на нём держится дашборд [R3, R4, R8, R11]
- [ ] Verify: `./scripts/gate.sh --fast`

### Phase 2 — Запись вкладки в URL, пустые состояния, вход из сайдбара

**Goal:** Вкладка переживает refresh и deep link в обе стороны; в экран можно попасть из меню.

- [ ] `lib/src/features/orders/presentation/business/business_orders_screen.dart` — TDD: с реальным `GoRouter` тап по вкладке даёт `router.state.uri.queryParameters['tab'] == 'completed'`, а `canPop()` остаётся `false` → затем реализовать запись через `context.goNamed(BusinessRoute.orders.name, pathParameters: {'storeId': storeShip.storeId}, queryParameters: {'tab': tab.param})`. `storeId` — из `currentStoreShipProvider`, не из конструктора; без `pathParameters` `goNamed` бросает [R6]
- [ ] `lib/src/features/orders/presentation/business/business_orders_screen.dart` — TDD: поток пуст → `noOrdersYet`; поток не пуст, вкладка пуста → `noOrdersWithStatus`; `tester.takeException()` пуст в обоих → затем реализовать различение по причине пустоты. Оба ключа уже есть во всех трёх локалях (`app_ru.arb:151`, `:179`) [R7, E1, E2]
- [ ] `lib/src/routing/scaffold_with_nested_navigation.dart` — пункт заказов в секцию «Store» сразу после «Dashboard»: `branchIndex: 5`, `allowedRoles: {StoreRole.owner, StoreRole.operator}`, `title: 'Orders'`. `allowedRoles` заполняется для консистентности с соседями, но ничего не фильтрует и в критерий проверки не входит (spec § Background 7) [R2]
- [ ] `lib/src/routing/scaffold_with_nested_navigation.dart` — TDD: сайдбар с локалью `ru` показывает «Заказы» и не показывает `'Orders'`; заголовки соседних пунктов не изменились → затем добавить `_localizedMenuItemTitle(context, item.title)` точной копией формы `_localizedSectionTitle` (`:331-338`): ветка `'Orders' => context.loc.orders`, `_ => key` для остальных; `_MenuTile` (`:363`) рисует через него [R2a]
- [ ] Verify: `./scripts/gate.sh --fast`

### Phase 3 — Дашборд: полный список → превью

**Goal:** Дашборд снова сводка: три активных заказа и ссылка. Второй источник правды исчезает.

- [ ] `lib/src/features/orders/presentation/business/widgets/dashboard_orders_preview.dart` — TDD: при пяти активных заказах отрисовано ровно три карточки; тап по ссылке «Все заказы →» ведёт на `BusinessRoute.orders`; при нуле активных секция скрыта целиком (N2) → затем реализовать превью на `BusinessOrderCard` из фазы 1 — второй виджет карточки не заводить [R12, N2]
- [ ] `lib/l10n/app_{ru,kk,en}.arb` — ключ `viewAllOrders` («Все заказы →») [R14]
- [ ] `lib/src/features/business_console/presentation/dashboard_screen.dart` — TDD: виджет-тест с локалью `ru` находит «Заказы» в заголовке секции → затем заменить `header: 'Reservations'` (`:99`) на `context.loc.orders` и `SliverBusinessOrders(storeId: storeId)` (`:100`) на превью [R13, R12]
- [ ] `lib/src/features/orders/presentation/business/business_orders_screen.dart` — удалить `SliverBusinessOrders` (`:323-426`), `_SliverBusinessOrdersState` и enum `_OrderFilter` (`:322`) вместе с чипами; удалить `test/src/features/orders/presentation/business/sliver_business_orders_test.dart` целиком — его сценарий («пустая отфильтрованная группа не роняет экран») уже покрыт тестом E2 из фазы 2. Не переписывать под новый UI [R10, spec § Validation]
- [ ] Verify: `./scripts/gate.sh --fast`

### Phase 4 — Дубли, осиротевшие ключи, документация

**Goal:** DoD-грепы пусты, словарь и routing-док догоняют код.

- [ ] `lib/src/features/orders/presentation/client/orders_screen.dart` — заменить `_activeStatuses` (`:17`, используется в `:42` и `:45`) на `order.isActive`; больше в клиентском экране не менять ничего. **Блокируется открытым вопросом L1/L5 из Assumptions** — если человек читает L1 буквально, задача снимается, а `_activeStatuses` уходит из DoD-грепа [R9]
- [ ] `lib/l10n/app_{ru,kk,en}.arb` — удалить осиротевшие `activeOrders`, `pastOrders`, `noOrdersDescription` (после фаз 1 и 3 использований в `lib/` не остаётся). `noOrdersWithStatus` сохранить — нужен R7; `all` сохранить — его использует `filter_bottom_sheet.dart:66` [R14]
- [ ] `ai_docs/GLOSSARY.md` — статья про `expired` как пользовательскую группу: канонические слова (ru «просроченный заказ», kk, en "expired order") и границы — NOT `cancelled` (отменил человек), NOT `completed` (заказ выдан); ставит только `expireOrders` по закрытию окна самовывоза (`functions/src/features/orders/functions/expire-orders.ts:12,50`). Статью «Active order» не дублировать — она уже есть, сверить с реализованным `Order.isActive` [R15]
- [ ] `ai_docs/ROUTING_DECISIONS.md` — «Business app: 5 `StatefulShellBranch`es» → 6, с Orders в списке (`docs-sync.md`: правка маршрута не завершена без правки дока)
- [ ] Проверить DoD-грепы: `grep -rn "_activeStatuses\|Reservations" lib` пуст; `grep -rn "loc.activeOrders\|loc.pastOrders\|loc.noOrdersDescription" lib/src/` пуст; `wc -l` по каждому изменённому файлу ≤ 300
- [ ] Verify: `./scripts/gate.sh` (полный прогон, тир 0 + тир 1 — он же пишет допуск для коммита)

## Data layer changes

_None._ Схема, `firestore.rules`, `firestore.indexes.json` и запросы в `StoreOrdersRepository` не меняются [L5]. Существующего индекса `(storeId, createdAt)` достаточно: все четыре вкладки читают один поток и фильтруют его в памяти.

## External integrations

`updateOrderStatus` и `cancelOrder` — уже существующие callable-функции (`orders_repository.dart:64-73`), переезжают вместе с карточкой без изменения контракта. Прямой записи в `orders/{id}` из клиента нет и не появляется: `firestore.rules:196-197` разрешает `update` только админу, всё остальное идёт через Cloud Functions.

## Risks

- **Гейт блокирует коммит из-за чужих правок.** `.gate/approved_sha` привязан к хешу всего рабочего дерева, а в нём сейчас лежат несвязанные изменения ветки `chore/release-audit-and-region-plan` (`ios/`, `.claude/hooks/guard-bash.sh`, `ai_docs/GLOSSARY.md`). Зелёный гейт проштампует и их. Смягчение: работать в отдельной ветке от чистого дерева.
- **`didUpdateWidget` забыт → вкладка и URL разъезжаются.** R6 делает каждый тап по вкладке новым `goNamed`, то есть новым `initialTab` в конструкторе; без ре-синхронизации `TabController` (`item_screen.dart:55-62`) экран покажет одну вкладку, а URL — другую. Смягчение: тест из фазы 2 проверяет URL после тапа, тест из фазы 1 — вкладку после deep link; разъезд валит один из двух.
- **Перенос карточки тихо меняет поведение.** `_BusinessOrderCard` — 190 строк с гейтом окна самовывоза, `SnackBar`-ами и диалогом причины отмены. Смягчение: `pickup_window_gate_test.dart` переносится первым и не переписывается; правка его ожиданий = сигнал, что перенос не «без изменения поведения».
- **`_pickupWindowBlockReason` считает от `DateTime.now()`** (`business_orders_screen.dart:124`) — прямое нарушение `riverpod.md` («never `DateTime.now()`»), но существующее. Смягчение: перенести как есть, `currentDateBuilderProvider` не вводить — это отдельная задача (spec § Validation), и смешивать её с переносом значит потерять регрессионный якорь.
- **Рост потока заказов.** Вкладки «Завершённые»/«Отменённые»/«Просроченные» растут монотонно, поток без `limit`, правило без `request.query.limit`. Смягчение: осознанно принято [L5]; порог пересмотра (~500 заказов или первая жалоба) записан в spec § Out of Scope.

## Out of scope

Копия из spec § Out of Scope:

- Экран деталей заказа для бизнеса (`/stores/:storeId/orders/:orderId`) — отдельной спекой [L6].
- Серверная фильтрация, `limit` и пагинация потока заказов [L5]; условие пересмотра записано в спеке.
- Ограничение `request.query.limit` в `firestore.rules` для `orders` — существующий пробел, самостоятельная задача по безопасности.
- Локализация остальных `SideMenuItem.title` (`'Dashboard'`, `'Performance'`, `'Financials'`, `'Settings'`, `'Help Centre'`) — хелпер R2a их не переводит, они падают в ветку `_`.
- Реализация фильтрации сайдбара по `allowedRoles` — включение немедленно скрыло бы `Financials` у `operator`, чего никто не заказывал.
- Единый источник активных статусов за пределами presentation: `orders_repository.dart:58` и `expire-orders.ts:17` остаются отдельными копиями.
- Выбор канонического ru-слова для `Store` («заведение» против «магазина») — открытый TODO в `GLOSSARY.md`.
- Изменения клиентского `/orders` за пределами замены дублированного множества статусов.
- Роль-зависимое ограничение действий над заказом на сервере: `StoreRole` не является границей безопасности.
- Перевод `_pickupWindowBlockReason` на `currentDateBuilderProvider`.
