import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/testing/test_offer.dart';
import 'package:sarqyt/src/utils/in_memory_store.dart';

class FakeClientOfferRepository implements ClientOfferRepository {
  FakeClientOfferRepository({this.addDelay = false});
  final bool addDelay;

  final _offers = InMemoryStore(kTestOffers);

  @override
  Stream<List<Offer>> watchNearbyOffers({
    required double latitude,
    required double longitude,
    int precision = 4,
  }) {
    return watchAllOffers();
  }

  @override
  Future<List<Offer>> fetchNearbyOffers({
    required double latitude,
    required double longitude,
    int precision = 4,
  }) async {
    final now = DateTime.now();
    return _offers.value.where((offer) {
      return offer.status == OfferStatus.active &&
          offer.pickupEndTime.isAfter(now);
    }).toList();
  }

  @override
  Stream<List<Offer>> watchAllOffers() {
    return _offers.stream.map((offers) {
      final now = DateTime.now();
      return offers
          .where((o) =>
              o.status == OfferStatus.active && o.pickupEndTime.isAfter(now))
          .toList();
    });
  }

  @override
  Future<Offer?> getOfferById(String id) async {
    return _offers.value.cast<Offer?>().firstWhere(
          (o) => o?.productId == id,
          orElse: () => null,
        );
  }

  @override
  Stream<Offer?> watchOfferByIdStream(String id) {
    return _offers.stream.map(
      (offers) => offers.cast<Offer?>().firstWhere(
            (o) => o?.productId == id,
            orElse: () => null,
          ),
    );
  }
}
