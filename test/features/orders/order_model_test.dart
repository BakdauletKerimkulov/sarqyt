import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';

Order _makeOrder({
  double unitPrice = 1500,
  int itemQuantity = 2,
  String currencySymbol = '₸',
  DateTime? pickupStartTime,
  DateTime? pickupEndTime,
  OrderStatus status = OrderStatus.confirmed,
}) {
  return Order(
    id: 'o1',
    itemId: 'i1',
    storeId: 's1',
    customerId: 'u1',
    itemName: 'Surprise bag',
    storeName: 'Test Store',
    unitPrice: unitPrice,
    currencySymbol: currencySymbol,
    itemQuantity: itemQuantity,
    status: status,
    paymentStatus: PaymentStatus.paid,
    pickupStartTime: pickupStartTime,
    pickupEndTime: pickupEndTime,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('Order.totalFormatted', () {
    test('calculates total correctly', () {
      final order = _makeOrder(unitPrice: 1500, itemQuantity: 2);
      expect(order.totalFormatted, '3000 ₸');
    });

    test('rounds fractional total', () {
      final order = _makeOrder(unitPrice: 999.7, itemQuantity: 3);
      // 999.7 * 3 = 2999.1 → round = 2999
      expect(order.totalFormatted, '2999 ₸');
    });

    test('single item', () {
      final order = _makeOrder(unitPrice: 500, itemQuantity: 1);
      expect(order.totalFormatted, '500 ₸');
    });
  });

  group('Order.timeUntilPickupEnd', () {
    test('null when pickupEndTime is null', () {
      final order = _makeOrder();
      expect(order.timeUntilPickupEnd, isNull);
    });

    test('zero when pickup already ended', () {
      final order = _makeOrder(
        pickupEndTime: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(order.timeUntilPickupEnd, Duration.zero);
    });

    test('positive when pickup not ended yet', () {
      final order = _makeOrder(
        pickupEndTime: DateTime.now().add(const Duration(hours: 2)),
      );
      final remaining = order.timeUntilPickupEnd!;
      expect(remaining.inMinutes, greaterThan(100));
    });
  });

  group('Order.isPickupExpired', () {
    test('false when pickupEndTime is null', () {
      final order = _makeOrder();
      expect(order.isPickupExpired, false);
    });

    test('true when past pickupEndTime', () {
      final order = _makeOrder(
        pickupEndTime: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(order.isPickupExpired, true);
    });

    test('false when before pickupEndTime', () {
      final order = _makeOrder(
        pickupEndTime: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(order.isPickupExpired, false);
    });
  });

  // pickupLabel is a presentation-layer extension (pickupLabelLocalized)
  // that requires BuildContext — tested in widget tests, not here.

  group('Order.fromJson backward compatibility', () {
    Map<String, dynamic> baseJson() => {
          'id': 'o1',
          'itemId': 'i1',
          'storeId': 's1',
          'customerId': 'u1',
          'itemName': 'Surprise bag',
          'storeName': 'Test Store',
          'unitPrice': 1500,
          'itemQuantity': 2,
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        };

    test('handles null paymentStatus (new orders)', () {
      final json = baseJson(); // no paymentStatus key
      final order = Order.fromJson(json);
      expect(order.paymentStatus, isNull);
    });

    test('handles existing paymentStatus "paid" (old orders)', () {
      final json = baseJson()..['paymentStatus'] = 'paid';
      final order = Order.fromJson(json);
      expect(order.paymentStatus, PaymentStatus.paid);
    });

    test('reads cancellationReason', () {
      final json = baseJson()
        ..['status'] = 'cancelled'
        ..['cancellationReason'] = 'Store closed early';
      final order = Order.fromJson(json);
      expect(order.cancellationReason, 'Store closed early');
    });

    test('reads cancelledBy store', () {
      final json = baseJson()
        ..['status'] = 'cancelled'
        ..['cancelledBy'] = 'store';
      final order = Order.fromJson(json);
      expect(order.cancelledBy, CancelledBy.store);
    });

    test('reads cancelledBy customer', () {
      final json = baseJson()
        ..['status'] = 'cancelled'
        ..['cancelledBy'] = 'customer';
      final order = Order.fromJson(json);
      expect(order.cancelledBy, CancelledBy.customer);
    });

    test('cancelledBy defaults to null when absent', () {
      final json = baseJson();
      final order = Order.fromJson(json);
      expect(order.cancelledBy, isNull);
    });

    test('handles unknown paymentStatus gracefully (e.g. "expired")', () {
      final json = baseJson()..['paymentStatus'] = 'expired';
      final order = Order.fromJson(json);
      expect(order.paymentStatus, isNull);
    });
  });
}
