import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';

part 'business_repository.g.dart';

class BusinessRepository {
  const BusinessRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String businessPath(BusinessID id) => 'businesses/$id';

  Future<Business?> fetchBusinessInfo(BusinessID id) async {
    final ref = _businessRef(id);
    final snap = await ref.get();
    return snap.data();
  }

  Stream<Business?> watchBusiness(BusinessID id) {
    return _businessRef(id).snapshots().map((snap) => snap.data());
  }

  /// Sets verificationStatus to "submitted" and fires the fake CF (fire-and-forget).
  Future<void> submitVerification(BusinessID businessId) async {
    await _firestore
        .doc(businessPath(businessId))
        .update({'verificationStatus': 'submitted'});

    final callable =
        FirebaseFunctions.instance.httpsCallable('fakeVerifyBusiness');
    // Fire-and-forget — do not await
    callable.call<dynamic>({'businessId': businessId});
  }

  DocumentReference<Business> _businessRef(BusinessID id) => _firestore
      .doc(businessPath(id))
      .withConverter(
        fromFirestore: (doc, _) => Business.fromJson(doc.data()!),
        toFirestore: (Business bus, _) => bus.toJson(),
      );
}

@riverpod
BusinessRepository businessRepository(Ref ref) {
  return BusinessRepository(FirebaseFirestore.instance);
}

@riverpod
FutureOr<Business?> businessFuture(Ref ref, BusinessID id) {
  final repo = ref.read(businessRepositoryProvider);
  return repo.fetchBusinessInfo(id);
}

@riverpod
Stream<Business?> businessStream(Ref ref, BusinessID id) {
  final repo = ref.read(businessRepositoryProvider);
  return repo.watchBusiness(id);
}
