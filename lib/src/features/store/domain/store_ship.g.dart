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
  role: $enumDecode(_$StoreRoleEnumMap, _readRole(json, 'role')),
  logoUrl: json['logoUrl'] as String?,
  welcomeCompleted: json['welcomeCompleted'] as bool? ?? false,
  hasFirstItem: json['hasFirstItem'] as bool? ?? false,
);

Map<String, dynamic> _$StoreShipToJson(_StoreShip instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'businessId': instance.businessId,
      'userId': instance.userId,
      'permissions': instance.permissions,
      'name': instance.name,
      'role': _$StoreRoleEnumMap[instance.role]!,
      'logoUrl': instance.logoUrl,
      'welcomeCompleted': instance.welcomeCompleted,
      'hasFirstItem': instance.hasFirstItem,
    };

const _$StoreRoleEnumMap = {
  StoreRole.owner: 'owner',
  StoreRole.operator: 'operator',
  StoreRole.employer: 'employer',
};
