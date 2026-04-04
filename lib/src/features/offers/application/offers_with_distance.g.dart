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
    r'f57eb192b714b99dde84c59e7d542abc2b55fbf3';
