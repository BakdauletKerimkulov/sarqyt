// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocode_address_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Универсальный провайдер геокодинга.
/// Принимает строку адреса, возвращает координаты.
/// Кэшируется Riverpod по значению query — повторный запрос с тем же адресом
/// не вызывает API, пока провайдер жив.

@ProviderFor(geocodeAddress)
const geocodeAddressProvider = GeocodeAddressFamily._();

/// Универсальный провайдер геокодинга.
/// Принимает строку адреса, возвращает координаты.
/// Кэшируется Riverpod по значению query — повторный запрос с тем же адресом
/// не вызывает API, пока провайдер жив.

final class GeocodeAddressProvider
    extends $FunctionalProvider<AsyncValue<LatLng?>, LatLng?, FutureOr<LatLng?>>
    with $FutureModifier<LatLng?>, $FutureProvider<LatLng?> {
  /// Универсальный провайдер геокодинга.
  /// Принимает строку адреса, возвращает координаты.
  /// Кэшируется Riverpod по значению query — повторный запрос с тем же адресом
  /// не вызывает API, пока провайдер жив.
  const GeocodeAddressProvider._({
    required GeocodeAddressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'geocodeAddressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$geocodeAddressHash();

  @override
  String toString() {
    return r'geocodeAddressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LatLng?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LatLng?> create(Ref ref) {
    final argument = this.argument as String;
    return geocodeAddress(ref, query: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GeocodeAddressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$geocodeAddressHash() => r'85196401e0aa4f7a9ccf22a1d366554834ffc37d';

/// Универсальный провайдер геокодинга.
/// Принимает строку адреса, возвращает координаты.
/// Кэшируется Riverpod по значению query — повторный запрос с тем же адресом
/// не вызывает API, пока провайдер жив.

final class GeocodeAddressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LatLng?>, String> {
  const GeocodeAddressFamily._()
    : super(
        retry: null,
        name: r'geocodeAddressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Универсальный провайдер геокодинга.
  /// Принимает строку адреса, возвращает координаты.
  /// Кэшируется Riverpod по значению query — повторный запрос с тем же адресом
  /// не вызывает API, пока провайдер жив.

  GeocodeAddressProvider call({required String query}) =>
      GeocodeAddressProvider._(argument: query, from: this);

  @override
  String toString() => r'geocodeAddressProvider';
}
