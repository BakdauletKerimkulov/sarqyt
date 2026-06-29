// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_location_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoreLocation)
const storeLocationProvider = StoreLocationProvider._();

final class StoreLocationProvider
    extends $AsyncNotifierProvider<StoreLocation, LatLng?> {
  const StoreLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeLocationHash();

  @$internal
  @override
  StoreLocation create() => StoreLocation();
}

String _$storeLocationHash() => r'b00f140603ac5a74e367f7f7ed6827a100634453';

abstract class _$StoreLocation extends $AsyncNotifier<LatLng?> {
  FutureOr<LatLng?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<LatLng?>, LatLng?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LatLng?>, LatLng?>,
              AsyncValue<LatLng?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
