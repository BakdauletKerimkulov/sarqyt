// ignore_for_file: scoped_providers_should_specify_dependencies
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/business/business_orders_screen.dart';

Order _readyForPickupOrder({
  DateTime? pickupStartTime,
  DateTime? pickupEndTime,
}) => Order(
  id: 'order-1',
  itemId: 'item-1',
  storeId: 'store-1',
  customerId: 'user-1',
  itemName: 'Surprise Bag',
  storeName: 'Test Store',
  unitPrice: 1500,
  itemQuantity: 1,
  status: OrderStatus.readyForPickup,
  paymentStatus: PaymentStatus.paid,
  pickupStartTime: pickupStartTime,
  pickupEndTime: pickupEndTime,
  createdAt: DateTime(2026, 1, 1),
);

Widget _buildSubject(Order order) {
  return ProviderScope(
    overrides: [
      ordersListStreamProvider(
        'store-1',
      ).overrideWith((_) => Stream.value([order])),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [SliverBusinessOrders(storeId: 'store-1')],
        ),
      ),
    ),
  );
}

void main() {
  group('pickup window gate on business order card', () {
    testWidgets(
      'disables "Mark completed" and shows a reason before the pickup window opens',
      (tester) async {
        final now = DateTime.now();
        final order = _readyForPickupOrder(
          pickupStartTime: now.add(const Duration(hours: 1)),
          pickupEndTime: now.add(const Duration(hours: 2)),
        );

        await tester.pumpWidget(_buildSubject(order));
        await tester.pumpAndSettle();

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Mark completed'),
        );
        expect(button.onPressed, isNull);
        expect(
          find.text('Available once the pickup window opens'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'disables "Mark completed" and shows a reason after the pickup window closes',
      (tester) async {
        final now = DateTime.now();
        final order = _readyForPickupOrder(
          pickupStartTime: now.subtract(const Duration(hours: 2)),
          pickupEndTime: now.subtract(const Duration(hours: 1)),
        );

        await tester.pumpWidget(_buildSubject(order));
        await tester.pumpAndSettle();

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Mark completed'),
        );
        expect(button.onPressed, isNull);
        expect(find.text('Pickup window has closed'), findsOneWidget);
      },
    );

    testWidgets('enables "Mark completed" inside the pickup window', (
      tester,
    ) async {
      final now = DateTime.now();
      final order = _readyForPickupOrder(
        pickupStartTime: now.subtract(const Duration(minutes: 1)),
        pickupEndTime: now.add(const Duration(minutes: 1)),
      );

      await tester.pumpWidget(_buildSubject(order));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Mark completed'),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
