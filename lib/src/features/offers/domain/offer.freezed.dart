// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Offer {

 Product get product; Store get store; Location get pickupLocation; int get itemsAvailable; bool get newItem; String get displayName; double? get distance;
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferCopyWith<Offer> get copyWith => _$OfferCopyWithImpl<Offer>(this as Offer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offer&&(identical(other.product, product) || other.product == product)&&(identical(other.store, store) || other.store == store)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.itemsAvailable, itemsAvailable) || other.itemsAvailable == itemsAvailable)&&(identical(other.newItem, newItem) || other.newItem == newItem)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.distance, distance) || other.distance == distance));
}


@override
int get hashCode => Object.hash(runtimeType,product,store,pickupLocation,itemsAvailable,newItem,displayName,distance);

@override
String toString() {
  return 'Offer(product: $product, store: $store, pickupLocation: $pickupLocation, itemsAvailable: $itemsAvailable, newItem: $newItem, displayName: $displayName, distance: $distance)';
}


}

/// @nodoc
abstract mixin class $OfferCopyWith<$Res>  {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) _then) = _$OfferCopyWithImpl;
@useResult
$Res call({
 Product product, Store store, Location pickupLocation, int itemsAvailable, bool newItem, String displayName, double? distance
});


$ProductCopyWith<$Res> get product;$StoreCopyWith<$Res> get store;$LocationCopyWith<$Res> get pickupLocation;

}
/// @nodoc
class _$OfferCopyWithImpl<$Res>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._self, this._then);

  final Offer _self;
  final $Res Function(Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? store = null,Object? pickupLocation = null,Object? itemsAvailable = null,Object? newItem = null,Object? displayName = null,Object? distance = freezed,}) {
  return _then(_self.copyWith(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,store: null == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as Store,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as Location,itemsAvailable: null == itemsAvailable ? _self.itemsAvailable : itemsAvailable // ignore: cast_nullable_to_non_nullable
as int,newItem: null == newItem ? _self.newItem : newItem // ignore: cast_nullable_to_non_nullable
as bool,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreCopyWith<$Res> get store {
  
  return $StoreCopyWith<$Res>(_self.store, (value) {
    return _then(_self.copyWith(store: value));
  });
}/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get pickupLocation {
  
  return $LocationCopyWith<$Res>(_self.pickupLocation, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [Offer].
extension OfferPatterns on Offer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Offer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Offer value)  $default,){
final _that = this;
switch (_that) {
case _Offer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Offer value)?  $default,){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Product product,  Store store,  Location pickupLocation,  int itemsAvailable,  bool newItem,  String displayName,  double? distance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.product,_that.store,_that.pickupLocation,_that.itemsAvailable,_that.newItem,_that.displayName,_that.distance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Product product,  Store store,  Location pickupLocation,  int itemsAvailable,  bool newItem,  String displayName,  double? distance)  $default,) {final _that = this;
switch (_that) {
case _Offer():
return $default(_that.product,_that.store,_that.pickupLocation,_that.itemsAvailable,_that.newItem,_that.displayName,_that.distance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Product product,  Store store,  Location pickupLocation,  int itemsAvailable,  bool newItem,  String displayName,  double? distance)?  $default,) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.product,_that.store,_that.pickupLocation,_that.itemsAvailable,_that.newItem,_that.displayName,_that.distance);case _:
  return null;

}
}

}

/// @nodoc


class _Offer extends Offer {
  const _Offer({required this.product, required this.store, required this.pickupLocation, required this.itemsAvailable, required this.newItem, required this.displayName, this.distance}): super._();
  

@override final  Product product;
@override final  Store store;
@override final  Location pickupLocation;
@override final  int itemsAvailable;
@override final  bool newItem;
@override final  String displayName;
@override final  double? distance;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferCopyWith<_Offer> get copyWith => __$OfferCopyWithImpl<_Offer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offer&&(identical(other.product, product) || other.product == product)&&(identical(other.store, store) || other.store == store)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.itemsAvailable, itemsAvailable) || other.itemsAvailable == itemsAvailable)&&(identical(other.newItem, newItem) || other.newItem == newItem)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.distance, distance) || other.distance == distance));
}


@override
int get hashCode => Object.hash(runtimeType,product,store,pickupLocation,itemsAvailable,newItem,displayName,distance);

@override
String toString() {
  return 'Offer(product: $product, store: $store, pickupLocation: $pickupLocation, itemsAvailable: $itemsAvailable, newItem: $newItem, displayName: $displayName, distance: $distance)';
}


}

/// @nodoc
abstract mixin class _$OfferCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$OfferCopyWith(_Offer value, $Res Function(_Offer) _then) = __$OfferCopyWithImpl;
@override @useResult
$Res call({
 Product product, Store store, Location pickupLocation, int itemsAvailable, bool newItem, String displayName, double? distance
});


@override $ProductCopyWith<$Res> get product;@override $StoreCopyWith<$Res> get store;@override $LocationCopyWith<$Res> get pickupLocation;

}
/// @nodoc
class __$OfferCopyWithImpl<$Res>
    implements _$OfferCopyWith<$Res> {
  __$OfferCopyWithImpl(this._self, this._then);

  final _Offer _self;
  final $Res Function(_Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? store = null,Object? pickupLocation = null,Object? itemsAvailable = null,Object? newItem = null,Object? displayName = null,Object? distance = freezed,}) {
  return _then(_Offer(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,store: null == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as Store,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as Location,itemsAvailable: null == itemsAvailable ? _self.itemsAvailable : itemsAvailable // ignore: cast_nullable_to_non_nullable
as int,newItem: null == newItem ? _self.newItem : newItem // ignore: cast_nullable_to_non_nullable
as bool,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreCopyWith<$Res> get store {
  
  return $StoreCopyWith<$Res>(_self.store, (value) {
    return _then(_self.copyWith(store: value));
  });
}/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get pickupLocation {
  
  return $LocationCopyWith<$Res>(_self.pickupLocation, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}
}

// dart format on
