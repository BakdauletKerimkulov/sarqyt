// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geolocator_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geolocatorService)
const geolocatorServiceProvider = GeolocatorServiceProvider._();

final class GeolocatorServiceProvider
    extends
        $FunctionalProvider<
          GeolocatorService,
          GeolocatorService,
          GeolocatorService
        >
    with $Provider<GeolocatorService> {
  const GeolocatorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geolocatorServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geolocatorServiceHash();

  @$internal
  @override
  $ProviderElement<GeolocatorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeolocatorService create(Ref ref) {
    return geolocatorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeolocatorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeolocatorService>(value),
    );
  }
}

String _$geolocatorServiceHash() => r'801847611a108a8b27206e7063040184726e64ee';

@ProviderFor(position)
const positionProvider = PositionProvider._();

final class PositionProvider
    extends
        $FunctionalProvider<
          AsyncValue<Position?>,
          Position?,
          FutureOr<Position?>
        >
    with $FutureModifier<Position?>, $FutureProvider<Position?> {
  const PositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'positionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$positionHash();

  @$internal
  @override
  $FutureProviderElement<Position?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Position?> create(Ref ref) {
    return position(ref);
  }
}

String _$positionHash() => r'cb01d52b6859ff023bffde371224b0e50af8efec';
