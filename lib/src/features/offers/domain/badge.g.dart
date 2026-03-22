// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Badge _$BadgeFromJson(Map<String, dynamic> json) => _Badge(
  type: $enumDecode(_$BadgeTypeEnumMap, json['type']),
  percentage: (json['percentage'] as num?)?.toInt(),
  userCount: (json['userCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$BadgeToJson(_Badge instance) => <String, dynamic>{
  'type': _$BadgeTypeEnumMap[instance.type]!,
  'percentage': instance.percentage,
  'userCount': instance.userCount,
};

const _$BadgeTypeEnumMap = {
  BadgeType.popular: 'popular',
  BadgeType.topRated: 'topRated',
  BadgeType.newItem: 'newItem',
  BadgeType.trending: 'trending',
  BadgeType.eco: 'eco',
  BadgeType.special: 'special',
};
