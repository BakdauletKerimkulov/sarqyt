// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_ship_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeShipRepository)
const storeShipRepositoryProvider = StoreShipRepositoryProvider._();

final class StoreShipRepositoryProvider
    extends
        $FunctionalProvider<
          StoreShipRepository,
          StoreShipRepository,
          StoreShipRepository
        >
    with $Provider<StoreShipRepository> {
  const StoreShipRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeShipRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeShipRepositoryHash();

  @$internal
  @override
  $ProviderElement<StoreShipRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StoreShipRepository create(Ref ref) {
    return storeShipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreShipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreShipRepository>(value),
    );
  }
}

String _$storeShipRepositoryHash() =>
    r'd3813a6013a39ea9c075158e994927502f7a6b18';

@ProviderFor(storeShipsListFutureForPartner)
const storeShipsListFutureForPartnerProvider =
    StoreShipsListFutureForPartnerFamily._();

final class StoreShipsListFutureForPartnerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoreShip>>,
          List<StoreShip>,
          FutureOr<List<StoreShip>>
        >
    with $FutureModifier<List<StoreShip>>, $FutureProvider<List<StoreShip>> {
  const StoreShipsListFutureForPartnerProvider._({
    required StoreShipsListFutureForPartnerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storeShipsListFutureForPartnerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeShipsListFutureForPartnerHash();

  @override
  String toString() {
    return r'storeShipsListFutureForPartnerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<StoreShip>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StoreShip>> create(Ref ref) {
    final argument = this.argument as String;
    return storeShipsListFutureForPartner(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreShipsListFutureForPartnerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeShipsListFutureForPartnerHash() =>
    r'e86a65a1c84b8920f51b1b9429678d9cd131e9c3';

final class StoreShipsListFutureForPartnerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<StoreShip>>, String> {
  const StoreShipsListFutureForPartnerFamily._()
    : super(
        retry: null,
        name: r'storeShipsListFutureForPartnerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreShipsListFutureForPartnerProvider call(String uid) =>
      StoreShipsListFutureForPartnerProvider._(argument: uid, from: this);

  @override
  String toString() => r'storeShipsListFutureForPartnerProvider';
}

@ProviderFor(storeShipsListStreamForPartner)
const storeShipsListStreamForPartnerProvider =
    StoreShipsListStreamForPartnerFamily._();

final class StoreShipsListStreamForPartnerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoreShip>>,
          List<StoreShip>,
          Stream<List<StoreShip>>
        >
    with $FutureModifier<List<StoreShip>>, $StreamProvider<List<StoreShip>> {
  const StoreShipsListStreamForPartnerProvider._({
    required StoreShipsListStreamForPartnerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storeShipsListStreamForPartnerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeShipsListStreamForPartnerHash();

  @override
  String toString() {
    return r'storeShipsListStreamForPartnerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<StoreShip>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StoreShip>> create(Ref ref) {
    final argument = this.argument as String;
    return storeShipsListStreamForPartner(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreShipsListStreamForPartnerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeShipsListStreamForPartnerHash() =>
    r'678584cf2d81f0dca81f83ad974c1860f6812800';

final class StoreShipsListStreamForPartnerFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StoreShip>>, String> {
  const StoreShipsListStreamForPartnerFamily._()
    : super(
        retry: null,
        name: r'storeShipsListStreamForPartnerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreShipsListStreamForPartnerProvider call(String uid) =>
      StoreShipsListStreamForPartnerProvider._(argument: uid, from: this);

  @override
  String toString() => r'storeShipsListStreamForPartnerProvider';
}

@ProviderFor(singleStoreShipForPartner)
const singleStoreShipForPartnerProvider = SingleStoreShipForPartnerFamily._();

final class SingleStoreShipForPartnerProvider
    extends
        $FunctionalProvider<
          AsyncValue<StoreShip?>,
          StoreShip?,
          FutureOr<StoreShip?>
        >
    with $FutureModifier<StoreShip?>, $FutureProvider<StoreShip?> {
  const SingleStoreShipForPartnerProvider._({
    required SingleStoreShipForPartnerFamily super.from,
    required UserID super.argument,
  }) : super(
         retry: null,
         name: r'singleStoreShipForPartnerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$singleStoreShipForPartnerHash();

  @override
  String toString() {
    return r'singleStoreShipForPartnerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StoreShip?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StoreShip?> create(Ref ref) {
    final argument = this.argument as UserID;
    return singleStoreShipForPartner(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleStoreShipForPartnerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$singleStoreShipForPartnerHash() =>
    r'1ca10e194cca4283d4ca707a473c62a697e0879e';

final class SingleStoreShipForPartnerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StoreShip?>, UserID> {
  const SingleStoreShipForPartnerFamily._()
    : super(
        retry: null,
        name: r'singleStoreShipForPartnerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SingleStoreShipForPartnerProvider call(UserID uid) =>
      SingleStoreShipForPartnerProvider._(argument: uid, from: this);

  @override
  String toString() => r'singleStoreShipForPartnerProvider';
}

/// Keeps a live stream of the current partner's [StoreShip] list.
///
/// - `keepAlive: true` so redirect can read `.valueOrNull` synchronously.
/// - Re-subscribes when the authenticated user changes.

@ProviderFor(currentPartnerStoreShips)
const currentPartnerStoreShipsProvider = CurrentPartnerStoreShipsProvider._();

/// Keeps a live stream of the current partner's [StoreShip] list.
///
/// - `keepAlive: true` so redirect can read `.valueOrNull` synchronously.
/// - Re-subscribes when the authenticated user changes.

final class CurrentPartnerStoreShipsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoreShip>>,
          List<StoreShip>,
          Stream<List<StoreShip>>
        >
    with $FutureModifier<List<StoreShip>>, $StreamProvider<List<StoreShip>> {
  /// Keeps a live stream of the current partner's [StoreShip] list.
  ///
  /// - `keepAlive: true` so redirect can read `.valueOrNull` synchronously.
  /// - Re-subscribes when the authenticated user changes.
  const CurrentPartnerStoreShipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPartnerStoreShipsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPartnerStoreShipsHash();

  @$internal
  @override
  $StreamProviderElement<List<StoreShip>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StoreShip>> create(Ref ref) {
    return currentPartnerStoreShips(ref);
  }
}

String _$currentPartnerStoreShipsHash() =>
    r'4727ea1a4430a70c1a551c739b8ac780c85a6e7f';
