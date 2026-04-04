import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/converters.dart';

part 'review.freezed.dart';
part 'review.g.dart';

typedef ReviewID = String;

@freezed
abstract class Review with _$Review {
  const factory Review({
    required ReviewID id,
    required OrderID orderId,
    required StoreID storeId,
    required UserID userId,
    required int storeRating,
    required int foodRating,
    String? comment,
    @TimestampConverter() required DateTime createdAt,
  }) = _Review;

  const Review._();

  double get averageRating => (storeRating + foodRating) / 2;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);
}
