// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BusinessMembership _$BusinessMembershipFromJson(Map<String, dynamic> json) =>
    _BusinessMembership(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      userId: json['userId'] as String,
      role: $enumDecode(_$BusinessMembershipRoleEnumMap, json['role']),
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      updatedAt: const NullableTimestampConverter().fromJson(
        json['updatedAt'] as Timestamp?,
      ),
    );

Map<String, dynamic> _$BusinessMembershipToJson(
  _BusinessMembership instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'userId': instance.userId,
  'role': _$BusinessMembershipRoleEnumMap[instance.role]!,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
};

const _$BusinessMembershipRoleEnumMap = {
  BusinessMembershipRole.owner: 'owner',
  BusinessMembershipRole.admin: 'admin',
};
