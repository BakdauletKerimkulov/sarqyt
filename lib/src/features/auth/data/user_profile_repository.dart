import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';

part 'user_profile_repository.g.dart';

class UserProfileRepository {
  const UserProfileRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<Map<String, dynamic>?> fetchProfile(UserID uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    return snap.data();
  }

  Stream<Map<String, dynamic>?> watchProfile(UserID uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.data());
  }

  Future<void> updateProfile(UserID uid, {
    String? displayName,
    String? phoneNumber,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (updates.isEmpty) return;

    await _firestore.collection('users').doc(uid).set(
      updates,
      SetOptions(merge: true),
    );

    // Also update Firebase Auth displayName
    if (displayName != null) {
      await _auth.currentUser?.updateDisplayName(displayName);
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) {
  return UserProfileRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
}

@riverpod
Stream<Map<String, dynamic>?> userProfileStream(Ref ref, UserID uid) {
  return ref.watch(userProfileRepositoryProvider).watchProfile(uid);
}
