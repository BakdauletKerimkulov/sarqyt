// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_filter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiscoverFilterController)
const discoverFilterControllerProvider = DiscoverFilterControllerProvider._();

final class DiscoverFilterControllerProvider
    extends $NotifierProvider<DiscoverFilterController, DiscoverFilter> {
  const DiscoverFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverFilterControllerHash();

  @$internal
  @override
  DiscoverFilterController create() => DiscoverFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoverFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoverFilter>(value),
    );
  }
}

String _$discoverFilterControllerHash() =>
    r'60049f1526f08505b7b1840da35e45a6f6fc4d69';

abstract class _$DiscoverFilterController extends $Notifier<DiscoverFilter> {
  DiscoverFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DiscoverFilter, DiscoverFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DiscoverFilter, DiscoverFilter>,
              DiscoverFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(filteredOffers)
const filteredOffersProvider = FilteredOffersFamily._();

final class FilteredOffersProvider
    extends
        $FunctionalProvider<
          List<OfferWithDistance>,
          List<OfferWithDistance>,
          List<OfferWithDistance>
        >
    with $Provider<List<OfferWithDistance>> {
  const FilteredOffersProvider._({
    required FilteredOffersFamily super.from,
    required (List<OfferWithDistance>, DiscoverFilter, Set<String>)
    super.argument,
  }) : super(
         retry: null,
         name: r'filteredOffersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredOffersHash();

  @override
  String toString() {
    return r'filteredOffersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<OfferWithDistance>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<OfferWithDistance> create(Ref ref) {
    final argument =
        this.argument as (List<OfferWithDistance>, DiscoverFilter, Set<String>);
    return filteredOffers(ref, argument.$1, argument.$2, argument.$3);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OfferWithDistance> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OfferWithDistance>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredOffersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredOffersHash() => r'80146c1def69d9876e127684f93629c87abf8dcc';

final class FilteredOffersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<OfferWithDistance>,
          (List<OfferWithDistance>, DiscoverFilter, Set<String>)
        > {
  const FilteredOffersFamily._()
    : super(
        retry: null,
        name: r'filteredOffersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredOffersProvider call(
    List<OfferWithDistance> offers,
    DiscoverFilter filter,
    Set<String> favoriteStoreIds,
  ) => FilteredOffersProvider._(
    argument: (offers, filter, favoriteStoreIds),
    from: this,
  );

  @override
  String toString() => r'filteredOffersProvider';
}
