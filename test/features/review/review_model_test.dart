import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/review/domain/review.dart';

void main() {
  group('Review.averageRating', () {
    test('average of equal ratings', () {
      final review = Review(
        id: 'r1',
        orderId: 'o1',
        storeId: 's1',
        userId: 'u1',
        storeRating: 4,
        offerRating: 4,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(review.averageRating, 4.0);
    });

    test('average of different ratings', () {
      final review = Review(
        id: 'r1',
        orderId: 'o1',
        storeId: 's1',
        userId: 'u1',
        storeRating: 3,
        offerRating: 5,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(review.averageRating, 4.0);
    });

    test('average with odd sum produces decimal', () {
      final review = Review(
        id: 'r1',
        orderId: 'o1',
        storeId: 's1',
        userId: 'u1',
        storeRating: 4,
        offerRating: 5,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(review.averageRating, 4.5);
    });

    test('minimum ratings', () {
      final review = Review(
        id: 'r1',
        orderId: 'o1',
        storeId: 's1',
        userId: 'u1',
        storeRating: 1,
        offerRating: 1,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(review.averageRating, 1.0);
    });
  });

  group('Review.fromJson backward compat', () {
    test('parses offerRating from new docs', () {
      final json = {
        'id': 'r1',
        'orderId': 'o1',
        'storeId': 's1',
        'userId': 'u1',
        'storeRating': 5,
        'offerRating': 4,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };
      final review = Review.fromJson(json);
      expect(review.offerRating, 4);
      expect(review.storeRating, 5);
      expect(review.averageRating, 4.5);
    });

    test('falls back to foodRating for old docs', () {
      final json = {
        'id': 'r1',
        'orderId': 'o1',
        'storeId': 's1',
        'userId': 'u1',
        'storeRating': 3,
        'foodRating': 5,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };
      final review = Review.fromJson(json);
      expect(review.offerRating, 5);
      expect(review.averageRating, 4.0);
    });

    test('parses itemId when present', () {
      final json = {
        'id': 'r1',
        'orderId': 'o1',
        'storeId': 's1',
        'userId': 'u1',
        'itemId': 'item1',
        'storeRating': 5,
        'offerRating': 4,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };
      final review = Review.fromJson(json);
      expect(review.itemId, 'item1');
    });

    test('itemId is null for pre-existing docs without it', () {
      final json = {
        'id': 'r1',
        'orderId': 'o1',
        'storeId': 's1',
        'userId': 'u1',
        'storeRating': 5,
        'offerRating': 4,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };
      final review = Review.fromJson(json);
      expect(review.itemId, isNull);
    });
  });
}
