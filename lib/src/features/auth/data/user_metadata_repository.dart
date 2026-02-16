import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';

part 'user_metadata_repository.g.dart';

class UserMetadataRepository {
  const UserMetadataRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<DateTime?> watchUserMetadata(UserID uid) {
    // TODO: реализовать логику
    return Stream.value(null);
  }
}

@Riverpod(keepAlive: true)
UserMetadataRepository userMetadataRepository(Ref ref) {
  return UserMetadataRepository(FirebaseFirestore.instance);
}
