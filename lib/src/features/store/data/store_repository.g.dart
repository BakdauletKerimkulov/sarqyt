// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeRepository)
const storeRepositoryProvider = StoreRepositoryProvider._();

final class StoreRepositoryProvider
    extends
        $FunctionalProvider<StoreRepository, StoreRepository, StoreRepository>
    with $Provider<StoreRepository> {
  const StoreRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeRepositoryHash();

  @$internal
  @override
  $ProviderElement<StoreRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreRepository create(Ref ref) {
    return storeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreRepository>(value),
    );
  }
}

String _$storeRepositoryHash() => r'dbabe05a1e28a2f2c593c41ec8884968b06af21f';

@ProviderFor(storeListStream)
const storeListStreamProvider = StoreListStreamProvider._();

final class StoreListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Store>>,
          List<Store>,
          Stream<List<Store>>
        >
    with $FutureModifier<List<Store>>, $StreamProvider<List<Store>> {
  const StoreListStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeListStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeListStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Store>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Store>> create(Ref ref) {
    return storeListStream(ref);
  }
}

String _$storeListStreamHash() => r'e181af130e19a1319431514e652fd864cb13e438';

@ProviderFor(storeStream)
const storeStreamProvider = StoreStreamFamily._();

final class StoreStreamProvider
    extends $FunctionalProvider<AsyncValue<Store?>, Store?, Stream<Store?>>
    with $FutureModifier<Store?>, $StreamProvider<Store?> {
  const StoreStreamProvider._({
    required StoreStreamFamily super.from,
    required StoreID super.argument,
  }) : super(
         retry: null,
         name: r'storeStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeStreamHash();

  @override
  String toString() {
    return r'storeStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Store?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Store?> create(Ref ref) {
    final argument = this.argument as StoreID;
    return storeStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeStreamHash() => r'2ab371ba3ebbf347b05e4bf39ace69c718008f73';

final class StoreStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Store?>, StoreID> {
  const StoreStreamFamily._()
    : super(
        retry: null,
        name: r'storeStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreStreamProvider call(StoreID storeId) =>
      StoreStreamProvider._(argument: storeId, from: this);

  @override
  String toString() => r'storeStreamProvider';
}
