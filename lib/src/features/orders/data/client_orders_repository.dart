import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';

part 'client_orders_repository.g.dart';

class ClientOrdersRepository {
  const ClientOrdersRepository(this._firestore, this._functions);
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Future<void> cancelOrder(OrderID orderId) async {
    final callable = _functions.httpsCallable('cancelOrder');
    await callable.call({'orderId': orderId});
  }

  Stream<List<Order>> watchOrdersForCustomer(UserID uid) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .withConverter(
          fromFirestore: (doc, _) => Order.fromJson(doc.data()!),
          toFirestore: (Order order, _) => order.toJson(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  /// Watch for an order created from a specific payment intent.
  Stream<Order?> watchOrderByPaymentIntent(
    String paymentIntentId,
    UserID uid,
  ) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .where('paymentIntentId', isEqualTo: paymentIntentId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : Order.fromJson(snap.docs.first.data()));
  }

  Stream<Order?> watchOrder(OrderID id) {
    return _firestore
        .doc('orders/$id')
        .withConverter(
          fromFirestore: (doc, _) => Order.fromJson(doc.data()!),
          toFirestore: (Order order, _) => order.toJson(),
        )
        .snapshots()
        .map((snap) => snap.data());
  }
}

@Riverpod(keepAlive: true)
ClientOrdersRepository clientOrdersRepository(Ref ref) {
  return ClientOrdersRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
}

@riverpod
Stream<List<Order>> customerOrdersStream(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(clientOrdersRepositoryProvider).watchOrdersForCustomer(user.uid);
}

@riverpod
Stream<Order?> customerOrderStream(Ref ref, OrderID id) {
  return ref.watch(clientOrdersRepositoryProvider).watchOrder(id);
}
