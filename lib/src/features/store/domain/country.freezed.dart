// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'country.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountryD {

 String get isoCode; String get name;
/// Create a copy of CountryD
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountryDCopyWith<CountryD> get copyWith => _$CountryDCopyWithImpl<CountryD>(this as CountryD, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountryD&&(identical(other.isoCode, isoCode) || other.isoCode == isoCode)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,isoCode,name);

@override
String toString() {
  return 'CountryD(isoCode: $isoCode, name: $name)';
}


}

/// @nodoc
abstract mixin class $CountryDCopyWith<$Res>  {
  factory $CountryDCopyWith(CountryD value, $Res Function(CountryD) _then) = _$CountryDCopyWithImpl;
@useResult
$Res call({
 String isoCode, String name
});




}
/// @nodoc
class _$CountryDCopyWithImpl<$Res>
    implements $CountryDCopyWith<$Res> {
  _$CountryDCopyWithImpl(this._self, this._then);

  final CountryD _self;
  final $Res Function(CountryD) _then;

/// Create a copy of CountryD
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isoCode = null,Object? name = null,}) {
  return _then(_self.copyWith(
isoCode: null == isoCode ? _self.isoCode : isoCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CountryD].
extension CountryDPatterns on CountryD {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountryD value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountryD() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountryD value)  $default,){
final _that = this;
switch (_that) {
case _CountryD():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountryD value)?  $default,){
final _that = this;
switch (_that) {
case _CountryD() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String isoCode,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountryD() when $default != null:
return $default(_that.isoCode,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String isoCode,  String name)  $default,) {final _that = this;
switch (_that) {
case _CountryD():
return $default(_that.isoCode,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String isoCode,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CountryD() when $default != null:
return $default(_that.isoCode,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _CountryD extends CountryD {
  const _CountryD({required this.isoCode, required this.name}): super._();
  

@override final  String isoCode;
@override final  String name;

/// Create a copy of CountryD
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountryDCopyWith<_CountryD> get copyWith => __$CountryDCopyWithImpl<_CountryD>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountryD&&(identical(other.isoCode, isoCode) || other.isoCode == isoCode)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,isoCode,name);

@override
String toString() {
  return 'CountryD(isoCode: $isoCode, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CountryDCopyWith<$Res> implements $CountryDCopyWith<$Res> {
  factory _$CountryDCopyWith(_CountryD value, $Res Function(_CountryD) _then) = __$CountryDCopyWithImpl;
@override @useResult
$Res call({
 String isoCode, String name
});




}
/// @nodoc
class __$CountryDCopyWithImpl<$Res>
    implements _$CountryDCopyWith<$Res> {
  __$CountryDCopyWithImpl(this._self, this._then);

  final _CountryD _self;
  final $Res Function(_CountryD) _then;

/// Create a copy of CountryD
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isoCode = null,Object? name = null,}) {
  return _then(_CountryD(
isoCode: null == isoCode ? _self.isoCode : isoCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
