import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';

part 'register_business_controller.g.dart';

const countryList = [CountryD(isoCode: 'KAZ', name: 'Казахстан')];

enum RegisterStep { createAccount, reviewDetails, createEmail }

extension RegisterStepX on RegisterStep {
  bool get canGoBack => index > 0;
  bool get isLast => index == RegisterStep.values.length - 1;

  RegisterStep get next {
    if (isLast) return this;
    return RegisterStep.values[index + 1];
  }

  RegisterStep get previous {
    if (!canGoBack) return this;
    return RegisterStep.values[index - 1];
  }
}

@riverpod
class RegistrationStepController extends _$RegistrationStepController {
  @override
  RegisterStep build() => RegisterStep.createAccount;

  void next() => state = state.next;

  void back() => state = state.previous;
}

@riverpod
class CreateAccountBusinessController
    extends _$CreateAccountBusinessController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<bool> submit(String email, String password, StoreDraft draft) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .registerBusiness(
            email: email,
            password: password,
            name: draft.name!,
            address: draft.address!,
            locality: draft.locality!,
            location: [draft.location!.latitude, draft.location!.longitude],
            country: draft.country!,
            storeType: draft.storeType!,
            phoneNumber: draft.phoneNumber!,
            postalCode: draft.postalCode!,
          ),
    );

    return state.hasError == false;
  }
}
