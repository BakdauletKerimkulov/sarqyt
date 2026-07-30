import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/business_console/domain/business_membership.dart';

part 'business_membership_repository.g.dart';

class BusinessMembershipRepository {
  const BusinessMembershipRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static const _collection = 'business_membership';

  /// Watch a single membership document by composite ID.
  Stream<BusinessMembership?> watchMembership(
    String businessId,
    String userId,
  ) {
    final compositeId = '${businessId}_$userId';
    return _membershipRef(compositeId).snapshots().map((snap) => snap.data());
  }

  /// Watch all members of a business.
  Stream<List<BusinessMembership>> watchBusinessMembers(String businessId) {
    return _firestore
        .collection(_collection)
        .where('businessId', isEqualTo: businessId)
        .withConverter(
          fromFirestore: (doc, _) => BusinessMembership.fromJson(doc.data()!),
          toFirestore: (BusinessMembership m, _) => m.toJson(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  DocumentReference<BusinessMembership> _membershipRef(String id) => _firestore
      .collection(_collection)
      .doc(id)
      .withConverter(
        fromFirestore: (doc, _) => BusinessMembership.fromJson(doc.data()!),
        toFirestore: (BusinessMembership m, _) => m.toJson(),
      );
}

@Riverpod(keepAlive: true)
BusinessMembershipRepository businessMembershipRepository(Ref ref) {
  return BusinessMembershipRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<BusinessMembership?> businessMembershipStream(
  Ref ref,
  String businessId,
  String userId,
) {
  return ref
      .watch(businessMembershipRepositoryProvider)
      .watchMembership(businessId, userId);
}

@riverpod
Stream<List<BusinessMembership>> businessMembersStream(
  Ref ref,
  String businessId,
) {
  return ref
      .watch(businessMembershipRepositoryProvider)
      .watchBusinessMembers(businessId);
}
