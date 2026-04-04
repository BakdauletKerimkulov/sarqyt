// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_offer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offerRepository)
const offerRepositoryProvider = OfferRepositoryProvider._();

final class OfferRepositoryProvider
    extends
        $FunctionalProvider<
          ClientOfferRepository,
          ClientOfferRepository,
          ClientOfferRepository
        >
    with $Provider<ClientOfferRepository> {
  const OfferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offerRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClientOfferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientOfferRepository create(Ref ref) {
    return offerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientOfferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientOfferRepository>(value),
    );
  }
}

String _$offerRepositoryHash() => r'c6f18aa32e2e819de85ff87305472e8a4e9ba26c';

@ProviderFor(offersListFuture)
const offersListFutureProvider = OffersListFutureProvider._();

final class OffersListFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Offer>>,
          List<Offer>,
          FutureOr<List<Offer>>
        >
    with $FutureModifier<List<Offer>>, $FutureProvider<List<Offer>> {
  const OffersListFutureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offersListFutureProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offersListFutureHash();

  @$internal
  @override
  $FutureProviderElement<List<Offer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Offer>> create(Ref ref) {
    return offersListFuture(ref);
  }
}

String _$offersListFutureHash() => r'ebea806ea973d86ce9bb603ce71e64969edc93b3';

@ProviderFor(offersListStream)
const offersListStreamProvider = OffersListStreamProvider._();

final class OffersListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Offer>>,
          List<Offer>,
          Stream<List<Offer>>
        >
    with $FutureModifier<List<Offer>>, $StreamProvider<List<Offer>> {
  const OffersListStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offersListStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offersListStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Offer>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Offer>> create(Ref ref) {
    return offersListStream(ref);
  }
}

String _$offersListStreamHash() => r'bf7f5254f8e131039edd3dda93351901df8750b5';

@ProviderFor(offerFuture)
const offerFutureProvider = OfferFutureFamily._();

final class OfferFutureProvider
    extends $FunctionalProvider<AsyncValue<Offer?>, Offer?, FutureOr<Offer?>>
    with $FutureModifier<Offer?>, $FutureProvider<Offer?> {
  const OfferFutureProvider._({
    required OfferFutureFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'offerFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$offerFutureHash();

  @override
  String toString() {
    return r'offerFutureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Offer?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Offer?> create(Ref ref) {
    final argument = this.argument as String;
    return offerFuture(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OfferFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerFutureHash() => r'edcd909d1504d11c9b9021b2c20462cafc20552a';

final class OfferFutureFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Offer?>, String> {
  const OfferFutureFamily._()
    : super(
        retry: null,
        name: r'offerFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OfferFutureProvider call(String id) =>
      OfferFutureProvider._(argument: id, from: this);

  @override
  String toString() => r'offerFutureProvider';
}
