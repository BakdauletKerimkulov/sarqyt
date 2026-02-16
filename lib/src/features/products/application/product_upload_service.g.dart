// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_upload_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productUploadService)
const productUploadServiceProvider = ProductUploadServiceProvider._();

final class ProductUploadServiceProvider
    extends
        $FunctionalProvider<
          ProductUploadService,
          ProductUploadService,
          ProductUploadService
        >
    with $Provider<ProductUploadService> {
  const ProductUploadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productUploadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productUploadServiceHash();

  @$internal
  @override
  $ProviderElement<ProductUploadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductUploadService create(Ref ref) {
    return productUploadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductUploadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductUploadService>(value),
    );
  }
}

String _$productUploadServiceHash() =>
    r'39f9363f5df55f1dd4f71006aa14991643621c99';
