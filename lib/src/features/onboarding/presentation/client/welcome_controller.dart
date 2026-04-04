import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/onboarding/data/client_onboarding_repository.dart';

part 'welcome_controller.g.dart';

@riverpod
class WelcomeController extends _$WelcomeController {
  @override
  FutureOr<void> build() {}

  Future<void> completeOnboarding() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(clientOnboardingRepositoryProvider).requireValue;
      await repo.setOnboardingComplete();
    });
  }
}
