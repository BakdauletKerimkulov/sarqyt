---
title: Экран заказов в бизнес-приложении
status: refined
size: L
date: 2026-09-06
type: feature
ledger: 049-business-orders-screen-ledger.md
---

# Spec: Экран заказов в бизнес-приложении

Source request: Экран «Заказы» в бизнес-приложении. Новая ветка в StatefulShellRoute (/stores/:storeId/orders), 5-я вкладка нижней навигации. По умолчанию показываются текущие (активные) заказы; если их нет — надпись по центру «У вас пока нет заказов». Разделы по статусам оформлены как TabBar по группам (Активные / Завершённые / Отменённые), активная вкладка кодируется в query-параметре по образцу ItemTabX в ItemScreen. Блок заказов на дашборде остаётся, но превращается в превью: 2-3 ближайших активных заказа и ссылка «Все заказы →» на новый экран. Контекст из анализа: осиротевший BusinessOrdersScreen (lib/src/features/orders/presentation/business/business_orders_screen.dart, 426 строк) не смонтирован ни в одном роутере — решить его судьбу; SliverBusinessOrders используется на дашборде (dashboard_screen.dart:100) под захардкоженным английским заголовком 'Reservations' мимо l10n; множество активных статусов _activeStatuses продублировано в трёх местах (orders_screen.dart:18, business_orders_screen.dart:21 и :336); в домене шесть статусов OrderStatus — confirmed, preparing, readyForPickup, completed, cancelled, expired.

## Goal

Персонал заведения получает отдельный экран заказов с четырьмя вкладками по группам статусов вместо блока внутри дашборда. По умолчанию открыты активные заказы — те, что требуют действия сейчас. Дашборд остаётся сводкой: показывает превью из трёх активных заказов и ведёт на новый экран. Побочный результат — исчезает мёртвый `BusinessOrdersScreen` и четырёхкратное дублирование множества активных статусов в Dart (Background 3).

## Background

**Stack & conventions** (`ai_toolkit/RULES.md`, читаны полностью; плюс `gorouter.md`, `riverpod.md`, `code-style.md`, `testing.md`):

- Маршруты — enum, каждый `GoRoute` задаёт `name: BusinessRoute.x.name`; навигация только по имени (`gorouter.md`). Вкладки — `StatefulShellRoute.indexedStack`.
- Состояние вкладки эфемерно по `riverpod.md` («tab index … остаётся в `StatefulWidget`»), провайдер под него не заводится. Источник истины для выбранной вкладки — query-параметр маршрута (CLAUDE.md: UI-state, переживающий refresh/deep link, кодируется в route/query params).
- `presentation → application → domain ← data`; множество активных статусов — «utility needed by two layers» ⇒ живёт в `domain/` (`architecture.md`).
- Все пользовательские строки через ARB и `context.loc` — инлайн-строк в Dart быть не должно.
- Максимум 300 строк на файл; виджет длиннее ~80 строк или используемый второй раз выносится в свой файл (`code-style.md`).
- Виджеты обрабатывают все три состояния `AsyncValue`; тесты подменяют репозитории/провайдеры, а не контроллеры (`riverpod.md`, `testing.md`).

**Project context:**

- Бизнес-навигация — сайдбар, а не нижняя панель: `ScaffoldWithNestedNavigation` рисует `_SidebarContent` шириной 280 px, а при ширине < 450 px — тот же список в `Drawer` (`lib/src/routing/scaffold_with_nested_navigation.dart:113-152`). Пункты описаны в `sideMenuSections` (`:42-82`) с явным `branchIndex`, поэтому порядок показа не связан с порядком веток.
- **`allowedRoles` сегодня ничего не фильтрует.** Поле объявлено (`scaffold_with_nested_navigation.dart:20,27`) и заполнено у всех пяти пунктов (`:51,57,63,69,80`), но `_SidebarContent.build` (`:196-230`) рисует `for (final item in section.items)` без единой проверки роли — `grep -rn "allowedRoles" lib/ test/` не даёт ни одного чтения. Следствие: `Financials` (`allowedRoles: {owner}`) сейчас виден `operator`. Это существующий разрыв между декларацией и поведением; фича его не создаёт и не закрывает — см. Out of Scope.
- Заголовки секций сайдбара уже локализованы через `_localizedSectionTitle(context, section.title)` — `switch` по ключу-строке на `context.loc.sectionStore` / `sectionSupport` (`scaffold_with_nested_navigation.dart:331-338`). Не локализованы только `SideMenuItem.title`: `_MenuTile` рисует `Text(item.title)` напрямую (`:363`), а `sideMenuSections` — `const`, поэтому `context.loc` внутри списка невозможен в принципе.
- Веток сейчас пять: dashboard, performance, financials, settings, help (`business_router.dart:330-411`), что совпадает с `ai_docs/ROUTING_DECISIONS.md`.
- Все маршруты под `/stores/:storeId/*` обёрнуты в `StoreStartupWidget`, который скоупит `currentStoreShipProvider` — `storeId` берётся из скоупа, а не из конструктора (`ROUTING_DECISIONS.md`, `lib/src/routing/store_startup.dart`).
- Данные: `ordersListStreamProvider(storeId)` (`orders_repository.dart:94`) отдаёт поток всех заказов заведения, отсортированных `createdAt desc`; индекс `(storeId, createdAt)` уже есть в `firestore.indexes.json`.
- Статусы и переходы — `ai_docs/BUSINESS_RULES.md`: `confirmed → preparing → readyForPickup → completed`, плюс терминальные `cancelled` и `expired`. Переходы идут через Cloud Functions (`updateOrderStatus`, `cancelOrder`), клиент в `orders/{id}` не пишет (`firestore.rules:187-198`).
- `StoreRole` не проверяется на сервере вообще (`BUSINESS_RULES.md:42` → «Partner roles & permissions»). `allowedRoles` в сайдбаре задумывался как UI-фильтр, но и им не является — поле не читается (см. следующий пункт). Границей безопасности `StoreRole` не служит ни на клиенте, ни на сервере.

**Расхождения, найденные при анализе** (фиксируются здесь, чинятся в объёме, указанном в Requirements / Out of Scope):

1. `BusinessOrdersScreen` (`business_orders_screen.dart:16-77`) не смонтирован ни в одном роутере — мёртвый код. Используется только `SliverBusinessOrders` из того же файла.
2. Заголовок секции на дашборде — `'Reservations'` (`dashboard_screen.dart:99`), английская строка мимо ARB **и** мимо словаря: в `ai_docs/GLOSSARY.md` у `Order` записано «NOT «бронь»: бронирование — это действие, создающее Order, а не отдельная сущность».
3. Множество активных статусов продублировано в Dart **четырежды**, а не трижды:
   - `client/orders_screen.dart:17` — `OrdersScreen`;
   - `business/business_orders_screen.dart:19` — `BusinessOrdersScreen`;
   - `business/business_orders_screen.dart:90` — **`_BusinessOrderCardState`**, используется в `:181` для `isActive`. Это тот самый класс, который R10 переносит в новый файл: без явного указания дубль просто переедет вместе с ним;
   - `business/business_orders_screen.dart:336` — `_SliverBusinessOrdersState`.

   Плюс два экземпляра вне объёма R9: `orders_repository.dart:58` (`whereIn: ['confirmed','preparing','readyForPickup']` в `hasActiveOrdersForItem`) и серверный `functions/src/features/orders/functions/expire-orders.ts:17`.
4. Файл `business_orders_screen.dart` — 426 строк при лимите 300.
5. У `match /orders/{id}` нет ограничения `request.query.limit`, которого требует `ai_toolkit/RULES-backend.md` («Every list rule caps request.query.limit»). Существующий пробел, эта фича его не создаёт и не закрывает — см. Out of Scope.
6. Не локализованы `SideMenuItem.title` (`'Dashboard'`, `'Performance'`, `'Financials'`, `'Settings'`, `'Help Centre'`) — тот же класс проблемы, что (2). Заголовки секций (`'Store'`, `'Support'`) локализованы и к этому пункту не относятся. Механизм локализации нового пункта — R2; остальные пункты вне объёма.
7. `allowedRoles` не читается ни одной строкой кода (см. Project context выше). R2 из-за этого не может опираться на роль в критерии проверки.

**Why now:** заказы — основной рабочий инструмент персонала, и сейчас они доступны только прокруткой дашборда, без разделения по статусам. Экран заказов — предпосылка для будущего экрана деталей заказа [L6].

## User Flow

### Happy path

1. Владелец или оператор открывает пункт «Заказы» в сайдбаре (в узком окне — в `Drawer`) → `/stores/:storeId/orders`.
2. Открывается вкладка «Активные». Показаны заказы в статусах `confirmed`, `preparing`, `readyForPickup`, отсортированные по `createdAt` убыв.
3. На карточке заказа доступны те же действия, что сегодня: перевод в следующий статус и отмена с указанием причины.
4. Пользователь переключается на «Завершённые», «Отменённые» или «Просроченные» → список меняется, в URL появляется `?tab=completed|cancelled|expired`.
5. Обновление страницы или переход по ссылке с `?tab=` открывает ту же вкладку.
6. На дашборде секция «Заказы» показывает до трёх активных заказов и ссылку «Все заказы →», ведущую на вкладку «Активные».

### Alternative flows

- Ссылка с неизвестным или отсутствующим `tab` (`?tab=bogus`) → открывается «Активные», без ошибки (поведение `ItemTabX.fromParam`).
- Пользователь с ролью вне `allowedRoles` открывает `/stores/:storeId/orders` по прямой ссылке → экран открывается. Более того, пункт ему и в сайдбаре **виден**: `allowedRoles` сегодня не читается вообще (Background 7), так что скрытия по роли не существует ни для одного пункта меню. `StoreRole` не является границей безопасности и на сервере (`BUSINESS_RULES.md:42`).

### Error & recovery flows

- Поток заказов отдал ошибку → экран показывает состояние ошибки `AsyncValueWidget` вместо списка; вкладки остаются доступны.
- Смена статуса или отмена упала (сеть, серверный отказ, окно самовывоза закрыто) → `SnackBar` с `humanReadableError(e)`, карточка возвращается из состояния загрузки, статус не меняется. Поведение сохраняется из текущего `_BusinessOrderCard`.
- Действие заблокировано окном самовывоза → кнопка недоступна с подписью-причиной (`pickupWindowNotOpenYet` / `pickupWindowAlreadyClosed`), как сегодня.

### Edge cases

- E1. Заказов у заведения нет вообще → на вкладке «Активные» по центру `noOrdersYet` («Заказов пока нет»).
- E2. Заказы есть, но не в этой группе (например, только завершённые, открыта «Активные») → по центру `noOrdersWithStatus` («Нет заказов с этим статусом»), а **не** `noOrdersYet`: заказы у заведения есть, и утверждать обратное нельзя. Переключение вкладок работает (R7).
- E3. Поток ещё грузится → индикатор загрузки, вкладки уже отрисованы.
- E4. Заказ меняет статус, пока открыт экран (сервер перевёл в `expired`, коллега — в `completed`) → заказ пропадает из текущей вкладки и появляется в другой без ручного обновления: список приходит потоком.
- E5. Много заказов (сотни) → страницы нет, рисуется весь отфильтрованный список; список строится ленивым сливером/`ListView.builder`.
- E6. Узкое окно (< 450 px) → вкладки прокручиваются горизонтально (`isScrollable: true`), сайдбар доступен через `Drawer`.

## Requirements

### Must Have

- [ ] R1: Маршрут `/stores/:storeId/orders` с `name: BusinessRoute.orders.name` добавлен шестой веткой `StatefulShellRoute` в `business_router.dart`; существующие `branchIndex` (0…4) не меняются. Verifiable by: тест роутера/навигации проходит по имени маршрута и получает `BusinessOrdersScreen`; `flutter analyze` зелёный. [L1]
- [ ] R2: В `sideMenuSections` добавлен пункт заказов с `branchIndex: 5`, `allowedRoles: {StoreRole.owner, StoreRole.operator}`, расположенный в секции «Store» сразу после «Dashboard». Verifiable by: виджет-тест сайдбара — пункт отрисован и тап по нему переключает ветку на `BusinessRoute.orders`. **`allowedRoles` в критерии не участвует**: поле сегодня не читается (Background 7), проверять по нему нечего. [L1]
- [ ] R2a: Заголовок нового пункта берётся из ARB, а не из инлайн-строки. `SideMenuItem.title` остаётся ключом-строкой (`'Orders'`), а `_MenuTile` рисует его через новый хелпер `_localizedMenuItemTitle(context, item.title)` — точная копия формы `_localizedSectionTitle` (`scaffold_with_nested_navigation.dart:331-338`): `switch` с веткой `'Orders' => context.loc.orders` и `_ => key` для остальных. Существующие пять заголовков через хелпер не переводятся — они падают в ветку `_` и остаются как есть (Background 6). Verifiable by: виджет-тест сайдбара с локалью `ru` находит «Заказы» и не находит `'Orders'`; `grep -n "'Dashboard'" lib/src/routing/scaffold_with_nested_navigation.dart` по-прежнему находит строку — соседние пункты не тронуты.
- [ ] R3: Экран показывает четыре вкладки в порядке: «Активные» (`confirmed`, `preparing`, `readyForPickup`), «Завершённые» (`completed`), «Отменённые» (`cancelled`), «Просроченные» (`expired`). Verifiable by: виджет-тест — заказ каждого из шести статусов попадает ровно в одну ожидаемую вкладку. [L2][L4]
- [ ] R4: При входе без `tab` открыта вкладка «Активные». Verifiable by: виджет-тест — экран без query-параметра показывает активный заказ и не показывает завершённый. [L1]
- [ ] R5: Выбранная вкладка кодируется в query-параметре `tab` значениями `active|completed|cancelled|expired`; неизвестное или отсутствующее значение даёт «Активные». Verifiable by: unit-тест `OrderTabX.fromParam` на все значения плюс `null` и мусорную строку. [L2]
- [ ] R6: Переключение вкладки записывает новое значение `tab` в URL через `context.goNamed(BusinessRoute.orders.name, pathParameters: {'storeId': storeShip.storeId}, queryParameters: {'tab': tab.param})`, не добавляя запись в стек навигации. `storeId` берётся из `currentStoreShipProvider`, не из конструктора; без `pathParameters` `goNamed` бросает исключение. Verifiable by: виджет-тест с реальным `GoRouter` — после тапа по вкладке `router.state.uri.queryParameters['tab']` равен ожидаемому, `canPop()` остаётся `false`. [L2]
- [ ] R7: Пустое состояние различает два случая. Поток пуст (E1) → `context.loc.noOrdersYet` («Заказов пока нет»). Поток не пуст, но отфильтрованный список пуст (E2) → `context.loc.noOrdersWithStatus` («Нет заказов с этим статусом»): говорить «заказов пока нет» там, где заказы есть, — ложь пользователю. Оба ключа уже существуют во всех трёх локалях (`app_ru.arb:151` и `:179`), новых ARB-ключей не требуется. Текст по центру области списка. Verifiable by: виджет-тест — E1 показывает `noOrdersYet`, E2 показывает `noOrdersWithStatus`, `tester.takeException()` пуст в обоих. [L1]
- [ ] R8: Все вкладки читают один `ordersListStreamProvider(storeId)` и фильтруют результат в памяти; запросы в `StoreOrdersRepository` и `firestore.indexes.json` не меняются. Verifiable by: ревью диффа — в `data/` нет изменений; виджет-тест переключает вкладки с одним overrideом провайдера. [L5]
- [ ] R9: Множество активных статусов объявлено один раз в `lib/src/features/orders/domain/order.dart` (геттер `Order.isActive` плюс `OrderStatusX.isActive` на enum); удалены **все четыре** дубля `_activeStatuses` — `client/orders_screen.dart:17`, `business_orders_screen.dart:19`, `:90` (внутри `_BusinessOrderCardState`, переезжающего по R10 — заменить на `order.isActive`, а не перенести) и `:336`. Verifiable by: `grep -rn "_activeStatuses" lib` пуст; unit-тест на `isActive` для всех шести статусов. [L5]
- [ ] R10: Карточка заказа вынесена в отдельный публичный файл `presentation/business/widgets/business_order_card.dart` без изменения поведения; каждый затронутый файл укладывается в 300 строк. Verifiable by: `pickup_window_gate_test.dart` (перенацеленный на `BusinessOrderCard`, смонтированный напрямую вместо `SliverBusinessOrders`) остаётся зелёным — он и есть регрессионный якорь переноса; `wc -l` по изменённым файлам ≤ 300. **`sliver_business_orders_test.dart` не «адаптируется под новые имена», а удаляется**: его единственный сценарий тапает по чипу (`find.text('Active')`, `sliver_business_orders_test.dart:58`) виджета, который эта фича удаляет целиком. Его смысл — «пустая отфильтрованная группа не роняет экран» — переходит в тест E2 из R7. Ослаблять или подгонять его под новый UI нельзя (`command-conventions.md` C8).
- [ ] R11: Мёртвый класс `BusinessOrdersScreen` в старом виде (секции «активные/прошлые», не смонтированный) удалён — его имя занимает новый экран. Verifiable by: в репозитории ровно одно объявление `class BusinessOrdersScreen`, и оно смонтировано в `business_router.dart`.
- [ ] R12: Секция заказов на дашборде показывает не более трёх активных заказов и ссылку «Все заказы →» на `BusinessRoute.orders`; чипы-фильтры с дашборда убраны. Verifiable by: виджет-тест дашборда — при пяти активных заказах отрисовано три карточки; тап по ссылке даёт переход на маршрут заказов. [L3]
- [ ] R13: Заголовок секции на дашборде берётся из `context.loc.orders`; строка `'Reservations'` в коде отсутствует. Verifiable by: `grep -rn "Reservations" lib` пуст; виджет-тест дашборда с локалью `ru` находит «Заказы». [L3]
- [ ] R14: Добавлены ключи ARB `expired` и `viewAllOrders` в `app_ru.arb`, `app_kk.arb`, `app_en.arb`; новых инлайн-строк в Dart нет. Значения `expired`: ru «Просроченные», kk «Мерзімі өткен», en "Expired". Verifiable by: `flutter gen-l10n` без предупреждений о пропущенных ключах; ревью диффа.

  Написание: **«Просроченные»**, не «Просрочённые» — причастие от «просро́чить» пишется без ё. Соседние ключи (`completed` → «Завершённые», `cancelled` → «Отменённые») с ё пишутся правильно, что и создаёт ложную аналогию.
- [ ] R15: `expired` как пользовательская группа заказов внесён в `ai_docs/GLOSSARY.md` в этом же прогоне. `ai_toolkit/docs-sync.md` делает новый l10n-ключ для доменного концепта, отсутствующего в словаре, **блокирующей** находкой: ключи нельзя переименовать позже без миграции. Сегодня словарь упоминает статус `expired` внутри статьи **Order**, но не фиксирует ни ru-, ни kk-слова — до L4 он и не был отдельной пользовательской группой, а после стал вкладкой. Запись должна назвать канонические слова (ru «просроченный заказ», kk, en "expired order") и то, чем он не является: NOT `cancelled` (отменил человек) и NOT `completed` (заказ выдан) — `expired` ставит только `expireOrders` по закрытию окна самовывоза (`functions/src/features/orders/functions/expire-orders.ts:12,50`). Verifiable by: `grep -n "expired" ai_docs/GLOSSARY.md` находит отдельную статью, а не только упоминание внутри **Order**. [L4]

### Nice to Have

- [ ] N1: Счётчик активных заказов рядом с названием вкладки «Активные».
- [ ] N2: Секция превью на дашборде скрывается целиком, когда активных заказов нет.

### Non-functional

- Производительность: список строится ленивым билдером; фильтрация — один проход по списку на построение вкладки. Пагинация не вводится (E5, Out of Scope).
- Доступность: вкладки — стандартный `TabBar` (семантика и размер тапа Material 3); ссылка «Все заказы →» — кнопка, а не `GestureDetector` по тексту.
- i18n: три локали (ru, kk, en), два новых ключа (`expired`, `viewAllOrders`), три удаляемых (`activeOrders`, `pastOrders`, `noOrdersDescription`); лейблы вкладок берутся из существующих `active`, `completed`, `cancelled` и нового `expired`. Заголовок пункта сайдбара — через хелпер R2a, не инлайн-строкой.

## Technical Constraints

**Files to create:**
- `lib/src/features/orders/presentation/business/order_tab.dart` — enum `OrderTab { active, completed, cancelled, expired }` плюс расширение `OrderTabX` с `param`, `label(AppLocalizations)`, `matches(OrderStatus)` и статическим `fromParam`.
- `lib/src/features/orders/presentation/business/widgets/business_order_card.dart` — публичная карточка заказа, перенесённая из `business_orders_screen.dart` без изменения поведения.
- `lib/src/features/orders/presentation/business/widgets/dashboard_orders_preview.dart` — превью для дашборда (до трёх активных заказов + ссылка).
- `test/src/features/orders/presentation/business/business_orders_screen_test.dart`, `.../order_tab_test.dart`, `.../dashboard_orders_preview_test.dart`.

**Files to modify:**
- `lib/src/routing/business_router.dart` — `BusinessRoute.orders` в enum, шестая ветка с `_ordersNavigatorKey` и `GoRoute(path: 'orders')`. **Билдер маршрута разбирает query-параметр и передаёт его в конструктор**, ровно как это уже делает маршрут `item/:itemId` (`business_router.dart:352-364`): `OrderTabX.fromParam(state.uri.queryParameters['tab'])` → `BusinessOrdersScreen(initialTab: tab)`. Экран сам `GoRouterState.of(context)` не читает — иначе `didUpdateWidget` не сработает и `TabController` разъедется с URL. Слои `businessRedirect()` не трогаются: `/stores/*` уже покрыт Layer 9.
- `lib/src/routing/scaffold_with_nested_navigation.dart` — пункт меню (R2) и хелпер локализации заголовка пункта (R2a).
- `lib/src/features/orders/presentation/business/business_orders_screen.dart` — экран переписывается: `TabBar` + `TabBarView`, `SliverBusinessOrders` и `_OrderFilter` удаляются вместе с чипами.
- `lib/src/features/business_console/presentation/dashboard_screen.dart` — секция заказов заменяется на превью, заголовок из l10n.
- `lib/src/features/orders/domain/order.dart` — `isActive` (R9).
- `lib/src/features/orders/presentation/client/orders_screen.dart` — `_activeStatuses` заменяется на `order.isActive`; поведение клиентского экрана не меняется.
- `lib/l10n/app_{ru,kk,en}.arb` — добавить `expired`, `viewAllOrders`; удалить осиротевшие после переписывания экрана `activeOrders`, `pastOrders`, `noOrdersDescription` (после R3/R7 у них не остаётся ни одного использования в `lib/` — проверяется `grep -rn "loc.activeOrders\|loc.pastOrders\|loc.noOrdersDescription" lib/src/`). `noOrdersWithStatus` **сохраняется** — он нужен R7 для E2. `all` тоже сохраняется: его использует `filter_bottom_sheet.dart:66`.
- `ai_docs/ROUTING_DECISIONS.md` — «Business app: 5 branches» → 6, с новым пунктом (`docs-sync.md`: изменение маршрута не завершено без обновления документа).
- `ai_docs/GLOSSARY.md` — статья про `expired` (R15).

**Patterns to follow:**
- `lib/src/features/items/presentation/item_tab.dart` + `item_screen.dart:38-62` — форма enum-вкладки, `fromParam`, `TabController` в `State`, плюс `didUpdateWidget`, синхронизирующий контроллер с новым `initialTab`. Отличие, обязательное здесь: `ItemScreen` читает `tab` из URL, но не записывает обратно; новый экран обязан записывать (R6), поэтому `didUpdateWidget` из декоративного становится обязательным — каждый `goNamed` перестраивает виджет с новым `initialTab`.
- `lib/src/routing/business_router.dart:372-411` — форма `StatefulShellBranch` с собственным `navigatorKey`.
- `lib/src/features/items/presentation/items_list/sliver_items_grid.dart` — сливер-список внутри `CustomScrollView` дашборда.
- `lib/src/common_widgets/async_value_widget.dart` — обработка трёх состояний `AsyncValue`.

**Anti-patterns / avoid:**
- Не заводить Riverpod-провайдер под индекс вкладки: это эфемерное состояние (`riverpod.md`), источник истины — query-параметр.
- Не добавлять запрос на вкладку и составной индекс `(storeId, status, createdAt)` [L5].
- Не тянуть `storeId` через конструкторы: он берётся из `currentStoreShipProvider` в скоупе `StoreStartupWidget`.
- Не заводить второй виджет карточки заказа: превью на дашборде и список на экране используют один `BusinessOrderCard` (или его явный компактный вариант с параметром, а не копию).
- Не менять `client/orders_screen.dart` дальше замены `_activeStatuses` — клиентский экран вне объёма [L1].
- Не писать в `orders/{id}` напрямую: смена статуса только через `updateOrderStatus` / `cancelOrder`.

**Data layer changes:** нет. Схема, правила и индексы не меняются [L5].

**External integrations:** вызовы `updateOrderStatus` и `cancelOrder` уже существуют в `StoreOrdersRepository` и переносятся вместе с карточкой без изменений.

## Out of Scope

- Экран деталей заказа для бизнеса (`/stores/:storeId/orders/:orderId`) — отдельной спекой [L6].
- Серверная фильтрация, `limit` и пагинация потока заказов: при текущем объёме данных не окупаются, а `limit` скрыл бы старые заказы [L5].
- Ограничение `request.query.limit` в `firestore.rules` для `orders` — существующий пробел (Background 5), самостоятельная задача по безопасности; эта фича не меняет правила.
- Локализация захардкоженных пунктов сайдбара и заголовков секций (Background 6) — кроме `'Reservations'`, который относится к затрагиваемому блоку (R13).
- Выбор канонического ru-слова для `Store` («заведение» против «магазина») — открытый TODO в `GLOSSARY.md`, не относится к заказам.
- Изменения клиентского `/orders` за пределами замены дублированного множества статусов.

  **Разрешённое противоречие в ledger — требует подтверждения человека.** L1 Constraints говорит «Клиентский `/orders` … и `OrdersScreen` **не трогаются**»; L5 Constraints говорит «Множество активных статусов должно существовать **в одном месте** в `domain/`». Буквально оба выполнить нельзя: единственное место требует правки `client/orders_screen.dart:17`, а DoD-проверка `grep -rn "_activeStatuses" lib` иначе не станет пустой. Спека читает L1 как «никакой работы над фичей там», а односточную замену `_activeStatuses` → `order.isActive` выводит из-под запрета в пользу L5. Ledger не редактировался. Если чтение неверно — правильный выход в откате R9 до трёх бизнес-дублей и снятии клиентского из DoD-грепа.
- Единый источник активных статусов **за пределами presentation**: `orders_repository.dart:58` (`whereIn` сырыми строками в `hasActiveOrdersForItem`) и серверный `expire-orders.ts:17` остаются самостоятельными копиями. Серверная неизбежна — другой язык; репозиторную можно вывести из домена, но это правка `data/` под фичей, которая по L5 не меняет `data/` вообще. Осознанное отступление от буквы L5 Constraints, отдельной задачей.
- Реализация фильтрации сайдбара по `allowedRoles` (Background 7). Поле не читается сегодня и не начнёт читаться в этой фиче: включение фильтрации немедленно скрыло бы `Financials` у `operator` — изменение поведения для существующих пунктов, которого никто не заказывал. Задача на права доступа, не на экран заказов.
- Пагинация и любое ограничение размера потока заказов [L5]. **Условие пересмотра:** сегодняшнее обоснование L5 («при текущем объёме данных не окупаются») — факт про сегодня, а не решение про архитектуру. Новый экран меняет профиль нагрузки: вкладки «Завершённые» / «Отменённые» / «Просроченные» растут монотонно и никогда не очищаются, и весь их объём скачивается при каждом открытии экрана (`watchOrdersListForStore` без `limit`, `orders_repository.dart:21-31`; `match /orders/{id}` без `request.query.limit`, `firestore.rules:187-198`). Возврат к вопросу отдельной спекой при первом заведении, перешагнувшем ~500 заказов, или при первой жалобе на время открытия экрана — что наступит раньше. Кто принимает рост до этого порога — решение человека при approve.
- Роль-зависимое ограничение действий над заказом на сервере: `StoreRole` сегодня не является границей безопасности (`BUSINESS_RULES.md`).

## Validation

**Test seams** (все — существующие, новых не вводится):
- `ordersListStreamProvider(storeId).overrideWith((_) => Stream.value(orders))` — подмена потока заказов; уже используется в `test/src/features/orders/presentation/business/sliver_business_orders_test.dart:26`.
- `currentStoreShipProvider.overrideWithValue(ship)` — подмена текущего заведения; уже используется в `test/features/business_console/store_settings_border_test.dart:27`.
- `ordersRepositoryProvider` — подмена репозитория для проверки, что действие карточки вызывает `updateOrderStatus`/`cancelOrder`.
- `AppLocalizations.localizationsDelegates` в harness — обязательны для экранов с `context.loc` (`flutter.md`).
- Окно самовывоза в `_pickupWindowBlockReason` считается от `DateTime.now()`; существующие тесты задают `pickupStartTime`/`pickupEndTime` относительно `DateTime.now()`. Перенос карточки поведение сохраняет; переход на `currentDateBuilderProvider` — отдельная задача, не в этой спеке.

**Automated tests:**
- Unit: `OrderTabX.fromParam` (все значения, `null`, мусор), `matches` для шести статусов → `test/src/features/orders/presentation/business/order_tab_test.dart`.
- Unit: `Order.isActive` для шести статусов → **`test/features/orders/order_model_test.dart`** — файл существует именно там, без `src/` в пути. Дерево тестов заказов сегодня разъехалось по двум корням (`test/features/orders/` и `test/src/features/orders/`), что нарушает `ai_toolkit/testing.md:90` («`test/` mirrors `lib/`»); разъезд существующий, эта фича его не чинит и новых файлов в `test/features/` не создаёт.
- Widget: вкладки фильтруют список; вкладка по умолчанию — «Активные» → `business_orders_screen_test.dart`.
- Widget: E1 показывает `noOrdersYet`, E2 показывает `noOrdersWithStatus` (R7) → там же.
- Widget: тап по вкладке пишет `tab` в URL и не добавляет запись в стек (с реальным `GoRouter`) → там же.
- Widget: превью дашборда ограничено тремя заказами, ссылка ведёт на маршрут заказов, заголовок локализован → `dashboard_orders_preview_test.dart`.
- Widget: пункт заказов отрисован в сайдбаре, заголовок локализован, тап переключает ветку (R2, R2a) → `test/src/routing/scaffold_with_nested_navigation_test.dart`.
- Regression: `pickup_window_gate_test.dart` — единственный сохраняемый регрессионный тест переноса карточки; перенацеливается с `SliverBusinessOrders(storeId: 'store-1')` (`:42`) на `BusinessOrderCard`, смонтированный напрямую. Поведение окна самовывоза меняться не должно.
- Deleted: `sliver_business_orders_test.dart` удаляется вместе с виджетом (R10); его сценарий переходит в тест E2.

**Отступление от Robot pattern — осознанное.** `ai_toolkit/testing.md:16,72` требует Robot для presentation-тестов, и в проекте инфраструктура есть (`test/src/robot.dart`, `test/src/features/offers/offers_robot.dart`). Тесты выше написаны прямыми файндерами, без `orders_robot.dart`, по двум причинам: (1) `testing.md:72` сам разрешает «skip widget tests for trivial screens» — здесь проверяется фильтрация списка и запись query-параметра, а не пользовательский флоу через несколько экранов; (2) оба существующих теста заказов (`sliver_business_orders_test.dart`, `pickup_window_gate_test.dart`) уже написаны без робота, и введение робота на одну фичу оставит два стиля в одной папке. Если ревьюер не согласен — цена решения — один новый файл `test/src/features/orders/orders_robot.dart`, а не переделка тестов. Зафиксировано здесь, чтобы отступление не было молчаливым (`command-conventions.md` C2).

**Manual QA scenarios:**
1. Дано: заведение с заказами во всех шести статусах. Когда открываю «Заказы». Тогда «Активные» открыта, в ней три заказа, остальные три разложены по своим вкладкам.
2. Дано: открыта вкладка «Отменённые», в URL `?tab=cancelled`. Когда перезагружаю страницу (web) или перехожу по ссылке. Тогда открыта та же вкладка.
3. Дано: у заведения нет ни одного заказа. Когда открываю экран. Тогда по центру «Заказов пока нет», приложение не падает.
3a. Дано: у заведения есть только завершённые заказы. Когда открываю экран (вкладка «Активные»). Тогда по центру «Нет заказов с этим статусом» — не «Заказов пока нет»; на вкладке «Завершённые» заказы видны.
4. Дано: открыта вкладка «Активные» с заказом в `readyForPickup`. Когда коллега завершает заказ с другого устройства. Тогда заказ исчезает из «Активных» и появляется в «Завершённых» без обновления вручную.
5. Дано: окно самовывоза ещё не открыто. Когда пытаюсь перевести заказ в `readyForPickup`. Тогда кнопка недоступна с подписью-причиной — как до изменений.
6. Дано: ширина окна < 450 px. Когда открываю экран. Тогда вкладки прокручиваются, сайдбар доступен через `Drawer`, «Заказы» в нём есть.
7. Дано: дашборд с пятью активными заказами. Когда смотрю секцию «Заказы». Тогда вижу три карточки и ссылку «Все заказы →», ведущую на вкладку «Активные».

**Expected behavior under edge conditions:**
- Оффлайн → Firestore отдаёт закешированный снимок; список рисуется из кеша, действия падают в `SnackBar` с ошибкой.
- Ошибка бэкенда в потоке → состояние ошибки `AsyncValueWidget`, вкладки остаются переключаемыми.
- Пустые данные → `noOrdersYet` по центру, когда заказов нет вовсе (E1); `noOrdersWithStatus`, когда пуста только выбранная вкладка (E2).

## Definition of Done

- [ ] Все требования Must Have покрыты автотестами и проходят
- [ ] Ручные сценарии 1–7 (включая 3a) пройдены на iOS-симуляторе и в web-сборке бизнес-приложения
- [ ] `flutter analyze` и `dart run custom_lint` без новых предупреждений; `dart run build_runner build --delete-conflicting-outputs` зелёный
- [ ] `grep -rn "_activeStatuses\|Reservations" lib` пуст (все четыре дубля, включая `_BusinessOrderCardState` — R9)
- [ ] `grep -rn "loc.activeOrders\|loc.pastOrders\|loc.noOrdersDescription" lib/src/` пуст, и эти три ключа удалены из всех трёх ARB
- [ ] Каждый изменённый файл ≤ 300 строк
- [ ] `ai_docs/ROUTING_DECISIONS.md` обновлён (6 веток); `ai_docs/GLOSSARY.md` содержит новую статью про `expired` (R15). Статья «Active order» там **уже есть** — она проверяется на соответствие реализованному `Order.isActive`, а не добавляется заново
- [ ] Спека связана с PR
