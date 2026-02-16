// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_business_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignInBusinessController)
const signInBusinessControllerProvider = SignInBusinessControllerProvider._();

final class SignInBusinessControllerProvider
    extends $AsyncNotifierProvider<SignInBusinessController, void> {
  const SignInBusinessControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInBusinessControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInBusinessControllerHash();

  @$internal
  @override
  SignInBusinessController create() => SignInBusinessController();
}

String _$signInBusinessControllerHash() =>
    r'e4a8165b750d837fd89e72a1c6cf4960e9ed7585';

abstract class _$SignInBusinessController extends $AsyncNotifier<void> {
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
