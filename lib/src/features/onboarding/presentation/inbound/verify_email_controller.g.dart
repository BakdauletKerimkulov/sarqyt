// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VerifyEmailController)
const verifyEmailControllerProvider = VerifyEmailControllerProvider._();

final class VerifyEmailControllerProvider
    extends $AsyncNotifierProvider<VerifyEmailController, void> {
  const VerifyEmailControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyEmailControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailControllerHash();

  @$internal
  @override
  VerifyEmailController create() => VerifyEmailController();
}

String _$verifyEmailControllerHash() =>
    r'1ea1edf7da261ccee1b4a5c403a0acce561bb984';

abstract class _$VerifyEmailController extends $AsyncNotifier<void> {
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
