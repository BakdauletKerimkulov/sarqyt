import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/onboarding/data/onboarding_repository.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/store_draft_controller.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';

part 'verify_email_controller.g.dart';

@riverpod
class VerifyEmailController extends _$VerifyEmailController {
  bool _completed = false;

  @override
  FutureOr<void> build() {}

  bool get completed => _completed;

  /// Called when the app resumes or by the polling timer.
  /// Reloads user, checks emailVerified, then completes onboarding.
  Future<void> checkAndComplete() async {
    if (state.isLoading || _completed) return;

    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;
    if (user == null) return;

    await user.reload();
    if (!user.emailVerified) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final onboardingRepo = ref.read(onboardingRepositoryProvider);
      await onboardingRepo.completeMerchantOnboarding();
      await user.forceRefreshIdToken();
    });

    // Always invalidate redirect providers so router picks up
    // the latest user/role/storeShips — even on error, the user
    // state may have changed (e.g. emailVerified is now true).
    ref.invalidate(userRoleProvider);
    ref.invalidate(currentPartnerStoreShipsProvider);

    if (!state.hasError) {
      _completed = true;
      ref.invalidate(storeDraftControllerProvider);
    }
  }
}
