// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_repoitory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productsRepoitory)
const productsRepoitoryProvider = ProductsRepoitoryProvider._();

final class ProductsRepoitoryProvider
    extends
        $FunctionalProvider<
          ProductsRepoitory,
          ProductsRepoitory,
          ProductsRepoitory
        >
    with $Provider<ProductsRepoitory> {
  const ProductsRepoitoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsRepoitoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsRepoitoryHash();

  @$internal
  @override
  $ProviderElement<ProductsRepoitory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductsRepoitory create(Ref ref) {
    return productsRepoitory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductsRepoitory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductsRepoitory>(value),
    );
  }
}

String _$productsRepoitoryHash() => r'03df6e9b91786158277f64cdf6440178d9bab6d5';

@ProviderFor(productsListStream)
const productsListStreamProvider = ProductsListStreamFamily._();

final class ProductsListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          Stream<List<Product>>
        >
    with $FutureModifier<List<Product>>, $StreamProvider<List<Product>> {
  const ProductsListStreamProvider._({
    required ProductsListStreamFamily super.from,
    required StoreID super.argument,
  }) : super(
         retry: null,
         name: r'productsListStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productsListStreamHash();

  @override
  String toString() {
    return r'productsListStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Product>> create(Ref ref) {
    final argument = this.argument as StoreID;
    return productsListStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductsListStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productsListStreamHash() =>
    r'0b0c273ca1256bd9f02b4c946e7dbc4a43ace8d0';

final class ProductsListStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Product>>, StoreID> {
  const ProductsListStreamFamily._()
    : super(
        retry: null,
        name: r'productsListStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductsListStreamProvider call(StoreID storeId) =>
      ProductsListStreamProvider._(argument: storeId, from: this);

  @override
  String toString() => r'productsListStreamProvider';
}

@ProviderFor(productStream)
const productStreamProvider = ProductStreamFamily._();

final class ProductStreamProvider
    extends
        $FunctionalProvider<AsyncValue<Product?>, Product?, Stream<Product?>>
    with $FutureModifier<Product?>, $StreamProvider<Product?> {
  const ProductStreamProvider._({
    required ProductStreamFamily super.from,
    required ({StoreID storeId, ProductID id}) super.argument,
  }) : super(
         retry: null,
         name: r'productStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productStreamHash();

  @override
  String toString() {
    return r'productStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Product?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Product?> create(Ref ref) {
    final argument = this.argument as ({StoreID storeId, ProductID id});
    return productStream(ref, storeId: argument.storeId, id: argument.id);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productStreamHash() => r'5fbd0faa7d65f8d87dd3b2c13336a35455193cf4';

final class ProductStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Product?>,
          ({StoreID storeId, ProductID id})
        > {
  const ProductStreamFamily._()
    : super(
        retry: null,
        name: r'productStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductStreamProvider call({
    required StoreID storeId,
    required ProductID id,
  }) =>
      ProductStreamProvider._(argument: (storeId: storeId, id: id), from: this);

  @override
  String toString() => r'productStreamProvider';
}
