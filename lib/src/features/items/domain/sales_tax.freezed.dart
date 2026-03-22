// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_tax.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesTax {

 String? get taxDescription; double? get taxPercentage;
/// Create a copy of SalesTax
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesTaxCopyWith<SalesTax> get copyWith => _$SalesTaxCopyWithImpl<SalesTax>(this as SalesTax, _$identity);

  /// Serializes this SalesTax to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesTax&&(identical(other.taxDescription, taxDescription) || other.taxDescription == taxDescription)&&(identical(other.taxPercentage, taxPercentage) || other.taxPercentage == taxPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taxDescription,taxPercentage);

@override
String toString() {
  return 'SalesTax(taxDescription: $taxDescription, taxPercentage: $taxPercentage)';
}


}

/// @nodoc
abstract mixin class $SalesTaxCopyWith<$Res>  {
  factory $SalesTaxCopyWith(SalesTax value, $Res Function(SalesTax) _then) = _$SalesTaxCopyWithImpl;
@useResult
$Res call({
 String? taxDescription, double? taxPercentage
});




}
/// @nodoc
class _$SalesTaxCopyWithImpl<$Res>
    implements $SalesTaxCopyWith<$Res> {
  _$SalesTaxCopyWithImpl(this._self, this._then);

  final SalesTax _self;
  final $Res Function(SalesTax) _then;

/// Create a copy of SalesTax
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxDescription = freezed,Object? taxPercentage = freezed,}) {
  return _then(_self.copyWith(
taxDescription: freezed == taxDescription ? _self.taxDescription : taxDescription // ignore: cast_nullable_to_non_nullable
as String?,taxPercentage: freezed == taxPercentage ? _self.taxPercentage : taxPercentage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesTax].
extension SalesTaxPatterns on SalesTax {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesTax value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesTax() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesTax value)  $default,){
final _that = this;
switch (_that) {
case _SalesTax():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesTax value)?  $default,){
final _that = this;
switch (_that) {
case _SalesTax() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? taxDescription,  double? taxPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesTax() when $default != null:
return $default(_that.taxDescription,_that.taxPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? taxDescription,  double? taxPercentage)  $default,) {final _that = this;
switch (_that) {
case _SalesTax():
return $default(_that.taxDescription,_that.taxPercentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? taxDescription,  double? taxPercentage)?  $default,) {final _that = this;
switch (_that) {
case _SalesTax() when $default != null:
return $default(_that.taxDescription,_that.taxPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesTax implements SalesTax {
  const _SalesTax({this.taxDescription, this.taxPercentage});
  factory _SalesTax.fromJson(Map<String, dynamic> json) => _$SalesTaxFromJson(json);

@override final  String? taxDescription;
@override final  double? taxPercentage;

/// Create a copy of SalesTax
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesTaxCopyWith<_SalesTax> get copyWith => __$SalesTaxCopyWithImpl<_SalesTax>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesTaxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesTax&&(identical(other.taxDescription, taxDescription) || other.taxDescription == taxDescription)&&(identical(other.taxPercentage, taxPercentage) || other.taxPercentage == taxPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taxDescription,taxPercentage);

@override
String toString() {
  return 'SalesTax(taxDescription: $taxDescription, taxPercentage: $taxPercentage)';
}


}

/// @nodoc
abstract mixin class _$SalesTaxCopyWith<$Res> implements $SalesTaxCopyWith<$Res> {
  factory _$SalesTaxCopyWith(_SalesTax value, $Res Function(_SalesTax) _then) = __$SalesTaxCopyWithImpl;
@override @useResult
$Res call({
 String? taxDescription, double? taxPercentage
});




}
/// @nodoc
class __$SalesTaxCopyWithImpl<$Res>
    implements _$SalesTaxCopyWith<$Res> {
  __$SalesTaxCopyWithImpl(this._self, this._then);

  final _SalesTax _self;
  final $Res Function(_SalesTax) _then;

/// Create a copy of SalesTax
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxDescription = freezed,Object? taxPercentage = freezed,}) {
  return _then(_SalesTax(
taxDescription: freezed == taxDescription ? _self.taxDescription : taxDescription // ignore: cast_nullable_to_non_nullable
as String?,taxPercentage: freezed == taxPercentage ? _self.taxPercentage : taxPercentage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
