// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offers_with_distance.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams nearby offers with distance calculated.
/// Uses geo-filtered Firestore query when location is available,
/// falls back to all offers when location is unavailable.

@ProviderFor(offersWithDistanceStream)
const offersWithDistanceStreamProvider = OffersWithDistanceStreamProvider._();

/// Streams nearby offers with distance calculated.
/// Uses geo-filtered Firestore query when location is available,
/// falls back to all offers when location is unavailable.

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
  /// Streams nearby offers with distance calculated.
  /// Uses geo-filtered Firestore query when location is available,
  /// falls back to all offers when location is unavailable.
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
    r'da7b982ccefbf9f1c02f1ac106a8af72efe32f74';
