// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itemsRepository)
const itemsRepositoryProvider = ItemsRepositoryProvider._();

final class ItemsRepositoryProvider
    extends
        $FunctionalProvider<ItemsRepository, ItemsRepository, ItemsRepository>
    with $Provider<ItemsRepository> {
  const ItemsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ItemsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItemsRepository create(Ref ref) {
    return itemsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemsRepository>(value),
    );
  }
}

String _$itemsRepositoryHash() => r'46d1cff0ec5fc02c5e003b6d93b54cad35ecaac1';

@ProviderFor(itemsListStream)
const itemsListStreamProvider = ItemsListStreamFamily._();

final class ItemsListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  const ItemsListStreamProvider._({
    required ItemsListStreamFamily super.from,
    required StoreID super.argument,
  }) : super(
         retry: null,
         name: r'itemsListStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemsListStreamHash();

  @override
  String toString() {
    return r'itemsListStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    final argument = this.argument as StoreID;
    return itemsListStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsListStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemsListStreamHash() => r'a39f3cc267a71641c2bdfc67b6bcefae50d78ace';

final class ItemsListStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Item>>, StoreID> {
  const ItemsListStreamFamily._()
    : super(
        retry: null,
        name: r'itemsListStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemsListStreamProvider call(StoreID storeId) =>
      ItemsListStreamProvider._(argument: storeId, from: this);

  @override
  String toString() => r'itemsListStreamProvider';
}

@ProviderFor(itemsListFuture)
const itemsListFutureProvider = ItemsListFutureFamily._();

final class ItemsListFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          FutureOr<List<Item>>
        >
    with $FutureModifier<List<Item>>, $FutureProvider<List<Item>> {
  const ItemsListFutureProvider._({
    required ItemsListFutureFamily super.from,
    required StoreID super.argument,
  }) : super(
         retry: null,
         name: r'itemsListFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemsListFutureHash();

  @override
  String toString() {
    return r'itemsListFutureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Item>> create(Ref ref) {
    final argument = this.argument as StoreID;
    return itemsListFuture(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsListFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemsListFutureHash() => r'2c435c3aad636cf09658aaf76882f1d491fdc789';

final class ItemsListFutureFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Item>>, StoreID> {
  const ItemsListFutureFamily._()
    : super(
        retry: null,
        name: r'itemsListFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemsListFutureProvider call(StoreID storeId) =>
      ItemsListFutureProvider._(argument: storeId, from: this);

  @override
  String toString() => r'itemsListFutureProvider';
}

@ProviderFor(itemStream)
const itemStreamProvider = ItemStreamFamily._();

final class ItemStreamProvider
    extends $FunctionalProvider<AsyncValue<Item?>, Item?, Stream<Item?>>
    with $FutureModifier<Item?>, $StreamProvider<Item?> {
  const ItemStreamProvider._({
    required ItemStreamFamily super.from,
    required ({StoreID storeId, ItemID id}) super.argument,
  }) : super(
         retry: null,
         name: r'itemStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemStreamHash();

  @override
  String toString() {
    return r'itemStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Item?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Item?> create(Ref ref) {
    final argument = this.argument as ({StoreID storeId, ItemID id});
    return itemStream(ref, storeId: argument.storeId, id: argument.id);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemStreamHash() => r'15a57635d6bd92dd79940932ffbc9780f1ebcc7e';

final class ItemStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Item?>,
          ({StoreID storeId, ItemID id})
        > {
  const ItemStreamFamily._()
    : super(
        retry: null,
        name: r'itemStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemStreamProvider call({required StoreID storeId, required ItemID id}) =>
      ItemStreamProvider._(argument: (storeId: storeId, id: id), from: this);

  @override
  String toString() => r'itemStreamProvider';
}

@ProviderFor(itemFuture)
const itemFutureProvider = ItemFutureFamily._();

final class ItemFutureProvider
    extends $FunctionalProvider<AsyncValue<Item?>, Item?, FutureOr<Item?>>
    with $FutureModifier<Item?>, $FutureProvider<Item?> {
  const ItemFutureProvider._({
    required ItemFutureFamily super.from,
    required ({StoreID storeId, ItemID id}) super.argument,
  }) : super(
         retry: null,
         name: r'itemFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemFutureHash();

  @override
  String toString() {
    return r'itemFutureProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Item?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Item?> create(Ref ref) {
    final argument = this.argument as ({StoreID storeId, ItemID id});
    return itemFuture(ref, storeId: argument.storeId, id: argument.id);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemFutureHash() => r'e6c9fa5b27e1434f986427674fc0ec84a0a710c2';

final class ItemFutureFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Item?>,
          ({StoreID storeId, ItemID id})
        > {
  const ItemFutureFamily._()
    : super(
        retry: null,
        name: r'itemFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemFutureProvider call({required StoreID storeId, required ItemID id}) =>
      ItemFutureProvider._(argument: (storeId: storeId, id: id), from: this);

  @override
  String toString() => r'itemFutureProvider';
}
