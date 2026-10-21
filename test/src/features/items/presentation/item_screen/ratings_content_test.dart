// ignore_for_file: scoped_providers_should_specify_dependencies
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/ratings_content.dart';
import 'package:sarqyt/src/features/review/data/review_repository.dart';
import 'package:sarqyt/src/features/review/domain/review.dart';

Review _makeReview({
  required String id,
  int storeRating = 4,
  int offerRating = 4,
  String? comment,
  DateTime? createdAt,
}) {
  return Review(
    id: id,
    orderId: id,
    storeId: 'store1',
    userId: 'user1',
    itemId: 'item1',
    storeRating: storeRating,
    offerRating: offerRating,
    comment: comment,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

Widget _buildSubject(List<Review> reviews) {
  return ProviderScope(
    overrides: [
      itemReviewsStreamProvider(
        'item1',
      ).overrideWith((_) => Stream.value(reviews)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      // item_screen.dart wraps tab content in a SingleChildScrollView.
      home: const Scaffold(
        body: SingleChildScrollView(child: RatingsContent(itemId: 'item1')),
      ),
    ),
  );
}

void main() {
  group('RatingsContent', () {
    testWidgets('shows empty state with no reviews', (tester) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pumpAndSettle();

      expect(find.text('Not enough reviews to show a rating'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows overall average and review count', (tester) async {
      await tester.pumpWidget(
        _buildSubject([
          _makeReview(id: 'r1', storeRating: 5, offerRating: 5),
          _makeReview(id: 'r2', storeRating: 5, offerRating: 1),
        ]),
      );
      await tester.pumpAndSettle();

      // Store avg = (5+5)/2 = 5.0, offer avg = (5+1)/2 = 3.0,
      // overall = avg of each review's own averageRating = (5+3)/2 = 4.0.
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('3.0'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);
      expect(find.text('2 reviews'), findsOneWidget);
    });

    testWidgets('lists individual review comments', (tester) async {
      await tester.pumpWidget(
        _buildSubject([
          _makeReview(id: 'r1', comment: 'Great value for money!'),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Great value for money!'), findsOneWidget);
    });
  });
}
