// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WelcomeController)
const welcomeControllerProvider = WelcomeControllerProvider._();

final class WelcomeControllerProvider
    extends $AsyncNotifierProvider<WelcomeController, void> {
  const WelcomeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'welcomeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$welcomeControllerHash();

  @$internal
  @override
  WelcomeController create() => WelcomeController();
}

String _$welcomeControllerHash() => r'1bd63a7431fbad3646ca76f8a4b5dc1af2200a7c';

abstract class _$WelcomeController extends $AsyncNotifier<void> {
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
