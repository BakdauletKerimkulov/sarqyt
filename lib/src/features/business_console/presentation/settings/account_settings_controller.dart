import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';

part 'account_settings_controller.g.dart';

@riverpod
class AccountSettingsController extends _$AccountSettingsController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
    return state.hasError == false;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}
