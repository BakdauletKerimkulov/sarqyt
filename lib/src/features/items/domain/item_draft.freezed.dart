// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItemDraft {

 String get title; String get description; double? get price; double? get estimatedValue; String? get imageUrl; int? get defaultDailyStock; WeeklySchedule? get schedule;
/// Create a copy of ItemDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemDraftCopyWith<ItemDraft> get copyWith => _$ItemDraftCopyWithImpl<ItemDraft>(this as ItemDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.estimatedValue, estimatedValue) || other.estimatedValue == estimatedValue)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.defaultDailyStock, defaultDailyStock) || other.defaultDailyStock == defaultDailyStock)&&(identical(other.schedule, schedule) || other.schedule == schedule));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,price,estimatedValue,imageUrl,defaultDailyStock,schedule);

@override
String toString() {
  return 'ItemDraft(title: $title, description: $description, price: $price, estimatedValue: $estimatedValue, imageUrl: $imageUrl, defaultDailyStock: $defaultDailyStock, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class $ItemDraftCopyWith<$Res>  {
  factory $ItemDraftCopyWith(ItemDraft value, $Res Function(ItemDraft) _then) = _$ItemDraftCopyWithImpl;
@useResult
$Res call({
 String title, String description, double? price, double? estimatedValue, String? imageUrl, int? defaultDailyStock, WeeklySchedule? schedule
});




}
/// @nodoc
class _$ItemDraftCopyWithImpl<$Res>
    implements $ItemDraftCopyWith<$Res> {
  _$ItemDraftCopyWithImpl(this._self, this._then);

  final ItemDraft _self;
  final $Res Function(ItemDraft) _then;

/// Create a copy of ItemDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? price = freezed,Object? estimatedValue = freezed,Object? imageUrl = freezed,Object? defaultDailyStock = freezed,Object? schedule = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,estimatedValue: freezed == estimatedValue ? _self.estimatedValue : estimatedValue // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,defaultDailyStock: freezed == defaultDailyStock ? _self.defaultDailyStock : defaultDailyStock // ignore: cast_nullable_to_non_nullable
as int?,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as WeeklySchedule?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemDraft].
extension ItemDraftPatterns on ItemDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemDraft value)  $default,){
final _that = this;
switch (_that) {
case _ItemDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ItemDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  double? price,  double? estimatedValue,  String? imageUrl,  int? defaultDailyStock,  WeeklySchedule? schedule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemDraft() when $default != null:
return $default(_that.title,_that.description,_that.price,_that.estimatedValue,_that.imageUrl,_that.defaultDailyStock,_that.schedule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  double? price,  double? estimatedValue,  String? imageUrl,  int? defaultDailyStock,  WeeklySchedule? schedule)  $default,) {final _that = this;
switch (_that) {
case _ItemDraft():
return $default(_that.title,_that.description,_that.price,_that.estimatedValue,_that.imageUrl,_that.defaultDailyStock,_that.schedule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  double? price,  double? estimatedValue,  String? imageUrl,  int? defaultDailyStock,  WeeklySchedule? schedule)?  $default,) {final _that = this;
switch (_that) {
case _ItemDraft() when $default != null:
return $default(_that.title,_that.description,_that.price,_that.estimatedValue,_that.imageUrl,_that.defaultDailyStock,_that.schedule);case _:
  return null;

}
}

}

/// @nodoc


class _ItemDraft implements ItemDraft {
  const _ItemDraft({this.title = 'Surprise bag', this.description = 'Lorem ipsum', this.price, this.estimatedValue, this.imageUrl, this.defaultDailyStock, this.schedule});
  

@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  double? price;
@override final  double? estimatedValue;
@override final  String? imageUrl;
@override final  int? defaultDailyStock;
@override final  WeeklySchedule? schedule;

/// Create a copy of ItemDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemDraftCopyWith<_ItemDraft> get copyWith => __$ItemDraftCopyWithImpl<_ItemDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.estimatedValue, estimatedValue) || other.estimatedValue == estimatedValue)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.defaultDailyStock, defaultDailyStock) || other.defaultDailyStock == defaultDailyStock)&&(identical(other.schedule, schedule) || other.schedule == schedule));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,price,estimatedValue,imageUrl,defaultDailyStock,schedule);

@override
String toString() {
  return 'ItemDraft(title: $title, description: $description, price: $price, estimatedValue: $estimatedValue, imageUrl: $imageUrl, defaultDailyStock: $defaultDailyStock, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class _$ItemDraftCopyWith<$Res> implements $ItemDraftCopyWith<$Res> {
  factory _$ItemDraftCopyWith(_ItemDraft value, $Res Function(_ItemDraft) _then) = __$ItemDraftCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, double? price, double? estimatedValue, String? imageUrl, int? defaultDailyStock, WeeklySchedule? schedule
});




}
/// @nodoc
class __$ItemDraftCopyWithImpl<$Res>
    implements _$ItemDraftCopyWith<$Res> {
  __$ItemDraftCopyWithImpl(this._self, this._then);

  final _ItemDraft _self;
  final $Res Function(_ItemDraft) _then;

/// Create a copy of ItemDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? price = freezed,Object? estimatedValue = freezed,Object? imageUrl = freezed,Object? defaultDailyStock = freezed,Object? schedule = freezed,}) {
  return _then(_ItemDraft(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,estimatedValue: freezed == estimatedValue ? _self.estimatedValue : estimatedValue // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,defaultDailyStock: freezed == defaultDailyStock ? _self.defaultDailyStock : defaultDailyStock // ignore: cast_nullable_to_non_nullable
as int?,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as WeeklySchedule?,
  ));
}


}

// dart format on
