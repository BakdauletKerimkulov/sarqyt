// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateAccountController)
const createAccountControllerProvider = CreateAccountControllerProvider._();

final class CreateAccountControllerProvider
    extends $AsyncNotifierProvider<CreateAccountController, void> {
  const CreateAccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createAccountControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createAccountControllerHash();

  @$internal
  @override
  CreateAccountController create() => CreateAccountController();
}

String _$createAccountControllerHash() =>
    r'6d8a84ed9a13494dbf29c949472769f266f02ea1';

abstract class _$CreateAccountController extends $AsyncNotifier<void> {
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
