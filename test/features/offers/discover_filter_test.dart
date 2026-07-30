import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/offers/application/discover_filter.dart';
import 'package:sarqyt/src/features/offers/application/offers_with_distance.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

final _testNow = DateTime(2026, 7, 12, 12);

OfferWithDistance _makeOWD({
  required String storeId,
  double price = 1500,
  double? distanceKm,
  DateTime? pickupStart,
}) {
  final now = _testNow;
  return OfferWithDistance(
    offer: Offer(
      id: 'offer_$storeId',
      storeId: storeId,
      productId: 'item1',
      quantity: 5,
      name: 'Bag',
      price: price,
      currencyCode: 'KZT',
      currencySymbol: '₸',
      storeName: 'Store $storeId',
      geopoint: const GeoPoint(43.25, 76.94),
      pickupStartTime: pickupStart ?? now.add(const Duration(hours: 1)),
      pickupEndTime: now.add(const Duration(hours: 3)),
      createdAt: now,
      createdBy: 'uid1',
      status: OfferStatus.active,
    ),
    distanceKm: distanceKm,
  );
}

void main() {
  group('DiscoverFilter', () {
    final today = _testNow;
    final tomorrow = today.add(const Duration(days: 1));

    final offers = [
      _makeOWD(
        storeId: 's1',
        price: 2000,
        distanceKm: 1.5,
        pickupStart: DateTime(today.year, today.month, today.day, 18, 0),
      ),
      _makeOWD(
        storeId: 's2',
        price: 1000,
        distanceKm: 0.5,
        pickupStart: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          18,
          0,
        ),
      ),
      _makeOWD(
        storeId: 's3',
        price: 3000,
        distanceKm: 3.0,
        pickupStart: DateTime(today.year, today.month, today.day, 19, 0),
      ),
    ];

    test('no filter returns all', () {
      const filter = DiscoverFilter();
      final result = applyFilter(offers, filter, {}, today);
      expect(result.length, 3);
    });

    test('favorites only filters by storeId', () {
      const filter = DiscoverFilter(favoritesOnly: true);
      final result = applyFilter(offers, filter, {'s1', 's3'}, today);
      expect(result.length, 2);
      expect(result.map((o) => o.offer.storeId), containsAll(['s1', 's3']));
    });

    test('today filter shows only today', () {
      const filter = DiscoverFilter(pickupTime: PickupTimeFilter.today);
      final result = applyFilter(offers, filter, {}, today);
      for (final o in result) {
        final d = o.offer.pickupStartTime;
        expect(
          DateTime(d.year, d.month, d.day),
          DateTime(today.year, today.month, today.day),
        );
      }
    });

    test('tomorrow filter shows only tomorrow', () {
      const filter = DiscoverFilter(pickupTime: PickupTimeFilter.tomorrow);
      final result = applyFilter(offers, filter, {}, today);
      for (final o in result) {
        final d = o.offer.pickupStartTime;
        expect(
          DateTime(d.year, d.month, d.day),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        );
      }
    });

    test('sort by price', () {
      const filter = DiscoverFilter(sortBy: SortBy.price);
      final result = applyFilter(offers, filter, {}, today);
      expect(result[0].offer.price, 1000);
      expect(result[1].offer.price, 2000);
      expect(result[2].offer.price, 3000);
    });

    test('sort by distance', () {
      const filter = DiscoverFilter(sortBy: SortBy.distance);
      final result = applyFilter(offers, filter, {}, today);
      expect(result[0].distanceKm, 0.5);
      expect(result[1].distanceKm, 1.5);
      expect(result[2].distanceKm, 3.0);
    });

    test('maxPrice filters correctly', () {
      const filter = DiscoverFilter(maxPrice: 2000);
      final result = applyFilter(offers, filter, {}, today);
      expect(result.length, 2);
      for (final o in result) {
        expect(o.offer.price <= 2000, true);
      }
    });
  });

  group('OfferWithDistance', () {
    test('distanceLabel shows meters for < 1km', () {
      final owd = _makeOWD(storeId: 's1', distanceKm: 0.35);
      expect(owd.distanceLabel, '350 m');
    });

    test('distanceLabel shows km for >= 1km', () {
      final owd = _makeOWD(storeId: 's1', distanceKm: 2.7);
      expect(owd.distanceLabel, '2.7 km');
    });

    test('distanceLabel empty when null', () {
      final owd = _makeOWD(storeId: 's1');
      expect(owd.distanceLabel, '');
    });
  });
}
