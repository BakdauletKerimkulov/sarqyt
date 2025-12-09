import 'package:sarqyt/src/constants/test_offers.dart';
import 'package:sarqyt/src/features/offers/data/offers_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/utils/in_memory_store.dart';

class FakeOfferRepository implements OffersRepository {
  final _offers = InMemoryStore<List<Offer>>(kTestOffers);

  @override
  Future<Offer?> fetchOffer(OfferID id) {
    return Future.value(_getOffer(_offers.value, id));
  }

  @override
  Future<List<Offer>> fetchOffersList() {
    return Future.value(_offers.value);
  }

  @override
  Offer? getOffer(OfferID id) {
    return _getOffer(_offers.value, id);
  }

  @override
  Stream<Offer?> watchOffer(OfferID id) {
    return watchOffersList().map((offers) => _getOffer(offers, id));
  }

  @override
  Stream<List<Offer>> watchOffersList() => _offers.stream;

  static Offer? _getOffer(List<Offer> offers, String id) {
    try {
      return offers.firstWhere((offer) => offer.id == id);
    } catch (e) {
      return null;
    }
  }
}
