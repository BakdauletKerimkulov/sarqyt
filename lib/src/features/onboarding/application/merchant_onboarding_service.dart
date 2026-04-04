import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/onboarding/data/onboarding_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';

part 'merchant_onboarding_service.g.dart';

class MerchantOnboardingService {
  const MerchantOnboardingService(
    this._authRepository,
    this._onboardingRepository,
  );
  final AuthRepository _authRepository;
  final OnboardingRepository _onboardingRepository;

  Future<void> register({
    required String email,
    required String password,
    required StoreDraft draft,
  }) async {
    var userCreated = false;
    try {
      await _authRepository.createUserWithEmailAndPassword(email, password);
      userCreated = true;

      await _onboardingRepository.createStoreDraft(draft.toCallableMap());
    } catch (e) {
      if (userCreated) {
        try {
          await _authRepository.signOut();
        } catch (_) {}
      }
      rethrow;
    }
  }
}

@riverpod
MerchantOnboardingService merchantOnboardingService(Ref ref) {
  return MerchantOnboardingService(
    ref.read(authRepositoryProvider),
    ref.read(onboardingRepositoryProvider),
  );
}
