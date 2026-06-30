import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_detail_screen.dart';

Order _makeOrder({
  OrderStatus status = OrderStatus.confirmed,
  CancelledBy? cancelledBy,
  String? cancellationReason,
  PaymentStatus? paymentStatus,
}) {
  return Order(
    id: 'o1',
    itemId: 'i1',
    storeId: 's1',
    customerId: 'u1',
    itemName: 'Surprise bag',
    storeName: 'Test Store',
    unitPrice: 1500,
    itemQuantity: 2,
    status: status,
    paymentStatus: paymentStatus,
    cancelledBy: cancelledBy,
    cancellationReason: cancellationReason,
    createdAt: DateTime(2026, 1, 1),
  );
}

Widget _buildScreen(Order order) {
  return ProviderScope(
    overrides: [
      customerOrderStreamProvider(order.id).overrideWith(
        (_) => Stream.value(order),
      ),
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
  group('OrderDetailScreen cancel button', () {
    testWidgets('shows cancel for confirmed', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeOrder()));
      await tester.pumpAndSettle();
      expect(find.text('Cancel order'), findsOneWidget);
    });

    testWidgets('shows cancel for preparing', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeOrder(status: OrderStatus.preparing)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cancel order'), findsOneWidget);
    });

    testWidgets('shows cancel for readyForPickup', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeOrder(status: OrderStatus.readyForPickup)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cancel order'), findsOneWidget);
    });

    testWidgets('hides cancel for completed', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeOrder(status: OrderStatus.completed)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cancel order'), findsNothing);
    });
  });

  group('OrderDetailScreen cancellation reason', () {
    testWidgets('shows store cancellation reason', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeOrder(
          status: OrderStatus.cancelled,
          cancelledBy: CancelledBy.store,
          cancellationReason: 'Store closed early',
        )),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cancelled by store'), findsOneWidget);
      expect(find.text('Store closed early'), findsOneWidget);
    });

    testWidgets('hides cancellation banner for customer cancel', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeOrder(
          status: OrderStatus.cancelled,
          cancelledBy: CancelledBy.customer,
        )),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cancelled by store'), findsNothing);
    });
  });

  group('OrderDetailScreen payment', () {
    testWidgets('shows pay on pickup text', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeOrder()));
      await tester.pumpAndSettle();
      expect(find.text('Pay on pickup'), findsOneWidget);
    });
  });
}
