// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReviewController)
const reviewControllerProvider = ReviewControllerProvider._();

final class ReviewControllerProvider
    extends $AsyncNotifierProvider<ReviewController, void> {
  const ReviewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewControllerHash();

  @$internal
  @override
  ReviewController create() => ReviewController();
}

String _$reviewControllerHash() => r'e8da1a57cbd1c903cf2d63f2d209e5f6336b9eef';

abstract class _$ReviewController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
