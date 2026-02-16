import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';

part 'checkout_service.g.dart';

@riverpod
double offerTotal(Ref ref, String id) {
  final offer = ref.watch(offerFutureProvider(id)).value;
  final quantity = ref.watch(offerItemsQuantityProvider);

  if (offer != null) {
    return offer.product.price.amount * quantity;
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
