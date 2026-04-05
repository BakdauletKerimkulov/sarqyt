import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/checkout/data/payment_repository.dart';
import 'package:sarqyt/src/features/checkout/data/payment_sheet_repository.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';

part 'checkout_service.g.dart';

@riverpod
FutureOr<double> offerTotal(Ref ref, String id) async {
  final offer = await ref.watch(offerFutureProvider(id).future);
  final quantity = ref.watch(offerItemsQuantityProvider);

  if (offer != null) {
    return offer.price * quantity;
  }
  return 0.0;
}

@riverpod
class OfferItemsQuantity extends _$OfferItemsQuantity {
  @override
  int build() {
    return 1;
  }

  void setQuantity(int quantity) {
    state = quantity;
  }
}

/// Result of a checkout: null if cancelled, OrderID if successful.
typedef CheckoutResult = OrderID?;

@riverpod
class CheckoutController extends _$CheckoutController {
  @override
  FutureOr<CheckoutResult> build() => null;

  /// Reserve without payment — for testing with real restaurants.
  /// TODO: Replace with pay() when Kaspi Pay is integrated.
  Future<CheckoutResult> pay({
    required String offerId,
    required int quantity,
    required String storeName,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final orderId = await paymentRepo.reserveOffer(
        offerId: offerId,
        quantity: quantity,
      );
      return orderId;
    });

    if (state.hasError) return null;

    return state.value;
  }

  /* --- Stripe payment flow (for when payment system is ready) ---
  Future<CheckoutResult> payWithStripe({
    required String offerId,
    required int quantity,
    required String storeName,
  }) async {
    final link = ref.keepAlive();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final paymentSheetRepo = ref.read(paymentSheetRepositoryProvider);

      final result = await paymentRepo.createPayment(
        offerId: offerId,
        quantity: quantity,
      );

      await paymentSheetRepo.initPaymentSheet(
        paymentIntentClientSecret: result.paymentIntentClientSecret,
        ephemeralKey: result.ephemeralKey,
        stripeCustomerId: result.stripeCustomerId,
        merchantDisplayName: storeName,
      );

      final success = await paymentSheetRepo.presentPaymentSheet();
      if (!success) throw const _PaymentCancelledException();

      final ordersRepo = ref.read(clientOrdersRepositoryProvider);
      final order = await ordersRepo
          .watchOrderByPaymentIntent(result.paymentIntentId, user.uid)
          .where((o) => o != null)
          .first
          .timeout(const Duration(seconds: 15), onTimeout: () => null);

      if (order == null) {
        throw TimeoutException('Order not received yet.');
      }
      return order.id;
    });

    link.close();

    if (state.hasError && state.error is _PaymentCancelledException) {
      state = const AsyncData(null);
      return null;
    }
    if (state.hasError) return null;
    return state.value;
  }
  */
}

class _PaymentCancelledException implements Exception {
  const _PaymentCancelledException();
}
