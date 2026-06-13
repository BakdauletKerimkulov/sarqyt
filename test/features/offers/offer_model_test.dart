import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

Offer _makeOffer({
  DateTime? pickupStart,
  DateTime? pickupEnd,
  int quantity = 5,
  OfferStatus status = OfferStatus.active,
}) {
  final now = DateTime.now();
  return Offer(
    id: 'offer1',
    storeId: 'store1',
    productId: 'item1',
    quantity: quantity,
    name: 'Surprise Bag',
    price: 1500,
    currencyCode: 'KZT',
    currencySymbol: '₸',
    storeName: 'Test Store',
    geopoint: const GeoPoint(43.25, 76.94),
    pickupStartTime: pickupStart ?? now.add(const Duration(hours: 1)),
    pickupEndTime: pickupEnd ?? now.add(const Duration(hours: 3)),
    createdAt: now,
    createdBy: 'uid1',
    status: status,
  );
}

void main() {
  group('Offer model', () {
    test('isActive returns true for active status', () {
      final offer = _makeOffer(status: OfferStatus.active);
      expect(offer.isActive, true);
    });

    test('isActive returns false for paused status', () {
      final offer = _makeOffer(status: OfferStatus.paused);
      expect(offer.isActive, false);
    });

    test('isAvailable returns true when quantity > 0', () {
      final offer = _makeOffer(quantity: 5);
      expect(offer.isAvailable, true);
    });

    test('isAvailable returns false when quantity == 0', () {
      final offer = _makeOffer(quantity: 0);
      expect(offer.isAvailable, false);
    });

    // availableText is a presentation-layer extension (availableTextLocalized)
    // that requires BuildContext — tested in widget tests, not here.

    test('discountPercent calculates correctly', () {
      final offer = _makeOffer().copyWith(
        price: 1500,
        estimatedValue: 5000,
      );
      // (1 - 1500/5000) * 100 = 70%
      expect(offer.discountPercent, 70);
    });

    test('discountPercent returns 0 when no estimatedValue', () {
      final offer = _makeOffer();
      expect(offer.discountPercent, 0);
    });

    // pickupDayLabel and pickupLabel are presentation-layer extensions
    // that require BuildContext — tested in widget tests, not here.
  });
}
