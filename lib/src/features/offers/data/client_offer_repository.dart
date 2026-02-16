import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';

part 'client_offer_repository.g.dart';

abstract class OfferRepository {
  Future<List<Offer>> fetchAllOffer({
    double latitude = 0.0,
    double longitude = 0.0,
    double radius = 10,
    List<String> itemCategories = const [],
    String? pickupEarliest,
    String? pickupLatest,
    bool hiddenOnly = false,
    bool weCareOnly = false,
  });

  Future<Offer?> getOfferById({required String id});

  Future<void> updateOrderQuantity({required String id, required int quantity});
}

@riverpod
OfferRepository offerRepository(Ref ref) => throw UnimplementedError();

@riverpod
FutureOr<List<Offer>> offersListFuture(Ref ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.fetchAllOffer();
}

@riverpod
FutureOr<Offer?> offerFuture(Ref ref, ProductID id) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getOfferById(id: id);
}
