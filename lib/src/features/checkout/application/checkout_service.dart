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

  Future<CheckoutResult> pay({
    required String offerId,
    required int quantity,
    required String storeName,
  }) async {
    final link = ref.keepAlive();

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final paymentSheetRepo = ref.read(paymentSheetRepositoryProvider);

      // 1. Create payment (decrements offer quantity + creates PaymentIntent)
      final result = await paymentRepo.createPayment(
        offerId: offerId,
        quantity: quantity,
      );

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

      // 4. Wait for webhook to create order (matched by paymentIntentId)
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw StateError('User not signed in');

      final ordersRepo = ref.read(clientOrdersRepositoryProvider);
      final order = await ordersRepo
          .watchOrderByPaymentIntent(result.paymentIntentId, user.uid)
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

    link.close();

    if (state.hasError && state.error is _PaymentCancelledException) {
      state = const AsyncData(null);
      return null;
    }

    if (state.hasError) return null;

    return state.value;
  }
}

class _PaymentCancelledException implements Exception {
  const _PaymentCancelledException();
}
