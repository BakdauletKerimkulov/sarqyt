import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';

part 'sign_in_business_controller.g.dart';

@riverpod
class SignInBusinessController extends _$SignInBusinessController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password),
    );
    return state.hasError == false;
  }
}
