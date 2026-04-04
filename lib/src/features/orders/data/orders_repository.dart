import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'orders_repository.g.dart';

class StoreOrdersRepository {
  const StoreOrdersRepository(this._firestore, this._functions);
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  static String ordersPath() => 'orders';
  static String orderPath(OrderID id) => 'orders/$id';

  Stream<List<Order>> watchOrdersListForStore(StoreID storeId) {
    return _firestore
        .collection(ordersPath())
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .withConverter(
          fromFirestore: (doc, _) => Order.fromJson(doc.data()!),
          toFirestore: (Order order, _) => order.toJson(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Stream<Order?> watchOrder(OrderID id) {
    final ref = _orderRef(id);
    return ref.snapshots().map((snapshot) => snapshot.data());
  }

  Future<void> updateOrderStatus(OrderID orderId, String status) async {
    final callable = _functions.httpsCallable('updateOrderStatus');
    await callable.call({'orderId': orderId, 'status': status});
  }

  DocumentReference<Order> _orderRef(OrderID id) => _firestore
      .doc(orderPath(id))
      .withConverter(
        fromFirestore: (doc, _) => Order.fromJson(doc.data()!),
        toFirestore: (Order order, _) => order.toJson(),
      );
}

@riverpod
StoreOrdersRepository ordersRepository(Ref ref) {
  return StoreOrdersRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
}

@riverpod
Stream<List<Order>> ordersListStream(Ref ref, StoreID id) {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.watchOrdersListForStore(id);
}
