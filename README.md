# Sarqyt

A marketplace connecting customers with surplus food from local restaurants and cafes at discounted prices. Reduce food waste, save money.

## Tech stack

- **Client & Business apps** — Flutter (Riverpod, GoRouter, Freezed)
- **Backend** — Firebase (Firestore, Cloud Functions, Auth, Storage)
- **Maps** — Stadia Maps + flutter_map with geohash-based geo queries

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Cloud Functions:

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```
