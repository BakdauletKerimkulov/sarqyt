// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offers_repository.dart';

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
          OffersRepository,
          OffersRepository,
          OffersRepository
        >
    with $Provider<OffersRepository> {
  const OfferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offerRepositoryHash();

  @$internal
  @override
  $ProviderElement<OffersRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OffersRepository create(Ref ref) {
    return offerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OffersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OffersRepository>(value),
    );
  }
}

String _$offerRepositoryHash() => r'bd38a84b10ddb25ceb93de15f50c459752ac7d18';

@ProviderFor(offerListStream)
const offerListStreamProvider = OfferListStreamProvider._();

final class OfferListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Offer>>,
          List<Offer>,
          Stream<List<Offer>>
        >
    with $FutureModifier<List<Offer>>, $StreamProvider<List<Offer>> {
  const OfferListStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offerListStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offerListStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Offer>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Offer>> create(Ref ref) {
    return offerListStream(ref);
  }
}

String _$offerListStreamHash() => r'c945f93a03efea707c36492987a03fcc8b50ae63';

@ProviderFor(offerListFuture)
const offerListFutureProvider = OfferListFutureProvider._();

final class OfferListFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Offer>>,
          List<Offer>,
          FutureOr<List<Offer>>
        >
    with $FutureModifier<List<Offer>>, $FutureProvider<List<Offer>> {
  const OfferListFutureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offerListFutureProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offerListFutureHash();

  @$internal
  @override
  $FutureProviderElement<List<Offer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Offer>> create(Ref ref) {
    return offerListFuture(ref);
  }
}

String _$offerListFutureHash() => r'ed5a2fe9d998bcdf9aafacfb0ecea094d8c83659';

@ProviderFor(offerStream)
const offerStreamProvider = OfferStreamFamily._();

final class OfferStreamProvider
    extends $FunctionalProvider<AsyncValue<Offer?>, Offer?, Stream<Offer?>>
    with $FutureModifier<Offer?>, $StreamProvider<Offer?> {
  const OfferStreamProvider._({
    required OfferStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'offerStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$offerStreamHash();

  @override
  String toString() {
    return r'offerStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Offer?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Offer?> create(Ref ref) {
    final argument = this.argument as String;
    return offerStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OfferStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerStreamHash() => r'b47c50d9e4258e655a451d5e1fef8dad8a21d082';

final class OfferStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Offer?>, String> {
  const OfferStreamFamily._()
    : super(
        retry: null,
        name: r'offerStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OfferStreamProvider call(String id) =>
      OfferStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'offerStreamProvider';
}

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

String _$offerFutureHash() => r'336e2dfe87484df90f70ad98f2dfac6681bf2460';

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
