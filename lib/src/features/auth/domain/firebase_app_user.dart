import 'package:firebase_auth/firebase_auth.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';

class FirebaseAppUser extends AppUser {
  FirebaseAppUser(this._user)
    : super(uid: _user.uid, email: _user.email, avatarUrl: _user.photoURL);

  final User _user;

  /// Read live value from the underlying Firebase User (updated after reload).
  @override
  bool get emailVerified => _user.emailVerified;

  @override
  String get userInitial {
    final displayName = _user.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      final firstInitial = parts[0].isNotEmpty ? parts[0][0] : '';
      final lastInitial = parts.length > 1 && parts[1].isNotEmpty
          ? parts[1][0]
          : '';
      return (firstInitial + lastInitial).toUpperCase();
    }
    return '';
  }

  @override
  Future<void> forceRefreshIdToken() {
    return _user.getIdToken(true);
  }

  @override
  Future<bool> isAdmin() async {
    final role = await getRole();
    return role == UserRole.admin;
  }

  @override
  Future<void> sendEmailVerification() => _user.sendEmailVerification();

  @override
  Future<void> reload() => _user.reload();

  @override
  Future<UserRole> getRole() async {
    final token = await _user.getIdTokenResult();
    final role = token.claims?['role'];

    return switch (role) {
      'admin' => UserRole.admin,
      'partner' => UserRole.partner,
      'customer' => UserRole.customer,
      _ => UserRole.guest,
    };
  }
}
