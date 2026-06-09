import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/orders_screen.dart';

void main() {
  group('OrdersScreen', () {
    testWidgets('AppBar contains history icon button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerOrdersStreamProvider
                .overrideWith((_) => Stream.value(<Order>[])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const OrdersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });
  });
}
