import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/firebase_functions_provider.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';

part 'store_repository.g.dart';

class StoreRepository {
  const StoreRepository(this._firestore, this._functions);
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  static String storesPath() => 'stores';
  static String storePath(String id) => 'stores/$id';

  /// Wire payload for the `createAdditionalStore` callable.
  ///
  /// Pure and static so the shape can be asserted without a Functions client.
  /// The contract it must match lives in
  /// `functions/src/features/stores/functions/create-additional-store.ts` —
  /// note it differs from [StoreDraft.toCallableMap], which serialises the
  /// *onboarding* draft for a different function.
  static Map<String, dynamic> additionalStorePayload({
    required StoreDraft draft,
    required String businessId,
  }) {
    final location = draft.location;
    return {
      'name': draft.name,
      'storeType': draft.storeType?.name ?? '',
      'address': {
        'country': {
          'name': draft.country?.name ?? '',
          'isoCode': draft.country?.isoCode ?? '',
        },
        'address': draft.address ?? '',
        'locality': draft.locality ?? '',
        'postalCode': draft.postalCode ?? '',
      },
      'geo': {
        'geohash': location != null
            ? GeoFirePoint(
                GeoPoint(location.latitude, location.longitude),
              ).geohash
            : '',
        'geopoint': {
          'latitude': location?.latitude ?? 0,
          'longitude': location?.longitude ?? 0,
        },
      },
      'phoneNumber': draft.phoneNumber ?? '',
      'businessId': businessId,
    };
  }

  /// Creates an additional store for an already-verified business.
  ///
  /// Returns the new store id. Throws [FirebaseFunctionsException] on
  /// failure — callers render it via `humanReadableError`.
  Future<String> createAdditionalStore({
    required StoreDraft draft,
    required String businessId,
  }) async {
    final callable = _functions.httpsCallable('createAdditionalStore');
    final result = await callable.call<dynamic>(
      additionalStorePayload(draft: draft, businessId: businessId),
    );
    return result.data['storeId'] as String;
  }

  Future<void> deleteStore(StoreID id) {
    return _firestore.doc(storePath(id)).delete();
  }

  Future<void> updateStore(Store store) {
    return _storeRef(store.id).set(store);
  }

  /// Watches stores owned by [ownerId] (denormalized field).
  /// For full list including stores where user is operator/employer,
  /// combine with storeIds from storeShips.
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
  return StoreRepository(
    FirebaseFirestore.instance,
    ref.watch(firebaseFunctionsProvider),
  );
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
