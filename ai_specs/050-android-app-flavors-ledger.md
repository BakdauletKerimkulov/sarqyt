---
title: Разделение сборки на flavor'ы client и business
parent: 050-android-app-flavors-spec.md
date: 2026-09-09
---

## L1
Status: current
Question: Название Qorzhyn утверждено. Что входит в эту спеку — только идентификаторы сборки или ещё переименование Dart-пакета `sarqyt` → `qorzhyn` (243 файла) и Firebase-проект?
Answer: Только сборка. Flavors, `applicationId`, `android:label`, иконки, Firebase-регистрации, CI.
Decision: Спека меняет `android/`, `firebase.json`, workflow'ы, `.vscode/launch.json`, entry point'ы и `ai_docs/`. `package:sarqyt/`, `name: sarqyt` в `pubspec.yaml` и ключи `appTitle`/`appTitleBusiness` в `.arb` не трогаются.
Constraints:
- Диффы не смешивать: этот проверяется сборкой, переименование пакета — `flutter analyze`.
- Расхождение «ярлык Qorzhyn, `appTitle` Sarqyt» принимается временно и фиксируется в спеке, а не чинится по дороге.
- Переименование пакета оформляется отдельной спекой до публикации в Play.

## L2
Status: current
Question: Где регистрировать два Android-приложения в Firebase — в существующем dev-проекте или ждать нового prod-проекта из плана 047?
Answer: В dev-проекте `sarqyt-1ab95`.
Decision: Два Android-приложения (`kz.qorzhyn.app`, `kz.qorzhyn.business`) в `sarqyt-1ab95`, свой `google-services.json` на flavor, свой `firebase_options_*.dart` на entry point.
Constraints:
- План 047 оставляет `sarqyt-1ab95` как dev/staging — регистрации не выбрасываются при переезде.
- В `qorzhyn-prod` та же процедура повторяется в рамках 047; спека 050 в prod-проект не ходит.

## L3
Status: current
Question: Нужен ли `applicationIdSuffix .dev` на debug, чтобы dev- и prod-сборки стояли на одном устройстве рядом?
Answer: Нет.
Decision: Ровно два `applicationId`; `buildTypes` не меняют идентификатор.
Constraints:
- Два Firebase Android-приложения, а не четыре.
- Решение пересматривается, когда появится prod-проект и потребуется держать обе среды на одном устройстве.

## L4
Status: current
Question: Что делать с web-сборкой и hosting после исчезновения дефолтного target'а?
Answer: Явный target, на хостинге остаётся бизнес-консоль.
Decision: `firebase-hosting-merge.yml` и `firebase-hosting-pull-request.yml` собирают `flutter build web -t lib/main_business.dart`. Клиентская web-сборка и hosting targets не заводятся.
Constraints:
- `EXTERNAL_SERVICES.md` уже фиксирует «клиент — mobile-only»; спека это не меняет.

## L5
Status: deferred
Question: Заводить ли flavor'ы, схемы и bundle ID на iOS в этой же работе?
Answer: —
Reason: Нет аккаунта разработчика Apple; целевая платформа релиза — Android + веб-консоль (`ai_docs/RELEASE_READINESS.md`). iOS остаётся на `com.example.sarqyt` и после удаления `lib/main.dart` требует явный `-t`.
