---
title: Переезд Firebase в europe-west1
status: in-progress
date: 2026-08-04
updated: 2026-08-06
type: infrastructure
---

# Plan: Переезд Firebase в europe-west1

Source: замеры latency из Казахстана + ревью готовности к релизу — `ai_docs/RELEASE_READINESS.md`

> **Как читать этот файл.** План разбит на два трека. **Трек A** не зависит от названия продукта и выполняется прямо сейчас. **Трек B** заблокирован до утверждения имени, потому что Firebase project ID неизменяем и протекает в пользовательские URL. Порядок внутри треков обязателен, между треками — нет.
>
> Начинаете с чистого контекста? Прочитайте Overview, Context и Phase 0 — там все установленные факты. Затем берите Трек A с первой невыполненной задачи.

## Overview

Firestore проекта `sarqyt-1ab95` фактически находится в **`asia-south1`** (Мумбаи), дефолтный бакет Storage — в **`us-central1`**, callables — в `us-central1`, триггеры и планировщик — в `asia-south1`. Пользователи в Казахстане. Локация Firestore и локация дефолтного бакета Storage **неизменяемы после создания**, поэтому переезд возможен только через новый Firebase-проект.

⚠️ **`firebase.json` врёт:** в нём записано `"firestore": { "location": "nam5" }`, тогда как `gcloud firestore databases describe` показывает `asia-south1`. Поле в `firebase.json` — подсказка для провижининга, а не отражение реальности. Исправляется в B3.

Замеры `time_total` из Казахстана:

| Регион | Время | |
|---|---|---|
| `europe-west1` | **0.433 c** | ← цель |
| `europe-central2` | 0.451 c | |
| `us-central1` | 0.582 c | текущие callables + Storage |
| `asia-south1` | 1.193 c | **текущий Firestore** |

База стоит в худшем из измеренных регионов. Это бьёт не только по callables, но и по всем прямым клиентским чтениям (лента discover, стримы заказов, избранное) — они идут в Мумбаи мимо функций. Ожидаемый выигрыш на основном пользовательском пути — примерно втрое.

Целевое состояние: **один новый проект, всё в `europe-west1`** — Firestore, дефолтный бакет Storage, все функции без исключений. Старый `sarqyt-1ab95` остаётся как dev/staging — попутно закрывается отсутствие разделения окружений.

Главный риск не в данных (их нет), а в том, что **все 20+ вызовов callables используют `FirebaseFunctions.instance`, который жёстко ходит в `us-central1`**. После переезда функций каждый такой вызов вернёт `not-found`, и заметить это можно только в рантайме — `flutter analyze` тут молчит. Снимается в A1.

## Блокировка по названию продукта

Название меняется: `Sarqyt` → предварительно **`Qorzhyn`**. Причина и все факты — в `ai_docs/RELEASE_READINESS.md`, раздел «Бренд». Коротко: `kz.sarqyt.app` занят живым листингом активного конкурента в Google Play, `sarqyt.com` — его же, package name в Play резервируется навсегда.

**Имя не финальное** — требует подтверждения. До подтверждения не выполнять ничего из Трека B.

Пустой проект `sarqyt-prod` создан 2026-08-06 и **подлежит удалению** — в нём нет ни Firestore, ни бакета, удаление бесплатно:

```bash
firebase projects:delete sarqyt-prod
```

## Context

- **Данных для миграции нет** — подтверждено фактом в Phase 0.
- **Что переносится обязательно:** Auth-пользователи с custom claims (`role: partner|admin`, `canCreateStore`) — на них завязаны `firestore.rules` и `assertStoreAccess`.
- **Регионы функций сейчас** (`grep -rn "region" functions/src`):
  - явно `asia-south1`: `on-item-status-changed.ts:15`, `triggers/reviews.ts:6`, `triggers/orders.ts:11`, `on-order-status-changed.ts:41`, `send-order-reminders.ts:13`
  - без региона (→ `us-central1`): все callables + `expireOrders`, `dailySyncOffers`, `cleanupOldData`
- **Точки конструирования `FirebaseFunctions.instance`** (централизуются в A1): `business_offer_repository.dart:118`, `payment_repository.dart:34`, `orders_repository.dart:88`, `client_orders_repository.dart:66`, `items_repository.dart:113`, `onboarding_repository.dart:38`, плюс инлайн в `business_repository.dart:30`, `invite_member_dialog.dart:34`, `add_store_screen.dart:54`.
- **Захардкоженные ссылки на старый проект:** `app_settings_screen.dart` — `https://sarqyt-1ab95.web.app/terms-of-service.html` и `/privacy-policy.html`; `firebase.json` → `projectId`/`appId`; `.firebaserc`; `lib/firebase_options.dart`; `android/app/google-services.json`; `.github/workflows/*` → `projectId: sarqyt-1ab95` и секрет `FIREBASE_SERVICE_ACCOUNT_SARQYT_1AB95`.
- **Lint + test command:** `./scripts/gate.sh` (полный гейт); точечно — `flutter analyze && flutter test --exclude-tags golden && dart run custom_lint`, `cd functions && npm run lint && npm test`.
- **Assumptions / Gaps:**
  - **G1 (класс надёжности) — снят.** Фактическая локация `asia-south1` уже региональная. Переезд идёт регион → регион, SLA не меняется (99.99%).
  - **G2 (`setGlobalOptions`):** `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` запрещает глобальный регион, потому что это сломало бы callables у клиента без `instanceFor(region:)`. После A1 запрет теряет основание и снимается осознанно в B2.
  - **G3 (FCM-токены):** новый проект = новый sender ID, сохранённые `fcmTokenClient`/`fcmTokenBusiness` протухают. Само-восстановление есть: `send-push.ts` удаляет токены по `registration-token-not-registered`. Первый push после переезда каждому устройству не дойдёт.
  - **G4 (Crashlytics):** история крашей не переносится — продовой истории нет.
  - **G5 (закон о локализации ПДн РК):** переезд в ЕС вопрос не решает. Вне плана, но требует ответа юриста до публичного запуска.
  - **G6 (TTL `storeDrafts`):** политика не деплоится через `firebase deploy`, заводится руками — B3.

---

## Phase 0 — Инвентаризация ✅ done (2026-08-04)

**Goal:** Убедиться, что переезд — это пересоздание, а не миграция данных.

- [x] `firebase firestore:databases:list` — единственная БД `(default)`
- [x] `gcloud firestore databases describe` — **локация `asia-south1`**, `FIRESTORE_NATIVE`, `PESSIMISTIC`
- [x] Локации бакетов: `sarqyt-1ab95.firebasestorage.app` → **`US-CENTRAL1`**
- [x] Счётчики коллекций, `firebase auth:export` (3 аккаунта), `gsutil du` (9.43 MiB, 5 объектов)
- [x] **Гейт решения пройден: продовых данных нет, данные не переносим**

**Firestore на 2026-08-04:**

| Коллекция | Документов |
|---|---|
| `orders` | 22 — все терминальные (16 `completed`, 4 `expired`, 2 `cancelled`), все от одного uid, свежайший 2026-07-31 |
| `offers` | 23 |
| `stores` | 2 |
| `users` | 6 |
| `businesses` | 2 |
| `storeShips` | 2 |
| `business_membership` | 1 |
| `items` (collection group) | 4 |
| `reviews` | **0** |
| `storeDrafts`, `payments`, `_processedEvents` | 0 |
| `stripe_customers` | **2** — не описана нигде |

**Auth:** 3 аккаунта. `bahaarmanov88@gmail.com` и `sharipzhan.aki@gmail.com` — оба с claims `{"role":"partner","canCreateStore":true}`; `test@test.com` без claims. Резервная копия с хешами паролей выгружена в scratchpad сессии — **содержит PII, в git не класть**; при необходимости перевыгрузить: `firebase auth:export users.json --project sarqyt-1ab95`.

**Находки:**

1. **`stripe_customers`** — 2 документа с `stripeId`, `stripeLink`, `email`. Остаток удалённой интеграции. Закрыта default-deny (в `firestore.rules` отсутствует). В новый проект не переносить; в старом удалить после переезда.
2. **`users` (6) > Auth-аккаунтов (3)** — три осиротевших профиля. Подтверждает блокер «удаление аккаунта не чистит данные».
3. **`reviews` = 0** — фича отзывов ни разу не проходила end-to-end. Включить «оставить отзыв» в ручной QA B4.

---

# ТРЕК A — не зависит от названия, выполняется сейчас

Ни одна задача трека не трогает project ID, домен и идентификаторы приложений. Всё применяется к текущему проекту `sarqyt-1ab95` и остаётся корректным при любом финальном имени.

### A1 — Централизация Cloud Functions на клиенте (без смены поведения)

**Goal:** Убрать 20+ разбросанных `FirebaseFunctions.instance` в один провайдер. Регион при этом **остаётся `us-central1`** — тот же, что сейчас, поэтому поведение не меняется и это безопасно на текущем проекте.

Ключ: `FirebaseFunctions.instance` — это в точности `instanceFor(region: 'us-central1')`. Делая регион явным, мы превращаем будущий переезд в правку одной константы и убираем самый большой рантайм-риск плана заранее.

- [ ] TDD: `test/src/app/firebase_region_test.dart` — провайдер отдаёт инстанс с регионом из `kFunctionsRegion`; регрессия: `grep -rn "FirebaseFunctions.instance" lib/src` не находит вхождений вне провайдера → затем реализовать
- [ ] `lib/src/app_bootstrap_firebase.dart` — `const kFunctionsRegion = 'us-central1';` с комментарием «меняется на `europe-west1` в B2 одновременно с деплоем функций» + `@Riverpod(keepAlive: true) FirebaseFunctions firebaseFunctions(...)` → `FirebaseFunctions.instanceFor(region: kFunctionsRegion)`
- [ ] Перевести на провайдер: `business_offer_repository.dart:118`, `payment_repository.dart:34`, `orders_repository.dart:88`, `client_orders_repository.dart:66`, `items_repository.dart:113`, `onboarding_repository.dart:38`
- [ ] Убрать инлайн-вызовы из виджетов: `business_repository.dart:30`, `invite_member_dialog.dart:34`, `add_store_screen.dart:54` — прокинуть репозиторий/`ref` (`ai_toolkit/architecture.md`: виджеты не ходят в SDK)
- [ ] `setupEmulators()` — `useFunctionsEmulator` на инстансе из провайдера, не на `.instance`
- [ ] Verify: `dart run build_runner build --delete-conflicting-outputs` + `./scripts/gate.sh` зелёный + ручная проверка, что бронирование и смена статуса заказа работают на текущем проекте **без изменений**

### A2 — Эмулятор в CI и включение спящих тестов

**Goal:** Закрыть самую опасную дыру процесса: `deploy.yml` автоматически деплоит `firestore` правила в прод при мёрдже в `main`, а `ci.yml` их не проверяет вообще.

Сейчас: 43 теста `functions/test/firestore-rules.test.ts` — **skipped**, 13 интеграционных (`cancel-order`, `expire-orders`, `update-order-status`, `reserve-offer`, `complete-merchant-onboarding`) падают по таймауту без эмулятора. Локально воспроизводится: `cd functions && npx vitest run`.

- [ ] Локально: `cd functions && firebase emulators:exec --only firestore "npm test"` — убедиться, что все 102 теста зелёные под эмулятором
- [ ] `.github/workflows/ci.yml` — в джобу `functions-lint` добавить установку `firebase-tools` и заменить шаг на `firebase emulators:exec --only firestore "npm test"` после `npm run build`
- [ ] Проверить, что джоба падает при намеренно сломанном правиле (например, временно разрешить `allow update: if true` на `orders`) — гейт должен ловить
- [ ] Verify: CI зелёный на чистой ветке, красный на сломанном правиле

### A3 — Лимиты в storage.rules

**Goal:** Закрыть находку ревью: любой участник магазина может залить файл любого размера и типа.

- [ ] `storage.rules` — к `match /stores/{storeId}/items/{fileName}` добавить `request.resource.size < 5 * 1024 * 1024` и `request.resource.contentType.matches('image/.*')`
- [ ] Тест в `functions/test/firestore-rules.test.ts` или соседнем storage-тесте: превышение размера и неверный content-type отклоняются
- [ ] Задеплоить в текущий проект: `firebase deploy --only storage`
- [ ] Verify: загрузка картинки товара из бизнес-приложения работает; загрузка не-изображения отклоняется

### A4 — Явный timeZone у scheduled-функций

**Goal:** Зафиксировать намерение расписаний до переезда, чтобы при смене региона не гадать.

`dailySyncOffers` (`every day 00:30`) задумывался как 06:30 по Алматы — это записано только в комментарии. Регион не меняет семантику UTC, но явный `timeZone` убирает двусмысленность.

- [ ] Проставить `timeZone: "Asia/Almaty"` в опциях scheduled-функций и пересчитать значения `schedule` под локальное время
- [ ] `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` — обновить таблицу расписаний под новые значения
- [ ] Verify: `cd functions && npm run lint && npm run build && npm test`

---

# ТРЕК B — заблокирован до утверждения названия

Не начинать, пока имя не подтверждено. Всюду ниже `<name>` — финальное имя в нижнем регистре (например `qorzhyn`).

### B1 — Новый проект и тонкий вертикальный срез

**Goal:** Доказать сквозной путь «клиент в KZ → callable в europe-west1 → Firestore в europe-west1».

- [ ] `firebase projects:delete sarqyt-prod` — удалить пустой проект, созданный под старым именем
- [ ] `firebase projects:create <name>-prod --display-name "<Name>"`
- [ ] `gcloud billing projects link <name>-prod --billing-account=<id>` (Blaze нужен для Functions v2)
- [ ] `gcloud services enable` — firestore, cloudfunctions, run, eventarc, cloudbuild, artifactregistry, storage, identitytoolkit
- [ ] ⚠️ **НЕОБРАТИМО:** `gcloud firestore databases create --location=europe-west1 --type=firestore-native --project=<name>-prod`
- [ ] ⚠️ **НЕОБРАТИМО:** создать бакет явно в нужном регионе — `gcloud storage buckets create gs://<name>-prod.firebasestorage.app --location=europe-west1`, затем привязать к Firebase. Не давать Firebase создать бакет самому: он возьмёт default resource location проекта
- [ ] Включить Auth (email/password), Messaging, Crashlytics
- [ ] `.firebaserc` → алиасы `dev: sarqyt-1ab95`, `prod: <name>-prod`; дефолт оставить `dev`, чтобы случайный `firebase deploy` не уехал в прод
- [ ] Задеплоить **только** `reserveOffer` с `region: "europe-west1"`, создать один `offers/{id}` вручную
- [ ] Собрать dev-билд клиента на временном `firebase_options.dart` от нового проекта, забронировать с физического устройства в KZ
- [ ] Замерить `reserveOffer` до и после, зафиксировать выигрыш в этом файле
- [ ] Verify: заказ создан, время отклика измерено и записано

### B2 — Единый регион: функции и клиент одновременно

**Goal:** Ни одной функции вне `europe-west1`; клиент смотрит туда же. **Оба изменения выкатываются вместе** — рассинхрон ломает все callables.

- [ ] `functions/src/app/firebase.ts` (или `index.ts` до импортов) — `setGlobalOptions({ region: "europe-west1" })`
- [ ] Снять явные `region: "asia-south1"` в `on-item-status-changed.ts:15`, `triggers/reviews.ts:6`, `triggers/orders.ts:11`, `on-order-status-changed.ts:41`, `send-order-reminders.ts:13`
- [ ] `lib/src/app_bootstrap_firebase.dart` — `kFunctionsRegion` → `'europe-west1'` (одна строка, подготовлена в A1)
- [ ] `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` — переписать «Region split»: разнесения больше нет; запрет на `setGlobalOptions` снят и заменён на обратное правило «регион задаётся только глобально, per-function `region` не добавлять»
- [ ] Verify: `firebase functions:list --project prod` показывает `europe-west1` у всех 24 функций; клиентское бронирование работает против нового проекта

### B3 — Правила, индексы, TTL

- [ ] `firebase.json` → `"firestore": { "location": "europe-west1" }` (сейчас неверный `nam5`)
- [ ] Задеплоить `firestore.rules`, `firestore.indexes.json`, `storage.rules` в `prod`; дождаться статуса `Enabled` у композитных индексов
- [ ] Завести TTL-политику на `storeDrafts.expiresAt` в консоли нового проекта (G6) и снять `TODO` в `ai_docs/FIRESTORE_GOTCHAS.md`
- [ ] Verify: `firebase emulators:exec --only firestore "npm test"` зелёный, индексы построены

### B4 — Пользователи, конфиги, ссылки

- [ ] Пользователи: рабочих аккаунтов 2 (оба разработчики). `auth:import` с параметрами scrypt дороже результата — **создать 2 аккаунта заново** и выставить claims `{"role":"partner","canCreateStore":true}` скриптом на admin SDK; `test@test.com` не переносить
- [ ] `flutterfire configure --project=<name>-prod` → пересобрать `lib/firebase_options.dart` и `android/app/google-services.json`
- [ ] `firebase.json` → секция `flutter.platforms`: новые `projectId`/`appId`
- [ ] Задеплоить `public/privacy-policy.html` и `terms-of-service.html` на хостинг нового проекта
- [ ] `app_settings_screen.dart` — заменить захардкоженные `https://sarqyt-1ab95.web.app/...` на новый домен; вынести в константу рядом с прочими внешними URL
- [ ] Verify: `./scripts/gate.sh` + ручной прогон обоих приложений — регистрация, бронирование, смена статуса партнёром, push, **оставить отзыв** (сценарий ни разу не проходил в проде, см. Phase 0)

### B5 — CI/CD и вывод старого проекта из прода

- [ ] Service account в новом проекте → GitHub Secret `FIREBASE_SERVICE_ACCOUNT_<NAME>_PROD`
- [ ] `.github/workflows/deploy.yml` — новый секрет, `--project prod` в аргументах
- [ ] `firebase-hosting-merge.yml` / `firebase-hosting-pull-request.yml` — новый `projectId` и секрет
- [ ] `ai_docs/PROJECT.md` + `EXTERNAL_SERVICES.md` + `RELEASE_READINESS.md` — новый projectId, регион, схема окружений dev/prod
- [ ] Старый `sarqyt-1ab95`: удалить коллекцию `stripe_customers`, отключить прод-алерты биллинга, пометить в README как dev-окружение; **не удалять** минимум месяц
- [ ] Verify: PR-превью и merge-деплой отработали в новый проект

---

## Rollback

Трек A откатывается обычным git revert — он не трогает инфраструктуру, только код и CI.

В треке B до B5 старый проект остаётся полностью рабочим: откат — вернуть `firebase_options.dart`, `google-services.json`, `.firebaserc`, `kFunctionsRegion` и секреты CI из git. После B5 откат тем же путём, но данные, накопленные в новом проекте, придётся переносить руками — поэтому B5 делается последней и только после зелёного ручного QA из B4.

Необратимы ровно два шага: создание Firestore и создание бакета в B1. Всё остальное — конфигурация под git.

## Оценка

| Трек | Объём |
|---|---|
| A1 | день — самая объёмная правка кода, но без изменения поведения |
| A2 | полдня |
| A3, A4 | полдня суммарно |
| B1 | полдня |
| B2–B3 | день |
| B4–B5 | день с прогонами QA |

**Трек A — около двух дней, доступен немедленно.** Трек B — около 2.5 дней после утверждения имени, из них необратимых решений на 10 минут.
