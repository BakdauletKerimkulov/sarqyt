---
title: Подготовка к переезду Firebase в europe-west1
status: approved
date: 2026-08-06
type: infrastructure
---

# Plan: Подготовка к переезду Firebase в europe-west1

Source: ревью готовности к релизу — `ai_docs/RELEASE_READINESS.md`

## Overview

Проект переезжает в `europe-west1` (обоснование и замеры — `ai_specs/047-migrate-firebase-region-europe-west1-plan.md`). Сам переезд заблокирован: не утверждено название продукта, а Firebase project ID неизменяем и протекает в пользовательские URL.

Этот план — та часть работы, которая **от названия не зависит и выполняется сейчас**. Все четыре фазы применяются к текущему проекту `sarqyt-1ab95` и остаются корректными при любом финальном имени.

Две фазы снимают риски будущего переезда, две закрывают находки ревью, которые всё равно надо чинить.

**Главное здесь — Phase 1.** Все 20+ вызовов callables идут через `FirebaseFunctions.instance`, который жёстко ходит в `us-central1`. В момент переезда функций каждый такой вызов вернёт `not-found`, и заметить это можно только в рантайме — `flutter analyze` тут молчит. Ключ к безопасности: `FirebaseFunctions.instance` — это в точности `instanceFor(region: 'us-central1')`, поэтому централизацию можно сделать **с сохранением текущего региона**, без изменения поведения, и проверить на работающей системе. Переезд после этого сводится к правке одной константы.

## Context

- **Structure:** feature-first, `lib/src/features/{feature}/{domain,data,application,presentation}` (`ai_toolkit/architecture.md`). Bootstrap-слой — `lib/src/app_bootstrap*.dart`.
- **State management:** Riverpod codegen; сервисы уровня приложения — `@Riverpod(keepAlive: true)`.
- **Точки конструирования `FirebaseFunctions.instance`** (Phase 1): `business_offer_repository.dart:118`, `payment_repository.dart:34`, `orders_repository.dart:88`, `client_orders_repository.dart:66`, `items_repository.dart:113`, `onboarding_repository.dart:38`. Плюс три прямых обращения из виджетов — нарушение `ai_toolkit/architecture.md`: `business_repository.dart:30`, `invite_member_dialog.dart:34`, `add_store_screen.dart:54`.
- **Состояние тестов бэкенда:** 43 теста `functions/test/firestore-rules.test.ts` — **skipped**, 13 интеграционных падают по таймауту без эмулятора. Под `firebase emulators:exec` все 102 зелёные — проверено 2026-08-06 через `./scripts/gate.sh`. В `ci.yml` для functions гоняются только `lint` и `build`.
- **Lint + test command:** `./scripts/gate.sh` (полный гейт: format, analyze, custom_lint, flutter test, functions lint/build, rules+functions под эмулятором). Хук блокирует коммит без свежего зелёного допуска.
- **Assumptions / Gaps:**
  - **G1 (регион в Phase 1):** константа намеренно ставится в `us-central1`, а не в `europe-west1`. Это делает фазу no-op по поведению и безопасной на текущем проекте. Смена значения — в Phase 2 плана 047, одновременно с деплоем функций.
  - **G2 (ручная проверка):** verify Phase 1 включает прогон бронирования на устройстве. Гейт этого не покрывает — callables ходят в живой `us-central1`, в тестах они не вызываются.
  - **G3 (деплой в Phase 3):** `firebase deploy --only storage` меняет правила живого проекта. Шаг выполняется человеком, не автоматикой.

## Plan

### Phase 1 — Централизация региона Cloud Functions на клиенте

**Goal:** Один провайдер вместо 20+ разбросанных `FirebaseFunctions.instance`; регион задан явно и остаётся прежним, поведение не меняется.

- [x] TDD: `test/src/app/firebase_region_test.dart` — регрессия: `FirebaseFunctions.instance` не встречается в `lib/` вне централизованного провайдера; плюс проверка значения `kFunctionsRegion`. _Проверку «провайдер отдаёт инстанс с нужным регионом» реализовать не удалось: `instanceFor()` требует инициализированного Firebase, а `testing.md` запрещает мокать SDK-клиент. Инвариант, ради которого фаза делается, покрыт регрессией._
- [x] `lib/src/app_bootstrap_firebase.dart` — `const kFunctionsRegion = 'us-central1';` + `@Riverpod(keepAlive: true) FirebaseFunctions firebaseFunctions(Ref ref)` → `FirebaseFunctions.instanceFor(region: kFunctionsRegion)`
- [x] Перевести на провайдер: `business_offer_repository.dart`, `payment_repository.dart`, `orders_repository.dart`, `client_orders_repository.dart`, `items_repository.dart`, `onboarding_repository.dart`
- [x] Убрать прямые обращения к SDK из виджетов: `business_repository.dart` (инъекция `FirebaseFunctions`), `invite_member_dialog.dart` → `StoreShipRepository.inviteTeamMember`, `add_store_screen.dart` → `StoreRepository.createAdditionalStore`. Оба виджета больше не импортируют `cloud_functions`; ошибки рендерятся через существующий `humanReadableError`
- [x] `setupEmulators()` — `useFunctionsEmulator` на `instanceFor(region: kFunctionsRegion)`, не на `.instance`
- [x] Verify: `dart run build_runner build --delete-conflicting-outputs` + `./scripts/gate.sh` зелёный + **ручной прогон** (G2). Гейт зелёный на всех тирах; ручной прогон выполнен пользователем 2026-08-08 — поведение на текущем проекте не изменилось.

### Phase 2 — Эмулятор в CI и включение спящих тестов

**Goal:** Закрыть дыру процесса: `deploy.yml` автоматически деплоит `firestore` правила в прод при мёрдже в `main`, а `ci.yml` их не проверяет вообще.

- [x] `.github/workflows/ci.yml` — в джобу `functions-lint` добавлены `actions/setup-java` (эмулятор Firestore — Java-процесс), установка `firebase-tools@^15` и шаг `firebase emulators:exec --only firestore,auth "cd functions && npm test"` с `working-directory: .` (у джобы дефолт `functions`, а `emulators:exec` читает корневой `firebase.json`). Вставлено пользователем 2026-08-08 — каталог `.github/` закрыт агенту на запись; YAML проверен парсером, 8 шагов в нужном порядке
- [x] Проверить, что джоба краснеет при намеренно сломанном правиле — выполнено локально 2026-08-08: временная замена `orders → allow update: if true` дала **2 failed | 100 passed** и код возврата 1 из `emulators:exec`; `firestore.rules` восстановлен из копии, sha256 совпал
- [x] Verify: CI зелёный — **2026-08-15 на PR #21 джоба `functions-lint` прошла за 1m13s: 11 файлов, 102 теста passed, ноль skipped**. Вместе с зелёной локальной проверкой на сломанном правиле это замыкает гейт: правила теперь не уедут в прод непроверенными.

  Первый реальный запуск джобы вскрыл две поломки, невидимые локальному гейту (он работает на готовом `node_modules` и на локальных node/java) — обе починены:
  - [x] `npm ci` падал: `package-lock.json` не содержал top-level `@emnapi/core` / `@emnapi/runtime`. Локальный npm 11 (node 24) резолвит optional-зависимости `@napi-rs/wasm-runtime` иначе, чем npm 10.8 из node 20 в CI. Lock перегенерирован под npm 10.8; `npm ci` чист под обеими версиями, версии прямых зависимостей не изменились
  - [x] `emulators:exec` падал: `firebase-tools no longer supports Java version before 21`, а `setup-java` ставил `17`. Поднято до JDK 21; заодно `node-version` 20 → 22 под `engines.node` из `functions/package.json` — именно этот разрыв версий и породил поломку lock выше. Правку внёс владелец репозитория (`.github/` закрыт агенту на запись)

  **Урок для будущих фаз:** локальный `./scripts/gate.sh` структурно не видит класс поломок, живущих в окружении CI — свежую установку зависимостей и версии node/java. Зелёный гейт не заменяет первый реальный прогон джобы.

### Phase 3 — Лимиты в storage.rules

**Goal:** Закрыть находку ревью: любой участник магазина может залить файл любого размера и типа.

- [ ] `storage.rules` — к `match /stores/{storeId}/items/{fileName}` добавить `request.resource.size < 5 * 1024 * 1024` и `request.resource.contentType.matches('image/.*')`
- [ ] Негативные тесты рядом с существующими rules-тестами: превышение размера и неверный content-type отклоняются
- [ ] Задеплоить в текущий проект: `firebase deploy --only storage` (G3)
- [ ] Verify: загрузка картинки товара из бизнес-приложения работает; загрузка не-изображения отклоняется

### Phase 4 — Явный timeZone у scheduled-функций

**Goal:** Зафиксировать намерение расписаний до переезда, чтобы при смене региона не гадать.

`dailySyncOffers` (`every day 00:30`) задумывался как 06:30 по Алматы — это записано только в комментарии.

- [ ] Проставить `timeZone: "Asia/Almaty"` в опциях scheduled-функций и пересчитать значения `schedule` под локальное время
- [ ] `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` — обновить таблицу расписаний под новые значения
- [ ] Verify: `cd functions && npm run lint && npm run build && npm test`

## Rollback

Весь план откатывается обычным `git revert` — инфраструктура не меняется, кроме правил Storage в Phase 3 (откат — редеплой предыдущей версии `storage.rules` из git).

## Оценка

Phase 1 — день, самая объёмная правка кода, но без изменения поведения. Phase 2 — полдня. Phases 3–4 — полдня суммарно. Итого около двух дней, доступно немедленно.

## См. также

- `ai_specs/047-migrate-firebase-region-europe-west1-plan.md` — сам переезд; заблокирован названием продукта, запускается после этого плана
- `ai_docs/RELEASE_READINESS.md` — блокеры релиза и принятые решения
