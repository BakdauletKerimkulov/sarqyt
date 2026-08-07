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
    r'6f725e83c6f7e50f5562b9241e728965a9b6adf0';

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

/// Upcoming/recent offers for an item, for the Calendar tab.

@ProviderFor(offersForItem)
const offersForItemProvider = OffersForItemFamily._();

/// Upcoming/recent offers for an item, for the Calendar tab.

final class OffersForItemProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Offer>>,
          List<Offer>,
          Stream<List<Offer>>
        >
    with $FutureModifier<List<Offer>>, $StreamProvider<List<Offer>> {
  /// Upcoming/recent offers for an item, for the Calendar tab.
  const OffersForItemProvider._({
    required OffersForItemFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'offersForItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$offersForItemHash();

  @override
  String toString() {
    return r'offersForItemProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Offer>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Offer>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return offersForItem(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is OffersForItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offersForItemHash() => r'b7eadc30d0d12d58eddde1826fdaa6492af1203a';

/// Upcoming/recent offers for an item, for the Calendar tab.

final class OffersForItemFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Offer>>, (String, String)> {
  const OffersForItemFamily._()
    : super(
        retry: null,
        name: r'offersForItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Upcoming/recent offers for an item, for the Calendar tab.

  OffersForItemProvider call(String storeId, String itemId) =>
      OffersForItemProvider._(argument: (storeId, itemId), from: this);

  @override
  String toString() => r'offersForItemProvider';
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
