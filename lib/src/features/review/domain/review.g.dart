// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  storeId: json['storeId'] as String,
  userId: json['userId'] as String,
  storeRating: (json['storeRating'] as num).toInt(),
  foodRating: (json['foodRating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'storeId': instance.storeId,
  'userId': instance.userId,
  'storeRating': instance.storeRating,
  'foodRating': instance.foodRating,
  'comment': instance.comment,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
