// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Business {

 BusinessID get id; UserID get ownerId; String get name; double get commissionRate;@TimestampConverter() DateTime get createdAt;@JsonKey(name: 'plan') SubscriptionPlan get subscriptionPlan; VerificationStatus get verificationStatus; BusinessType? get type; String? get paymentAccountId;@NullableTimestampConverter() DateTime? get updatedAt;
/// Create a copy of Business
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessCopyWith<Business> get copyWith => _$BusinessCopyWithImpl<Business>(this as Business, _$identity);

  /// Serializes this Business to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Business&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.subscriptionPlan, subscriptionPlan) || other.subscriptionPlan == subscriptionPlan)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.type, type) || other.type == type)&&(identical(other.paymentAccountId, paymentAccountId) || other.paymentAccountId == paymentAccountId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,commissionRate,createdAt,subscriptionPlan,verificationStatus,type,paymentAccountId,updatedAt);

@override
String toString() {
  return 'Business(id: $id, ownerId: $ownerId, name: $name, commissionRate: $commissionRate, createdAt: $createdAt, subscriptionPlan: $subscriptionPlan, verificationStatus: $verificationStatus, type: $type, paymentAccountId: $paymentAccountId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BusinessCopyWith<$Res>  {
  factory $BusinessCopyWith(Business value, $Res Function(Business) _then) = _$BusinessCopyWithImpl;
@useResult
$Res call({
 BusinessID id, UserID ownerId, String name, double commissionRate,@TimestampConverter() DateTime createdAt,@JsonKey(name: 'plan') SubscriptionPlan subscriptionPlan, VerificationStatus verificationStatus, BusinessType? type, String? paymentAccountId,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$BusinessCopyWithImpl<$Res>
    implements $BusinessCopyWith<$Res> {
  _$BusinessCopyWithImpl(this._self, this._then);

  final Business _self;
  final $Res Function(Business) _then;

/// Create a copy of Business
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? commissionRate = null,Object? createdAt = null,Object? subscriptionPlan = null,Object? verificationStatus = null,Object? type = freezed,Object? paymentAccountId = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as BusinessID,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as UserID,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,subscriptionPlan: null == subscriptionPlan ? _self.subscriptionPlan : subscriptionPlan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlan,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BusinessType?,paymentAccountId: freezed == paymentAccountId ? _self.paymentAccountId : paymentAccountId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Business].
extension BusinessPatterns on Business {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Business value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Business() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Business value)  $default,){
final _that = this;
switch (_that) {
case _Business():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Business value)?  $default,){
final _that = this;
switch (_that) {
case _Business() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BusinessID id,  UserID ownerId,  String name,  double commissionRate, @TimestampConverter()  DateTime createdAt, @JsonKey(name: 'plan')  SubscriptionPlan subscriptionPlan,  VerificationStatus verificationStatus,  BusinessType? type,  String? paymentAccountId, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Business() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.commissionRate,_that.createdAt,_that.subscriptionPlan,_that.verificationStatus,_that.type,_that.paymentAccountId,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BusinessID id,  UserID ownerId,  String name,  double commissionRate, @TimestampConverter()  DateTime createdAt, @JsonKey(name: 'plan')  SubscriptionPlan subscriptionPlan,  VerificationStatus verificationStatus,  BusinessType? type,  String? paymentAccountId, @NullableTimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Business():
return $default(_that.id,_that.ownerId,_that.name,_that.commissionRate,_that.createdAt,_that.subscriptionPlan,_that.verificationStatus,_that.type,_that.paymentAccountId,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BusinessID id,  UserID ownerId,  String name,  double commissionRate, @TimestampConverter()  DateTime createdAt, @JsonKey(name: 'plan')  SubscriptionPlan subscriptionPlan,  VerificationStatus verificationStatus,  BusinessType? type,  String? paymentAccountId, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Business() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.commissionRate,_that.createdAt,_that.subscriptionPlan,_that.verificationStatus,_that.type,_that.paymentAccountId,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Business extends Business {
  const _Business({required this.id, required this.ownerId, required this.name, required this.commissionRate, @TimestampConverter() required this.createdAt, @JsonKey(name: 'plan') this.subscriptionPlan = SubscriptionPlan.free, this.verificationStatus = VerificationStatus.unverified, this.type, this.paymentAccountId, @NullableTimestampConverter() this.updatedAt}): super._();
  factory _Business.fromJson(Map<String, dynamic> json) => _$BusinessFromJson(json);

@override final  BusinessID id;
@override final  UserID ownerId;
@override final  String name;
@override final  double commissionRate;
@override@TimestampConverter() final  DateTime createdAt;
@override@JsonKey(name: 'plan') final  SubscriptionPlan subscriptionPlan;
@override@JsonKey() final  VerificationStatus verificationStatus;
@override final  BusinessType? type;
@override final  String? paymentAccountId;
@override@NullableTimestampConverter() final  DateTime? updatedAt;

/// Create a copy of Business
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessCopyWith<_Business> get copyWith => __$BusinessCopyWithImpl<_Business>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Business&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.subscriptionPlan, subscriptionPlan) || other.subscriptionPlan == subscriptionPlan)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.type, type) || other.type == type)&&(identical(other.paymentAccountId, paymentAccountId) || other.paymentAccountId == paymentAccountId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,commissionRate,createdAt,subscriptionPlan,verificationStatus,type,paymentAccountId,updatedAt);

@override
String toString() {
  return 'Business(id: $id, ownerId: $ownerId, name: $name, commissionRate: $commissionRate, createdAt: $createdAt, subscriptionPlan: $subscriptionPlan, verificationStatus: $verificationStatus, type: $type, paymentAccountId: $paymentAccountId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BusinessCopyWith<$Res> implements $BusinessCopyWith<$Res> {
  factory _$BusinessCopyWith(_Business value, $Res Function(_Business) _then) = __$BusinessCopyWithImpl;
@override @useResult
$Res call({
 BusinessID id, UserID ownerId, String name, double commissionRate,@TimestampConverter() DateTime createdAt,@JsonKey(name: 'plan') SubscriptionPlan subscriptionPlan, VerificationStatus verificationStatus, BusinessType? type, String? paymentAccountId,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$BusinessCopyWithImpl<$Res>
    implements _$BusinessCopyWith<$Res> {
  __$BusinessCopyWithImpl(this._self, this._then);

  final _Business _self;
  final $Res Function(_Business) _then;

/// Create a copy of Business
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? commissionRate = null,Object? createdAt = null,Object? subscriptionPlan = null,Object? verificationStatus = null,Object? type = freezed,Object? paymentAccountId = freezed,Object? updatedAt = freezed,}) {
  return _then(_Business(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as BusinessID,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as UserID,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,subscriptionPlan: null == subscriptionPlan ? _self.subscriptionPlan : subscriptionPlan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlan,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BusinessType?,paymentAccountId: freezed == paymentAccountId ? _self.paymentAccountId : paymentAccountId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
