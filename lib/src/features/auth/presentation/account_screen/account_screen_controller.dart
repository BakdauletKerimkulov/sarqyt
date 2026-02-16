import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';

part 'account_screen_controller.g.dart';

@riverpod
class AccountScreenController extends _$AccountScreenController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => authRepository.signOut());
  }
}
