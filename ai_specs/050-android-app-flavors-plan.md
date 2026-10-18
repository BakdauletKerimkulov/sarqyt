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
  - **У `flutterfire_cli 1.3.1` нет флага `--flavor`** (обнаружено 2026-09-27 при разблокировке Phase 2). Пофлейворность задаётся путями вывода: `--out` определяет ключ в `firebase.json` под `flutter.platforms.dart`, `--android-out` — ключ `src/<flavor>` под `flutter.platforms.android.buildConfigurations`. Риск «второй прогон затрёт первый» этим и закрыт; формулировки R5 и задачи Phase 2 в спеке всё ещё называют `--flavor` — расхождение в тексте, не в поведении.
  - **Прогон с `ios` в `--platforms` лезет за границы спеки** и его правки приходится откатывать вручную. Клиентский прогон 2026-09-27 дополнительно: добавил `com.google.gms.google-services` и `com.google.firebase.crashlytics` в `android/app/build.gradle.kts` и `android/settings.gradle.kts` (прямо запрещено [L6]); добавил `GoogleService-Info.plist` и build phase `FlutterFire: upload-crashlytics-symbols` в `ios/Runner.xcodeproj/project.pbxproj` ([L5]); переписал `firebase.json` в одну строку и поднял `uploadDebugSymbols` в `true`. Все четыре правки откачены (решение пользователя 2026-09-27), от прогона оставлены только `lib/firebase_options_client.dart`, `android/app/src/client/google-services.json` и запись `ios` под dart-ключом клиента. Следующий прогон здесь — со снапшотом этих файлов до старта.
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

- [x] Firebase-проект `sarqyt-1ab95` — зарегистрировать два Android-приложения (`kz.qorzhyn.app`, `kz.qorzhyn.business`); **ручной шаг** — выполнен человеком 2026-09-20
- [x] `flutterfire configure --out lib/firebase_options_client.dart --android-out android/app/src/client/google-services.json --platforms=android,ios` и симметрично `business` (`--platforms=android,web`); запись в `firebase.json` не затирается, потому что ключ берётся из пути вывода (`src/client` / `src/business`, `flutter.platforms.dart.<путь>`) _(поправка к формулировке задачи: у установленного `flutterfire_cli 1.3.1` **нет флага `--flavor`** — flavor выражается через `--out` / `--android-out`; см. Assumptions. Клиентский прогон 2026-09-27 вернул iOS-конфигурацию в `lib/firebase_options_client.dart` (`ios:c061…`, bundle `com.example.sarqyt`), бизнесовый остался android+web по решению пользователя. Побочные правки прогона откачены как Out of scope — см. Assumptions.)_
- [x] `lib/main_client.dart`, `lib/main_business.dart` — импорт своего `firebase_options_*.dart`; `lib/firebase_options.dart` и `android/app/google-services.json` удалить с диска
- [x] `.gitignore` — запись `android/app/google-services.json` заменить на две пофлейворные (`android/app/src/client/`, `android/app/src/business/`)
- [x] TDD: `test/src/app/flavor_config_test.dart` — ни один `.dart` не импортирует оба `firebase_options_*`; **условная** сверка `package_name` ↔ `applicationId` из `build.gradle.kts`, выполняется только при наличии файла на диске, иначе `skip:` с внятным сообщением; комментарий объясняет, что это единственный механизм сверки в проекте (Google Services Gradle plugin не подключён) → реализовано (проверка «не импортирует оба» прошла сразу: импорты разведены предыдущей задачей)
- [x] Verify: `./scripts/gate.sh`; `git check-ignore android/app/src/client/google-services.json` утвердительно; `firebase.json` содержит обе записи под `flutter.platforms.android` и два ключа под `flutter.platforms.dart`; тест зелёный и с файлами, и без них _(все четыре проверки пройдены 2026-09-27: гейт зелёный по всем тирам после одного круга (сгенерированный файл не был `dart format`-чистым); `check-ignore` отвечает обеими строками `.gitignore:57-58`; `firebase.json` содержит обе android-записи и оба dart-ключа, у клиентского теперь `android` + `ios`; тест — 6 зелёных с файлами на диске, 4 зелёных + 2 `skip` без них)_

### Phase 3 — Иконки на flavor
**Goal:** два разных ярлыка на устройстве; генерация не задевает web/iOS/macOS/windows.

- [x] `flutter_launcher_icons-client.yaml` — `image_path: assets/app-icon.png`, `android: "flutter_launcher_icons"`, `ios: false`, `web.generate: false`, `macos.generate: false`, `windows.generate: false` _(ключ верхнего уровня — `flutter_launcher_icons:`, не `flutter_icons:`: последний в отдельном файле у 0.14.4 deprecated и печатает warning)_
- [x] `flutter_launcher_icons-business.yaml` — то же с `assets/app-icon-2.png`; имя ресурса **совпадает** с клиентским, иначе манифест разрешится в оставшийся файл из `main` и оба приложения получат одну иконку
- [x] `pubspec.yaml:124-136` — секцию `flutter_icons:` удалить _(она и так перестала читаться: при наличии `flutter_launcher_icons-*.yaml` пакет уходит в ветку flavor'ов и конфиг из `pubspec.yaml` игнорирует целиком — `flutter_launcher_icons-0.14.4/lib/main.dart:72-125`)_
- [x] `android/app/src/main/res/mipmap-*/flutter_launcher_icons.png` — удалить общий ресурс: пока он в `main`, подмена иконки останется незамеченной до установки _(удалены все пять плотностей. Рядом в тех же каталогах остались `flutter_icons.png` и `ic_launcher.png` — мусор от прежних прогонов, манифестом не используется; не трогал, чтобы не чинить попутно)_
- [x] Verify: `dart run flutter_launcher_icons` для обоих конфигов создаёт ресурсы в `android/app/src/client/res/` и `android/app/src/business/res/`; `git status` не показывает изменений в `web/`, `ios/`, `macos/`, `windows/`; `./scripts/gate.sh` _(прогон без `-f` сам нашёл оба конфига по маске `flutter_launcher_icons-(.*).yaml` и отработал по каждому flavor'у; по пять mipmap-плотностей в каждом каталоге, хеши клиентской и бизнесовой иконки различаются; `git status` до и после прогона отличается только двумя новыми каталогами — `web/`, `macos/`, `windows/` не тронуты, изменения в `ios/` — из работы до этой фазы)_

### Phase 4 — CI и launch-конфигурации
**Goal:** оба flavor'а собираются на PR; web-workflow'ы и обе launch-конфигурации живут без дефолтного target'а.

- [x] `.github/workflows/ci.yml` — в джобу `analyze-and-test` добавить `actions/setup-java` (`distribution: temurin`, `java-version: "17"`) **перед** `subosito/flutter-action`, затем две сборки `flutter build apk --debug --flavor {client,business} -t lib/main_{client,business}.dart` после `flutter test`; `google-services.json` в джобу не прокидывается _(применено человеком, коммит `f6f5f44`; на PR #21 `analyze-and-test` зелёный, обе debug-APK собраны, в логе `JAVA_HOME: …/Java_Temurin-Hotspot_jdk/17.0.20-1/x64`. Агенту `.github/workflows/` по-прежнему закрыт правами и хуком)_
- [x] `.github/workflows/firebase-hosting-merge.yml` и `firebase-hosting-pull-request.yml` — `flutter build web -t lib/main_business.dart` _(применено человеком 2026-10-11; агенту `.github/workflows/` закрыт правами и хуком. Проверено: `grep -rn 'flutter build web' .github/workflows/` даёт две строки, обе с `-t`. Деплой бизнес-консоли, сломанный с момента переименования `lib/main.dart`, этим починен)_

<details>
<summary><b>Готовый диф для двух заблокированных задач выше</b> (правит человек: <code>.github/workflows/</code> закрыт для агента permission settings и хуком <code>guard-edits.sh</code>)</summary>

```diff
--- a/.github/workflows/ci.yml
+++ b/.github/workflows/ci.yml
@@ -12,6 +12,13 @@ jobs:
         steps:
             - uses: actions/checkout@v4
 
+            # JDK по умолчанию едет вместе с образом раннера и с AGP 8.9.1
+            # совпадает не гарантированно. Форма пина — как в functions-lint
+            # ниже, версия другая: там 21 для эмулятора, здесь 17 для AGP.
+            - uses: actions/setup-java@v4
+              with:
+                  distribution: temurin
+                  java-version: "17"
+
             - uses: subosito/flutter-action@v2
               with:
                   channel: stable
@@ -27,3 +34,10 @@ jobs:
             - run: flutter analyze --no-fatal-warnings
 
             - run: flutter test --exclude-tags golden
+
+            # Дефолтного target'а в проекте нет: обе сборки обязаны называть
+            # свой -t и свой --flavor. google-services.json в джобу не
+            # прокидывается — плагин не подключён, сборка от него не зависит [L6].
+            - run: flutter build apk --debug --flavor client -t lib/main_client.dart
+
+            - run: flutter build apk --debug --flavor business -t lib/main_business.dart
--- a/.github/workflows/firebase-hosting-merge.yml
+++ b/.github/workflows/firebase-hosting-merge.yml
@@ -19,7 +19,7 @@ jobs:
       - name: Create .env for envied codegen
         run: echo 'STADIA_MAPS_API_KEY=${{ secrets.STADIA_MAPS_API_KEY }}' > .env
       - run: dart run build_runner build --delete-conflicting-outputs
-      - run: flutter build web
+      - run: flutter build web -t lib/main_business.dart
       - uses: FirebaseExtended/action-hosting-deploy@v0
--- a/.github/workflows/firebase-hosting-pull-request.yml
+++ b/.github/workflows/firebase-hosting-pull-request.yml
@@ -21,7 +21,7 @@ jobs:
       - name: Create dummy .env for envied codegen
         run: ...
       - run: dart run build_runner build --delete-conflicting-outputs
-      - run: flutter build web
+      - run: flutter build web -t lib/main_business.dart
```

Порядок применения: **сначала** два hosting-workflow'а — после удаления `lib/main.dart` обе джобы падают на отсутствующем дефолтном target'е, то есть деплой бизнес-консоли сломан в `main` независимо от этой ветки (отмечено в `ai_docs/EXTERNAL_SERVICES.md` и в блокере 4 `ai_docs/RELEASE_READINESS.md`). Пин JDK и сборки APK — вторым шагом, они только добавляют покрытие.

</details>
- [x] `.claude/launch.json:7` — `lib/main.dart` → `lib/main_business.dart` (файл отслеживается git'ом, после Phase 1 сломан в репозитории) _(`grep -c 'lib/main\.dart' .claude/launch.json` = 0)_
- [x] `.gitignore` — `!.vscode/launch.json` после строки `.vscode/`, иначе правка R12 невидима ревью _(одного `!` не хватило: при `.vscode/` git отсекает обход каталога целиком и отрицание внутри него не действует — строка исключения заменена на `.vscode/*`. Проверено: `git check-ignore -q .vscode/launch.json` → 1 (виден), для `.vscode/settings.json` → 0 (по-прежнему скрыт))_
- [ ] `.vscode/launch.json` — четыре конфигурации (Client/Business × Android/Web), каждая с `-t`, Android — ещё и с `--flavor`; существующие `Client (iOS)` и compound `Both: Business (Web) + Client (iOS)` сохранить, добавив `-t` _blocked: правка внесена, но названная в R12 проверка — «запуск каждой конфигурации из VS Code ставит ожидаемое приложение» — выполняется человеком, агент её провести не может. Форма конфигураций: точку входа в Dart-Code задаёт `program` (не `-t`), аргументы flutter-тула — `toolArgs` (не `args`: там аргументы самого приложения), устройство — `deviceId`. У web-конфигураций `deviceId: chrome` — настоящий id устройства; у Android-конфигураций устройство не фиксируется вовсе: `-d android` ничему не соответствует (flutter резолвит `-d` по точному или префиксному совпадению id/имени, серийник `emulator-5554` с «android» не начинается), и штатный путь — устройство, выбранное в VS Code. Первая версия этой правки положила `-d` и `--flavor` в `args`, где они до `flutter run` не доезжают — поймано ревью, исправлено. Попутно выяснилось, что прежние `"args": ["-d", "chrome"]` в этом файле не действовали никогда. `Business (Web)` переведён с `lib/main.dart`, добавлена недостающая `Business (Android)`; `Client (iOS)` и compound сохранены._
- [x] Verify: `./scripts/gate.sh`; зелёный CI на PR (в логе шага сборки JDK 17); превью хостинга открывает бизнес-консоль (QA-4); `grep -c 'lib/main\.dart' .claude/launch.json` = 0 _(все четыре условия выполнены; первые три — 2026-10-11. Гейт зелёный, `grep` = 0. **QA-4:** после правки hosting-workflow'ов (коммит `1b95dbb`) все чеки PR #21 зелёные, включая `build_and_preview` и `Deploy Preview` — превью развёрнуто на https://sarqyt-1ab95--pr21-chore-release-audit-xng9zmcw.web.app (истекает 2026-10-17). Это доказывает, что бизнес-консоль собирается явным `-t` и публикуется; визуально страницу ещё никто не открывал. **JDK 17 в логе** подтверждён 2026-10-18 (`analyze-and-test`, `JAVA_HOME` → Temurin 17.0.20) — четвёртое условие выполнено. **QA-4 закрыт 2026-10-18:** человек открыл превью — бизнес-консоль работает нормально.)_

### Phase 5 — Словарь, документация, скрипты
**Goal:** ни один `ai_docs/` не описывает старый порядок сборки; новый термин записан в том же прогоне.

- [x] `ai_docs/GLOSSARY.md` — запись **Qorzhyn** (бренд; ярлыки `Qorzhyn` / `Qorzhyn Business`; `NOT Sarqyt` — прежнее имя, живущее в `package:sarqyt/`, `name:` в `pubspec.yaml` и ключах `appTitle` / `appTitleBusiness` до отдельной спеки); той же правкой развести **бизнес-приложение** (сборка) и **бизнес-консоль** (её web-развёртывание) _(выполнено досрочно по прямой просьбе пользователя после Phase 1; R15 закрыт. Попутно найдена третья формулировка «веб-консоль для бизнеса» в `RELEASE_READINESS.md:24` — выравнивается в рамках R14 ниже)_
- [x] `ai_docs/RELEASE_READINESS.md` — блокеры 1 и 4 закрыты; название утверждено; схема идентификаторов зафиксирована _(блокеры 1 и 4 вычеркнуты с датой и способом проверки; дата снимка в шапке обновлена; раздел «Схема идентификаторов» помечен зафиксированным. Попутно по R14 закрыта третья формулировка из `GLOSSARY.md:53`: «веб-консоль для бизнеса» → «бизнес-консоль» (строка 24), и сама отсылка в глоссарии переведена из будущего времени в прошедшее)_
- [x] `ai_docs/EXTERNAL_SERVICES.md` — web собирается явным target'ом; `main.dart` (строка 88) больше не существует _(строка 88 переписана на `flutter build web -t lib/main_business.dart` с оговоркой, что без `-t` сборка падает, а не деплоит не то. Заодно строка 40: `firebase_options.dart` → два пофлейворных файла — её не покрывала ни одна задача плана, нашло ревью Phase 2)_
- [x] `ai_docs/PROJECT.md:24-27` — `main.dart` → `main_business.dart`; команды сборки на flavor _(плюс блок из шести команд run/build с `-t` и `--flavor` (включая `main_fakes_client.dart`) и явным объяснением, что падение без флагов — защитный механизм, а не неудобство)_
- [x] `ai_docs/ROUTING_DECISIONS.md:7` — **задача, которой не было в плане**: пятый файл `ai_docs/`, описывавший старый порядок (`lib/main.dart` как entry point бизнес-приложения плюс неверное «`firebase.json` hosting targets differ», противоречившее отредактированному `EXTERNAL_SERVICES.md:88`). R14 перечисляет четыре файла, но Goal фазы — «ни один `ai_docs/` не описывает старый порядок», и по нему эта строка в зоне фазы. Найдено ревью Phase 5 как blocking — дважды: круг 1 нашёл строку 7, круг 2 — отдельный раздел «Firebase Hosting is a deploy convention» (строки 41-47) с той же неверной моделью, переименованный в «Which app ships to web is a build-command decision»
- [x] `scripts/` — две обёртки для локальной release-сборки APK на flavor (N1, nice-to-have; пропустить, если фаза раздувается) _(`scripts/build-client-apk.sh`, `scripts/build-business-apk.sh`; `set -euo pipefail`, `exec`, проброс `"$@"`, в комментарии — ссылка на блокер №2 про debug-подпись)_
- [x] Verify: `./scripts/gate.sh`; `grep -c Qorzhyn ai_docs/GLOSSARY.md` > 0; ревью дифа — ни один файл `ai_docs/` не описывает старый порядок (не «четыре файла из R14»: ревью нашло старый порядок в `ROUTING_DECISIONS.md` и в `solutions/tooling/ci-cd-flutter-firebase-workflows.md`, которых требование не перечисляет, а правка задела ещё и `GLOSSARY.md`) _(пройден 2026-10-04: гейт зелёный по всем тирам, `grep -c Qorzhyn ai_docs/GLOSSARY.md` = 2, четыре круга ревью — последний подтвердил, что ссылок на `lib/main.dart`, удалённый `firebase_options.dart`, `com.example.sarqyt` как текущее состояние и команд сборки без `-t` в `ai_docs/` не осталось)_

### Phase 6 — Ручной QA на устройстве
**Goal:** закрыть то, что файловым тестом и CI не покрывается.

- [ ] QA-1 — обе сборки ставятся рядом: два ярлыка, разные иконки, каждый открывает свой роутер _blocked: требует устройства. **Частично подтверждено из артефактов 2026-10-10** (`aapt2 dump badging` по release-APK): пакеты `kz.qorzhyn.app` / `kz.qorzhyn.business`, ярлыки `Qorzhyn` / `Qorzhyn Business`, иконки внутри APK различаются (23 948 и 20 783 байта, разные хеши — с исходниками в репозитории хеши не совпадают, потому что release перепаковывает PNG). Разные ID, ярлыки и иконки доказаны; на устройстве остаётся проверить, что сборки действительно встают рядом и каждая открывает свой роутер._
- [ ] QA-2 — вход под одним аккаунтом в обеих сборках даёт на `users/{uid}` оба поля `fcmTokenClient` / `fcmTokenBusiness` с разными значениями; перевод заказа в `readyForPickup` шлёт пуш в клиентское и не шлёт в бизнесовое
- [x] QA-5 — `flutter build apk --release` для обоих flavor'ов собирается (подпись остаётся debug-ключом — блокер №2 вне спеки) _(выполнено агентом 2026-10-10 через `scripts/build-{client,business}-apk.sh` — обёртки заодно проверены впервые. Обе сборки зелёные (~156 с каждая); `output-metadata.json`: `clientRelease` → `kz.qorzhyn.app` (65.8 MB), `businessRelease` → `kz.qorzhyn.business` (70.4 MB))_
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
