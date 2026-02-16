// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Product {

 ProductID get id; String get name; Money get price; String? get imageUrl; String? get description; List<Badge> get badges; String? get category; String? get foodHandlingInstructions; bool? get canUserSupplyPackaging; String? get packagingOption; String? get collectionInfo; Rating? get rating; bool get buffet;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.category, category) || other.category == category)&&(identical(other.foodHandlingInstructions, foodHandlingInstructions) || other.foodHandlingInstructions == foodHandlingInstructions)&&(identical(other.canUserSupplyPackaging, canUserSupplyPackaging) || other.canUserSupplyPackaging == canUserSupplyPackaging)&&(identical(other.packagingOption, packagingOption) || other.packagingOption == packagingOption)&&(identical(other.collectionInfo, collectionInfo) || other.collectionInfo == collectionInfo)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.buffet, buffet) || other.buffet == buffet));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,price,imageUrl,description,const DeepCollectionEquality().hash(badges),category,foodHandlingInstructions,canUserSupplyPackaging,packagingOption,collectionInfo,rating,buffet);

@override
String toString() {
  return 'Product(id: $id, name: $name, price: $price, imageUrl: $imageUrl, description: $description, badges: $badges, category: $category, foodHandlingInstructions: $foodHandlingInstructions, canUserSupplyPackaging: $canUserSupplyPackaging, packagingOption: $packagingOption, collectionInfo: $collectionInfo, rating: $rating, buffet: $buffet)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 ProductID id, String name, Money price, String? imageUrl, String? description, List<Badge> badges, String? category, String? foodHandlingInstructions, bool? canUserSupplyPackaging, String? packagingOption, String? collectionInfo, Rating? rating, bool buffet
});


$MoneyCopyWith<$Res> get price;$RatingCopyWith<$Res>? get rating;

}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrl = freezed,Object? description = freezed,Object? badges = null,Object? category = freezed,Object? foodHandlingInstructions = freezed,Object? canUserSupplyPackaging = freezed,Object? packagingOption = freezed,Object? collectionInfo = freezed,Object? rating = freezed,Object? buffet = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProductID,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Money,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<Badge>,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,foodHandlingInstructions: freezed == foodHandlingInstructions ? _self.foodHandlingInstructions : foodHandlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,canUserSupplyPackaging: freezed == canUserSupplyPackaging ? _self.canUserSupplyPackaging : canUserSupplyPackaging // ignore: cast_nullable_to_non_nullable
as bool?,packagingOption: freezed == packagingOption ? _self.packagingOption : packagingOption // ignore: cast_nullable_to_non_nullable
as String?,collectionInfo: freezed == collectionInfo ? _self.collectionInfo : collectionInfo // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating?,buffet: null == buffet ? _self.buffet : buffet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get price {
  
  return $MoneyCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $RatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductID id,  String name,  Money price,  String? imageUrl,  String? description,  List<Badge> badges,  String? category,  String? foodHandlingInstructions,  bool? canUserSupplyPackaging,  String? packagingOption,  String? collectionInfo,  Rating? rating,  bool buffet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.description,_that.badges,_that.category,_that.foodHandlingInstructions,_that.canUserSupplyPackaging,_that.packagingOption,_that.collectionInfo,_that.rating,_that.buffet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductID id,  String name,  Money price,  String? imageUrl,  String? description,  List<Badge> badges,  String? category,  String? foodHandlingInstructions,  bool? canUserSupplyPackaging,  String? packagingOption,  String? collectionInfo,  Rating? rating,  bool buffet)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.description,_that.badges,_that.category,_that.foodHandlingInstructions,_that.canUserSupplyPackaging,_that.packagingOption,_that.collectionInfo,_that.rating,_that.buffet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductID id,  String name,  Money price,  String? imageUrl,  String? description,  List<Badge> badges,  String? category,  String? foodHandlingInstructions,  bool? canUserSupplyPackaging,  String? packagingOption,  String? collectionInfo,  Rating? rating,  bool buffet)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.description,_that.badges,_that.category,_that.foodHandlingInstructions,_that.canUserSupplyPackaging,_that.packagingOption,_that.collectionInfo,_that.rating,_that.buffet);case _:
  return null;

}
}

}

/// @nodoc


class _Product extends Product {
  const _Product({required this.id, required this.name, required this.price, this.imageUrl, this.description, final  List<Badge> badges = const [], this.category, this.foodHandlingInstructions, this.canUserSupplyPackaging, this.packagingOption, this.collectionInfo, this.rating, this.buffet = false}): _badges = badges,super._();
  

@override final  ProductID id;
@override final  String name;
@override final  Money price;
@override final  String? imageUrl;
@override final  String? description;
 final  List<Badge> _badges;
@override@JsonKey() List<Badge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

@override final  String? category;
@override final  String? foodHandlingInstructions;
@override final  bool? canUserSupplyPackaging;
@override final  String? packagingOption;
@override final  String? collectionInfo;
@override final  Rating? rating;
@override@JsonKey() final  bool buffet;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.category, category) || other.category == category)&&(identical(other.foodHandlingInstructions, foodHandlingInstructions) || other.foodHandlingInstructions == foodHandlingInstructions)&&(identical(other.canUserSupplyPackaging, canUserSupplyPackaging) || other.canUserSupplyPackaging == canUserSupplyPackaging)&&(identical(other.packagingOption, packagingOption) || other.packagingOption == packagingOption)&&(identical(other.collectionInfo, collectionInfo) || other.collectionInfo == collectionInfo)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.buffet, buffet) || other.buffet == buffet));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,price,imageUrl,description,const DeepCollectionEquality().hash(_badges),category,foodHandlingInstructions,canUserSupplyPackaging,packagingOption,collectionInfo,rating,buffet);

@override
String toString() {
  return 'Product(id: $id, name: $name, price: $price, imageUrl: $imageUrl, description: $description, badges: $badges, category: $category, foodHandlingInstructions: $foodHandlingInstructions, canUserSupplyPackaging: $canUserSupplyPackaging, packagingOption: $packagingOption, collectionInfo: $collectionInfo, rating: $rating, buffet: $buffet)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 ProductID id, String name, Money price, String? imageUrl, String? description, List<Badge> badges, String? category, String? foodHandlingInstructions, bool? canUserSupplyPackaging, String? packagingOption, String? collectionInfo, Rating? rating, bool buffet
});


@override $MoneyCopyWith<$Res> get price;@override $RatingCopyWith<$Res>? get rating;

}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrl = freezed,Object? description = freezed,Object? badges = null,Object? category = freezed,Object? foodHandlingInstructions = freezed,Object? canUserSupplyPackaging = freezed,Object? packagingOption = freezed,Object? collectionInfo = freezed,Object? rating = freezed,Object? buffet = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProductID,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Money,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<Badge>,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,foodHandlingInstructions: freezed == foodHandlingInstructions ? _self.foodHandlingInstructions : foodHandlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,canUserSupplyPackaging: freezed == canUserSupplyPackaging ? _self.canUserSupplyPackaging : canUserSupplyPackaging // ignore: cast_nullable_to_non_nullable
as bool?,packagingOption: freezed == packagingOption ? _self.packagingOption : packagingOption // ignore: cast_nullable_to_non_nullable
as String?,collectionInfo: freezed == collectionInfo ? _self.collectionInfo : collectionInfo // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating?,buffet: null == buffet ? _self.buffet : buffet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get price {
  
  return $MoneyCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $RatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}

// dart format on
