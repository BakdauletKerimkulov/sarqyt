// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/utils/converters.dart';

part 'business.freezed.dart';
part 'business.g.dart';

typedef BusinessID = String;

enum BusinessType { individual, company }

enum SubscriptionPlan { free, basic, pro }

enum VerificationStatus { unverified, submitted, verified, rejected }

@freezed
abstract class Business with _$Business {
  const factory Business({
    required BusinessID id,
    required UserID ownerId,
    required String name,
    required double commissionRate,
    @TimestampConverter() required DateTime createdAt,
    @JsonKey(name: 'plan')
    @Default(SubscriptionPlan.free)
    SubscriptionPlan subscriptionPlan,
    @Default(VerificationStatus.unverified)
    VerificationStatus verificationStatus,
    BusinessType? type,
    String? paymentAccountId,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Business;

  const Business._();

  bool get isConfirmed => verificationStatus == VerificationStatus.verified;

  factory Business.fromJson(Map<String, dynamic> json) =>
      _$BusinessFromJson(json);
}
