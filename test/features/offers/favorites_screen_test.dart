import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/offers/data/favorites_repository.dart';
import 'package:sarqyt/src/features/offers/presentation/favorites/favorites_screen.dart';
import 'package:sarqyt/src/features/store/domain/address.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/location.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

final _testStore = Store(
  id: 'store-1',
  name: 'Test Bakery',
  location: Location(
    location: const LatLng(43.25, 76.94),
    geohash: 'txn0e',
    address: Address(
      address: '123 Main St',
      locality: 'Almaty',
      postalCode: '050000',
      country: CountryD(isoCode: 'KZ', name: 'Kazakhstan'),
    ),
  ),
);

void main() {
  group('FavoritesScreen', () {
    testWidgets('shows empty placeholder when no favorites', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteStoresProvider.overrideWith((_) => const AsyncData([])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const FavoritesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      // ARB uses '' as ICU escape for apostrophe
      expect(find.text("You don''t have any favorite restaurants yet"),
          findsOneWidget);
    });

    testWidgets('shows store list when favorites present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteStoresProvider
                .overrideWith((_) => AsyncData([_testStore])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const FavoritesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Bakery'), findsOneWidget);
      expect(find.text('123 Main St, Almaty, Kazakhstan'), findsOneWidget);
    });
  });
}
