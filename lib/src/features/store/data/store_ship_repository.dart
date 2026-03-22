import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';

part 'store_ship_repository.g.dart';

class StoreShipRepository {
  const StoreShipRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String storeStaffPath(String storeShipId) => 'storeShips/$storeShipId';
  static String storeStaffsPath() => 'storeShips';

  Future<StoreShip?> fetchStoreShip(String storeShipId) async {
    final ref = _storeStaffRef(storeShipId);
    final snapshot = await ref.get();
    return snapshot.data();
  }

  Stream<StoreShip?> watchStoreRef(String storeShipId) {
    final ref = _storeStaffRef(storeShipId);
    return ref.snapshots().map((snapshot) => snapshot.data());
  }

  Future<List<StoreShip>> fetchStoreShipsListForPartner(UserID uid) async {
    final ref = _storeStaffsRef(uid);
    final snapshot = await ref.get();
    return snapshot.docs.map((snapshot) => snapshot.data()).toList();
  }

  Stream<List<StoreShip>> watchStoreShipsListForPartner(UserID uid) {
    final ref = _storeStaffsRef(uid);
    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> updateOnboardingStatus({
    required String storeId,
    required UserID uid,
    required OnboardingStatus status,
  }) {
    final compositeId = '${storeId}_$uid';
    return _firestore.collection(storeStaffsPath()).doc(compositeId).update({
      'onboardingStatus': status.name,
    });
  }

  DocumentReference<StoreShip> _storeStaffRef(String storeShipId) => _firestore
      .doc(storeStaffPath(storeShipId))
      .withConverter(
        fromFirestore: (doc, _) => StoreShip.fromJson(doc.data()!),
        toFirestore: (StoreShip st, _) => st.toJson(),
      );

  Query<StoreShip> _storeStaffsRef(UserID uid) => _firestore
      .collection(storeStaffsPath())
      .withConverter(
        fromFirestore: (doc, _) => StoreShip.fromJson(doc.data()!),
        toFirestore: (StoreShip st, _) => st.toJson(),
      )
      .where('userId', isEqualTo: uid)
      .orderBy('userId');
}

@Riverpod(keepAlive: true)
StoreShipRepository storeShipRepository(Ref ref) {
  return StoreShipRepository(FirebaseFirestore.instance);
}

@riverpod
FutureOr<List<StoreShip>> storeShipsListFutureForPartner(Ref ref, String uid) {
  final repo = ref.read(storeShipRepositoryProvider);
  return repo.fetchStoreShipsListForPartner(uid);
}

@riverpod
Stream<List<StoreShip>> storeShipsListStreamForPartner(Ref ref, String uid) {
  final repo = ref.read(storeShipRepositoryProvider);
  return repo.watchStoreShipsListForPartner(uid);
}

@riverpod
FutureOr<StoreShip?> singleStoreShipForPartner(Ref ref, UserID uid) async {
  final repo = ref.read(storeShipRepositoryProvider);
  final storeShips = await repo.fetchStoreShipsListForPartner(uid);
  return storeShips.first;
}

/// Keeps a live stream of the current partner's [StoreShip] list.
///
/// - `keepAlive: true` so redirect can read `.valueOrNull` synchronously.
/// - Re-subscribes when the authenticated user changes.
@Riverpod(keepAlive: true)
Stream<List<StoreShip>> currentPartnerStoreShips(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream<List<StoreShip>>.empty();
  return ref
      .watch(storeShipRepositoryProvider)
      .watchStoreShipsListForPartner(user.uid);
}
