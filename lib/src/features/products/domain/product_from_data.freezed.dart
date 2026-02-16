// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_from_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductFromData {

 String get name; Money get price; String? get description; String? get packagingOption; String? get imageUrl;
/// Create a copy of ProductFromData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductFromDataCopyWith<ProductFromData> get copyWith => _$ProductFromDataCopyWithImpl<ProductFromData>(this as ProductFromData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductFromData&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.packagingOption, packagingOption) || other.packagingOption == packagingOption)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,name,price,description,packagingOption,imageUrl);

@override
String toString() {
  return 'ProductFromData(name: $name, price: $price, description: $description, packagingOption: $packagingOption, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ProductFromDataCopyWith<$Res>  {
  factory $ProductFromDataCopyWith(ProductFromData value, $Res Function(ProductFromData) _then) = _$ProductFromDataCopyWithImpl;
@useResult
$Res call({
 String name, Money price, String? description, String? packagingOption, String? imageUrl
});


$MoneyCopyWith<$Res> get price;

}
/// @nodoc
class _$ProductFromDataCopyWithImpl<$Res>
    implements $ProductFromDataCopyWith<$Res> {
  _$ProductFromDataCopyWithImpl(this._self, this._then);

  final ProductFromData _self;
  final $Res Function(ProductFromData) _then;

/// Create a copy of ProductFromData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? packagingOption = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Money,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,packagingOption: freezed == packagingOption ? _self.packagingOption : packagingOption // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProductFromData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get price {
  
  return $MoneyCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductFromData].
extension ProductFromDataPatterns on ProductFromData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductFromData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductFromData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductFromData value)  $default,){
final _that = this;
switch (_that) {
case _ProductFromData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductFromData value)?  $default,){
final _that = this;
switch (_that) {
case _ProductFromData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Money price,  String? description,  String? packagingOption,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductFromData() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.packagingOption,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Money price,  String? description,  String? packagingOption,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _ProductFromData():
return $default(_that.name,_that.price,_that.description,_that.packagingOption,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Money price,  String? description,  String? packagingOption,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _ProductFromData() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.packagingOption,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ProductFromData implements ProductFromData {
  const _ProductFromData({required this.name, required this.price, this.description, this.packagingOption, this.imageUrl});
  

@override final  String name;
@override final  Money price;
@override final  String? description;
@override final  String? packagingOption;
@override final  String? imageUrl;

/// Create a copy of ProductFromData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductFromDataCopyWith<_ProductFromData> get copyWith => __$ProductFromDataCopyWithImpl<_ProductFromData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductFromData&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.packagingOption, packagingOption) || other.packagingOption == packagingOption)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,name,price,description,packagingOption,imageUrl);

@override
String toString() {
  return 'ProductFromData(name: $name, price: $price, description: $description, packagingOption: $packagingOption, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ProductFromDataCopyWith<$Res> implements $ProductFromDataCopyWith<$Res> {
  factory _$ProductFromDataCopyWith(_ProductFromData value, $Res Function(_ProductFromData) _then) = __$ProductFromDataCopyWithImpl;
@override @useResult
$Res call({
 String name, Money price, String? description, String? packagingOption, String? imageUrl
});


@override $MoneyCopyWith<$Res> get price;

}
/// @nodoc
class __$ProductFromDataCopyWithImpl<$Res>
    implements _$ProductFromDataCopyWith<$Res> {
  __$ProductFromDataCopyWithImpl(this._self, this._then);

  final _ProductFromData _self;
  final $Res Function(_ProductFromData) _then;

/// Create a copy of ProductFromData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? packagingOption = freezed,Object? imageUrl = freezed,}) {
  return _then(_ProductFromData(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Money,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,packagingOption: freezed == packagingOption ? _self.packagingOption : packagingOption // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProductFromData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get price {
  
  return $MoneyCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}

// dart format on
