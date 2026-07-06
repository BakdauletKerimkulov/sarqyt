# External Services — Sarqyt-Specific Decisions

Non-obvious choices around external services, regions, and environment configuration. Universal Firebase patterns (emulators, auth, rules) are in `ai_toolkit/guidelines/firebase.md`.

---

## Maps: Stadia Maps, not Google Maps

**Decision:** Use [Stadia Maps](https://stadiamaps.com/) via `flutter_map`, not `google_maps_flutter`.

**Why:** Stadia Maps offers a generous free tier sufficient for early-stage usage in Kazakhstan. Google Maps charges per map load and geocoding request, which adds up quickly during development and beta testing. `flutter_map` also avoids platform-specific native map SDKs, simplifying web support.

**How it works:**
- Tile layer: `https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png`
- Geocoding: `https://api.stadiamaps.com/geocoding/v1/search`
- Static map previews: same tile URL pattern (used in `static_map_preview.dart`)
- API key passed via `Env.stadiaMapsApiKey` in `additionalOptions`

> **AI warning:** Do not suggest migrating to Google Maps or adding `google_maps_flutter`. The billing model is the reason for Stadia Maps.

---

## Stripe: KZT Currency, Firebase Secret Manager

**Decision:** Stripe handles all payments in KZT (Kazakhstani Tenge).

**How it works:**
- Client: `flutter_stripe` / `flutter_stripe_web`, publishable key via `Env.stripePublishableKey` (envied)
- Server: Stripe SDK initialized with `STRIPE_SECRET_KEY` via Firebase `defineSecret()` — not hardcoded, not in `process.env`
- Currency: `offerData.currencyCode.toLowerCase()` passed to `PaymentIntent` — currently always `"kzt"`
- Webhook verification: `STRIPE_WEBHOOK_SECRET` also via `defineSecret()`

**Secrets (Cloud Functions):**

| Secret | `defineSecret` location | Used by |
|--------|------------------------|---------|
| `STRIPE_SECRET_KEY` | `shared/helpers/stripe-client.ts` | `createPayment`, `stripeWebhook`, `cancelOrder` |
| `STRIPE_WEBHOOK_SECRET` | `payments/functions/stripe-webhook.ts` | `stripeWebhook` only |

> **AI warning:** Never hardcode Stripe keys. Never use `process.env` for secrets — use `defineSecret` from `firebase-functions/params` and pass via `{ secrets: [...] }` in function options.

---

## Firebase API Keys: Public by Design

**Decision:** Firebase API keys in `firebase_options.dart` (`AIza...`) are committed to the repo and shipped in every app binary. This is normal and intended.

**Why:** A Firebase API key is a project identifier, not an access credential. It grants no data access — data protection comes from Firestore/Storage security rules. The key is trivially extractable from any APK/IPA, so "hiding" it in `.env` or rewriting git history provides zero security and breaks `flutterfire configure` regeneration.

**Actual protection layers:**
1. Key restrictions in Google Cloud Console → Credentials: application restrictions (iOS bundle ID / Android package + SHA-1 / web referrers) + API restrictions (Firebase APIs only)
2. App Check — verifies requests come from the real app
3. Security rules (`firestore.rules`, `storage.rules`) — the only real data protection

GitHub secret-scanning alerts on these keys are pattern-based false positives: restrict the key, then close the alert as "used in client app".

> **AI warning:** Do NOT suggest moving Firebase API keys to `.env`/envied, rotating them on a leak alert, or scrubbing them from git history. They are public by design. Real secrets (Stripe secret key, etc.) follow the rules in the sections above.

---

## Firebase Cloud Functions: Region Split

**Decision:** There is no `setGlobalOptions({ region: ... })`. Functions use two different regions.

| Function type | Region | How set |
|---------------|--------|---------|
| Firestore triggers (`onOrderCreated`, `onOrderStatusChanged`, `onItemStatusChanged`) | `asia-south1` | Explicitly per-function in trigger options |
| Callable/HTTPS functions (`createPayment`, `reserveOffer`, `stripeWebhook`, `cancelOrder`, etc.) | `us-central1` | Default (no region specified) |
| Scheduled functions (`dailySyncOffers`, `expireOrders`) | `us-central1` | Default (no region specified) |

**Why `asia-south1` for triggers:** Firestore triggers should be in the same region as the Firestore database for lower latency on document change events. However, note that `firebase.json` lists `"location": "nam5"` for Firestore — `TODO: ask maintainer` whether the production Firestore is actually in `nam5` or `asia-south1`, as this affects trigger latency.

**Why no `setGlobalOptions`:** Callable functions are already deployed at `us-central1` and clients call them at the default region (no `instanceFor(region:)` on the Flutter side). Adding `setGlobalOptions` would move callables to a different region and break existing client URLs.

> **AI warning:** Do NOT add `setGlobalOptions({ region: 'asia-south1' })` or suggest a global region. It would break all callable function invocations from the Flutter client.

---

## Firebase Hosting: Business App Only (by Convention)

**Decision:** Single hosting config in `firebase.json` pointing to `build/web`.

```json
"hosting": {
  "public": "build/web",
  "rewrites": [{ "source": "**", "destination": "/index.html" }]
}
```

**Why:** There is no multi-site setup, no `"target"` field. The config is flavor-agnostic — it deploys whatever was last built into `build/web`. The convention is to build and deploy only the business app (`main.dart` flavor) for web. The client app is mobile-only for now.

> **AI warning:** If adding a second hosting site (e.g., client web app), you need Firebase multi-site hosting with named targets — the current single-block config won't work for two apps.

---

## FCM Push Notifications: Token in Firestore

**Decision:** FCM device token stored as a field on the user document, not in a subcollection.

**How it works:**
- Token stored at `users/{uid}` with field `fcmToken` via `set(merge: true)`
- Refreshed automatically via `onTokenRefresh` listener
- iOS: requests APNs token before FCM token (required)
- Handles foreground (`onMessage`), background tap (`onMessageOpenedApp`), and cold launch (`getInitialMessage`)
- Background handler registered via `FirebaseMessaging.onBackgroundMessage`

**Why merge-set on user doc:** Simpler than a subcollection for single-device-per-user. If multi-device support is needed later, this should move to `users/{uid}/devices/{tokenId}`.

---

## Environment Variables: envied with Obfuscation

**Decision:** Client-side secrets managed via `envied` package with XOR obfuscation.

**File:** `lib/env.dart` (source) / `lib/env.g.dart` (generated)

| Variable | Field | Purpose |
|----------|-------|---------|
| `STRIPE_PUBLISHABLE_KEY` | `Env.stripePublishableKey` | Stripe client SDK init |
| `STADIA_MAPS_API_KEY` | `Env.stadiaMapsApiKey` | Map tile requests |
| `SUPABASE_URL` | `Env.supabaseUrl` | `TODO: ask maintainer` — purpose unknown, may be a leftover |

**How it works:**
- `@Envied()` annotation on `Env` class
- `@EnviedField(obfuscate: true)` on each field — generates XOR-encoded byte arrays in `.g.dart`
- Values sourced from `.env` file (not committed to git)
- Regenerate with `dart run build_runner build --delete-conflicting-outputs` after changing `.env`

> **AI warning:** Do not add secrets to `lib/env.dart` without `obfuscate: true`. Do not commit `.env` to git. Server-side secrets go in Firebase Secret Manager (see Stripe section above), not in envied.

---

## See Also

- `ai_toolkit/guidelines/firebase.md` — universal Firebase patterns (emulators, rules, auth, crashlytics)
- `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` — function-specific decisions (schedules, retry logic, order paths)
