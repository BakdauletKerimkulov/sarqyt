// ignore_for_file: scoped_providers_should_specify_dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/calendar_content.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

Offer _makeOffer({
  required String id,
  required DateTime pickupStart,
  OfferStatus status = OfferStatus.active,
  int quantity = 3,
}) {
  return Offer(
    id: id,
    storeId: 'store1',
    productId: 'item1',
    quantity: quantity,
    name: 'Surprise bag',
    price: 1500,
    currencyCode: 'KZT',
    currencySymbol: '₸',
    storeName: 'Test store',
    geopoint: const GeoPoint(43.25, 76.94),
    pickupStartTime: pickupStart,
    pickupEndTime: pickupStart.add(const Duration(hours: 2)),
    createdAt: DateTime(2026, 1, 1),
    createdBy: 'uid1',
    status: status,
  );
}

Widget _buildSubject(List<Offer> offers) {
  return ProviderScope(
    overrides: [
      offersForItemProvider(
        'store1',
        'item1',
      ).overrideWith((_) => Stream.value(offers)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(
        body: CalendarContent(storeId: 'store1', itemId: 'item1'),
      ),
    ),
  );
}

void main() {
  group('CalendarContent', () {
    testWidgets('shows empty state with no offers', (tester) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pumpAndSettle();

      expect(find.text('No scheduled pickups yet'), findsOneWidget);
    });

    testWidgets('groups offers by pickup date', (tester) async {
      final day1 = DateTime(2026, 8, 10, 9);
      final day2 = DateTime(2026, 8, 11, 9);
      await tester.pumpWidget(
        _buildSubject([
          _makeOffer(id: 'o1', pickupStart: day1),
          _makeOffer(id: 'o2', pickupStart: day2),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('10 August'), findsOneWidget);
      expect(find.textContaining('11 August'), findsOneWidget);
    });

    testWidgets('shows quantity and time window for each offer', (
      tester,
    ) async {
      final day1 = DateTime(2026, 8, 10, 9, 30);
      await tester.pumpWidget(
        _buildSubject([_makeOffer(id: 'o1', pickupStart: day1, quantity: 5)]),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('09:30'), findsOneWidget);
      expect(find.text('5 left'), findsOneWidget);
    });
  });
}
