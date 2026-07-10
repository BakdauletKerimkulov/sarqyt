// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_content_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsContentController)
const settingsContentControllerProvider = SettingsContentControllerProvider._();

final class SettingsContentControllerProvider
    extends $AsyncNotifierProvider<SettingsContentController, void> {
  const SettingsContentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsContentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsContentControllerHash();

  @$internal
  @override
  SettingsContentController create() => SettingsContentController();
}

String _$settingsContentControllerHash() =>
    r'47f4c2a344da6c2a36f378a0cd51dc4396957472';

abstract class _$SettingsContentController extends $AsyncNotifier<void> {
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
