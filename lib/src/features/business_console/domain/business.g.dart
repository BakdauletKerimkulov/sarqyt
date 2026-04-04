// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Business _$BusinessFromJson(Map<String, dynamic> json) => _Business(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  commissionRate: (json['commissionRate'] as num).toDouble(),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  subscriptionPlan:
      $enumDecodeNullable(_$SubscriptionPlanEnumMap, json['plan']) ??
      SubscriptionPlan.free,
  verificationStatus:
      $enumDecodeNullable(
        _$VerificationStatusEnumMap,
        json['verificationStatus'],
      ) ??
      VerificationStatus.unverified,
  type: $enumDecodeNullable(_$BusinessTypeEnumMap, json['type']),
  paymentAccountId: json['paymentAccountId'] as String?,
  updatedAt: const NullableTimestampConverter().fromJson(
    json['updatedAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$BusinessToJson(_Business instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'name': instance.name,
  'commissionRate': instance.commissionRate,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'plan': _$SubscriptionPlanEnumMap[instance.subscriptionPlan]!,
  'verificationStatus':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'type': _$BusinessTypeEnumMap[instance.type],
  'paymentAccountId': instance.paymentAccountId,
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
};

const _$SubscriptionPlanEnumMap = {
  SubscriptionPlan.free: 'free',
  SubscriptionPlan.basic: 'basic',
  SubscriptionPlan.pro: 'pro',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.unverified: 'unverified',
  VerificationStatus.submitted: 'submitted',
  VerificationStatus.verified: 'verified',
  VerificationStatus.rejected: 'rejected',
};

const _$BusinessTypeEnumMap = {
  BusinessType.individual: 'individual',
  BusinessType.company: 'company',
};
