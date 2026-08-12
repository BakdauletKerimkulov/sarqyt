// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviewRepository)
const reviewRepositoryProvider = ReviewRepositoryProvider._();

final class ReviewRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewRepository,
          ReviewRepository,
          ReviewRepository
        >
    with $Provider<ReviewRepository> {
  const ReviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewRepository create(Ref ref) {
    return reviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewRepository>(value),
    );
  }
}

String _$reviewRepositoryHash() => r'8ee468176d9ba2f025a6c00936684c69d848f54f';

@ProviderFor(itemReviewsStream)
const itemReviewsStreamProvider = ItemReviewsStreamFamily._();

final class ItemReviewsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Review>>,
          List<Review>,
          Stream<List<Review>>
        >
    with $FutureModifier<List<Review>>, $StreamProvider<List<Review>> {
  const ItemReviewsStreamProvider._({
    required ItemReviewsStreamFamily super.from,
    required ItemID super.argument,
  }) : super(
         retry: null,
         name: r'itemReviewsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemReviewsStreamHash();

  @override
  String toString() {
    return r'itemReviewsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Review>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Review>> create(Ref ref) {
    final argument = this.argument as ItemID;
    return itemReviewsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemReviewsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemReviewsStreamHash() => r'0e202b5a33f606880733f4925fcee4af29d14482';

final class ItemReviewsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Review>>, ItemID> {
  const ItemReviewsStreamFamily._()
    : super(
        retry: null,
        name: r'itemReviewsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemReviewsStreamProvider call(ItemID itemId) =>
      ItemReviewsStreamProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemReviewsStreamProvider';
}
