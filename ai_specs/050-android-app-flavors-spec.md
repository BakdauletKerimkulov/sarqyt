---
title: Разделение сборки на flavor'ы client и business
status: in-progress
size: L
date: 2026-09-09
type: refactor
ledger: 050-android-app-flavors-ledger.md
---

# Spec: Разделение сборки на flavor'ы client и business

Source request: «Разделить сборку на два приложения через Android product flavors: client (kz.qorzhyn.app) и business (kz.qorzhyn.business). Один Dart-пакет, два entry point (переименовать lib/main.dart в lib/main_business.dart, чтобы убрать дефолтный target). Отдельные google-services.json на flavor, свои иконки и label. Название бренда утверждено: Qorzhyn. iOS-схемы — опционально/отложено (нет dev-аккаунта). Затронуть CI и скрипты сборки.»

## Goal

Собирать из одного Dart-пакета два независимо устанавливаемых Android-приложения: клиентское `kz.qorzhyn.app` и бизнес-приложение `kz.qorzhyn.business`. Каждое со своей Firebase-регистрацией, иконкой и именем, оба ставятся на одно устройство одновременно и получают пуши в свою аудиторию. Попутно исчезает дефолтный target сборки: `flutter build` без `-t` сейчас молча собирает бизнес-приложение, и это блокер №4 из `ai_docs/RELEASE_READINESS.md`.

Разделения кода спека не делает и не требует: два entry point, два роутера и два корневых виджета уже существуют. Не хватает только разделения на уровне сборки.

## Background

**Stack & conventions.** `ai_toolkit/RULES.md`: код и комментарии на английском, пользовательские строки — через ARB, никогда инлайном в Dart; `.g.dart` не редактируются руками, а перегенерируются. `ai_toolkit/RULES-backend.md`: регион функций берётся из константы проекта, не хардкодится по файлам. Дарт-часть этой работы сводится к перемещению файлов и замене импорта `firebase_options`; правил слоёв (`presentation → application → domain ← data`) она не касается.

**Что уже разделено в коде.** Два entry point: `lib/main.dart` (бизнес, `PushAudience.business`) и `lib/main_client.dart` (клиент, `PushAudience.client`); два корневых виджета `lib/src/app_business.dart` и `lib/src/app_client.dart`; два независимых роутера `lib/src/routing/business_router.dart` (420 строк) и `lib/src/routing/client_router.dart` (273 строки). `features/business_console/` импортируется только из `business_router.dart`, `routing/store_startup.dart` и `onboarding/presentation/welcome/welcome_screen.dart` — перекрёстных зависимостей между клиентским и бизнесовым деревьями нет. `PushAudience` (`lib/src/features/notifications/domain/push_audience.dart`) уже разводит FCM-токены по полям `fcmTokenClient` / `fcmTokenBusiness` на `users/{uid}`, потому что «две сборки делят одного Firebase-пользователя».

**Что не разделено.** `android/app/build.gradle.kts:24` — единственный `applicationId = "com.example.sarqyt"`, `namespace` там же; `android:label="sarqyt"` в `android/app/src/main/AndroidManifest.xml:6`; один `android/app/google-services.json`; один `lib/firebase_options.dart` на оба entry point; `flutter_icons:` в `pubspec.yaml` генерирует одну иконку. Google Play не примет два приложения с одним `applicationId`, а `com.example.*` не примет вообще.

**Чего в сборке нет и не появится в этой спеке.** Google Services Gradle-плагин (`com.google.gms.google-services`) в проекте **не подключён**: `android/app/build.gradle.kts:1-6` объявляет только `com.android.application`, `kotlin-android` и `dev.flutter.flutter-gradle-plugin`, `android/settings.gradle.kts:21-25` — те же три. Поэтому `android/app/google-services.json` сегодня сборкой не читается вообще, а Firebase инициализируется целиком из Dart: `DefaultFirebaseOptions.currentPlatform` в `lib/main.dart:14` и `lib/main_client.dart:14`. Решение 050: **плагин не подключаем** (принято человеком на ревью `/refine` 2026-09-20, записано как [L6]). Следствие, которое надо держать в голове при чтении требований ниже: расхождение `package_name` ↔ `applicationId` не поймает ни одна сборка — единственный, кто его ловит, это тест R11.

**`google-services.json` в git не попадает** (то же решение того же ревью, записано как [L7]). `.gitignore:53-55` держит его в секции `# Platform secrets`, и спека это правило продлевает на пофлейворные пути, а не отменяет. Файлы кладёт себе локально каждый разработчик через `flutterfire configure`; ни сборка, ни CI, ни `flutter test` от их присутствия не зависят.

**Why now.** Название **Qorzhyn** утверждено (`ai_docs/RELEASE_READINESS.md`, раздел «Бренд»: `kz.qorzhyn.app`, `kz.qorzhyn.business`, домены проверены свободными). `applicationId` после первой заливки в Play неизменяем навсегда — до публикации эта работа стоит день, после неё невозможна. Приложение никогда не публиковалось, продовых пользователей нет.

**Отношение к плану 047.** `ai_specs/047-migrate-firebase-region-europe-west1-plan.md` создаёт новый prod-проект в `europe-west1` и оставляет `sarqyt-1ab95` как dev/staging. Регистрации из этой спеки живут в `sarqyt-1ab95` и переезд переживают [L2]; в prod-проекте та же процедура повторяется внутри 047. Спека 050 в prod-проект не ходит и план 047 не разблокирует и не заменяет.

**Известное расхождение, принятое осознанно** [L1]. Ярлык приложения станет `Qorzhyn`, а `package:sarqyt/`, `name: sarqyt` в `pubspec.yaml` и ключи `appTitle` / `appTitleBusiness` в трёх `.arb` останутся прежними до отдельной спеки по переименованию. Внутри UI пользователь увидит «Sarqyt», на ярлыке — «Qorzhyn». Приложение не опубликовано; расхождение живёт ровно до следующей спеки и не является находкой ревью.

## User Flow

Пользователь этой работы — разработчик и (позже) владелец устройства с двумя установленными приложениями.

### Happy path
1. Разработчик запускает `flutter run --flavor client -t lib/main_client.dart` → на устройство ставится «Qorzhyn» с иконкой клиента, открывается `client_router`.
2. Разработчик запускает `flutter run --flavor business -t lib/main_business.dart` → рядом, не заменяя первое, ставится «Qorzhyn Business» с иконкой бизнеса, открывается `business_router`.
3. В обоих приложениях можно войти под одним и тем же аккаунтом; `users/{uid}` получает оба поля токена — `fcmTokenClient` и `fcmTokenBusiness`.
4. Пуш о заказе приходит в то приложение, аудитория которого совпадает: клиентский — в «Qorzhyn», бизнесовый — в «Qorzhyn Business».
5. `flutter build apk --release --flavor client -t lib/main_client.dart` и та же команда с `business` собираются обе.
6. CI на PR собирает оба flavor'а; hosting-workflow собирает web с явным `-t lib/main_business.dart`.

### Alternative flows
- В VS Code разработчик выбирает одну из четырёх конфигураций `.vscode/launch.json`; каждая несёт и `--flavor`, и `-t`.
- Web собирается только для бизнес-консоли и flavor'ов не имеет: `--flavor` на web не применяется, разделение делает `-t` [L4].

### Error & recovery flows
- `flutter build apk` **совсем без флагов** падает на резолве target'а: `Target file "lib/main.dart" not found`. До Gradle дело не доходит, про flavor'ы в сообщении ничего нет. Восстановление — указать и `-t`, и `--flavor`.
- `flutter build apk -t lib/main_business.dart` **без `--flavor`** запускает `assembleDebug`. При заведённых `flavorDimensions` этот таск не производит ни одного варианта, и на чистом `build/` Flutter падает с `Gradle build failed to produce an .apk file`. Сообщение тоже не называет flavor — диагностировать по нему трудно, но молчаливой сборки бизнес-приложения (блокер №4) больше нет. Восстановление — добавить `--flavor`.
- **Та же команда при непустом `build/` — ловушка**: если в `build/app/outputs/flutter-apk/` лежит `app-debug.apk` от досборочной эпохи, Flutter печатает `✓ Built .../app-debug.apk` и завершается успешно, показывая на протухший артефакт с `applicationId = com.example.sarqyt`. Сборка при этом не произошла. Проверено 2026-09-20 в Phase 1: `build/app/outputs/apk/debug/output-metadata.json` содержал старый `applicationId` и дату предыдущей сборки. Восстановление — `flutter clean` или удаление `build/app/outputs/apk/debug/`; профилактика — всегда указывать `--flavor`, что и делает CI (R9).
- `flutter run -t lib/main.dart` падает: файла больше нет. Восстановление — `lib/main_business.dart`.
- Сборка flavor'а, для которого не положен `google-services.json`, **проходит успешно**: плагин не подключён, файл сборкой не читается. Приложение соберётся и запустится — конфигурацию Firebase оно берёт из `firebase_options_*.dart`. Это осознанно принятая слепая зона, а не упущение.
- `package_name` в `google-services.json` разъехался с `applicationId` flavor'а → ни сборка, ни рантайм этого не заметят. Единственный, кто ловит расхождение, — тест R11, и только у разработчика, у которого файлы лежат локально. На CI (файлов нет) эта проверка пропускается — см. R11.

### Edge cases
- **Старые установки.** На устройствах разработчиков остаётся debug-приложение с прежним `com.example.sarqyt` — оно не обновится, а останется третьим ярлыком. Удаляется вручную; в CI неактуально.
- **Первый запуск после смены `applicationId`.** Токен FCM выдаётся новый (он привязан к приложению), старые записи `fcmToken*` в `users/{uid}` указывают на несуществующее приложение. Продовых пользователей нет, миграция не нужна; в dev — перелогин.
- **Оба `firebase_options_*.dart` объявляют класс `DefaultFirebaseOptions`.** Импорт обоих в одном файле — ошибка компиляции. Такой импорт запрещён тестом (R11), а не соглашением.
- **iOS/macOS.** Схем и flavor'ов там нет [L5]; после удаления `lib/main.dart` iOS-сборка требует явный `-t`, иначе падает на отсутствии дефолтного target'а. Это ожидаемо и записано в доках.
- **`flutter test`** flavor'ов не знает и продолжает работать как раньше: тесты не собирают Android-часть.

## Requirements

### Must Have

- [ ] **R1**: `android/app/build.gradle.kts` объявляет измерение `app` и два product flavor'а — `client` с `applicationId = "kz.qorzhyn.app"` и `business` с `applicationId = "kz.qorzhyn.business"`. `defaultConfig` не задаёт `applicationId`. Verifiable by: `./gradlew tasks` показывает `assembleClientDebug` и `assembleBusinessDebug`; тест R11 читает файл и проверяет оба идентификатора. [L1]
- [ ] **R2**: `namespace` модуля — `kz.qorzhyn`; `MainActivity.kt` переезжает в `android/app/src/main/kotlin/kz/qorzhyn/` с соответствующим `package`. Каталог `com/example/sarqyt/` удаляется. Verifiable by: обе сборки запускаются на устройстве и открывают свой роутер; в дереве нет файлов под `com/example`.
- [ ] **R3**: `lib/main.dart` переименован в `lib/main_business.dart` без изменения содержимого, кроме импорта `firebase_options` из R5. Дефолтного target'а в проекте не остаётся. Verifiable by: `lib/main.dart` отсутствует (тест R11); `flutter build web -t lib/main_business.dart` собирается. [L1]
- [ ] **R4**: в Firebase-проекте `sarqyt-1ab95` зарегистрированы два Android-приложения (`kz.qorzhyn.app`, `kz.qorzhyn.business`). Их `google-services.json` лежат локально в `android/app/src/client/` и `android/app/src/business/`, **в git не коммитятся**: `.gitignore` получает обе новые записи взамен старой `android/app/google-services.json`, сам старый файл удаляется с диска. Сборка от этих файлов не зависит (плагин не подключён) — они артефакт на будущее и вход для R11. Verifiable by: `firebase apps:list --project sarqyt-1ab95` показывает оба Android-приложения с нужными `package_name`; `git check-ignore android/app/src/client/google-services.json` отвечает утвердительно; `git status` после `flutterfire configure` чистый. [L2] [L6] [L7]
- [ ] **R5**: `lib/firebase_options_client.dart` и `lib/firebase_options_business.dart` сгенерированы `flutterfire configure` под соответствующие Firebase-приложения; `lib/main_client.dart` и `lib/main_business.dart` импортируют каждый свой; `lib/firebase_options.dart` удалён. Web-конфигурация присутствует только в бизнесовом файле. Каждый вызов идёт с явным `--flavor` (`flutterfire configure --flavor client --out lib/firebase_options_client.dart --android-out android/app/src/client/google-services.json`, и симметрично для `business`): без него второй прогон перезапишет запись первого в `firebase.json`, где сейчас лежит ровно одна конфигурация на платформу (`flutter.platforms.android.default`) и один dart-выход. После обоих прогонов в `firebase.json` присутствуют **обе** записи. Verifiable by: `flutter analyze` зелёный; тест R11 проверяет, что ни один файл не импортирует оба; `firebase.json` содержит `client` и `business` под `flutter.platforms.android` и два ключа под `flutter.platforms.dart`. [L2]
- [ ] **R6**: `android:label` в `android/app/src/main/AndroidManifest.xml` берётся из manifest-плейсхолдера, значение задаётся в flavor'е: `Qorzhyn` для `client`, `Qorzhyn Business` для `business`. Второго `AndroidManifest.xml` на flavor не заводится. Verifiable by: ярлыки на устройстве после установки обеих сборок; `grep` по манифесту не находит строку `sarqyt`.
- [ ] **R7**: иконки задаются пофлейворными конфигами `flutter_launcher_icons-client.yaml` и `flutter_launcher_icons-business.yaml`; секция `flutter_icons:` из `pubspec.yaml` удалена. Клиентская иконка — `assets/app-icon.png`, бизнесовая — `assets/app-icon-2.png`. Каждый конфиг генерирует **только Android**: `ios: false`, `web.generate: false`, `macos.generate: false`, `windows.generate: false`. Причины конкретные: пофлейворным у `flutter_launcher_icons` является вывод Android и iOS, а `web/`, `macos/`, `windows/` пишутся в одно место — второй прогон затёр бы первый; а включённый `ios` создал бы `clientAppIcon.appiconset` и переписал `ASSETCATALOG_COMPILER_APPICON_NAME` в `ios/Runner.xcodeproj`, что прямо запрещено Out of Scope [L5]. Имя ресурса в обоих конфигах — `android: "flutter_launcher_icons"`, ровно как в `android:icon` манифеста, иначе манифест разрешится в оставшийся файл из `main` и **оба приложения получат одну иконку**. Уже закоммиченные `web/icons/Icon-*.png` и `web/favicon.png` остаются как есть: их обслуживает хостинг из R10, перегенерация им не нужна. Verifiable by: `dart run flutter_launcher_icons` создаёт ресурсы в `android/app/src/client/res/` и `android/app/src/business/res/` и ничего не меняет в `web/`, `ios/`, `macos/`, `windows/` (`git status` после прогона); на устройстве два разных ярлыка.
- [ ] **R8**: обе сборки ставятся на одно устройство одновременно и работают независимо; вход под одним аккаунтом даёт на `users/{uid}` оба поля — `fcmTokenClient` и `fcmTokenBusiness`, ни одно не перетирает другое. Verifiable by: ручной сценарий QA-2 ниже.
- [ ] **R9**: `.github/workflows/ci.yml` собирает оба flavor'а (`flutter build apk --debug --flavor client -t lib/main_client.dart` и то же для `business`) в существующей джобе `analyze-and-test` или в отдельной. `google-services.json` джобе не нужен и в неё не прокидывается — плагин не подключён. Джоба получает явный `actions/setup-java` (`distribution: temurin`, `java-version: "17"`) перед `subosito/flutter-action`: это первая Gradle-сборка в `analyze-and-test`, а JDK по умолчанию у `ubuntu-latest` меняется вместе с образом раннера и с AGP 8.9.1 (`android/settings.gradle.kts:23`) совпадает не гарантированно. Соседняя джоба `functions-lint` уже пинит Java явно (`ci.yml:46-49`) — форма берётся оттуда. Verifiable by: зелёный CI на PR этой спеки на чистом checkout'е, без секретов сверх существующего `STADIA_MAPS_API_KEY`; в логе шага сборки версия JDK — 17; намеренно сломанный `applicationId` роняет джобу. [L1] [L6]
- [ ] **R10**: `.github/workflows/firebase-hosting-merge.yml` и `firebase-hosting-pull-request.yml` собирают `flutter build web -t lib/main_business.dart`. Verifiable by: PR-превью хостинга разворачивает бизнес-консоль, как и до спеки. [L4]
- [ ] **R11**: тест-tripwire `test/src/app/flavor_config_test.dart` проверяет по файловой системе: `lib/main.dart` отсутствует; `lib/main_business.dart` и `lib/main_client.dart` существуют и указывают соответственно `PushAudience.business` и `PushAudience.client`; ни один `.dart` не импортирует оба `firebase_options_*`; и — **условно** — `package_name` в `google-services.json` совпадает с `applicationId` своего flavor'а из `build.gradle.kts`. Условность обязательна и не является послаблением: файлы не коммитятся (R4), поэтому на CI и на чистом checkout'е их нет, и безусловная проверка красила бы `flutter test` у всех. Проверка выполняется, когда файл на диске есть, и пропускается через `skip:` с внятным сообщением, когда его нет; отсутствие файла само по себе никогда не красное. Комментарий в тесте объясняет, что именно эта проверка — единственный механизм сверки во всём проекте, потому что Google Services Gradle plugin не подключён. Verifiable by: тест зелёный и с файлами, и без них; правка любого из трёх безусловных фактов делает его красным; подмена `package_name` при наличии файлов делает его красным. [L6] [L7]
- [ ] **R12**: `.vscode/launch.json` содержит четыре конфигурации — Client (Android), Business (Android), Client (Web), Business (Web) — каждая с `-t` и, для Android, с `--flavor`. Существующие `Client (iOS)` и compound `Both: Business (Web) + Client (iOS)` сохраняются с добавленным `-t`: iOS по [L5] остаётся рабочим, и молча выкидывать его конфигурацию спека не уполномочена. Чтобы требование вообще попало в PR и было проверяемо, `.gitignore` перестаёт игнорировать этот один файл (`!.vscode/launch.json` после строки `.vscode/`) — сейчас `.gitignore:60-61` прячет каталог целиком, и правка была бы невидима ревью, хотя [L1] прямо включает `.vscode/launch.json` в состав изменения. Verifiable by: файл виден в дифе PR; запуск каждой конфигурации из VS Code ставит ожидаемое приложение.
- [ ] **R12a**: `.claude/launch.json:7` переведён с `lib/main.dart` на `lib/main_business.dart`. Файл **отслеживается git'ом** (в отличие от `.vscode/`), поэтому после R3 он ломается прямо в репозитории. Verifiable by: `grep -c 'lib/main\.dart' .claude/launch.json` = 0; конфигурация `business-web` поднимает бизнес-консоль.
- [ ] **R13**: применяется ровно два `applicationId`; `buildTypes` их не модифицируют (`applicationIdSuffix` не используется). Verifiable by: `grep -c applicationIdSuffix android/app/build.gradle.kts` = 0. [L3]
- [ ] **R14**: документация обновлена в этом же изменении: `ai_docs/RELEASE_READINESS.md` (блокеры 1 и 4 закрыты, название утверждено, схема идентификаторов зафиксирована), `ai_docs/EXTERNAL_SERVICES.md` (web собирается явным target'ом; `main.dart` в строке 88 больше не существует), `ai_docs/PROJECT.md` (строки 24-27: `main.dart` → `main_business.dart`, команды сборки на flavor), `ai_docs/GLOSSARY.md` (новый долгоживущий термин **Qorzhyn**). Verifiable by: ревью дифа — ни один из четырёх файлов не описывает старый порядок сборки.
- [ ] **R15**: `ai_docs/GLOSSARY.md` получает запись `Qorzhyn` — бренд; ярлыки приложений `Qorzhyn` / `Qorzhyn Business`; `NOT Sarqyt` как прежнее имя, которое до отдельной спеки остаётся в `package:sarqyt/`, `name:` в `pubspec.yaml` и ключах `appTitle` / `appTitleBusiness`. Записывается в этом же прогоне, а не откладывается: `command-conventions.md:85` (C10) и раздел docs-sync в `ai_toolkit/RULES.md` требуют именно этого, и расхождение «ярлык Qorzhyn / `appTitle` Sarqyt» [L1] — ровно то, что словарь обязан объяснять, пока оно живёт. Той же правкой фиксируется разница между «бизнес-приложением» (сборка, уже канонизировано в `GLOSSARY.md:49`) и «бизнес-консолью» (её web-развёртывание; так называются `lib/src/features/business_console/` и `RELEASE_READINESS.md:14`) — сейчас словарь второго слова не знает, а спека и код используют оба. Verifiable by: `grep -c Qorzhyn ai_docs/GLOSSARY.md` > 0; оба термина имеют по одному определению и не конкурируют.

### Nice to Have
- [ ] **N1**: `scripts/` получает две обёртки для локальной сборки release-APK на flavor, чтобы длинные команды не набирались руками.

### Non-functional
- Время CI: две debug-сборки APK добавляют минуты к джобе. Приемлемо; если станет узким местом — сборки выносятся в отдельную джобу, идущую параллельно тестам, а не удаляются.
- Локализация: спека не добавляет и не меняет ни одного ARB-ключа. `android:label` — не пользовательская строка в смысле `RULES.md`, а метаданные пакета.
- Обратимость: всё, кроме регистрации Firebase-приложений, обратимо правкой файлов. Регистрации в Firebase удаляемы, но `applicationId` в Google Play после первой заливки — нет; заливки в рамках этой спеки не происходит.

## Technical Constraints

**Files to create:**
- `lib/main_business.dart` — переименованный `lib/main.dart`.
- `lib/firebase_options_client.dart`, `lib/firebase_options_business.dart` — вывод `flutterfire configure`, руками не правятся.
- `android/app/src/client/google-services.json`, `android/app/src/business/google-services.json` — вывод `flutterfire configure --flavor <name> --android-out=...`. Создаются локально, **в git не попадают** (R4).
- `android/app/src/main/kotlin/kz/qorzhyn/MainActivity.kt` — перемещённый файл.
- `flutter_launcher_icons-client.yaml`, `flutter_launcher_icons-business.yaml`.
- `test/src/app/flavor_config_test.dart` — tripwire из R11.

**Files to modify:**
- `android/app/build.gradle.kts` — `namespace`, `flavorDimensions`, `productFlavors`, снятие `applicationId` с `defaultConfig`.
- `android/app/src/main/AndroidManifest.xml:6` — `android:label` через плейсхолдер.
- `lib/main_client.dart` — импорт `firebase_options_client.dart`.
- `pubspec.yaml` — удаление секции `flutter_icons:`.
- `firebase.json` — секция `flutter.platforms` перезаписывается `flutterfire configure`; вручную не редактируется.
- `.github/workflows/ci.yml`, `firebase-hosting-merge.yml`, `firebase-hosting-pull-request.yml`.
- `.vscode/launch.json` (R12), `.claude/launch.json` (R12a — этот отслеживается git'ом).
- `.gitignore` — две пофлейворные записи `google-services.json` взамен старой (R4); снятие игнора с `.vscode/launch.json` (R12).
- `ai_docs/RELEASE_READINESS.md`, `ai_docs/EXTERNAL_SERVICES.md`, `ai_docs/PROJECT.md`, `ai_docs/GLOSSARY.md`.

**Files to delete:**
- `lib/main.dart`, `lib/firebase_options.dart`, `android/app/google-services.json` (с диска; в git его и не было), `android/app/src/main/kotlin/com/example/sarqyt/MainActivity.kt`.
- `android/app/src/main/res/mipmap-*/flutter_launcher_icons.png` — старый общий ресурс иконки. Пока он лежит в `main`, манифест разрешится в него для любого flavor'а, у которого генерация не сработала, и подмена останется незамеченной до установки на устройство (R7).

**Patterns to follow (with citations):**
- `test/src/app/firebase_region_test.dart` — образец конфигурационного tripwire-теста: сканирует `lib/` по файловой системе, объясняет в комментарии, *почему* проверка не тавтология. Тест R11 пишется в этой же форме и в том же каталоге.
- `lib/main_client.dart` — форма entry point (`Firebase.initializeApp` → `AppBootstrap` → `UncontrolledProviderScope`). `main_business.dart` её сохраняет; менять состав bootstrap'а спека не разрешает.
- `.github/workflows/ci.yml:8-33` — форма Flutter-джобы (создание `.env` до `build_runner`); сборки flavor'ов встают после `flutter test` и требуют того же `.env`.
- `lib/src/features/notifications/domain/push_audience.dart` — источник имён `client` / `business`. Имена flavor'ов повторяют члены этого enum'а, а не изобретают свои.

**Anti-patterns / avoid:**
- **Не заводить второй `AndroidManifest.xml` в `src/client/` и `src/business/`** ради разных `android:label`. Два манифеста расходятся: разрешение или meta-data, добавленные в один, тихо отсутствуют во втором. Плейсхолдер решает ту же задачу одной строкой.
- **Не вводить runtime-флаг** вида `String.fromEnvironment('flavor')` или `--dart-define` для выбора приложения. Разделение уже сделано entry point'ами; второй механизм даст два источника истины о том, какое это приложение.
- **Не объединять** `firebase_options_client.dart` и `firebase_options_business.dart` в один файл с двумя классами и не редактировать сгенерированный вывод.
- **Не трогать** `kFunctionsRegion`, `firestore.rules`, `firestore.indexes.json`, схему Firestore и Cloud Functions — регион и правила меняет план 047.
- **Не переименовывать** `package:sarqyt/`, `name` в `pubspec.yaml` и ключи `.arb` [L1] и не удалять `lib/main_fakes_client.dart`.
- **Не чинить попутно** блокер №2 (release подписан debug-ключом) — это отдельная работа, смешивать её с flavor'ами значит смешивать секрет с конфигом.

**Data layer changes:** нет. Схема Firestore, правила и индексы не меняются. Поля `fcmTokenClient` / `fcmTokenBusiness` уже существуют и используются.

**External integrations:** Firebase-проект `sarqyt-1ab95` — регистрация двух Android-приложений через `flutterfire configure` (интерактивная операция, требует доступа к проекту). FCM выдаёт токены на каждое приложение отдельно. Crashlytics начинает разделять отчёты по двум приложениям — это желаемое следствие, а не побочный эффект.

## Out of Scope

- **Переименование Dart-пакета** `sarqyt` → `qorzhyn`, `name` в `pubspec.yaml`, ключей `appTitle` / `appTitleBusiness` в трёх `.arb`, `web/index.html`, `web/manifest.json` — 243 файла, отдельный класс риска, отдельная спека до публикации в Play [L1].
- **Upload keystore и подпись release-сборки** (блокер №2 в `RELEASE_READINESS.md`) — не зависит от flavor'ов, требует работы с секретами.
- **iOS и macOS**: схемы, `xcconfig`, bundle ID остаются как есть [L5]. Нет аккаунта разработчика Apple; целевая платформа релиза — Android плюс бизнес-консоль.
- **Firebase prod-проект `qorzhyn-prod` и переезд региона** — план 047, заблокирован отдельно.
- **Клиентская web-сборка и hosting targets** [L4]: клиент остаётся mobile-only, как записано в `ai_docs/EXTERNAL_SERVICES.md`.
- **Суффикс `.dev` для отладочных сборок** [L3] — пересматривается, когда появится prod-проект.
- **Подключение `com.google.gms.google-services`** и Crashlytics Gradle-плагина. Решение ревью 2026-09-20: не в этой спеке. Цена решения названа прямо — сверки `package_name` ↔ `applicationId` на сборке нет, её заменяет условная проверка в R11. Вопрос возвращается вместе с prod-проектом (план 047) или когда понадобится нативный Crashlytics с символикацией. [L6]
- **Google Play Console**: аккаунт, листинг, скриншоты, политика конфиденциальности.
- **Разделение репозитория или Dart-пакета** на `apps/` + `packages/core`: около двух третей кода (12 933 строки `data/` + `domain/`, плюс `common_widgets`, `constants`, `localization`) общие, границы ещё двигаются — бизнес-консоль готова на 65%. Вопрос возвращается, когда консоль стабилизируется.

## Validation

**Test seams.** Автоматизируемая часть этой работы — конфигурация, поэтому seam здесь один и он существующий: **конфигурационный tripwire-тест по файловой системе**, ровно как `test/src/app/firebase_region_test.dart`, который уже сканирует `lib/` и падает, когда конфиг разъезжается с намерением. Никаких новых моков и никакого нового seam'а спека не требует; поведение приложения не меняется, поэтому провайдер-оверрайды и fakes-контейнер здесь неприменимы. Всё, что файловым тестом не покрывается (реальная сборка Gradle, установка рядом, доставка пушей), покрывается сборкой в CI и ручными сценариями ниже — и это заявлено честно, а не замаскировано тестом-тавтологией.

**Automated tests:**
- Конфигурация: `test/src/app/flavor_config_test.dart` — три безусловные проверки из R11 (отсутствие `lib/main.dart`; пара entry point ↔ `PushAudience`; запрет импортировать оба `firebase_options_*`) плюс четвёртая, условная: совпадение `package_name` в обоих `google-services.json` с `applicationId` из `build.gradle.kts`, выполняется только при наличии файлов на диске.
- Регрессия существующего: `flutter test --exclude-tags golden` остаётся зелёным без правок в остальных тестах. Правка чужого теста ради этой спеки — сигнал, что задето лишнее.
- Сборка: джоба CI из R9 — единственное, что доказывает работоспособность Gradle-конфига.

**Manual QA scenarios:**
1. **QA-1 (установка рядом).** Given чистое устройство, when выполнены `flutter run --flavor client -t lib/main_client.dart` и затем `flutter run --flavor business -t lib/main_business.dart`, then на устройстве два ярлыка — «Qorzhyn» и «Qorzhyn Business» — с разными иконками, каждый открывает своё приложение, ни один не заменил другой.
2. **QA-2 (пуши по аудиториям).** Given обе сборки установлены и в обеих выполнен вход под одним аккаунтом, when открыт документ `users/{uid}`, then в нём заполнены оба поля — `fcmTokenClient` и `fcmTokenBusiness`, значения различаются; when заведение переводит заказ в `readyForPickup`, then уведомление приходит в клиентское приложение и не приходит в бизнесовое.
3. **QA-3 (нет дефолтного target'а).** Given рабочее дерево после изменений и **чистый `build/`** (`flutter clean`), when выполнено `flutter build apk` без флагов, then сборка падает на `Target file "lib/main.dart" not found`; when выполнено `flutter build apk -t lib/main_business.dart` без `--flavor`, then сборка падает на `Gradle build failed to produce an .apk file`. Ни один из двух случаев не собирает бизнес-приложение молча — это и есть закрытый блокер №4. Чистый `build/` в предусловии обязателен: без него второй случай даёт ложный успех на протухшем `app-debug.apk` (см. Error flows).
4. **QA-4 (бизнес-консоль).** Given PR с этими изменениями, when отработал `firebase-hosting-pull-request.yml`, then превью открывает бизнес-консоль, как и до спеки.
5. **QA-5 (release-сборки).** Given настроенный SDK, when выполнены `flutter build apk --release` для обоих flavor'ов, then оба APK собираются (подпись остаётся debug-ключом — блокер №2 вне спеки).

**Expected behavior under edge conditions:**
- Отсутствует `google-services.json` у flavor'а → сборка проходит: плагин не подключён, файл в неё не входит. Условная проверка R11 при этом пропускается.
- `package_name` разъехался с `applicationId` → красный `flutter test` (R11) у разработчика с файлами на диске. На CI не ловится ничем — принятая слепая зона решения «плагин не подключаем».
- Собирают без `--flavor` на чистом `build/` → `Gradle build failed to produce an .apk file`. Падение есть, но flavor в сообщении не назван: это заменённое поведение блокера №4, а не удобная диагностика.
- Собирают без `--flavor` при непустом `build/` → ложный успех на протухшем `app-debug.apk`. Единственная оставшаяся дыра блокера №4; на CI закрыта явным `--flavor` (R9), локально — только дисциплиной и `flutter clean`.
- Собирают `-t lib/main.dart` → файла нет, внятная ошибка Flutter.

## Открытые вопросы

- **Закрыто 2026-09-20.** Два решения того же ревью — (а) `com.google.gms.google-services` не подключаем, (б) `google-services.json` не коммитим — записаны в ledger как [L6] и [L7] со `Status: current` и покрыты в R4, R9, R11 и Out of Scope. Записи внесены постфактум и реконструированы из этой спеки, а не из стенограммы: пометка о происхождении стоит в самом ledger над ними.
- **Иконка бизнес-приложения.** `assets/app-icon-2.png` существует, но это рабочий файл, а не утверждённый бренд-ассет под именем Qorzhyn. Если до релиза появится настоящая пара иконок, R7 меняет два пути и больше ничего.

## Definition of Done

- [ ] Все Must Have (R1–R15, включая R12a) выполнены и проверены названным способом
- [ ] `./scripts/gate.sh` зелёный (format, analyze, custom_lint, test, functions, rules)
- [ ] CI собирает оба flavor'а; hosting-workflow собирает web с явным target'ом
- [ ] QA-1…QA-5 пройдены на реальном Android-устройстве
- [ ] Два Android-приложения зарегистрированы в `sarqyt-1ab95`; оба `google-services.json` лежат локально и заигнорены — в дифе PR их нет
- [ ] `ai_docs/RELEASE_READINESS.md`, `EXTERNAL_SERVICES.md`, `PROJECT.md`, `GLOSSARY.md` обновлены в этом же PR
- [ ] Новых предупреждений линта нет; диффа за пределами Out of Scope нет
- [ ] Спека и ledger указаны в описании PR
