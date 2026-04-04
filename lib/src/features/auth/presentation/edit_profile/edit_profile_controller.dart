import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/user_profile_repository.dart';

part 'edit_profile_controller.g.dart';

@riverpod
class EditProfileController extends _$EditProfileController {
  @override
  FutureOr<void> build() {}

  Future<bool> save({
    required String displayName,
    required String phoneNumber,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userProfileRepositoryProvider).updateProfile(
            user.uid,
            displayName: displayName.isNotEmpty ? displayName : null,
            phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
          );
    });
    return !state.hasError;
  }
}
