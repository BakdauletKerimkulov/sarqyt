import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/app_bootstrap.dart';
import 'package:sarqyt/src/exceptions/async_error_logger.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/fake_auth_repository.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/data/fake_client_offer_repository.dart';

/// Extension methods specific for the "fakes" project configuration
extension AppBootstrapFakes on AppBootstrap {
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

  Future<ProviderContainer> createsFakeProviderContainer({
    bool addDelay = true,
  }) async {
    final authRepo = FakeAuthRepository(addDelay: addDelay);
    final offerRepo = FakeClientOfferRepository(addDelay: addDelay);

    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        offerRepositoryProvider.overrideWithValue(offerRepo),
      ],
      observers: [AsyncErrorLogger()],
    );
  }
}
