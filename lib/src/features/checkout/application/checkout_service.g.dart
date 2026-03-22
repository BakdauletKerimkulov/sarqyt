// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offerTotal)
const offerTotalProvider = OfferTotalFamily._();

final class OfferTotalProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  const OfferTotalProvider._({
    required OfferTotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'offerTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$offerTotalHash();

  @override
  String toString() {
    return r'offerTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return offerTotal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OfferTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerTotalHash() => r'd17892dbdaa88fe5702027ff830fcbfa58a875c0';

final class OfferTotalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  const OfferTotalFamily._()
    : super(
        retry: null,
        name: r'offerTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OfferTotalProvider call(String id) =>
      OfferTotalProvider._(argument: id, from: this);

  @override
  String toString() => r'offerTotalProvider';
}

@ProviderFor(OfferItemsQuantity)
const offerItemsQuantityProvider = OfferItemsQuantityProvider._();

final class OfferItemsQuantityProvider
    extends $NotifierProvider<OfferItemsQuantity, int> {
  const OfferItemsQuantityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offerItemsQuantityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offerItemsQuantityHash();

  @$internal
  @override
  OfferItemsQuantity create() => OfferItemsQuantity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$offerItemsQuantityHash() =>
    r'a02c9a6a2cca7321db9e96034fcd47b3aacab32d';

abstract class _$OfferItemsQuantity extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
