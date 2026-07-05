---
title: CI secrets for API keys in web builds
date: 2026-07-02
work_type: tooling
tags: [ci, github-actions, firebase-hosting, envied, secrets, stadia-maps]
confidence: medium
references: [fa1f0da, PR #4]
---

## Summary
Firebase Hosting web build was deployed with a placeholder API key (`ci-placeholder`) instead of the real Stadia Maps key. The app worked locally but maps and geocoding silently failed on the hosted site. Fixed by injecting `secrets.STADIA_MAPS_API_KEY` into the `.env` created during CI, but the hosted domain must also be whitelisted in the API provider's dashboard.

## Reusable Insights

- **Placeholder `.env` breaks runtime features, not just builds** — when using `envied` with `obfuscate: true`, a placeholder key passes codegen and compilation without errors but silently fails at runtime (HTTP 401/403). Always use real secrets for deploy workflows even if placeholders are fine for CI lint/test. _Example: `firebase-hosting-merge.yml` vs `ci.yml` — deploy needs real keys, CI can use placeholders._
- **Domain-restricted API keys need hosting domains whitelisted** — after fixing the key injection, the hosted site may still fail if the API provider restricts by domain. Add the Firebase Hosting domains (`<project>.web.app`, `<project>.firebaseapp.com`, custom domain) to the API key's allowed origins. _Example: Stadia Maps dashboard → API key → Domain restrictions._
- **Diagnose hosted-vs-local bugs by checking secrets first** — when a feature works locally but not on hosting, check whether the build-time secrets were injected correctly. GitHub masks secrets in logs as `***`, so look for the `Create .env` step to confirm it ran with a non-empty value.

## Pitfalls

- **Silent geocoding failure with invalid API key** — symptom: map shows no pin, Continue button does nothing. Cause: `MapRepository.getCoordinates()` returns `null` on HTTP error, `StaticMapPreview` shows fallback, button guards on `location == null`. No error is surfaced to the user. Fix: use real API key in deploy workflow. Avoid by: always distinguishing CI-only workflows (placeholder ok) from deploy workflows (real secrets required).
