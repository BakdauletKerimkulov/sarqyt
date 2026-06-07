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
        foodRating: 4,
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
        foodRating: 5,
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
        foodRating: 5,
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
        foodRating: 1,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(review.averageRating, 1.0);
    });
  });
}
