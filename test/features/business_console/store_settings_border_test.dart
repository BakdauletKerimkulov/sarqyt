import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/business_console/presentation/settings_screen.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/business_router.dart';

final _testShip = StoreShip(
  storeId: 'store-1',
  businessId: 'biz-1',
  userId: 'user-1',
  permissions: [],
  name: 'Alice',
  role: StoreRole.owner,
  welcomeCompleted: true,
);

void main() {
  testWidgets(
    'StoreSettingsContent border wraps content (uses SingleChildScrollView)',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStoreShipProvider.overrideWithValue(_testShip),
            storeStreamProvider('store-1')
                .overrideWith((_) => const Stream.empty()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: StoreSettingsContent()),
          ),
        ),
      );

      // SingleChildScrollView loosens tight constraints so the border
      // wraps content instead of stretching to fill the tab.
      expect(
        find.descendant(
          of: find.byType(StoreSettingsContent),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    },
  );
}
