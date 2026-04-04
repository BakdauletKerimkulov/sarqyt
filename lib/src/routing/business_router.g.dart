// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentStoreShip)
const currentStoreShipProvider = CurrentStoreShipProvider._();

final class CurrentStoreShipProvider
    extends $FunctionalProvider<StoreShip, StoreShip, StoreShip>
    with $Provider<StoreShip> {
  const CurrentStoreShipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentStoreShipProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentStoreShipHash();

  @$internal
  @override
  $ProviderElement<StoreShip> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreShip create(Ref ref) {
    return currentStoreShip(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreShip value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreShip>(value),
    );
  }
}

String _$currentStoreShipHash() => r'd427ce1af8703ee638961bfd12f3cce2ac6530a9';

@ProviderFor(businessRouter)
const businessRouterProvider = BusinessRouterProvider._();

final class BusinessRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  const BusinessRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return businessRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$businessRouterHash() => r'0e8b030c3d39c900feb21fa3255bb5301a0999f6';
