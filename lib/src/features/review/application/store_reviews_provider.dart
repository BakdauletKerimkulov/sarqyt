import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/review/data/review_repository.dart';
import 'package:sarqyt/src/features/review/domain/review.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'store_reviews_provider.g.dart';

@riverpod
Stream<List<Review>> storeReviews(
  Ref ref, {
  required StoreID storeId,
  int? limit,
}) {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.watchStoreReviews(storeId, limit: limit);
}
