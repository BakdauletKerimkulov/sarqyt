// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Rating _$RatingFromJson(Map<String, dynamic> json) => _Rating(
  average: (json['average'] as num).toDouble(),
  ratingCount: (json['ratingCount'] as num).toInt(),
);

Map<String, dynamic> _$RatingToJson(_Rating instance) => <String, dynamic>{
  'average': instance.average,
  'ratingCount': instance.ratingCount,
};
