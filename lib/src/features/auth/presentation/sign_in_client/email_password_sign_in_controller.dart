import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_form_type.dart';

part 'email_password_sign_in_controller.g.dart';

@riverpod
class EmailPasswordSignInController extends _$EmailPasswordSignInController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<bool> submit({
    required String email,
    required String password,
    required EmailPasswordSignInFormType formType,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authenticate(email, password, formType),
    );
    return state.hasError == false;
  }

  Future<void> _authenticate(
    String email,
    String password,
    EmailPasswordSignInFormType formType,
  ) async {
    final authRepo = ref.read(authRepositoryProvider);

    switch (formType) {
      case EmailPasswordSignInFormType.register:
        authRepo.createUserWithEmailAndPassword(email, password);
      case EmailPasswordSignInFormType.signIn:
        return authRepo.signInWithEmailAndPassword(email, password);
    }
  }
}
