import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/review/data/review_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'review_controller.g.dart';

@riverpod
class ReviewController extends _$ReviewController {
  @override
  FutureOr<void> build() {}

  Future<bool> submitReview({
    required OrderID orderId,
    required StoreID storeId,
    required int storeRating,
    required int offerRating,
    String? comment,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // itemId is denormalized from the order rather than threaded through
      // navigation params, so it's correct regardless of entry point
      // (order-detail button vs. a review-prompt push deep link).
      final order = await ref
          .read(clientOrdersRepositoryProvider)
          .watchOrder(orderId)
          .first;
      await ref
          .read(reviewRepositoryProvider)
          .submitReview(
            orderId: orderId,
            storeId: storeId,
            userId: user.uid,
            itemId: order?.itemId,
            storeRating: storeRating,
            offerRating: offerRating,
            comment: comment,
          );
    });
    return !state.hasError;
  }
}
