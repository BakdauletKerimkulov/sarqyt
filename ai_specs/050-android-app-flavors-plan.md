---
title: Разделение сборки на flavor'ы client и business
status: in-progress
size: L
date: 2026-09-20
type: refactor
---

# Plan: Разделение сборки на flavor'ы client и business

Source: `ai_specs/050-android-app-flavors-spec.md`

## Overview

Один Dart-пакет → два устанавливаемых рядом Android-приложения. Работа целиком конфигурационная: Gradle product flavors (`client` / `business`) с разными `applicationId`, `namespace = kz.qorzhyn`, пофлейворные `google-services.json` и `firebase_options_*.dart`, пофлейворные иконки и `android:label` через manifest-плейсхолдер. Дефолтный target исчезает вместе с `lib/main.dart`. Кода приложения план не трогает: разделение entry point'ами, роутерами и `PushAudience` уже существует.

Порядок фаз — снизу вверх по риску: Phase 1 доказывает, что Gradle-конфиг собирает оба flavor'а на устройство; всё остальное (Firebase, иконки, CI, доки) навешивается на доказанный каркас.

**Spec:** `ai_specs/050-android-app-flavors-spec.md`

## Context

- **Structure:** feature-first Flutter (`lib/src/features/{feature}/{domain,data,application,presentation}/`); эта работа живёт вне `lib/src/` — в `android/`, корневых entry point'ах, `.github/`, `ai_docs/`.
- **State management:** Riverpod codegen; план провайдеров не касается (`lib/src/app_bootstrap_firebase.dart` вызывается обоими entry point'ами без изменений).
- **Reference implementations:** `lib/main_client.dart` — форма entry point (`Firebase.initializeApp` → `AppBootstrap` → `UncontrolledProviderScope`); `.github/workflows/ci.yml:46-49` (`functions-lint`) — форма явного пина Java.
- **Test seams:** один, существующий — конфигурационный tripwire-тест по файловой системе, образец `test/src/app/firebase_region_test.dart:1-60`. Новых seam'ов спека не требует; поведение приложения не меняется.
- **Testing convention:** `ai_toolkit/testing.md` («Test seams»: набор фиксирован, новый требует письменного обоснования); `test/` зеркалит `lib/`, тест ложится в `test/src/app/`.
- **Lint + test command:** `./scripts/gate.sh` (тир 0: `dart format --output=none --set-exit-if-changed`, `flutter analyze --fatal-infos --fatal-warnings`, `dart run custom_lint`, `flutter test --exclude-tags golden`; тир 1: functions + rules в эмуляторе). Внутри фазы — `./scripts/gate.sh --fast`.
- **Assumptions / Gaps:**
  - ~~**L6/L7 в ledger отсутствуют.**~~ Закрыто 2026-09-20 после Phase 1: записи [L6] и [L7] внесены со `Status: current`, покрытие проставлено в R4, R9, R11 и Out of Scope. Записи реконструированы из текста спеки, а не из стенограммы — пометка о происхождении стоит в ledger над ними.
  - ~~**Статус спеки — `refined`, не `approved`.**~~ Закрыто: спека и план переведены в `in-progress` перед Phase 1.
  - **`flutterfire configure` интерактивен** и требует доступа к Firebase-проекту `sarqyt-1ab95`. Phase 2 не автоматизируется агентом целиком — регистрацию двух Android-приложений выполняет человек.
  - **Иконка бизнес-приложения** — `assets/app-icon-2.png`, рабочий файл, не утверждённый бренд-ассет. Появится настоящая пара — R7 меняет два пути.
  - **Версия Java для сборки APK в `analyze-and-test` — 17** (R9). Соседняя джоба `functions-lint` пинит 21 для эмулятора; расхождение намеренное и не выравнивается в этой спеке.

## Plan

### Phase 1 — Два flavor'а собираются и ставятся рядом
**Goal:** Gradle-конфиг доказан end-to-end: два APK с разными `applicationId` и ярлыками живут на одном устройстве.

- [x] TDD: `test/src/app/flavor_config_test.dart` — `lib/main.dart` отсутствует; `lib/main_business.dart` и `lib/main_client.dart` существуют и указывают `PushAudience.business` / `PushAudience.client` (форма и комментарий-обоснование — по образцу `test/src/app/firebase_region_test.dart`) → затем реализовать
- [x] `lib/main.dart` → `lib/main_business.dart` — переименование без изменения содержимого (импорт `firebase_options` меняется в Phase 2)
- [x] `android/app/build.gradle.kts` — `namespace = "kz.qorzhyn"`; `flavorDimensions += "app"`; `productFlavors` `client` (`applicationId = "kz.qorzhyn.app"`) и `business` (`applicationId = "kz.qorzhyn.business"`); снять `applicationId` с `defaultConfig`; `applicationIdSuffix` не вводить (R13)
- [x] `android/app/src/main/kotlin/kz/qorzhyn/MainActivity.kt` — перенос файла с новым `package`; каталог `android/app/src/main/kotlin/com/example/sarqyt/` удалить
- [x] `android/app/src/main/AndroidManifest.xml:6` — `android:label` через manifest-плейсхолдер, значения задаются в flavor'ах (`Qorzhyn` / `Qorzhyn Business`); второго манифеста не заводить
- [x] Verify: `./scripts/gate.sh` + локально `flutter build apk --debug --flavor client -t lib/main_client.dart` и то же для `business`; `flutter build apk` без флагов падает на неуказанном flavor'е (QA-3)

### Phase 2 — Firebase-конфигурация на flavor
**Goal:** у каждого приложения своя регистрация и свой `firebase_options`; общий файл исчезает.

- [ ] Firebase-проект `sarqyt-1ab95` — зарегистрировать два Android-приложения (`kz.qorzhyn.app`, `kz.qorzhyn.business`); **ручной шаг, выполняет человек**
- [ ] `flutterfire configure --flavor client --out lib/firebase_options_client.dart --android-out android/app/src/client/google-services.json` и симметрично `business`; **`--flavor` обязателен** — без него второй прогон затрёт запись первого в `firebase.json`
- [ ] `lib/main_client.dart`, `lib/main_business.dart` — импорт своего `firebase_options_*.dart`; `lib/firebase_options.dart` и `android/app/google-services.json` удалить с диска
- [ ] `.gitignore` — запись `android/app/google-services.json` заменить на две пофлейворные (`android/app/src/client/`, `android/app/src/business/`)
- [ ] TDD: `test/src/app/flavor_config_test.dart` — ни один `.dart` не импортирует оба `firebase_options_*`; **условная** сверка `package_name` ↔ `applicationId` из `build.gradle.kts`, выполняется только при наличии файла на диске, иначе `skip:` с внятным сообщением; комментарий объясняет, что это единственный механизм сверки в проекте (Google Services Gradle plugin не подключён) → затем реализовать
- [ ] Verify: `./scripts/gate.sh`; `git check-ignore android/app/src/client/google-services.json` утвердительно; `firebase.json` содержит обе записи под `flutter.platforms.android` и два ключа под `flutter.platforms.dart`; тест зелёный и с файлами, и без них

### Phase 3 — Иконки на flavor
**Goal:** два разных ярлыка на устройстве; генерация не задевает web/iOS/macOS/windows.

- [ ] `flutter_launcher_icons-client.yaml` — `image_path: assets/app-icon.png`, `android: "flutter_launcher_icons"`, `ios: false`, `web.generate: false`, `macos.generate: false`, `windows.generate: false`
- [ ] `flutter_launcher_icons-business.yaml` — то же с `assets/app-icon-2.png`; имя ресурса **совпадает** с клиентским, иначе манифест разрешится в оставшийся файл из `main` и оба приложения получат одну иконку
- [ ] `pubspec.yaml:124-136` — секцию `flutter_icons:` удалить
- [ ] `android/app/src/main/res/mipmap-*/flutter_launcher_icons.png` — удалить общий ресурс: пока он в `main`, подмена иконки останется незамеченной до установки
- [ ] Verify: `dart run flutter_launcher_icons` для обоих конфигов создаёт ресурсы в `android/app/src/client/res/` и `android/app/src/business/res/`; `git status` не показывает изменений в `web/`, `ios/`, `macos/`, `windows/`; `./scripts/gate.sh`

### Phase 4 — CI и launch-конфигурации
**Goal:** оба flavor'а собираются на PR; web-workflow'ы и обе launch-конфигурации живут без дефолтного target'а.

- [ ] `.github/workflows/ci.yml` — в джобу `analyze-and-test` добавить `actions/setup-java` (`distribution: temurin`, `java-version: "17"`) **перед** `subosito/flutter-action`, затем две сборки `flutter build apk --debug --flavor {client,business} -t lib/main_{client,business}.dart` после `flutter test`; `google-services.json` в джобу не прокидывается
- [ ] `.github/workflows/firebase-hosting-merge.yml` и `firebase-hosting-pull-request.yml` — `flutter build web -t lib/main_business.dart`
- [ ] `.claude/launch.json:7` — `lib/main.dart` → `lib/main_business.dart` (файл отслеживается git'ом, после Phase 1 сломан в репозитории)
- [ ] `.gitignore` — `!.vscode/launch.json` после строки `.vscode/`, иначе правка R12 невидима ревью
- [ ] `.vscode/launch.json` — четыре конфигурации (Client/Business × Android/Web), каждая с `-t`, Android — ещё и с `--flavor`; существующие `Client (iOS)` и compound `Both: Business (Web) + Client (iOS)` сохранить, добавив `-t`
- [ ] Verify: `./scripts/gate.sh`; зелёный CI на PR (в логе шага сборки JDK 17); превью хостинга открывает бизнес-консоль (QA-4); `grep -c 'lib/main\.dart' .claude/launch.json` = 0

### Phase 5 — Словарь, документация, скрипты
**Goal:** ни один `ai_docs/` не описывает старый порядок сборки; новый термин записан в том же прогоне.

- [x] `ai_docs/GLOSSARY.md` — запись **Qorzhyn** (бренд; ярлыки `Qorzhyn` / `Qorzhyn Business`; `NOT Sarqyt` — прежнее имя, живущее в `package:sarqyt/`, `name:` в `pubspec.yaml` и ключах `appTitle` / `appTitleBusiness` до отдельной спеки); той же правкой развести **бизнес-приложение** (сборка) и **бизнес-консоль** (её web-развёртывание) _(выполнено досрочно по прямой просьбе пользователя после Phase 1; R15 закрыт. Попутно найдена третья формулировка «веб-консоль для бизнеса» в `RELEASE_READINESS.md:24` — выравнивается в рамках R14 ниже)_
- [ ] `ai_docs/RELEASE_READINESS.md` — блокеры 1 и 4 закрыты; название утверждено; схема идентификаторов зафиксирована
- [ ] `ai_docs/EXTERNAL_SERVICES.md` — web собирается явным target'ом; `main.dart` (строка 88) больше не существует
- [ ] `ai_docs/PROJECT.md:24-27` — `main.dart` → `main_business.dart`; команды сборки на flavor
- [ ] `scripts/` — две обёртки для локальной release-сборки APK на flavor (N1, nice-to-have; пропустить, если фаза раздувается)
- [ ] Verify: `./scripts/gate.sh`; `grep -c Qorzhyn ai_docs/GLOSSARY.md` > 0; ревью дифа — ни один из четырёх файлов не описывает старый порядок

### Phase 6 — Ручной QA на устройстве
**Goal:** закрыть то, что файловым тестом и CI не покрывается.

- [ ] QA-1 — обе сборки ставятся рядом: два ярлыка, разные иконки, каждый открывает свой роутер
- [ ] QA-2 — вход под одним аккаунтом в обеих сборках даёт на `users/{uid}` оба поля `fcmTokenClient` / `fcmTokenBusiness` с разными значениями; перевод заказа в `readyForPickup` шлёт пуш в клиентское и не шлёт в бизнесовое
- [ ] QA-5 — `flutter build apk --release` для обоих flavor'ов собирается (подпись остаётся debug-ключом — блокер №2 вне спеки)
- [ ] Старые debug-установки `com.example.sarqyt` удалить с устройств разработчиков вручную
- [ ] Verify: `./scripts/gate.sh` зелёный; Definition of Done спеки пройден по пунктам; спека и ledger указаны в описании PR

## Data layer changes

_None._ Схема Firestore, `firestore.rules` и `firestore.indexes.json` не меняются. Поля `fcmTokenClient` / `fcmTokenBusiness` на `users/{uid}` уже существуют и используются. `kFunctionsRegion` и регион функций — зона плана 047, не этой работы.

## External integrations

- **Firebase `sarqyt-1ab95`** — регистрация двух Android-приложений через `flutterfire configure` (интерактивно, требует доступа к проекту). Регистрации переживают переезд по плану 047: 047 оставляет `sarqyt-1ab95` как dev/staging [L2].
- **FCM** — токен выдаётся на приложение; после смены `applicationId` токены новые, старые записи `fcmToken*` указывают в никуда. Продовых пользователей нет, миграции не требуется; в dev — перелогин.
- **Crashlytics** — отчёты начинают делиться по двум приложениям. Желаемое следствие.

## Risks

- **`flutterfire configure` без `--flavor` затрёт первую запись в `firebase.json`** (сейчас там ровно одна конфигурация на платформу). Митигация: флаг зафиксирован в задаче Phase 2; проверка — обе записи присутствуют после обоих прогонов.
- **Расхождение `package_name` ↔ `applicationId` не ловится ни сборкой, ни рантаймом** — Google Services Gradle-плагин не подключён (осознанное решение ревью). Митигация: условная проверка R11, работающая у разработчика с файлами на диске; на CI слепая зона заявлена явно, а не замаскирована.
- **Разные имена ресурса иконки в двух конфигах** дадут обоим приложениям одну иконку, и это видно только на устройстве. Митигация: имя ресурса зафиксировано как `flutter_launcher_icons` в обоих конфигах + удаление общего mipmap из `main` (Phase 3) + QA-1.
- **JDK в `analyze-and-test` по умолчанию меняется вместе с образом раннера** и с AGP 8.9.1 совпадает не гарантированно. Митигация: явный `actions/setup-java` 17 (Phase 4), форма взята из `ci.yml:46-49`.
- **Время CI**: две debug-сборки APK добавляют минуты. Приемлемо; станет узким местом — сборки выносятся в отдельную параллельную джобу, а не удаляются.
- **Хук `guard-bash.sh` блокирует коммиты при протухшем допуске gate** — каждая фаза коммитится только после зелёного `./scripts/gate.sh`.

## Out of scope

- **Переименование Dart-пакета** `sarqyt` → `qorzhyn`, `name` в `pubspec.yaml`, ключей `appTitle` / `appTitleBusiness` в трёх `.arb`, `web/index.html`, `web/manifest.json` — 243 файла, отдельная спека до публикации в Play [L1].
- **Upload keystore и подпись release-сборки** (блокер №2) — не зависит от flavor'ов, требует работы с секретами.
- **iOS и macOS**: схемы, `xcconfig`, bundle ID остаются как есть [L5]. Нет аккаунта разработчика Apple.
- **Firebase prod-проект `qorzhyn-prod` и переезд региона** — план 047.
- **Клиентская web-сборка и hosting targets** [L4]: клиент остаётся mobile-only.
- **Суффикс `.dev` для отладочных сборок** [L3] — пересматривается с появлением prod-проекта.
- **Подключение `com.google.gms.google-services`** и Crashlytics Gradle-плагина — решение ревью 2026-09-20, возвращается вместе с планом 047.
- **Google Play Console**: аккаунт, листинг, скриншоты, политика конфиденциальности.
- **Разделение репозитория или Dart-пакета** на `apps/` + `packages/core` — около двух третей кода общие, границы ещё двигаются.
