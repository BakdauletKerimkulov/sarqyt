#!/usr/bin/env bash
# Локальная release-сборка клиентского APK (Qorzhyn).
#
# Обёртка существует ровно для того, чтобы не держать -t и --flavor в голове:
# дефолтного target'а в проекте нет, а без --flavor Gradle не найдёт
# assembleRelease. Подпись пока debug-ключом — блокер №2 в
# ai_docs/RELEASE_READINESS.md, вне спеки 050.
set -euo pipefail
cd "$(dirname "$0")/.."
exec flutter build apk --release -t lib/main_client.dart --flavor client "$@"
