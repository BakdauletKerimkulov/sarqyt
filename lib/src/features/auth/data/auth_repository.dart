import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<void> signOut();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => throw UnimplementedError();
