// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/auth/domain/firebase_app_user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_convertUser);
  }

  Stream<AppUser?> idTokenChanges() {
    return _auth.idTokenChanges().map(_convertUser);
  }

  AppUser? get currentUser => _convertUser(_auth.currentUser);

  Future<void> signOut() => _auth.signOut();

  Future<void> signInWithEmailAndPassword(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> createUserWithEmailAndPassword(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  AppUser? _convertUser(User? user) =>
      user != null ? FirebaseAppUser(user) : null;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(FirebaseAuth.instance);

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
}
