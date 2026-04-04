import 'package:sarqyt/src/exceptions/app_exception.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/auth/domain/fake_app_user.dart';
import 'package:sarqyt/src/utils/delay.dart';
import 'package:sarqyt/src/utils/in_memory_store.dart';

const kTestUser = AppUser(
  uid: '123123',
  avatarUrl: 'https://upload.wikimedia.org/wikipedia/az/4/41/Morty_Smith.jpg',
  //email: 'test@test.com',
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.addDelay = true});
  final bool addDelay;

  final _authState = InMemoryStore<AppUser?>(null);

  // List to keep track of all users
  final List<FakeAppUser> _users = [];

  @override
  Stream<AppUser?> authStateChanges() => _authState.stream;

  @override
  AppUser? get currentUser => _authState.value;

  @override
  Future<void> signOut() async {
    _authState.value = null;
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await delay(addDelay);
    // check the given credentials agains each registered user
    for (final u in _users) {
      if (u.email == email && u.password == password) {
        _authState.value = u;
        return;
      }
      // same email, wrong password
      if (u.email == email && u.password != password) {
        throw WrongPasswordException();
      }
    }

    throw UserNotFoundException();
  }

  @override
  Future<AppUser?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await delay(addDelay);
    for (final u in _users) {
      if (u.email == email) {
        throw EmailAlreadyInUseException();
      }
    }

    if (password.length < 8) {
      throw WeakPasswordException();
    }

    _createNewUser(email, password);

    return AppUser(uid: '123');
  }

  void _createNewUser(String email, String password) {
    // create new user
    final user = FakeAppUser(
      uid: email.split('').reversed.join(),
      email: email,
      password: password,
    );
    // register it
    _users.add(user);
    // update the auth state
    _authState.value = user;
  }

  @override
  Stream<AppUser?> idTokenChanges() {
    // TODO: implement idTokenChanges
    throw UnimplementedError();
  }
}
