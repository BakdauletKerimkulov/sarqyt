---
title: CI/CD fixes for Flutter + Firebase workflows
date: 2026-06-30
work_type: tooling
tags: [ci, github-actions, firebase, envied, codegen, flutter-analyze, hosting]
confidence: high
references: [ai_specs/017-send-changes-to-firebase-plan.md, e1d9a76, 5b64874]
---

## Summary
Fixed GitHub Actions workflows to handle `.env`/codegen, Firestore index deployment, and `flutter analyze` warnings in generated files. These are recurring patterns for any Flutter + Firebase project using `envied` and `freezed` with CI/CD.

## Reusable Insights

- **Dummy `.env` for CI when using `envied`** — when `@Envied` reads a gitignored `.env` at codegen time, CI has no `.env` and `build_runner` fails silently or produces missing files. Add `echo 'KEY=placeholder' > .env` before `build_runner` in every workflow that runs codegen. _Applied in: `.github/workflows/ci.yml`, `firebase-hosting-merge.yml`, `firebase-hosting-pull-request.yml`._
- **`--no-fatal-warnings` for `flutter analyze` in CI** — `freezed` generates `duplicate_ignore` pragmas that produce warnings. These can't be suppressed at the source (generated code). Use `flutter analyze --no-fatal-warnings` to prevent CI failure on generated-code warnings while still catching real errors.
- **`--only firestore` deploys both rules AND indexes** — `firebase deploy --only firestore:rules` skips composite indexes. Use `--only firestore` to deploy everything under the `firestore` target (rules + indexes). Check `firebase.json` to confirm both `firestore.rules` and `firestore.indexes.json` are referenced.
- **Every `flutter build web` workflow needs `build_runner`** — if any `.g.dart` file is gitignored or stale, web compilation fails. Always run `dart run build_runner build --delete-conflicting-outputs` before `flutter build web` in hosting workflows.

## Pitfalls

- **Firebase Hosting "same version" 400 error** — symptom: preview deploy fails with "supplied version is the current active version". Cause: re-deploying an identical build to the same channel. Fix: push a new commit with actual changes; the error resolves on next run. Avoid by: not re-running hosting deploy without code changes.
- **Stale `.g.dart` files after branch work** — symptom: `git status` shows modified `.g.dart` files you didn't touch. Cause: codegen hashes drift when annotated source files change across commits. Fix: run `build_runner` and commit results before creating a PR.
