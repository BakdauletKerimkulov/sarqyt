// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoreDraftController)
const storeDraftControllerProvider = StoreDraftControllerProvider._();

final class StoreDraftControllerProvider
    extends $NotifierProvider<StoreDraftController, StoreDraft> {
  const StoreDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeDraftControllerHash();

  @$internal
  @override
  StoreDraftController create() => StoreDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreDraft>(value),
    );
  }
}

String _$storeDraftControllerHash() =>
    r'0cf6cc1e95ad8c96950cb7382c79f88e79eec54c';

abstract class _$StoreDraftController extends $Notifier<StoreDraft> {
  StoreDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StoreDraft, StoreDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StoreDraft, StoreDraft>,
              StoreDraft,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
