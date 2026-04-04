import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';

part 'client_orders_repository.g.dart';

class ClientOrdersRepository {
  const ClientOrdersRepository(this._firestore);
  final FirebaseFirestore _firestore;

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

  /// Watch for an order created from a specific reservation.
  /// Returns the first matching order, or stays open until one appears.
  Stream<Order?> watchOrderByReservation(String reservationId) {
    return _firestore
        .collection('orders')
        .where('reservationId', isEqualTo: reservationId)
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
  return ClientOrdersRepository(FirebaseFirestore.instance);
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
