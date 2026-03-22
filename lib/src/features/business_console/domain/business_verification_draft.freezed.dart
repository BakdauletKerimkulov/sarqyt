// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_verification_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BusinessVerificationDraft {

 BusinessType get businessType; CompanyVerificationDraft get company; IndividualVerificationDraft get individual;
/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessVerificationDraftCopyWith<BusinessVerificationDraft> get copyWith => _$BusinessVerificationDraftCopyWithImpl<BusinessVerificationDraft>(this as BusinessVerificationDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessVerificationDraft&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.company, company) || other.company == company)&&(identical(other.individual, individual) || other.individual == individual));
}


@override
int get hashCode => Object.hash(runtimeType,businessType,company,individual);

@override
String toString() {
  return 'BusinessVerificationDraft(businessType: $businessType, company: $company, individual: $individual)';
}


}

/// @nodoc
abstract mixin class $BusinessVerificationDraftCopyWith<$Res>  {
  factory $BusinessVerificationDraftCopyWith(BusinessVerificationDraft value, $Res Function(BusinessVerificationDraft) _then) = _$BusinessVerificationDraftCopyWithImpl;
@useResult
$Res call({
 BusinessType businessType, CompanyVerificationDraft company, IndividualVerificationDraft individual
});


$CompanyVerificationDraftCopyWith<$Res> get company;$IndividualVerificationDraftCopyWith<$Res> get individual;

}
/// @nodoc
class _$BusinessVerificationDraftCopyWithImpl<$Res>
    implements $BusinessVerificationDraftCopyWith<$Res> {
  _$BusinessVerificationDraftCopyWithImpl(this._self, this._then);

  final BusinessVerificationDraft _self;
  final $Res Function(BusinessVerificationDraft) _then;

/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessType = null,Object? company = null,Object? individual = null,}) {
  return _then(_self.copyWith(
businessType: null == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as BusinessType,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as CompanyVerificationDraft,individual: null == individual ? _self.individual : individual // ignore: cast_nullable_to_non_nullable
as IndividualVerificationDraft,
  ));
}
/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyVerificationDraftCopyWith<$Res> get company {
  
  return $CompanyVerificationDraftCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IndividualVerificationDraftCopyWith<$Res> get individual {
  
  return $IndividualVerificationDraftCopyWith<$Res>(_self.individual, (value) {
    return _then(_self.copyWith(individual: value));
  });
}
}


/// Adds pattern-matching-related methods to [BusinessVerificationDraft].
extension BusinessVerificationDraftPatterns on BusinessVerificationDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessVerificationDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessVerificationDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessVerificationDraft value)  $default,){
final _that = this;
switch (_that) {
case _BusinessVerificationDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessVerificationDraft value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessVerificationDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BusinessType businessType,  CompanyVerificationDraft company,  IndividualVerificationDraft individual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessVerificationDraft() when $default != null:
return $default(_that.businessType,_that.company,_that.individual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BusinessType businessType,  CompanyVerificationDraft company,  IndividualVerificationDraft individual)  $default,) {final _that = this;
switch (_that) {
case _BusinessVerificationDraft():
return $default(_that.businessType,_that.company,_that.individual);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BusinessType businessType,  CompanyVerificationDraft company,  IndividualVerificationDraft individual)?  $default,) {final _that = this;
switch (_that) {
case _BusinessVerificationDraft() when $default != null:
return $default(_that.businessType,_that.company,_that.individual);case _:
  return null;

}
}

}

/// @nodoc


class _BusinessVerificationDraft extends BusinessVerificationDraft {
  const _BusinessVerificationDraft({this.businessType = BusinessType.company, this.company = const CompanyVerificationDraft(), this.individual = const IndividualVerificationDraft()}): super._();
  

@override@JsonKey() final  BusinessType businessType;
@override@JsonKey() final  CompanyVerificationDraft company;
@override@JsonKey() final  IndividualVerificationDraft individual;

/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessVerificationDraftCopyWith<_BusinessVerificationDraft> get copyWith => __$BusinessVerificationDraftCopyWithImpl<_BusinessVerificationDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessVerificationDraft&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.company, company) || other.company == company)&&(identical(other.individual, individual) || other.individual == individual));
}


@override
int get hashCode => Object.hash(runtimeType,businessType,company,individual);

@override
String toString() {
  return 'BusinessVerificationDraft(businessType: $businessType, company: $company, individual: $individual)';
}


}

/// @nodoc
abstract mixin class _$BusinessVerificationDraftCopyWith<$Res> implements $BusinessVerificationDraftCopyWith<$Res> {
  factory _$BusinessVerificationDraftCopyWith(_BusinessVerificationDraft value, $Res Function(_BusinessVerificationDraft) _then) = __$BusinessVerificationDraftCopyWithImpl;
@override @useResult
$Res call({
 BusinessType businessType, CompanyVerificationDraft company, IndividualVerificationDraft individual
});


@override $CompanyVerificationDraftCopyWith<$Res> get company;@override $IndividualVerificationDraftCopyWith<$Res> get individual;

}
/// @nodoc
class __$BusinessVerificationDraftCopyWithImpl<$Res>
    implements _$BusinessVerificationDraftCopyWith<$Res> {
  __$BusinessVerificationDraftCopyWithImpl(this._self, this._then);

  final _BusinessVerificationDraft _self;
  final $Res Function(_BusinessVerificationDraft) _then;

/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessType = null,Object? company = null,Object? individual = null,}) {
  return _then(_BusinessVerificationDraft(
businessType: null == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as BusinessType,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as CompanyVerificationDraft,individual: null == individual ? _self.individual : individual // ignore: cast_nullable_to_non_nullable
as IndividualVerificationDraft,
  ));
}

/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyVerificationDraftCopyWith<$Res> get company {
  
  return $CompanyVerificationDraftCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of BusinessVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IndividualVerificationDraftCopyWith<$Res> get individual {
  
  return $IndividualVerificationDraftCopyWith<$Res>(_self.individual, (value) {
    return _then(_self.copyWith(individual: value));
  });
}
}

/// @nodoc
mixin _$CompanyVerificationDraft {

 String? get companyName; String? get bin; String? get vatId;
/// Create a copy of CompanyVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyVerificationDraftCopyWith<CompanyVerificationDraft> get copyWith => _$CompanyVerificationDraftCopyWithImpl<CompanyVerificationDraft>(this as CompanyVerificationDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyVerificationDraft&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.bin, bin) || other.bin == bin)&&(identical(other.vatId, vatId) || other.vatId == vatId));
}


@override
int get hashCode => Object.hash(runtimeType,companyName,bin,vatId);

@override
String toString() {
  return 'CompanyVerificationDraft(companyName: $companyName, bin: $bin, vatId: $vatId)';
}


}

/// @nodoc
abstract mixin class $CompanyVerificationDraftCopyWith<$Res>  {
  factory $CompanyVerificationDraftCopyWith(CompanyVerificationDraft value, $Res Function(CompanyVerificationDraft) _then) = _$CompanyVerificationDraftCopyWithImpl;
@useResult
$Res call({
 String? companyName, String? bin, String? vatId
});




}
/// @nodoc
class _$CompanyVerificationDraftCopyWithImpl<$Res>
    implements $CompanyVerificationDraftCopyWith<$Res> {
  _$CompanyVerificationDraftCopyWithImpl(this._self, this._then);

  final CompanyVerificationDraft _self;
  final $Res Function(CompanyVerificationDraft) _then;

/// Create a copy of CompanyVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyName = freezed,Object? bin = freezed,Object? vatId = freezed,}) {
  return _then(_self.copyWith(
companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,bin: freezed == bin ? _self.bin : bin // ignore: cast_nullable_to_non_nullable
as String?,vatId: freezed == vatId ? _self.vatId : vatId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyVerificationDraft].
extension CompanyVerificationDraftPatterns on CompanyVerificationDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyVerificationDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyVerificationDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyVerificationDraft value)  $default,){
final _that = this;
switch (_that) {
case _CompanyVerificationDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyVerificationDraft value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyVerificationDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? companyName,  String? bin,  String? vatId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyVerificationDraft() when $default != null:
return $default(_that.companyName,_that.bin,_that.vatId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? companyName,  String? bin,  String? vatId)  $default,) {final _that = this;
switch (_that) {
case _CompanyVerificationDraft():
return $default(_that.companyName,_that.bin,_that.vatId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? companyName,  String? bin,  String? vatId)?  $default,) {final _that = this;
switch (_that) {
case _CompanyVerificationDraft() when $default != null:
return $default(_that.companyName,_that.bin,_that.vatId);case _:
  return null;

}
}

}

/// @nodoc


class _CompanyVerificationDraft extends CompanyVerificationDraft {
  const _CompanyVerificationDraft({this.companyName, this.bin, this.vatId}): super._();
  

@override final  String? companyName;
@override final  String? bin;
@override final  String? vatId;

/// Create a copy of CompanyVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyVerificationDraftCopyWith<_CompanyVerificationDraft> get copyWith => __$CompanyVerificationDraftCopyWithImpl<_CompanyVerificationDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyVerificationDraft&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.bin, bin) || other.bin == bin)&&(identical(other.vatId, vatId) || other.vatId == vatId));
}


@override
int get hashCode => Object.hash(runtimeType,companyName,bin,vatId);

@override
String toString() {
  return 'CompanyVerificationDraft(companyName: $companyName, bin: $bin, vatId: $vatId)';
}


}

/// @nodoc
abstract mixin class _$CompanyVerificationDraftCopyWith<$Res> implements $CompanyVerificationDraftCopyWith<$Res> {
  factory _$CompanyVerificationDraftCopyWith(_CompanyVerificationDraft value, $Res Function(_CompanyVerificationDraft) _then) = __$CompanyVerificationDraftCopyWithImpl;
@override @useResult
$Res call({
 String? companyName, String? bin, String? vatId
});




}
/// @nodoc
class __$CompanyVerificationDraftCopyWithImpl<$Res>
    implements _$CompanyVerificationDraftCopyWith<$Res> {
  __$CompanyVerificationDraftCopyWithImpl(this._self, this._then);

  final _CompanyVerificationDraft _self;
  final $Res Function(_CompanyVerificationDraft) _then;

/// Create a copy of CompanyVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyName = freezed,Object? bin = freezed,Object? vatId = freezed,}) {
  return _then(_CompanyVerificationDraft(
companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,bin: freezed == bin ? _self.bin : bin // ignore: cast_nullable_to_non_nullable
as String?,vatId: freezed == vatId ? _self.vatId : vatId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$IndividualVerificationDraft {

 String? get vatId; String? get iin; String? get dateOfBirth; String? get firstName; String? get lastName; String? get addressLine1; String? get addressLine2; String? get postalCode; String? get city; String? get region; String? get country;
/// Create a copy of IndividualVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndividualVerificationDraftCopyWith<IndividualVerificationDraft> get copyWith => _$IndividualVerificationDraftCopyWithImpl<IndividualVerificationDraft>(this as IndividualVerificationDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndividualVerificationDraft&&(identical(other.vatId, vatId) || other.vatId == vatId)&&(identical(other.iin, iin) || other.iin == iin)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.region, region) || other.region == region)&&(identical(other.country, country) || other.country == country));
}


@override
int get hashCode => Object.hash(runtimeType,vatId,iin,dateOfBirth,firstName,lastName,addressLine1,addressLine2,postalCode,city,region,country);

@override
String toString() {
  return 'IndividualVerificationDraft(vatId: $vatId, iin: $iin, dateOfBirth: $dateOfBirth, firstName: $firstName, lastName: $lastName, addressLine1: $addressLine1, addressLine2: $addressLine2, postalCode: $postalCode, city: $city, region: $region, country: $country)';
}


}

/// @nodoc
abstract mixin class $IndividualVerificationDraftCopyWith<$Res>  {
  factory $IndividualVerificationDraftCopyWith(IndividualVerificationDraft value, $Res Function(IndividualVerificationDraft) _then) = _$IndividualVerificationDraftCopyWithImpl;
@useResult
$Res call({
 String? vatId, String? iin, String? dateOfBirth, String? firstName, String? lastName, String? addressLine1, String? addressLine2, String? postalCode, String? city, String? region, String? country
});




}
/// @nodoc
class _$IndividualVerificationDraftCopyWithImpl<$Res>
    implements $IndividualVerificationDraftCopyWith<$Res> {
  _$IndividualVerificationDraftCopyWithImpl(this._self, this._then);

  final IndividualVerificationDraft _self;
  final $Res Function(IndividualVerificationDraft) _then;

/// Create a copy of IndividualVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vatId = freezed,Object? iin = freezed,Object? dateOfBirth = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? addressLine1 = freezed,Object? addressLine2 = freezed,Object? postalCode = freezed,Object? city = freezed,Object? region = freezed,Object? country = freezed,}) {
  return _then(_self.copyWith(
vatId: freezed == vatId ? _self.vatId : vatId // ignore: cast_nullable_to_non_nullable
as String?,iin: freezed == iin ? _self.iin : iin // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IndividualVerificationDraft].
extension IndividualVerificationDraftPatterns on IndividualVerificationDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndividualVerificationDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndividualVerificationDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndividualVerificationDraft value)  $default,){
final _that = this;
switch (_that) {
case _IndividualVerificationDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndividualVerificationDraft value)?  $default,){
final _that = this;
switch (_that) {
case _IndividualVerificationDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? vatId,  String? iin,  String? dateOfBirth,  String? firstName,  String? lastName,  String? addressLine1,  String? addressLine2,  String? postalCode,  String? city,  String? region,  String? country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndividualVerificationDraft() when $default != null:
return $default(_that.vatId,_that.iin,_that.dateOfBirth,_that.firstName,_that.lastName,_that.addressLine1,_that.addressLine2,_that.postalCode,_that.city,_that.region,_that.country);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? vatId,  String? iin,  String? dateOfBirth,  String? firstName,  String? lastName,  String? addressLine1,  String? addressLine2,  String? postalCode,  String? city,  String? region,  String? country)  $default,) {final _that = this;
switch (_that) {
case _IndividualVerificationDraft():
return $default(_that.vatId,_that.iin,_that.dateOfBirth,_that.firstName,_that.lastName,_that.addressLine1,_that.addressLine2,_that.postalCode,_that.city,_that.region,_that.country);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? vatId,  String? iin,  String? dateOfBirth,  String? firstName,  String? lastName,  String? addressLine1,  String? addressLine2,  String? postalCode,  String? city,  String? region,  String? country)?  $default,) {final _that = this;
switch (_that) {
case _IndividualVerificationDraft() when $default != null:
return $default(_that.vatId,_that.iin,_that.dateOfBirth,_that.firstName,_that.lastName,_that.addressLine1,_that.addressLine2,_that.postalCode,_that.city,_that.region,_that.country);case _:
  return null;

}
}

}

/// @nodoc


class _IndividualVerificationDraft extends IndividualVerificationDraft {
  const _IndividualVerificationDraft({this.vatId, this.iin, this.dateOfBirth, this.firstName, this.lastName, this.addressLine1, this.addressLine2, this.postalCode, this.city, this.region, this.country}): super._();
  

@override final  String? vatId;
@override final  String? iin;
@override final  String? dateOfBirth;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? addressLine1;
@override final  String? addressLine2;
@override final  String? postalCode;
@override final  String? city;
@override final  String? region;
@override final  String? country;

/// Create a copy of IndividualVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndividualVerificationDraftCopyWith<_IndividualVerificationDraft> get copyWith => __$IndividualVerificationDraftCopyWithImpl<_IndividualVerificationDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndividualVerificationDraft&&(identical(other.vatId, vatId) || other.vatId == vatId)&&(identical(other.iin, iin) || other.iin == iin)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.region, region) || other.region == region)&&(identical(other.country, country) || other.country == country));
}


@override
int get hashCode => Object.hash(runtimeType,vatId,iin,dateOfBirth,firstName,lastName,addressLine1,addressLine2,postalCode,city,region,country);

@override
String toString() {
  return 'IndividualVerificationDraft(vatId: $vatId, iin: $iin, dateOfBirth: $dateOfBirth, firstName: $firstName, lastName: $lastName, addressLine1: $addressLine1, addressLine2: $addressLine2, postalCode: $postalCode, city: $city, region: $region, country: $country)';
}


}

/// @nodoc
abstract mixin class _$IndividualVerificationDraftCopyWith<$Res> implements $IndividualVerificationDraftCopyWith<$Res> {
  factory _$IndividualVerificationDraftCopyWith(_IndividualVerificationDraft value, $Res Function(_IndividualVerificationDraft) _then) = __$IndividualVerificationDraftCopyWithImpl;
@override @useResult
$Res call({
 String? vatId, String? iin, String? dateOfBirth, String? firstName, String? lastName, String? addressLine1, String? addressLine2, String? postalCode, String? city, String? region, String? country
});




}
/// @nodoc
class __$IndividualVerificationDraftCopyWithImpl<$Res>
    implements _$IndividualVerificationDraftCopyWith<$Res> {
  __$IndividualVerificationDraftCopyWithImpl(this._self, this._then);

  final _IndividualVerificationDraft _self;
  final $Res Function(_IndividualVerificationDraft) _then;

/// Create a copy of IndividualVerificationDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vatId = freezed,Object? iin = freezed,Object? dateOfBirth = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? addressLine1 = freezed,Object? addressLine2 = freezed,Object? postalCode = freezed,Object? city = freezed,Object? region = freezed,Object? country = freezed,}) {
  return _then(_IndividualVerificationDraft(
vatId: freezed == vatId ? _self.vatId : vatId // ignore: cast_nullable_to_non_nullable
as String?,iin: freezed == iin ? _self.iin : iin // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
