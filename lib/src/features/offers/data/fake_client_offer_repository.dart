import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/testing/test_offer.dart';
import 'package:sarqyt/src/utils/in_memory_store.dart';

class FakeClientOfferRepository implements ClientOfferRepository {
  FakeClientOfferRepository({this.addDelay = false});
  final bool addDelay;

  final _offers = InMemoryStore(kTestOffers);

  @override
  Future<List<Offer>> fetchAllOffer({
    double latitude = 43.238949,
    double longitude = 43.238949,
    double radius = 21,
    List<String> itemCategories = const [],
    String? pickupEarliest,
    String? pickupLatest,
    bool hiddenOnly = false,
    bool weCareOnly = false,
  }) {
    final now = DateTime.now();
    final visibleOffers = _offers.value.where((offer) {
      final visibleFrom =
          offer.visibleFrom ??
          offer.pickupStartTime.subtract(const Duration(days: 1));
      return offer.status == OfferStatus.active &&
          !visibleFrom.isAfter(now) &&
          offer.pickupEndTime.isAfter(now);
    }).toList()..sort((a, b) => a.pickupStartTime.compareTo(b.pickupStartTime));
    return Future.value(visibleOffers);
  }

  @override
  Future<Offer?> getOfferById(String id) async {
    return Future.value(_getOffer(_offers.value, id));
  }

  Offer? _getOffer(List<Offer> offers, String id) {
    return offers.firstWhere((o) => o.productId == id);
  }

  @override
  Stream<List<Offer>> watchAllOffer({
    double latitude = 0.0,
    double longitude = 0.0,
    double radius = 10,
    List<String> itemCategories = const [],
    String? pickupEarliest,
    String? pickupLatest,
    bool hiddenOnly = false,
    bool weCareOnly = false,
  }) {
    // TODO: implement watchAllOffer
    throw UnimplementedError();
  }
}
