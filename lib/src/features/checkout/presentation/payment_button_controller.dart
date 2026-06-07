import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/checkout/application/checkout_service.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';

part 'payment_button_controller.g.dart';

enum PaymentResult { success, cancelled, error }

@riverpod
class PaymentButtonController extends _$PaymentButtonController {
  @override
  FutureOr<void> build() {}

  Future<(PaymentResult, OrderID?)> submitPayment({
    required String offerId,
    required int quantity,
    required String storeName,
  }) async {
    state = const AsyncLoading();

    try {
      final orderId = await ref
          .read(checkoutControllerProvider.notifier)
          .pay(offerId: offerId, quantity: quantity, storeName: storeName);

      if (orderId != null) {
        state = const AsyncData(null);
        return (PaymentResult.success, orderId);
      }

      final checkoutState = ref.read(checkoutControllerProvider);
      if (checkoutState.hasError) {
        state = AsyncError(checkoutState.error!, StackTrace.current);
        return (PaymentResult.error, null);
      }

      state = const AsyncData(null);
      return (PaymentResult.cancelled, null);
    } catch (e, st) {
      state = AsyncError(e, st);
      return (PaymentResult.error, null);
    }
  }
}
