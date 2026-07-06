import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/business_console/presentation/settings_screen.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/business_router.dart';

final _testShip = StoreShip(
  storeId: 'store-1',
  businessId: 'biz-1',
  userId: 'user-1',
  permissions: ['manage_items'],
  name: 'Alice Owner',
  role: StoreRole.owner,
  welcomeCompleted: true,
);

final _testShip2 = StoreShip(
  storeId: 'store-1',
  businessId: 'biz-1',
  userId: 'user-2',
  permissions: [],
  name: 'Bob Operator',
  role: StoreRole.operator,
  welcomeCompleted: true,
);

void main() {
  group('TeamSettingsContent', () {
    testWidgets('shows team member names from provider', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStoreShipProvider.overrideWithValue(_testShip),
            storeShipsByStoreIdProvider('store-1')
                .overrideWith((_) => Stream.value([_testShip, _testShip2])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: TeamSettingsContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice Owner'), findsOneWidget);
      expect(find.text('Bob Operator'), findsOneWidget);
    });

    testWidgets('shows empty state when no team members', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStoreShipProvider.overrideWithValue(_testShip),
            storeShipsByStoreIdProvider('store-1')
                .overrideWith((_) => Stream.value(<StoreShip>[])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: TeamSettingsContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.group_outlined), findsOneWidget);
    });
  });
}
