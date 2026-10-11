// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountSettingsController)
const accountSettingsControllerProvider = AccountSettingsControllerProvider._();

final class AccountSettingsControllerProvider
    extends $AsyncNotifierProvider<AccountSettingsController, void> {
  const AccountSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSettingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSettingsControllerHash();

  @$internal
  @override
  AccountSettingsController create() => AccountSettingsController();
}

String _$accountSettingsControllerHash() =>
    r'3bfc52f9a0cb0c216123609c3b15396ee44d2f93';

abstract class _$AccountSettingsController extends $AsyncNotifier<void> {
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
