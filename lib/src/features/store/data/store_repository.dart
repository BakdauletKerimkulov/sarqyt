import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';

part 'store_repository.g.dart';

class StoreRepository {
  const StoreRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String storesPath() => 'stores';
  static String storePath(String id) => 'stores/$id';

  Future<void> createStore({
    required UserID ownerId,
    required StoreDraft store,
  }) {
    final docRef = _firestore.collection(storesPath()).doc();

    return docRef.set(
      store.toFirestore(ownerId: ownerId, storeId: docRef.id),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteStore(StoreID id) {
    return _firestore.doc(storePath(id)).delete();
  }

  Future<void> updateStore(Store store) {
    return _storeRef(store.id).set(store);
  }

  Stream<List<Store>> watchStoresList(UserID ownerId) {
    return _storesRef()
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Store?> watchStore(StoreID storeId) {
    return _storeRef(storeId).snapshots().map((snapshot) => snapshot.data());
  }

  DocumentReference<Store> _storeRef(StoreID id) => _firestore
      .doc(storePath(id))
      .withConverter(
        fromFirestore: (doc, _) => Store.fromMap(doc.data()!),
        toFirestore: (Store store, _) => store.toMap(),
      );

  Query<Store> _storesRef() => _firestore
      .collection(storesPath())
      .withConverter(
        fromFirestore: (doc, _) => Store.fromMap(doc.data()!),
        toFirestore: (Store store, options) => store.toMap(),
      );
}

@Riverpod(keepAlive: true)
StoreRepository storeRepository(Ref ref) {
  return StoreRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Store>> storeListStream(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;

  if (user != null) {
    return ref.watch(storeRepositoryProvider).watchStoresList(user.uid);
  } else {
    return Stream.empty();
  }
}

@riverpod
Stream<Store?> storeStream(Ref ref, StoreID storeId) {
  return ref.watch(storeRepositoryProvider).watchStore(storeId);
}
