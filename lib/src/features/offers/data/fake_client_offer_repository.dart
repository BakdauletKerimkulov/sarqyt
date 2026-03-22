import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/data/test_offer.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/utils/in_memory_store.dart';

class FakeClientOfferRepository implements CLientOfferRepository {
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
    return Future.value(_offers.value);
  }

  @override
  Future<Offer?> getOfferById({required String id}) async {
    return Future.value(_getOffer(_offers.value, id));
  }

  Offer? _getOffer(List<Offer> offers, String id) {
    return offers.firstWhere((o) => o.productId == id);
  }

  @override
  Future<void> updateOrderQuantity({
    required String id,
    required int quantity,
  }) async {
    final offers = List<Offer>.from(_offers.value);
    final index = offers.indexWhere((o) => o.productId == id);
    if (index == -1) {
      throw StateError('Offer not found');
    }

    final offer = offers[index];
    if (quantity <= 0) {
      throw ArgumentError('Quantity to decrease must be positive');
    }

    if (offer.itemsAvailable < quantity) {
      throw StateError('Not enough items available');
    }

    final updatedOffer = offer.copyWith(quantity: offer.quantity - quantity);

    offers[index] = updatedOffer;
    _offers.value = offers;
  }
}
