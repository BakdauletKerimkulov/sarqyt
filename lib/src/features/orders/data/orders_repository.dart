import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'orders_repository.g.dart';

class StoreOrdersRepository {
  const StoreOrdersRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String ordersPath() => 'orders';
  static String orderPath(OrderID id) => 'orders/$id';

  Stream<List<Order>> watchOrdersListForStore(StoreID storeId) {
    final ref = _ordersRef();
    return ref
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Order?> watchOrder(OrderID id) {
    final ref = _orderRef(id);
    return ref.snapshots().map((snapshot) => snapshot.data());
  }

  DocumentReference<Order> _orderRef(OrderID id) => _firestore
      .doc(orderPath(id))
      .withConverter(
        fromFirestore: (doc, _) => Order.fromJson(doc.data()!),
        toFirestore: (Order order, _) => order.toJson(),
      );

  Query<Order> _ordersRef() => _firestore
      .collection(ordersPath())
      .withConverter(
        fromFirestore: (doc, _) => Order.fromJson(doc.data()!),
        toFirestore: (Order order, _) => order.toJson(),
      )
      .orderBy('status');
}

@riverpod
StoreOrdersRepository ordersRepository(Ref ref) {
  return StoreOrdersRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Order>> ordersListStream(Ref ref, StoreID id) {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.watchOrdersListForStore(id);
}
