// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_offer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(businessOfferRepository)
const businessOfferRepositoryProvider = BusinessOfferRepositoryProvider._();

final class BusinessOfferRepositoryProvider
    extends
        $FunctionalProvider<
          BusinessOfferRepository,
          BusinessOfferRepository,
          BusinessOfferRepository
        >
    with $Provider<BusinessOfferRepository> {
  const BusinessOfferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessOfferRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessOfferRepositoryHash();

  @$internal
  @override
  $ProviderElement<BusinessOfferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BusinessOfferRepository create(Ref ref) {
    return businessOfferRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessOfferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessOfferRepository>(value),
    );
  }
}

String _$businessOfferRepositoryHash() =>
    r'3c0305d3028b6c7e5f88a6c3a8a6ce817568946e';

/// Stream of current offer for an item (today's active).

@ProviderFor(currentOfferForItem)
const currentOfferForItemProvider = CurrentOfferForItemFamily._();

/// Stream of current offer for an item (today's active).

final class CurrentOfferForItemProvider
    extends $FunctionalProvider<AsyncValue<Offer?>, Offer?, Stream<Offer?>>
    with $FutureModifier<Offer?>, $StreamProvider<Offer?> {
  /// Stream of current offer for an item (today's active).
  const CurrentOfferForItemProvider._({
    required CurrentOfferForItemFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'currentOfferForItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentOfferForItemHash();

  @override
  String toString() {
    return r'currentOfferForItemProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Offer?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Offer?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return currentOfferForItem(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentOfferForItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentOfferForItemHash() =>
    r'4db0686ab8e0085fdb9e8456eca1e348eaa4de44';

/// Stream of current offer for an item (today's active).

final class CurrentOfferForItemFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Offer?>, (String, String)> {
  const CurrentOfferForItemFamily._()
    : super(
        retry: null,
        name: r'currentOfferForItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream of current offer for an item (today's active).

  CurrentOfferForItemProvider call(String storeId, String itemId) =>
      CurrentOfferForItemProvider._(argument: (storeId, itemId), from: this);

  @override
  String toString() => r'currentOfferForItemProvider';
}

/// Stream of active item IDs (productId) for a given store.

@ProviderFor(storeActiveOfferItemIds)
const storeActiveOfferItemIdsProvider = StoreActiveOfferItemIdsFamily._();

/// Stream of active item IDs (productId) for a given store.

final class StoreActiveOfferItemIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<ItemID>>,
          Set<ItemID>,
          Stream<Set<ItemID>>
        >
    with $FutureModifier<Set<ItemID>>, $StreamProvider<Set<ItemID>> {
  /// Stream of active item IDs (productId) for a given store.
  const StoreActiveOfferItemIdsProvider._({
    required StoreActiveOfferItemIdsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storeActiveOfferItemIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeActiveOfferItemIdsHash();

  @override
  String toString() {
    return r'storeActiveOfferItemIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<ItemID>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<ItemID>> create(Ref ref) {
    final argument = this.argument as String;
    return storeActiveOfferItemIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreActiveOfferItemIdsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeActiveOfferItemIdsHash() =>
    r'cff1814d76272e84377888b33fa100066cf4e1d6';

/// Stream of active item IDs (productId) for a given store.

final class StoreActiveOfferItemIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<ItemID>>, String> {
  const StoreActiveOfferItemIdsFamily._()
    : super(
        retry: null,
        name: r'storeActiveOfferItemIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream of active item IDs (productId) for a given store.

  StoreActiveOfferItemIdsProvider call(String storeId) =>
      StoreActiveOfferItemIdsProvider._(argument: storeId, from: this);

  @override
  String toString() => r'storeActiveOfferItemIdsProvider';
}
