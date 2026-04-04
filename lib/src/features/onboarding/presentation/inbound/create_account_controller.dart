import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/onboarding/application/merchant_onboarding_service.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';

part 'create_account_controller.g.dart';

const countryList = [CountryD(isoCode: 'KAZ', name: 'Казахстан')];

@riverpod
class CreateAccountController extends _$CreateAccountController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<void> register(String email, String password, StoreDraft draft) async {
    // Capture the service before any async work — it's a plain Dart object
    // that continues running even after this controller is auto-disposed
    // (redirect fires after createUser → EmailScreen unmounts → dispose).
    final service = ref.read(merchantOnboardingServiceProvider);
    state = const AsyncLoading();
    try {
      await service.register(email: email, password: password, draft: draft);
    } catch (e, st) {
      if (ref.mounted) {
        state = AsyncError(e, st);
      }
    }
  }
}
