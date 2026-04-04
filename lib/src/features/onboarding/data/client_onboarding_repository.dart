import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sarqyt/src/utils/shared_preferences_provider.dart';

part 'client_onboarding_repository.g.dart';

class ClientOnboardingRepository {
  ClientOnboardingRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'onboardingComplete';

  bool isOnboardingComplete() => _prefs.getBool(_key) ?? false;

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_key, true);
  }
}

@Riverpod(keepAlive: true)
Future<ClientOnboardingRepository> clientOnboardingRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ClientOnboardingRepository(prefs);
}
