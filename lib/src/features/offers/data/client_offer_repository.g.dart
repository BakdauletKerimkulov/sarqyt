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

String _$offerStreamHash() => r'bd8199ec219bd63045d6dce91ad69833c0fed205';

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
