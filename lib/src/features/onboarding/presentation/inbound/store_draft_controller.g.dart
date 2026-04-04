// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_draft_controller.dart';

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
        isAutoDispose: false,
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
    r'2902c78e70c4e4f54ac4f0c0f15fbd424cfa05bc';

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
