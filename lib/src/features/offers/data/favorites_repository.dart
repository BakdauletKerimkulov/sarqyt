import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';

part 'favorites_repository.g.dart';

class FavoritesRepository {
  const FavoritesRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _favRef(UserID uid) =>
      _firestore.collection('users/$uid/favorites');

  Stream<Set<String>> watchFavoriteStoreIds(UserID uid) {
    return _favRef(uid).snapshots().map(
          (snap) => snap.docs.map((doc) => doc.id).toSet(),
        );
  }

  Future<void> addFavorite(UserID uid, String storeId) {
    return _favRef(uid).doc(storeId).set({'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite(UserID uid, String storeId) {
    return _favRef(uid).doc(storeId).delete();
  }
}

@Riverpod(keepAlive: true)
FavoritesRepository favoritesRepository(Ref ref) {
  return FavoritesRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<Set<String>> favoriteStoreIds(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(const {});
  return ref.watch(favoritesRepositoryProvider).watchFavoriteStoreIds(user.uid);
}
