import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';

part 'user_metadata_repository.g.dart';

class UserMetadataRepository {
  const UserMetadataRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<DateTime?> watchUserMetadata(UserID uid) {
    final ref = _firestore.doc('users/$uid');
    return ref.snapshots().map((snapshot) {
      final data = snapshot.data();
      final refreshTime = data?['refreshTime'];
      if (refreshTime is Timestamp) {
        return refreshTime.toDate();
      } else {
        return null;
      }
    });
  }
}

@Riverpod(keepAlive: true)
UserMetadataRepository userMetadataRepository(Ref ref) {
  return UserMetadataRepository(FirebaseFirestore.instance);
}
