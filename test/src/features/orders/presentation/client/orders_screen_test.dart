import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/orders_screen.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/active_order_card.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/active_order_inline.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/recent_order_card.dart';

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
      customerOrdersStreamProvider
          .overrideWith((_) => Stream.value(orders)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const OrdersScreen(),
    ),
  );
}

void main() {
  group('OrdersScreen', () {
    testWidgets('AppBar contains history icon button', (tester) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('1 active order shows inline view', (tester) async {
      final orders = [
        _makeOrder(id: 'o1', status: OrderStatus.preparing),
      ];
      await tester.pumpWidget(_buildSubject(orders));
      await tester.pumpAndSettle();

      expect(find.byType(ActiveOrderInline), findsOneWidget);
      expect(find.byType(ActiveOrderCard), findsNothing);
    });

    testWidgets('2+ active orders shows cards', (tester) async {
      final orders = [
        _makeOrder(id: 'o1', status: OrderStatus.confirmed),
        _makeOrder(id: 'o2', status: OrderStatus.preparing),
      ];
      await tester.pumpWidget(_buildSubject(orders));
      await tester.pumpAndSettle();

      expect(find.byType(ActiveOrderCard), findsNWidgets(2));
      expect(find.byType(ActiveOrderInline), findsNothing);
    });

    testWidgets(
        '0 active + 5 past shows empty state + max 3 recent cards',
        (tester) async {
      final orders = [
        for (int i = 0; i < 5; i++)
          _makeOrder(id: 'p$i', status: OrderStatus.completed),
      ];
      await tester.pumpWidget(_buildSubject(orders));
      await tester.pumpAndSettle();

      // Empty active state text
      expect(find.textContaining('No active orders'), findsOneWidget);
      // Max 3 recent cards
      expect(find.byType(RecentOrderCard), findsNWidgets(3));
    });
  });
}
