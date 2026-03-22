import 'package:freezed_annotation/freezed_annotation.dart';

part "rating.freezed.dart";
part "rating.g.dart";

/// The [Rating] contains the `averageOverallRating`,
/// the `ratingCount` and the `monthCount` of a [Item].
@freezed
abstract class Rating with _$Rating {
  const factory Rating({required double average, required int ratingCount}) =
      _Rating;

  const Rating._();

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

  void validate() {
    assert(average >= 0 && average <= 5, 'Average must be between 0 and 5');
    assert(ratingCount >= 0, 'Rating count cannot be negative');
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      average: map['average'] ?? 0.0,
      ratingCount: map['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'average': average, 'ratingCount': ratingCount};
  }
}
