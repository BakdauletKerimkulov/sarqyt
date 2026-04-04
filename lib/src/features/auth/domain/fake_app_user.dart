import 'package:sarqyt/src/features/auth/domain/app_user.dart';

class FakeAppUser extends AppUser {
  FakeAppUser({
    required super.uid,
    required super.email,
    required this.password,
    this.role = UserRole.partner,
    super.emailVerified,
  });

  final String password;
  final UserRole role;

  @override
  Future<UserRole> getRole() async => role;
}
