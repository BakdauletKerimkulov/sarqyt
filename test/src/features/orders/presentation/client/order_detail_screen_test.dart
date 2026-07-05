import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_detail_screen.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_status_badge.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/order_status_progress_line.dart';

Order _makeOrder(OrderStatus status) => Order(
      id: 'test-order',
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

Widget _buildSubject(Order order) {
  return ProviderScope(
    overrides: [
      customerOrderStreamProvider(order.id)
          .overrideWith((_) => Stream.value(order)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: OrderDetailScreen(orderId: order.id),
    ),
  );
}

void main() {
  group('OrderDetailScreen', () {
    testWidgets('preparing order shows progress line', (tester) async {
      await tester.pumpWidget(_buildSubject(_makeOrder(OrderStatus.preparing)));
      await tester.pumpAndSettle();

      expect(find.byType(OrderStatusProgressLine), findsOneWidget);
      expect(find.byType(OrderStatusBadge), findsNothing);
    });

    testWidgets('completed order shows fully-filled progress line',
        (tester) async {
      await tester.pumpWidget(_buildSubject(_makeOrder(OrderStatus.completed)));
      await tester.pumpAndSettle();

      expect(find.byType(OrderStatusProgressLine), findsOneWidget);
      expect(find.byType(OrderStatusBadge), findsNothing);
    });

    testWidgets('cancelled order shows badge, not progress line',
        (tester) async {
      await tester.pumpWidget(_buildSubject(_makeOrder(OrderStatus.cancelled)));
      await tester.pumpAndSettle();

      expect(find.byType(OrderStatusBadge), findsOneWidget);
      expect(find.byType(OrderStatusProgressLine), findsNothing);
    });
  });
}
