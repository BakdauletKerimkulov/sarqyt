import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sarqyt/src/features/map/application/geolocator_service.dart';
import 'package:sarqyt/src/features/offers/application/offers_with_distance.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

class MockClientOfferRepository extends Mock implements ClientOfferRepository {}

final _testNow = DateTime(2026, 7, 12, 12);

Offer _makeOffer(String id) => Offer(
  id: id,
  storeId: 'store_$id',
  productId: 'item1',
  quantity: 5,
  name: 'Bag',
  price: 1500,
  currencyCode: 'KZT',
  currencySymbol: '₸',
  storeName: 'Store $id',
  geopoint: const GeoPoint(43.25, 76.94),
  pickupStartTime: _testNow.add(const Duration(hours: 1)),
  pickupEndTime: _testNow.add(const Duration(hours: 3)),
  createdAt: _testNow,
  createdBy: 'uid1',
  status: OfferStatus.active,
);

Position _testPosition() => Position(
  latitude: 37.4219983,
  longitude: -122.084,
  timestamp: _testNow,
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  test('falls back to all offers when the nearby geo query is empty', () async {
    final repo = MockClientOfferRepository();
    final allOffers = [_makeOffer('a'), _makeOffer('b')];
    when(
      () => repo.watchAllOffers(),
    ).thenAnswer((_) => Stream.value(allOffers));
    when(
      () => repo.watchNearbyOffers(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) => Stream.value(const []));

    final container = ProviderContainer(
      overrides: [
        offerRepositoryProvider.overrideWithValue(repo),
        positionProvider.overrideWith((ref) => Future.value(_testPosition())),
      ],
    );
    addTearDown(container.dispose);
    container.listen(offersWithDistanceStreamProvider, (_, _) {});

    final result = await container.read(
      offersWithDistanceStreamProvider.future,
    );

    expect(result.map((o) => o.offer.id), containsAll(['a', 'b']));
  });
}
