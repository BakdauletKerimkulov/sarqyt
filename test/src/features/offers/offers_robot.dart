import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/offer_card.dart';

/// Robot for the offers/discover feature.
class OffersRobot {
  OffersRobot(this.tester);
  final WidgetTester tester;

  /// Expects at least one [OfferCard] visible on the discover screen.
  void expectOffersVisible() {
    expect(find.byType(OfferCard), findsWidgets);
  }

  /// Taps the first visible offer card and pumps frames for navigation.
  Future<void> tapFirstOffer() async {
    final card = find.byType(OfferCard).first;
    await tester.tap(card);
    // Use pump() loop instead of pumpAndSettle() — CachedNetworkImage keeps
    // firing timers that prevent pumpAndSettle from completing.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Drain image-loading exceptions from the new screen.
    while (tester.takeException() != null) {}
  }

  /// Expects the offer detail screen shows the given store name.
  void expectOfferDetailVisible(String storeName) {
    expect(find.text(storeName), findsWidgets);
  }
}
