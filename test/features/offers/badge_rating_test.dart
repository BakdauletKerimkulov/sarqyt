import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/offers/domain/badge.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';

void main() {
  group('Badge', () {
    group('requiresStats', () {
      test('true for topRated', () {
        const badge = Badge(type: BadgeType.topRated);
        expect(badge.requiresStats, true);
      });

      test('true for trending', () {
        const badge = Badge(type: BadgeType.trending);
        expect(badge.requiresStats, true);
      });

      test('false for popular', () {
        const badge = Badge(type: BadgeType.popular);
        expect(badge.requiresStats, false);
      });

      test('false for eco', () {
        const badge = Badge(type: BadgeType.eco);
        expect(badge.requiresStats, false);
      });
    });

    group('isDecorative', () {
      test('true for eco', () {
        const badge = Badge(type: BadgeType.eco);
        expect(badge.isDecorative, true);
      });

      test('true for special', () {
        const badge = Badge(type: BadgeType.special);
        expect(badge.isDecorative, true);
      });

      test('false for popular', () {
        const badge = Badge(type: BadgeType.popular);
        expect(badge.isDecorative, false);
      });

      test('false for topRated', () {
        const badge = Badge(type: BadgeType.topRated);
        expect(badge.isDecorative, false);
      });
    });

    group('serialization', () {
      test('toMap / fromMap roundtrip', () {
        const badge = Badge(
          type: BadgeType.popular,
          percentage: 85,
          userCount: 120,
        );
        final map = badge.toMap();
        final restored = Badge.fromMap(map);

        expect(restored.type, BadgeType.popular);
        expect(restored.percentage, 85);
        expect(restored.userCount, 120);
      });

      test('toMap with null optional fields', () {
        const badge = Badge(type: BadgeType.eco);
        final map = badge.toMap();

        expect(map['type'], 'eco');
        expect(map['percentage'], isNull);
        expect(map['userCount'], isNull);
      });
    });
  });

  group('Rating', () {
    test('fromMap / toMap roundtrip', () {
      final rating = Rating.fromMap({'average': 4.5, 'ratingCount': 10});
      final map = rating.toMap();

      expect(map['average'], 4.5);
      expect(map['ratingCount'], 10);
    });

    test('fromMap defaults missing values', () {
      final rating = Rating.fromMap({});
      expect(rating.average, 0.0);
      expect(rating.ratingCount, 0);
    });

    test('validate passes for valid rating', () {
      const rating = Rating(average: 3.5, ratingCount: 5);
      // Should not throw
      rating.validate();
    });
  });
}
