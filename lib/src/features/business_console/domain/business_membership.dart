import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/utils/converters.dart';

part 'business_membership.freezed.dart';
part 'business_membership.g.dart';

enum BusinessMembershipRole { owner, admin }

@freezed
abstract class BusinessMembership with _$BusinessMembership {
  const factory BusinessMembership({
    required String id,
    required String businessId,
    required String userId,
    required BusinessMembershipRole role,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _BusinessMembership;

  factory BusinessMembership.fromJson(Map<String, dynamic> json) =>
      _$BusinessMembershipFromJson(json);
}
