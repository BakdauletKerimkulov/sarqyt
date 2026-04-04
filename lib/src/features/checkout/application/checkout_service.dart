import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/checkout/data/payment_sheet_repository.dart';
import 'package:sarqyt/src/features/checkout/data/reservation_repository.dart';
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

  /// Pays for an offer and waits for the order to be created by the webhook.
  /// Returns the new OrderID on success.
  /// Returns null if user cancelled.
  /// Throws (via AsyncError state) on real errors — UI listener shows dialog.
  Future<CheckoutResult> pay({
    required String offerId,
    required int quantity,
    required String storeName,
  }) async {
    // Keep alive during payment flow — Payment Sheet is a native overlay
    // that may cause Riverpod to dispose autoDispose providers.
    final link = ref.keepAlive();

    state = const AsyncLoading();

    late final String reservationId;

    state = await AsyncValue.guard(() async {
      final reservationRepo = ref.read(reservationRepositoryProvider);
      final paymentSheetRepo = ref.read(paymentSheetRepositoryProvider);

      // 1. Create reservation + get Stripe secrets from server
      final result = await reservationRepo.createReservation(
        offerId: offerId,
        quantity: quantity,
      );
      reservationId = result.reservationId;

      // 2. Init payment sheet
      await paymentSheetRepo.initPaymentSheet(
        paymentIntentClientSecret: result.paymentIntentClientSecret,
        ephemeralKey: result.ephemeralKey,
        stripeCustomerId: result.stripeCustomerId,
        merchantDisplayName: storeName,
      );

      // 3. Present payment sheet
      final success = await paymentSheetRepo.presentPaymentSheet();
      if (!success) throw const _PaymentCancelledException();

      // 4. Wait for webhook to create the order with this reservationId
      final ordersRepo = ref.read(clientOrdersRepositoryProvider);
      final order = await ordersRepo
          .watchOrderByReservation(reservationId)
          .where((o) => o != null)
          .first
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => null,
          );

      if (order == null) {
        throw TimeoutException(
          'Order not received yet. Check your orders later.',
        );
      }

      return order.id;
    });

    // Allow dispose now that payment flow is complete.
    link.close();

    // User cancelled — not an error, just return null
    if (state.hasError && state.error is _PaymentCancelledException) {
      state = const AsyncData(null);
      return null;
    }

    // Real error — state remains AsyncError, UI listener shows dialog
    if (state.hasError) return null;

    // Success — return the order ID
    return state.value;
  }
}

class _PaymentCancelledException implements Exception {
  const _PaymentCancelledException();
}
