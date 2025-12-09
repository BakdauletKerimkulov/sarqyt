import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/utils/in_memory_store.dart';

const kTestUser = AppUser(uid: '123123');

class FakeAuthRepository implements AuthRepository {
  final _authState = InMemoryStore<AppUser?>(kTestUser);

  @override
  Stream<AppUser?> authStateChanges() => _authState.stream;

  @override
  AppUser? get currentUser => _authState.value;

  @override
  Future<void> signOut() async {
    _authState.value = null;
  }
}
