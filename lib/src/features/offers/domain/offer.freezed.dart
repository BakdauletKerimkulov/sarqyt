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

// IDs
 OfferID get id; String get storeId; String get productId;// Offer content
 int get quantity; String get name;/// Price the customer pays.
@JsonKey(fromJson: Offer._readPrice) double get price; String get currencyCode; String get currencySymbol;/// Estimated retail value (optional).
@JsonKey(fromJson: Offer._readOptionalPrice) double? get estimatedValue;// Store display
 String get storeName; String? get geohash;@JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint) GeoPoint get geopoint;@JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate) DateTime? get visibleFrom; String? get storeLogo;@JsonKey(fromJson: Offer._readStoreAddress) String? get storeAddress;// Product display
 String? get productImage;// Pickup window
@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime get pickupStartTime;@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime get pickupEndTime;// Metadata
@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime get createdAt; String get createdBy;@JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus) OfferStatus get status;
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferCopyWith<Offer> get copyWith => _$OfferCopyWithImpl<Offer>(this as Offer, _$identity);

  /// Serializes this Offer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.estimatedValue, estimatedValue) || other.estimatedValue == estimatedValue)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint)&&(identical(other.visibleFrom, visibleFrom) || other.visibleFrom == visibleFrom)&&(identical(other.storeLogo, storeLogo) || other.storeLogo == storeLogo)&&(identical(other.storeAddress, storeAddress) || other.storeAddress == storeAddress)&&(identical(other.productImage, productImage) || other.productImage == productImage)&&(identical(other.pickupStartTime, pickupStartTime) || other.pickupStartTime == pickupStartTime)&&(identical(other.pickupEndTime, pickupEndTime) || other.pickupEndTime == pickupEndTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,productId,quantity,name,price,currencyCode,currencySymbol,estimatedValue,storeName,geohash,geopoint,visibleFrom,storeLogo,storeAddress,productImage,pickupStartTime,pickupEndTime,createdAt,createdBy,status]);

@override
String toString() {
  return 'Offer(id: $id, storeId: $storeId, productId: $productId, quantity: $quantity, name: $name, price: $price, currencyCode: $currencyCode, currencySymbol: $currencySymbol, estimatedValue: $estimatedValue, storeName: $storeName, geohash: $geohash, geopoint: $geopoint, visibleFrom: $visibleFrom, storeLogo: $storeLogo, storeAddress: $storeAddress, productImage: $productImage, pickupStartTime: $pickupStartTime, pickupEndTime: $pickupEndTime, createdAt: $createdAt, createdBy: $createdBy, status: $status)';
}


}

/// @nodoc
abstract mixin class $OfferCopyWith<$Res>  {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) _then) = _$OfferCopyWithImpl;
@useResult
$Res call({
 OfferID id, String storeId, String productId, int quantity, String name,@JsonKey(fromJson: Offer._readPrice) double price, String currencyCode, String currencySymbol,@JsonKey(fromJson: Offer._readOptionalPrice) double? estimatedValue, String storeName, String? geohash,@JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint) GeoPoint geopoint,@JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate) DateTime? visibleFrom, String? storeLogo,@JsonKey(fromJson: Offer._readStoreAddress) String? storeAddress, String? productImage,@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime pickupStartTime,@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime pickupEndTime,@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime createdAt, String createdBy,@JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus) OfferStatus status
});




}
/// @nodoc
class _$OfferCopyWithImpl<$Res>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._self, this._then);

  final Offer _self;
  final $Res Function(Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? productId = null,Object? quantity = null,Object? name = null,Object? price = null,Object? currencyCode = null,Object? currencySymbol = null,Object? estimatedValue = freezed,Object? storeName = null,Object? geohash = freezed,Object? geopoint = null,Object? visibleFrom = freezed,Object? storeLogo = freezed,Object? storeAddress = freezed,Object? productImage = freezed,Object? pickupStartTime = null,Object? pickupEndTime = null,Object? createdAt = null,Object? createdBy = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as OfferID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,estimatedValue: freezed == estimatedValue ? _self.estimatedValue : estimatedValue // ignore: cast_nullable_to_non_nullable
as double?,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,visibleFrom: freezed == visibleFrom ? _self.visibleFrom : visibleFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,storeLogo: freezed == storeLogo ? _self.storeLogo : storeLogo // ignore: cast_nullable_to_non_nullable
as String?,storeAddress: freezed == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String?,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,pickupStartTime: null == pickupStartTime ? _self.pickupStartTime : pickupStartTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupEndTime: null == pickupEndTime ? _self.pickupEndTime : pickupEndTime // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OfferID id,  String storeId,  String productId,  int quantity,  String name, @JsonKey(fromJson: Offer._readPrice)  double price,  String currencyCode,  String currencySymbol, @JsonKey(fromJson: Offer._readOptionalPrice)  double? estimatedValue,  String storeName,  String? geohash, @JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint)  GeoPoint geopoint, @JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate)  DateTime? visibleFrom,  String? storeLogo, @JsonKey(fromJson: Offer._readStoreAddress)  String? storeAddress,  String? productImage, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime pickupStartTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime pickupEndTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime createdAt,  String createdBy, @JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus)  OfferStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.name,_that.price,_that.currencyCode,_that.currencySymbol,_that.estimatedValue,_that.storeName,_that.geohash,_that.geopoint,_that.visibleFrom,_that.storeLogo,_that.storeAddress,_that.productImage,_that.pickupStartTime,_that.pickupEndTime,_that.createdAt,_that.createdBy,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OfferID id,  String storeId,  String productId,  int quantity,  String name, @JsonKey(fromJson: Offer._readPrice)  double price,  String currencyCode,  String currencySymbol, @JsonKey(fromJson: Offer._readOptionalPrice)  double? estimatedValue,  String storeName,  String? geohash, @JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint)  GeoPoint geopoint, @JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate)  DateTime? visibleFrom,  String? storeLogo, @JsonKey(fromJson: Offer._readStoreAddress)  String? storeAddress,  String? productImage, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime pickupStartTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime pickupEndTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime createdAt,  String createdBy, @JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus)  OfferStatus status)  $default,) {final _that = this;
switch (_that) {
case _Offer():
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.name,_that.price,_that.currencyCode,_that.currencySymbol,_that.estimatedValue,_that.storeName,_that.geohash,_that.geopoint,_that.visibleFrom,_that.storeLogo,_that.storeAddress,_that.productImage,_that.pickupStartTime,_that.pickupEndTime,_that.createdAt,_that.createdBy,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OfferID id,  String storeId,  String productId,  int quantity,  String name, @JsonKey(fromJson: Offer._readPrice)  double price,  String currencyCode,  String currencySymbol, @JsonKey(fromJson: Offer._readOptionalPrice)  double? estimatedValue,  String storeName,  String? geohash, @JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint)  GeoPoint geopoint, @JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate)  DateTime? visibleFrom,  String? storeLogo, @JsonKey(fromJson: Offer._readStoreAddress)  String? storeAddress,  String? productImage, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime pickupStartTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime pickupEndTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)  DateTime createdAt,  String createdBy, @JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus)  OfferStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.quantity,_that.name,_that.price,_that.currencyCode,_that.currencySymbol,_that.estimatedValue,_that.storeName,_that.geohash,_that.geopoint,_that.visibleFrom,_that.storeLogo,_that.storeAddress,_that.productImage,_that.pickupStartTime,_that.pickupEndTime,_that.createdAt,_that.createdBy,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Offer extends Offer {
  const _Offer({required this.id, required this.storeId, required this.productId, required this.quantity, required this.name, @JsonKey(fromJson: Offer._readPrice) required this.price, required this.currencyCode, required this.currencySymbol, @JsonKey(fromJson: Offer._readOptionalPrice) this.estimatedValue, required this.storeName, this.geohash, @JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint) required this.geopoint, @JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate) this.visibleFrom, this.storeLogo, @JsonKey(fromJson: Offer._readStoreAddress) this.storeAddress, this.productImage, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) required this.pickupStartTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) required this.pickupEndTime, @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) required this.createdAt, required this.createdBy, @JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus) required this.status}): super._();
  factory _Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

// IDs
@override final  OfferID id;
@override final  String storeId;
@override final  String productId;
// Offer content
@override final  int quantity;
@override final  String name;
/// Price the customer pays.
@override@JsonKey(fromJson: Offer._readPrice) final  double price;
@override final  String currencyCode;
@override final  String currencySymbol;
/// Estimated retail value (optional).
@override@JsonKey(fromJson: Offer._readOptionalPrice) final  double? estimatedValue;
// Store display
@override final  String storeName;
@override final  String? geohash;
@override@JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint) final  GeoPoint geopoint;
@override@JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate) final  DateTime? visibleFrom;
@override final  String? storeLogo;
@override@JsonKey(fromJson: Offer._readStoreAddress) final  String? storeAddress;
// Product display
@override final  String? productImage;
// Pickup window
@override@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) final  DateTime pickupStartTime;
@override@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) final  DateTime pickupEndTime;
// Metadata
@override@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) final  DateTime createdAt;
@override final  String createdBy;
@override@JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus) final  OfferStatus status;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferCopyWith<_Offer> get copyWith => __$OfferCopyWithImpl<_Offer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.estimatedValue, estimatedValue) || other.estimatedValue == estimatedValue)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint)&&(identical(other.visibleFrom, visibleFrom) || other.visibleFrom == visibleFrom)&&(identical(other.storeLogo, storeLogo) || other.storeLogo == storeLogo)&&(identical(other.storeAddress, storeAddress) || other.storeAddress == storeAddress)&&(identical(other.productImage, productImage) || other.productImage == productImage)&&(identical(other.pickupStartTime, pickupStartTime) || other.pickupStartTime == pickupStartTime)&&(identical(other.pickupEndTime, pickupEndTime) || other.pickupEndTime == pickupEndTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,productId,quantity,name,price,currencyCode,currencySymbol,estimatedValue,storeName,geohash,geopoint,visibleFrom,storeLogo,storeAddress,productImage,pickupStartTime,pickupEndTime,createdAt,createdBy,status]);

@override
String toString() {
  return 'Offer(id: $id, storeId: $storeId, productId: $productId, quantity: $quantity, name: $name, price: $price, currencyCode: $currencyCode, currencySymbol: $currencySymbol, estimatedValue: $estimatedValue, storeName: $storeName, geohash: $geohash, geopoint: $geopoint, visibleFrom: $visibleFrom, storeLogo: $storeLogo, storeAddress: $storeAddress, productImage: $productImage, pickupStartTime: $pickupStartTime, pickupEndTime: $pickupEndTime, createdAt: $createdAt, createdBy: $createdBy, status: $status)';
}


}

/// @nodoc
abstract mixin class _$OfferCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$OfferCopyWith(_Offer value, $Res Function(_Offer) _then) = __$OfferCopyWithImpl;
@override @useResult
$Res call({
 OfferID id, String storeId, String productId, int quantity, String name,@JsonKey(fromJson: Offer._readPrice) double price, String currencyCode, String currencySymbol,@JsonKey(fromJson: Offer._readOptionalPrice) double? estimatedValue, String storeName, String? geohash,@JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint) GeoPoint geopoint,@JsonKey(fromJson: Offer._readNullableDate, toJson: Offer._writeNullableDate) DateTime? visibleFrom, String? storeLogo,@JsonKey(fromJson: Offer._readStoreAddress) String? storeAddress, String? productImage,@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime pickupStartTime,@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime pickupEndTime,@JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate) DateTime createdAt, String createdBy,@JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus) OfferStatus status
});




}
/// @nodoc
class __$OfferCopyWithImpl<$Res>
    implements _$OfferCopyWith<$Res> {
  __$OfferCopyWithImpl(this._self, this._then);

  final _Offer _self;
  final $Res Function(_Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? productId = null,Object? quantity = null,Object? name = null,Object? price = null,Object? currencyCode = null,Object? currencySymbol = null,Object? estimatedValue = freezed,Object? storeName = null,Object? geohash = freezed,Object? geopoint = null,Object? visibleFrom = freezed,Object? storeLogo = freezed,Object? storeAddress = freezed,Object? productImage = freezed,Object? pickupStartTime = null,Object? pickupEndTime = null,Object? createdAt = null,Object? createdBy = null,Object? status = null,}) {
  return _then(_Offer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as OfferID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,estimatedValue: freezed == estimatedValue ? _self.estimatedValue : estimatedValue // ignore: cast_nullable_to_non_nullable
as double?,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,visibleFrom: freezed == visibleFrom ? _self.visibleFrom : visibleFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,storeLogo: freezed == storeLogo ? _self.storeLogo : storeLogo // ignore: cast_nullable_to_non_nullable
as String?,storeAddress: freezed == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String?,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,pickupStartTime: null == pickupStartTime ? _self.pickupStartTime : pickupStartTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupEndTime: null == pickupEndTime ? _self.pickupEndTime : pickupEndTime // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,
  ));
}


}

// dart format on
