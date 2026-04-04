import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/app_bootstrap.dart';
import 'package:sarqyt/src/exceptions/async_error_logger.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/onboarding/data/client_onboarding_repository.dart';

extension AppBootstrapFirebase on AppBootstrap {
  /// Creates the top-level [ProviderContainer] by overriding providers with fake
  /// repositories only. This is useful for testing purposes and for running the
  /// app with a "fake" backend.
  ///
  /// Note: all repositories needed by the app can be accessed via providers.
  /// Some of these providers throw an [UnimplementedError] by default.
  ///
  /// Example:
  /// ```dart
  /// @Riverpod(keepAlive: true)
  /// LocalCartRepository localCartRepository(LocalCartRepositoryRef ref) {
  ///   throw UnimplementedError();
  /// }
  /// ```
  ///
  /// As a result, this method does two things:
  /// - create and configure the repositories as desired
  /// - override the default implementations with a list of "overrides"
  Future<ProviderContainer> createFirebaseProviderContainer({
    bool addDelay = true,
  }) async {
    final offeRepo = ClientOfferRepository(FirebaseFirestore.instance);
    final container = ProviderContainer(
      overrides: [offerRepositoryProvider.overrideWithValue(offeRepo)],
      observers: [AsyncErrorLogger()],
    );
    // Pre-load onboarding repository so redirect can read it synchronously
    await container.read(clientOnboardingRepositoryProvider.future);
    return container;
  }

  Future<void> setupEmulators() async {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    await FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    FirebaseFunctions.instance.useFunctionsEmulator('127.0.0.1', 5001);
  }
}
