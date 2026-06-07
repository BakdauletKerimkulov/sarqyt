// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritesRepository)
const favoritesRepositoryProvider = FavoritesRepositoryProvider._();

final class FavoritesRepositoryProvider
    extends
        $FunctionalProvider<
          FavoritesRepository,
          FavoritesRepository,
          FavoritesRepository
        >
    with $Provider<FavoritesRepository> {
  const FavoritesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoritesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoritesRepository create(Ref ref) {
    return favoritesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesRepository>(value),
    );
  }
}

String _$favoritesRepositoryHash() =>
    r'66f79844897169a2c297845de4e708ff66042698';

@ProviderFor(favoriteStoreIds)
const favoriteStoreIdsProvider = FavoriteStoreIdsProvider._();

final class FavoriteStoreIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  const FavoriteStoreIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteStoreIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteStoreIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return favoriteStoreIds(ref);
  }
}

String _$favoriteStoreIdsHash() => r'09673170bd914c8886adbce4e6243797642c4fec';

@ProviderFor(favoriteStores)
const favoriteStoresProvider = FavoriteStoresProvider._();

final class FavoriteStoresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Store>>,
          AsyncValue<List<Store>>,
          AsyncValue<List<Store>>
        >
    with $Provider<AsyncValue<List<Store>>> {
  const FavoriteStoresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteStoresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteStoresHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Store>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Store>> create(Ref ref) {
    return favoriteStores(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Store>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Store>>>(value),
    );
  }
}

String _$favoriteStoresHash() => r'6edfe363e4ae5a7c9e589ff815233b12a4d6099d';
