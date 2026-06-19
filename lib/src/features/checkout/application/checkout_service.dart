import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/checkout/data/payment_repository.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:uuid/uuid.dart';

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
  String _idempotencyKey = const Uuid().v4();
  int _lastQuantity = 1;

  @override
  FutureOr<CheckoutResult> build() => null;

  /// Reserve without online payment — order is paid on pickup at the store.
  Future<CheckoutResult> pay({
    required String offerId,
    required int quantity,
    required String storeName,
  }) async {
    // Regenerate key if quantity changed since last attempt
    if (quantity != _lastQuantity) {
      _idempotencyKey = const Uuid().v4();
      _lastQuantity = quantity;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final orderId = await paymentRepo.reserveOffer(
        offerId: offerId,
        quantity: quantity,
        idempotencyKey: _idempotencyKey,
      );
      return orderId;
    });

    if (state.hasError) return null;

    return state.value;
  }
}
