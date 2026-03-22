// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_ship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreShip _$StoreShipFromJson(Map<String, dynamic> json) => _StoreShip(
  storeId: json['storeId'] as String,
  businessId: json['businessId'] as String,
  userId: json['userId'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  name: json['name'] as String,
  storeRole: $enumDecode(_$StoreRoleEnumMap, json['storeRole']),
  logoUrl: json['logoUrl'] as String?,
  onboardingStatus:
      $enumDecodeNullable(
        _$OnboardingStatusEnumMap,
        json['onboardingStatus'],
      ) ??
      OnboardingStatus.storeCreated,
);

Map<String, dynamic> _$StoreShipToJson(_StoreShip instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'businessId': instance.businessId,
      'userId': instance.userId,
      'permissions': instance.permissions,
      'name': instance.name,
      'storeRole': _$StoreRoleEnumMap[instance.storeRole]!,
      'logoUrl': instance.logoUrl,
      'onboardingStatus': _$OnboardingStatusEnumMap[instance.onboardingStatus]!,
    };

const _$StoreRoleEnumMap = {
  StoreRole.owner: 'owner',
  StoreRole.operator: 'operator',
  StoreRole.employer: 'employer',
};

const _$OnboardingStatusEnumMap = {
  OnboardingStatus.storeCreated: 'storeCreated',
  OnboardingStatus.itemCreated: 'itemCreated',
  OnboardingStatus.completed: 'completed',
};
