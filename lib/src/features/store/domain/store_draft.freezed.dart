// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreDraft {

 String? get name; StoreType? get storeType; String? get address; String? get locality; String? get postalCode; CountryD? get country; String? get phoneNumber; LatLng? get location;
/// Create a copy of StoreDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreDraftCopyWith<StoreDraft> get copyWith => _$StoreDraftCopyWithImpl<StoreDraft>(this as StoreDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.storeType, storeType) || other.storeType == storeType)&&(identical(other.address, address) || other.address == address)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode => Object.hash(runtimeType,name,storeType,address,locality,postalCode,country,phoneNumber,location);

@override
String toString() {
  return 'StoreDraft(name: $name, storeType: $storeType, address: $address, locality: $locality, postalCode: $postalCode, country: $country, phoneNumber: $phoneNumber, location: $location)';
}


}

/// @nodoc
abstract mixin class $StoreDraftCopyWith<$Res>  {
  factory $StoreDraftCopyWith(StoreDraft value, $Res Function(StoreDraft) _then) = _$StoreDraftCopyWithImpl;
@useResult
$Res call({
 String? name, StoreType? storeType, String? address, String? locality, String? postalCode, CountryD? country, String? phoneNumber, LatLng? location
});


$CountryDCopyWith<$Res>? get country;

}
/// @nodoc
class _$StoreDraftCopyWithImpl<$Res>
    implements $StoreDraftCopyWith<$Res> {
  _$StoreDraftCopyWithImpl(this._self, this._then);

  final StoreDraft _self;
  final $Res Function(StoreDraft) _then;

/// Create a copy of StoreDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? storeType = freezed,Object? address = freezed,Object? locality = freezed,Object? postalCode = freezed,Object? country = freezed,Object? phoneNumber = freezed,Object? location = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,storeType: freezed == storeType ? _self.storeType : storeType // ignore: cast_nullable_to_non_nullable
as StoreType?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as CountryD?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,
  ));
}
/// Create a copy of StoreDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryDCopyWith<$Res>? get country {
    if (_self.country == null) {
    return null;
  }

  return $CountryDCopyWith<$Res>(_self.country!, (value) {
    return _then(_self.copyWith(country: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreDraft].
extension StoreDraftPatterns on StoreDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreDraft value)  $default,){
final _that = this;
switch (_that) {
case _StoreDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreDraft value)?  $default,){
final _that = this;
switch (_that) {
case _StoreDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  StoreType? storeType,  String? address,  String? locality,  String? postalCode,  CountryD? country,  String? phoneNumber,  LatLng? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreDraft() when $default != null:
return $default(_that.name,_that.storeType,_that.address,_that.locality,_that.postalCode,_that.country,_that.phoneNumber,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  StoreType? storeType,  String? address,  String? locality,  String? postalCode,  CountryD? country,  String? phoneNumber,  LatLng? location)  $default,) {final _that = this;
switch (_that) {
case _StoreDraft():
return $default(_that.name,_that.storeType,_that.address,_that.locality,_that.postalCode,_that.country,_that.phoneNumber,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  StoreType? storeType,  String? address,  String? locality,  String? postalCode,  CountryD? country,  String? phoneNumber,  LatLng? location)?  $default,) {final _that = this;
switch (_that) {
case _StoreDraft() when $default != null:
return $default(_that.name,_that.storeType,_that.address,_that.locality,_that.postalCode,_that.country,_that.phoneNumber,_that.location);case _:
  return null;

}
}

}

/// @nodoc


class _StoreDraft implements StoreDraft {
  const _StoreDraft({this.name, this.storeType, this.address, this.locality, this.postalCode, this.country, this.phoneNumber, this.location});
  

@override final  String? name;
@override final  StoreType? storeType;
@override final  String? address;
@override final  String? locality;
@override final  String? postalCode;
@override final  CountryD? country;
@override final  String? phoneNumber;
@override final  LatLng? location;

/// Create a copy of StoreDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreDraftCopyWith<_StoreDraft> get copyWith => __$StoreDraftCopyWithImpl<_StoreDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.storeType, storeType) || other.storeType == storeType)&&(identical(other.address, address) || other.address == address)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode => Object.hash(runtimeType,name,storeType,address,locality,postalCode,country,phoneNumber,location);

@override
String toString() {
  return 'StoreDraft(name: $name, storeType: $storeType, address: $address, locality: $locality, postalCode: $postalCode, country: $country, phoneNumber: $phoneNumber, location: $location)';
}


}

/// @nodoc
abstract mixin class _$StoreDraftCopyWith<$Res> implements $StoreDraftCopyWith<$Res> {
  factory _$StoreDraftCopyWith(_StoreDraft value, $Res Function(_StoreDraft) _then) = __$StoreDraftCopyWithImpl;
@override @useResult
$Res call({
 String? name, StoreType? storeType, String? address, String? locality, String? postalCode, CountryD? country, String? phoneNumber, LatLng? location
});


@override $CountryDCopyWith<$Res>? get country;

}
/// @nodoc
class __$StoreDraftCopyWithImpl<$Res>
    implements _$StoreDraftCopyWith<$Res> {
  __$StoreDraftCopyWithImpl(this._self, this._then);

  final _StoreDraft _self;
  final $Res Function(_StoreDraft) _then;

/// Create a copy of StoreDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? storeType = freezed,Object? address = freezed,Object? locality = freezed,Object? postalCode = freezed,Object? country = freezed,Object? phoneNumber = freezed,Object? location = freezed,}) {
  return _then(_StoreDraft(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,storeType: freezed == storeType ? _self.storeType : storeType // ignore: cast_nullable_to_non_nullable
as StoreType?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as CountryD?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,
  ));
}

/// Create a copy of StoreDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryDCopyWith<$Res>? get country {
    if (_self.country == null) {
    return null;
  }

  return $CountryDCopyWith<$Res>(_self.country!, (value) {
    return _then(_self.copyWith(country: value));
  });
}
}

// dart format on
