// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountScreenController)
const accountScreenControllerProvider = AccountScreenControllerProvider._();

final class AccountScreenControllerProvider
    extends $AsyncNotifierProvider<AccountScreenController, void> {
  const AccountScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountScreenControllerHash();

  @$internal
  @override
  AccountScreenController create() => AccountScreenController();
}

String _$accountScreenControllerHash() =>
    r'214c588739a1c695e32a9a386805299d46a9625a';

abstract class _$AccountScreenController extends $AsyncNotifier<void> {
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
