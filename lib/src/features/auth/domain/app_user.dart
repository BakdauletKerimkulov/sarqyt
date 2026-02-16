typedef UserID = String;

enum UserRole { owner, employee, user, guest }

/// Simple class representing the user UID and email.
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.avatarUrl,
    this.emailVerified = false,
    this.userInitial = '',
  });
  final UserID uid;
  final String? email;
  final String? avatarUrl;
  final bool emailVerified;
  final String userInitial;

  Future<void> sendEmailVerification() async {
    // no-op - implemented by subclasses
  }

  Future<UserRole> getRole() async {
    return UserRole.user;
  }

  Future<bool> isAdmin() {
    return Future.value(false);
  }

  Future<void> forceRefreshIdToken() async {
    // no-op - implemented by subclasses
  }

  Future<void> reload() async {
    // no-op
  }

  // * Here we override methods from [Object] directly rather than using
  // * [Equatable], since this class will be subclassed or implemented
  // * by other classes.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser && other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;

  @override
  String toString() => 'AppUser(uid: $uid, email: $email)';
}
