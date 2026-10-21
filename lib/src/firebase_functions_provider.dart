import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_functions_provider.g.dart';

/// Region the Cloud Functions callables are deployed in.
///
/// The SDK's default instance silently pins every caller to `us-central1`,
/// so a single direct use left behind survives a region migration and fails
/// at runtime with `not-found`. Keeping the region in one constant is what
/// makes the move to `europe-west1` a one-line change — see
/// `ai_specs/047-migrate-firebase-region-europe-west1-plan.md`, Phase 2.
const kFunctionsRegion = 'us-central1';

/// The single [FirebaseFunctions] instance the app talks to.
///
/// Repositories take it by constructor injection; nothing else reaches for
/// the SDK's default instance directly.
///
/// Lives outside `app_bootstrap_firebase.dart` on purpose: `data/`
/// repositories depend on this provider, and the bootstrap layer depends on
/// `data/` — putting it there would close an import cycle.
@Riverpod(keepAlive: true)
FirebaseFunctions firebaseFunctions(Ref ref) =>
    FirebaseFunctions.instanceFor(region: kFunctionsRegion);
