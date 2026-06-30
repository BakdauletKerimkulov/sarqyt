// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_reviews_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeReviews)
const storeReviewsProvider = StoreReviewsFamily._();

final class StoreReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Review>>,
          List<Review>,
          Stream<List<Review>>
        >
    with $FutureModifier<List<Review>>, $StreamProvider<List<Review>> {
  const StoreReviewsProvider._({
    required StoreReviewsFamily super.from,
    required ({StoreID storeId, int? limit}) super.argument,
  }) : super(
         retry: null,
         name: r'storeReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeReviewsHash();

  @override
  String toString() {
    return r'storeReviewsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Review>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Review>> create(Ref ref) {
    final argument = this.argument as ({StoreID storeId, int? limit});
    return storeReviews(ref, storeId: argument.storeId, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeReviewsHash() => r'2bb860a6f8ca3e034821d150369fe5b2bd3c4fbf';

final class StoreReviewsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Review>>,
          ({StoreID storeId, int? limit})
        > {
  const StoreReviewsFamily._()
    : super(
        retry: null,
        name: r'storeReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreReviewsProvider call({required StoreID storeId, int? limit}) =>
      StoreReviewsProvider._(
        argument: (storeId: storeId, limit: limit),
        from: this,
      );

  @override
  String toString() => r'storeReviewsProvider';
}
