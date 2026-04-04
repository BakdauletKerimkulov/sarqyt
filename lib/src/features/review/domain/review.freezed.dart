// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Review {

 ReviewID get id; OrderID get orderId; StoreID get storeId; UserID get userId; int get storeRating; int get foodRating; String? get comment;@TimestampConverter() DateTime get createdAt;
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewCopyWith<Review> get copyWith => _$ReviewCopyWithImpl<Review>(this as Review, _$identity);

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Review&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeRating, storeRating) || other.storeRating == storeRating)&&(identical(other.foodRating, foodRating) || other.foodRating == foodRating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,storeId,userId,storeRating,foodRating,comment,createdAt);

@override
String toString() {
  return 'Review(id: $id, orderId: $orderId, storeId: $storeId, userId: $userId, storeRating: $storeRating, foodRating: $foodRating, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReviewCopyWith<$Res>  {
  factory $ReviewCopyWith(Review value, $Res Function(Review) _then) = _$ReviewCopyWithImpl;
@useResult
$Res call({
 ReviewID id, OrderID orderId, StoreID storeId, UserID userId, int storeRating, int foodRating, String? comment,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$ReviewCopyWithImpl<$Res>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._self, this._then);

  final Review _self;
  final $Res Function(Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? storeId = null,Object? userId = null,Object? storeRating = null,Object? foodRating = null,Object? comment = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReviewID,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as OrderID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as StoreID,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as UserID,storeRating: null == storeRating ? _self.storeRating : storeRating // ignore: cast_nullable_to_non_nullable
as int,foodRating: null == foodRating ? _self.foodRating : foodRating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Review].
extension ReviewPatterns on Review {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Review value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Review value)  $default,){
final _that = this;
switch (_that) {
case _Review():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Review value)?  $default,){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReviewID id,  OrderID orderId,  StoreID storeId,  UserID userId,  int storeRating,  int foodRating,  String? comment, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.orderId,_that.storeId,_that.userId,_that.storeRating,_that.foodRating,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReviewID id,  OrderID orderId,  StoreID storeId,  UserID userId,  int storeRating,  int foodRating,  String? comment, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Review():
return $default(_that.id,_that.orderId,_that.storeId,_that.userId,_that.storeRating,_that.foodRating,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReviewID id,  OrderID orderId,  StoreID storeId,  UserID userId,  int storeRating,  int foodRating,  String? comment, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.orderId,_that.storeId,_that.userId,_that.storeRating,_that.foodRating,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Review extends Review {
  const _Review({required this.id, required this.orderId, required this.storeId, required this.userId, required this.storeRating, required this.foodRating, this.comment, @TimestampConverter() required this.createdAt}): super._();
  factory _Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

@override final  ReviewID id;
@override final  OrderID orderId;
@override final  StoreID storeId;
@override final  UserID userId;
@override final  int storeRating;
@override final  int foodRating;
@override final  String? comment;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewCopyWith<_Review> get copyWith => __$ReviewCopyWithImpl<_Review>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Review&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeRating, storeRating) || other.storeRating == storeRating)&&(identical(other.foodRating, foodRating) || other.foodRating == foodRating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,storeId,userId,storeRating,foodRating,comment,createdAt);

@override
String toString() {
  return 'Review(id: $id, orderId: $orderId, storeId: $storeId, userId: $userId, storeRating: $storeRating, foodRating: $foodRating, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$ReviewCopyWith(_Review value, $Res Function(_Review) _then) = __$ReviewCopyWithImpl;
@override @useResult
$Res call({
 ReviewID id, OrderID orderId, StoreID storeId, UserID userId, int storeRating, int foodRating, String? comment,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$ReviewCopyWithImpl<$Res>
    implements _$ReviewCopyWith<$Res> {
  __$ReviewCopyWithImpl(this._self, this._then);

  final _Review _self;
  final $Res Function(_Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? storeId = null,Object? userId = null,Object? storeRating = null,Object? foodRating = null,Object? comment = freezed,Object? createdAt = null,}) {
  return _then(_Review(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReviewID,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as OrderID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as StoreID,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as UserID,storeRating: null == storeRating ? _self.storeRating : storeRating // ignore: cast_nullable_to_non_nullable
as int,foodRating: null == foodRating ? _self.foodRating : foodRating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
