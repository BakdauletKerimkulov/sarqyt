import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/app_client.dart';
import 'package:sarqyt/src/exceptions/async_error_logger.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/fake_auth_repository.dart';
import 'package:sarqyt/src/features/checkout/data/payment_repository.dart';
import 'package:sarqyt/src/features/map/application/geolocator_service.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/data/fake_client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/data/favorites_repository.dart';
import 'package:sarqyt/src/utils/current_date_builder.dart';
import 'package:sarqyt/src/features/onboarding/data/client_onboarding_repository.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/offers/offers_robot.dart';
import 'mocks.dart';

/// Composite Robot — pumps the client app with fakes.
class Robot {
  Robot(this.tester)
    : offers = OffersRobot(tester),
      mockPaymentRepo = MockPaymentRepository(),
      mockClientOrdersRepo = MockClientOrdersRepository();
  final WidgetTester tester;
  final OffersRobot offers;
  final MockPaymentRepository mockPaymentRepo;
  final MockClientOrdersRepository mockClientOrdersRepo;

  Future<void> pumpClientApp() async {
    // Initialize sqflite FFI so flutter_cache_manager (used by
    // CachedNetworkImage) can open its SQLite database in tests.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider so CachedNetworkImage doesn't throw
    // MissingPluginException when trying to access the cache directory.
    _mockPathProvider();

    // Mark onboarding as complete so the router doesn't redirect to /welcome.
    SharedPreferences.setMockInitialValues({'onboardingComplete': true});
    final prefs = await SharedPreferences.getInstance();

    final authRepo = FakeAuthRepository(addDelay: false);
    // Use the same fixed time as kTestOffers so offers aren't expired.
    final offerRepo = FakeClientOfferRepository(
      addDelay: false,
      currentDateBuilder: () => DateTime(2026, 7, 12, 12),
    );
    final onboardingRepo = ClientOnboardingRepository(prefs);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        offerRepositoryProvider.overrideWithValue(offerRepo),
        paymentRepositoryProvider.overrideWithValue(mockPaymentRepo),
        clientOrdersRepositoryProvider.overrideWithValue(mockClientOrdersRepo),
        clientOnboardingRepositoryProvider.overrideWith(
          (_) async => onboardingRepo,
        ),
        // Fixed clock matching kTestOffers data.
        currentDateBuilderProvider.overrideWithValue(
          () => DateTime(2026, 7, 12, 12),
        ),
        // No GPS in tests — null position triggers watchAllOffers fallback.
        positionProvider.overrideWith((_) => Future.value(null)),
        // No Firestore for favorites — empty set.
        favoriteStoreIdsProvider.overrideWith((_) => Stream.value(const {})),
        // No orders for client.
        customerOrdersStreamProvider.overrideWith(
          (_) => Stream.value(<Order>[]),
        ),
      ],
      observers: [AsyncErrorLogger()],
    );

    // Pre-load async providers that the router accesses via .requireValue.
    await container.read(clientOnboardingRepositoryProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyAppClient(),
      ),
    );
    // Pump frames to let async providers emit; avoid pumpAndSettle which
    // may loop forever on CachedNetworkImage HTTP errors.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Let async cache-manager / HTTP exceptions fire, then drain them.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    _drainImageExceptions(tester);

    // Pump once more after draining to settle the widget tree.
    await tester.pump(const Duration(milliseconds: 100));
    _drainImageExceptions(tester);
  }

  /// Consume all pending async exceptions thrown by image widgets in tests.
  static void _drainImageExceptions(WidgetTester tester) {
    while (tester.takeException() != null) {
      // Intentionally draining — image HTTP errors are expected in widget tests
      // because CachedNetworkImage cannot reach picsum.photos.
    }
  }

  /// Mock path_provider channel for CachedNetworkImage's cache directory.
  static void _mockPathProvider() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (methodCall) async {
            switch (methodCall.method) {
              case 'getTemporaryDirectory':
              case 'getApplicationSupportDirectory':
                return '/tmp';
              default:
                return null;
            }
          },
        );
  }
}
