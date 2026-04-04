import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
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
    required int foodRating,
    String? comment,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(reviewRepositoryProvider).submitReview(
            orderId: orderId,
            storeId: storeId,
            userId: user.uid,
            storeRating: storeRating,
            foodRating: foodRating,
            comment: comment,
          );
    });
    return !state.hasError;
  }
}
