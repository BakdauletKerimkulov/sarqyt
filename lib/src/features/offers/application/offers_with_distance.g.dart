// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offers_with_distance.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offersWithDistance)
const offersWithDistanceProvider = OffersWithDistanceProvider._();

final class OffersWithDistanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OfferWithDistance>>,
          List<OfferWithDistance>,
          FutureOr<List<OfferWithDistance>>
        >
    with
        $FutureModifier<List<OfferWithDistance>>,
        $FutureProvider<List<OfferWithDistance>> {
  const OffersWithDistanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offersWithDistanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offersWithDistanceHash();

  @$internal
  @override
  $FutureProviderElement<List<OfferWithDistance>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OfferWithDistance>> create(Ref ref) {
    return offersWithDistance(ref);
  }
}

String _$offersWithDistanceHash() =>
    r'39c75c934f64433c06e59b5a286417819b61f491';

@ProviderFor(offersWithDistanceStream)
const offersWithDistanceStreamProvider = OffersWithDistanceStreamProvider._();

final class OffersWithDistanceStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OfferWithDistance>>,
          List<OfferWithDistance>,
          Stream<List<OfferWithDistance>>
        >
    with
        $FutureModifier<List<OfferWithDistance>>,
        $StreamProvider<List<OfferWithDistance>> {
  const OffersWithDistanceStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offersWithDistanceStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offersWithDistanceStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<OfferWithDistance>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<OfferWithDistance>> create(Ref ref) {
    return offersWithDistanceStream(ref);
  }
}

String _$offersWithDistanceStreamHash() =>
    r'c3da174e89f2f06f6f036ec9cbe46b8ca5ebfa13';
