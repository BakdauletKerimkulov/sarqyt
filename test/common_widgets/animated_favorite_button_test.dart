import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/common_widgets/animated_favorite_button.dart';

void main() {
  Widget buildTestWidget({required bool isFavorite, VoidCallback? onToggle}) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedFavoriteButton(
          isFavorite: isFavorite,
          storeName: 'Test Store',
          onToggle: onToggle,
        ),
      ),
    );
  }

  group('AnimatedFavoriteButton', () {
    testWidgets('shows filled heart when isFavorite is true', (tester) async {
      await tester.pumpWidget(buildTestWidget(isFavorite: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('shows outline heart when isFavorite is false', (tester) async {
      await tester.pumpWidget(buildTestWidget(isFavorite: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('calls onToggle when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(isFavorite: false, onToggle: () => tapped = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AnimatedFavoriteButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not crash when onToggle is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(isFavorite: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AnimatedFavoriteButton));
      await tester.pumpAndSettle();
      // No error expected
    });
  });
}
