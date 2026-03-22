// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemDraftController)
const itemDraftControllerProvider = ItemDraftControllerProvider._();

final class ItemDraftControllerProvider
    extends $NotifierProvider<ItemDraftController, ItemDraft> {
  const ItemDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemDraftControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemDraftControllerHash();

  @$internal
  @override
  ItemDraftController create() => ItemDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemDraft>(value),
    );
  }
}

String _$itemDraftControllerHash() =>
    r'46c1cb89af970ed86b4da800d2bc579b0a2b97e1';

abstract class _$ItemDraftController extends $Notifier<ItemDraft> {
  ItemDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ItemDraft, ItemDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ItemDraft, ItemDraft>,
              ItemDraft,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
