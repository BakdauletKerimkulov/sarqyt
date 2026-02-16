// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_product_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateProductController)
const createProductControllerProvider = CreateProductControllerProvider._();

final class CreateProductControllerProvider
    extends $AsyncNotifierProvider<CreateProductController, void> {
  const CreateProductControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createProductControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createProductControllerHash();

  @$internal
  @override
  CreateProductController create() => CreateProductController();
}

String _$createProductControllerHash() =>
    r'b929d23bc4cb91eecd0d302c6fd8ab014cfa96ba';

abstract class _$CreateProductController extends $AsyncNotifier<void> {
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

@ProviderFor(ProductImagePickerController)
const productImagePickerControllerProvider =
    ProductImagePickerControllerProvider._();

final class ProductImagePickerControllerProvider
    extends
        $AsyncNotifierProvider<
          ProductImagePickerController,
          Either<File, Uint8List>?
        > {
  const ProductImagePickerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productImagePickerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productImagePickerControllerHash();

  @$internal
  @override
  ProductImagePickerController create() => ProductImagePickerController();
}

String _$productImagePickerControllerHash() =>
    r'a430604f2f2dca91413b9614de4d3a49f65ca6d7';

abstract class _$ProductImagePickerController
    extends $AsyncNotifier<Either<File, Uint8List>?> {
  FutureOr<Either<File, Uint8List>?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Either<File, Uint8List>?>,
              Either<File, Uint8List>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Either<File, Uint8List>?>,
                Either<File, Uint8List>?
              >,
              AsyncValue<Either<File, Uint8List>?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
