// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/firebase_app_user.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth, this._functions);
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_convertUser);
  }

  Stream<AppUser?> userChanges() {
    return _auth.userChanges().map(_convertUser);
  }

  Stream<AppUser?> idTokenChanges() {
    return _auth.idTokenChanges().map(_convertUser);
  }

  Future<String?> abc() async {
    final userToken = await _auth.currentUser?.getIdTokenResult();

    return userToken?.claims?['role'];
  }

  AppUser? get currentUser => _convertUser(_auth.currentUser);

  Future<void> signOut() => _auth.signOut();

  Future<void> signInWithEmailAndPassword(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> createUserWithEmailAndPassword(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  AppUser? _convertUser(User? user) =>
      user != null ? FirebaseAppUser(user) : null;

  Future<void> registerBusiness({
    required String email,
    required String password,
    required String name,
    required String address,
    required String locality,
    required List<double> location,
    required CountryD country,
    required StoreType storeType,
    required String phoneNumber,
    required String postalCode,
  }) async {
    try {
      final callable = _functions.httpsCallable("registerBusiness");

      final callBody = {
        'email': email,
        'password': password,
        'name': name,
        'address': address,
        'locality': locality,
        'location': location,
        'country': country.toMap(),
        'storeType': storeType.name,
        'phoneNumber': phoneNumber,
        'postalCode': postalCode,
      };

      await callable.call(callBody);

      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionsError(e);
    } catch (e) {
      rethrow;
    }
  }

  // Вспомогательный метод для красивых ошибок
  String _handleFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'invalid-argument':
        return 'Заполните все поля корректно.';
      case 'already-exists':
        return 'Такой пользователь уже существует.';
      default:
        return 'Ошибка регистрации: ${e.message} ${e.stackTrace}';
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(FirebaseAuth.instance, FirebaseFunctions.instance);

// * Using keepAlive since other providers need it to be an
// * [AlwaysAliveProviderListenable]
@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
}

@Riverpod(keepAlive: true)
Stream<AppUser?> authUserChanges(Ref ref) {
  final userChanges = ref.watch(authRepositoryProvider).userChanges();
  return userChanges;
}

@Riverpod(keepAlive: true)
Stream<AppUser?> idTokenChanges(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.idTokenChanges();
}

@riverpod
Future<UserRole> currentUserRole(Ref ref) async {
  final user = ref.watch(idTokenChangesProvider).value;
  if (user == null) {
    return UserRole.guest;
  }

  return user.getRole();
}
