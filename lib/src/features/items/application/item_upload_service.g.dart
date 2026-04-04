// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_upload_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itemUploadService)
const itemUploadServiceProvider = ItemUploadServiceProvider._();

final class ItemUploadServiceProvider
    extends
        $FunctionalProvider<
          ItemUploadService,
          ItemUploadService,
          ItemUploadService
        >
    with $Provider<ItemUploadService> {
  const ItemUploadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemUploadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemUploadServiceHash();

  @$internal
  @override
  $ProviderElement<ItemUploadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ItemUploadService create(Ref ref) {
    return itemUploadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemUploadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemUploadService>(value),
    );
  }
}

String _$itemUploadServiceHash() => r'e8b538e15199b9f0d406d32201983ae2504917eb';
