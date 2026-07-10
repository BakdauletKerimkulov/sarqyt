import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/business/business_orders_screen.dart';

Order _makeOrder({
  required String id,
  required OrderStatus status,
}) =>
    Order(
      id: id,
      itemId: 'item-1',
      storeId: 'store-1',
      customerId: 'user-1',
      itemName: 'Surprise Bag',
      storeName: 'Test Store',
      unitPrice: 1500,
      itemQuantity: 1,
      status: status,
      paymentStatus: PaymentStatus.paid,
      createdAt: DateTime(2026, 1, 1),
    );

Widget _buildSubject(List<Order> orders) {
  return ProviderScope(
    overrides: [
      ordersListStreamProvider('store-1')
          .overrideWith((_) => Stream.value(orders)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverBusinessOrders(storeId: 'store-1'),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('SliverBusinessOrders', () {
    testWidgets(
      'selecting Active filter with no active orders does not crash',
      (tester) async {
        // Only completed orders — no active ones.
        final orders = [
          _makeOrder(id: 'o1', status: OrderStatus.completed),
          _makeOrder(id: 'o2', status: OrderStatus.completed),
        ];

        await tester.pumpWidget(_buildSubject(orders));
        await tester.pumpAndSettle();

        // Tap the "Active" chip to filter — results in empty list.
        await tester.tap(find.text('Active'));
        await tester.pumpAndSettle();

        // Should show empty-state text without crashing.
        expect(tester.takeException(), isNull);
      },
    );
  });
}
