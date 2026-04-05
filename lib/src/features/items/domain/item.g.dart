// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: _readRequiredId(json['id']),
  name: _readRequiredName(json['name']),
  price: _readRequiredPrice(json['price']),
  schedule: _readRequiredSchedule(json['schedule']),
  estimatedValue: _readOptionalPrice(
    _readEstimatedValueSource(json, 'estimatedValue'),
  ),
  imageUrl: json['imageUrl'] as String?,
  description: json['description'] as String?,
  category: json['category'] as String?,
  dietaryType:
      $enumDecodeNullable(
        _$DietaryTypeEnumMap,
        json['dietaryType'],
        unknownValue: DietaryType.notSpecified,
      ) ??
      DietaryType.notSpecified,
  packagingType:
      $enumDecodeNullable(
        _$PackagingOptionEnumMap,
        json['packagingType'],
        unknownValue: PackagingOption.withBagOrOwnBag,
      ) ??
      PackagingOption.withBagOrOwnBag,
  collectionInstructions: json['collectionInstructions'] as String?,
  isActive: json['isActive'] as bool? ?? false,
  type:
      $enumDecodeNullable(
        _$ItemTypeEnumMap,
        json['type'],
        unknownValue: ItemType.scheduled,
      ) ??
      ItemType.scheduled,
  oneTimeDate: json['oneTimeDate'] as String?,
  oneTimeStartHour: (json['oneTimeStartHour'] as num?)?.toInt(),
  oneTimeStartMinute: (json['oneTimeStartMinute'] as num?)?.toInt(),
  oneTimeEndHour: (json['oneTimeEndHour'] as num?)?.toInt(),
  oneTimeEndMinute: (json['oneTimeEndMinute'] as num?)?.toInt(),
  oneTimeQuantity: (json['oneTimeQuantity'] as num?)?.toInt(),
  isBuffetFood: json['isBuffetFood'] as bool? ?? false,
  storingAndAllergens: json['storingAndAllergens'] as String?,
  badges:
      (json['badges'] as List<dynamic>?)
          ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  averageOverallRating: json['averageOverallRating'] == null
      ? null
      : Rating.fromJson(json['averageOverallRating'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': _writePrice(instance.price),
  'schedule': _writeSchedule(instance.schedule),
  'estimatedValue': _writeOptionalPrice(instance.estimatedValue),
  'imageUrl': instance.imageUrl,
  'description': instance.description,
  'category': instance.category,
  'dietaryType': _$DietaryTypeEnumMap[instance.dietaryType]!,
  'packagingType': _$PackagingOptionEnumMap[instance.packagingType]!,
  'collectionInstructions': instance.collectionInstructions,
  'isActive': instance.isActive,
  'type': _$ItemTypeEnumMap[instance.type]!,
  'oneTimeDate': instance.oneTimeDate,
  'oneTimeStartHour': instance.oneTimeStartHour,
  'oneTimeStartMinute': instance.oneTimeStartMinute,
  'oneTimeEndHour': instance.oneTimeEndHour,
  'oneTimeEndMinute': instance.oneTimeEndMinute,
  'oneTimeQuantity': instance.oneTimeQuantity,
  'isBuffetFood': instance.isBuffetFood,
  'storingAndAllergens': instance.storingAndAllergens,
  'badges': instance.badges.map((e) => e.toJson()).toList(),
  'averageOverallRating': instance.averageOverallRating?.toJson(),
};

const _$DietaryTypeEnumMap = {
  DietaryType.notSpecified: 'notSpecified',
  DietaryType.vegetarian: 'vegetarian',
};

const _$PackagingOptionEnumMap = {
  PackagingOption.withBag: 'withBag',
  PackagingOption.withBagOrOwnBag: 'withBagOrOwnBag',
  PackagingOption.noBag: 'noBag',
};

const _$ItemTypeEnumMap = {
  ItemType.scheduled: 'scheduled',
  ItemType.oneTime: 'oneTime',
};
