// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_business_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegistrationStepController)
const registrationStepControllerProvider =
    RegistrationStepControllerProvider._();

final class RegistrationStepControllerProvider
    extends $NotifierProvider<RegistrationStepController, RegisterStep> {
  const RegistrationStepControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registrationStepControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registrationStepControllerHash();

  @$internal
  @override
  RegistrationStepController create() => RegistrationStepController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterStep value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterStep>(value),
    );
  }
}

String _$registrationStepControllerHash() =>
    r'cf3c5664730a5e618ba1d5e4959653f5fd8c5e62';

abstract class _$RegistrationStepController extends $Notifier<RegisterStep> {
  RegisterStep build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RegisterStep, RegisterStep>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegisterStep, RegisterStep>,
              RegisterStep,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CreateAccountBusinessController)
const createAccountBusinessControllerProvider =
    CreateAccountBusinessControllerProvider._();

final class CreateAccountBusinessControllerProvider
    extends $AsyncNotifierProvider<CreateAccountBusinessController, void> {
  const CreateAccountBusinessControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createAccountBusinessControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createAccountBusinessControllerHash();

  @$internal
  @override
  CreateAccountBusinessController create() => CreateAccountBusinessController();
}

String _$createAccountBusinessControllerHash() =>
    r'0a0244f1850bcc3b075ed383496ea7f4226c2a9f';

abstract class _$CreateAccountBusinessController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
