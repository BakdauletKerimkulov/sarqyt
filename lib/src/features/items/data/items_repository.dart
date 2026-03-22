import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'items_repository.g.dart';

class ItemsRepository {
  const ItemsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String itemsPath(StoreID storeId) => 'stores/$storeId/items';
  static String itemPath(StoreID storeId, ItemID itemId) =>
      'stores/$storeId/items/$itemId';

  Future<List<Item>> fetchItemsList(StoreID storeId) async {
    final ref = _itemsRef(storeId);
    final snapshot = await ref.get();
    return snapshot.docs.map((snapshot) => snapshot.data()).toList();
  }

  Stream<List<Item>> watchItemsList(StoreID storeId) {
    final ref = _itemsRef(storeId);
    return ref.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((docSnapshot) => docSnapshot.data()).toList(),
    );
  }

  Future<Item?> fetchItem(StoreID storeId, ItemID id) async {
    final ref = _itemRef(storeId, id);
    final snapshot = await ref.get();
    return snapshot.data();
  }

  Stream<Item?> watchItem(StoreID storeId, ItemID id) {
    final ref = _itemRef(storeId, id);
    return ref.snapshots().map((snapshot) => snapshot.data());
  }

  /// All fields are required and validated by the caller (controller/service).
  Future<void> createItem(
    StoreID storeId, {
    required String name,
    required String description,
    required double price,
    double? estimatedValue,
    required WeeklySchedule schedule,
    String? imageUrl,
  }) {
    final docRef = _firestore.collection(itemsPath(storeId)).doc();
    return docRef.set({
      'id': docRef.id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      if (estimatedValue != null) 'estimatedValue': estimatedValue,
      'schedule': schedule.toMap(),
      'badges': <Map<String, dynamic>>[],
    });
  }

  Future<void> updateItem(StoreID storeId, {required Item item}) {
    return _itemRef(storeId, item.id).set(item, SetOptions(merge: true));
  }

  Future<void> deleteItem(StoreID storeId, {required ItemID id}) {
    return _firestore.doc(itemPath(storeId, id)).delete();
  }

  DocumentReference<Item> _itemRef(StoreID storeId, ItemID id) => _firestore
      .doc(itemPath(storeId, id))
      .withConverter(
        fromFirestore: (doc, _) => Item.fromJson(doc.data()!),
        toFirestore: (Item item, options) => item.toJson(),
      );

  Query<Item> _itemsRef(StoreID storeId) => _firestore
      .collection(itemsPath(storeId))
      .withConverter(
        fromFirestore: (doc, _) => Item.fromJson(doc.data()!),
        toFirestore: (Item item, options) => item.toJson(),
      )
      .orderBy('id');
}

@Riverpod(keepAlive: true)
ItemsRepository itemsRepository(Ref ref) {
  return ItemsRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Item>> itemsListStream(Ref ref, StoreID storeId) {
  final repo = ref.watch(itemsRepositoryProvider);
  return repo.watchItemsList(storeId);
}

@riverpod
FutureOr<List<Item>> itemsListFuture(Ref ref, StoreID storeId) {
  final repo = ref.watch(itemsRepositoryProvider);
  return repo.fetchItemsList(storeId);
}

@riverpod
Stream<Item?> itemStream(
  Ref ref, {
  required StoreID storeId,
  required ItemID id,
}) {
  final repo = ref.watch(itemsRepositoryProvider);
  return repo.watchItem(storeId, id);
}

@riverpod
FutureOr<Item?> itemFuture(
  Ref ref, {
  required StoreID storeId,
  required ItemID id,
}) {
  final repo = ref.read(itemsRepositoryProvider);
  return repo.fetchItem(storeId, id);
}
