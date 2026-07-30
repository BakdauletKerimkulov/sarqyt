import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/data/favorites_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/offer_screen.dart';

Offer _makeOffer() {
  final now = DateTime.now();
  return Offer(
    id: 'offer1',
    storeId: 'store1',
    productId: 'item1',
    quantity: 5,
    name: 'Surprise Bag',
    price: 1500,
    currencyCode: 'KZT',
    currencySymbol: '₸',
    storeName: 'Test Store',
    geopoint: const GeoPoint(43.25, 76.94),
    pickupStartTime: now.add(const Duration(hours: 1)),
    pickupEndTime: now.add(const Duration(hours: 3)),
    createdAt: now,
    createdBy: 'uid1',
    status: OfferStatus.active,
  );
}

void main() {
  group('OfferScreen redirect on null', () {
    testWidgets('navigates to home when offer stream emits null', (
      tester,
    ) async {
      final controller = StreamController<Offer?>();
      addTearDown(controller.close);

      // Emit a valid offer first
      controller.add(_makeOffer());

      final homeRoute = GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => const Scaffold(body: Text('HOME')),
        routes: [
          GoRoute(
            path: 'offer/:id',
            name: 'offer',
            builder: (_, state) {
              final offerId = state.pathParameters['id']!;
              return OfferScreen(offerId: offerId);
            },
          ),
        ],
      );

      final router = GoRouter(
        initialLocation: '/offer/offer1',
        routes: [homeRoute],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            offerStreamProvider(
              'offer1',
            ).overrideWith((_) => controller.stream),
            favoriteStoreIdsProvider.overrideWith(
              (_) => Stream.value(const <String>{}),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify offer screen is showing
      expect(find.text('Surprise Bag'), findsOneWidget);

      // Emit null — offer deleted
      controller.add(null);
      await tester.pumpAndSettle();

      // Should have navigated to home
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('Surprise Bag'), findsNothing);
    });
  });
}
