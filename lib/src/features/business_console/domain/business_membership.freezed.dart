// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BusinessMembership {

 String get id; String get businessId; String get userId; BusinessMembershipRole get role;@TimestampConverter() DateTime get createdAt;@NullableTimestampConverter() DateTime? get updatedAt;
/// Create a copy of BusinessMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessMembershipCopyWith<BusinessMembership> get copyWith => _$BusinessMembershipCopyWithImpl<BusinessMembership>(this as BusinessMembership, _$identity);

  /// Serializes this BusinessMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,userId,role,createdAt,updatedAt);

@override
String toString() {
  return 'BusinessMembership(id: $id, businessId: $businessId, userId: $userId, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BusinessMembershipCopyWith<$Res>  {
  factory $BusinessMembershipCopyWith(BusinessMembership value, $Res Function(BusinessMembership) _then) = _$BusinessMembershipCopyWithImpl;
@useResult
$Res call({
 String id, String businessId, String userId, BusinessMembershipRole role,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$BusinessMembershipCopyWithImpl<$Res>
    implements $BusinessMembershipCopyWith<$Res> {
  _$BusinessMembershipCopyWithImpl(this._self, this._then);

  final BusinessMembership _self;
  final $Res Function(BusinessMembership) _then;

/// Create a copy of BusinessMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? userId = null,Object? role = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as BusinessMembershipRole,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessMembership].
extension BusinessMembershipPatterns on BusinessMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessMembership value)  $default,){
final _that = this;
switch (_that) {
case _BusinessMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessMembership value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String businessId,  String userId,  BusinessMembershipRole role, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessMembership() when $default != null:
return $default(_that.id,_that.businessId,_that.userId,_that.role,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String businessId,  String userId,  BusinessMembershipRole role, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BusinessMembership():
return $default(_that.id,_that.businessId,_that.userId,_that.role,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String businessId,  String userId,  BusinessMembershipRole role, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BusinessMembership() when $default != null:
return $default(_that.id,_that.businessId,_that.userId,_that.role,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessMembership implements BusinessMembership {
  const _BusinessMembership({required this.id, required this.businessId, required this.userId, required this.role, @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.updatedAt});
  factory _BusinessMembership.fromJson(Map<String, dynamic> json) => _$BusinessMembershipFromJson(json);

@override final  String id;
@override final  String businessId;
@override final  String userId;
@override final  BusinessMembershipRole role;
@override@TimestampConverter() final  DateTime createdAt;
@override@NullableTimestampConverter() final  DateTime? updatedAt;

/// Create a copy of BusinessMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessMembershipCopyWith<_BusinessMembership> get copyWith => __$BusinessMembershipCopyWithImpl<_BusinessMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,userId,role,createdAt,updatedAt);

@override
String toString() {
  return 'BusinessMembership(id: $id, businessId: $businessId, userId: $userId, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BusinessMembershipCopyWith<$Res> implements $BusinessMembershipCopyWith<$Res> {
  factory _$BusinessMembershipCopyWith(_BusinessMembership value, $Res Function(_BusinessMembership) _then) = __$BusinessMembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String businessId, String userId, BusinessMembershipRole role,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$BusinessMembershipCopyWithImpl<$Res>
    implements _$BusinessMembershipCopyWith<$Res> {
  __$BusinessMembershipCopyWithImpl(this._self, this._then);

  final _BusinessMembership _self;
  final $Res Function(_BusinessMembership) _then;

/// Create a copy of BusinessMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? userId = null,Object? role = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_BusinessMembership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as BusinessMembershipRole,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
