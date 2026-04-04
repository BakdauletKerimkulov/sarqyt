// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {

 ReservationID get id; OfferID get offerId; StoreID get storeId; UserID get customerId; OfferID get itemId; String get itemName; String get storeName; String? get itemImageUrl; double get unitPrice; String get currencyCode; String get currencySymbol; int get quantity; ReservationStatus get status; String? get paymentIntentId;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get expiresAt;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.itemImageUrl, itemImageUrl) || other.itemImageUrl == itemImageUrl)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offerId,storeId,customerId,itemId,itemName,storeName,itemImageUrl,unitPrice,currencyCode,currencySymbol,quantity,status,paymentIntentId,createdAt,expiresAt);

@override
String toString() {
  return 'Reservation(id: $id, offerId: $offerId, storeId: $storeId, customerId: $customerId, itemId: $itemId, itemName: $itemName, storeName: $storeName, itemImageUrl: $itemImageUrl, unitPrice: $unitPrice, currencyCode: $currencyCode, currencySymbol: $currencySymbol, quantity: $quantity, status: $status, paymentIntentId: $paymentIntentId, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 ReservationID id, OfferID offerId, StoreID storeId, UserID customerId, OfferID itemId, String itemName, String storeName, String? itemImageUrl, double unitPrice, String currencyCode, String currencySymbol, int quantity, ReservationStatus status, String? paymentIntentId,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime expiresAt
});




}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? offerId = null,Object? storeId = null,Object? customerId = null,Object? itemId = null,Object? itemName = null,Object? storeName = null,Object? itemImageUrl = freezed,Object? unitPrice = null,Object? currencyCode = null,Object? currencySymbol = null,Object? quantity = null,Object? status = null,Object? paymentIntentId = freezed,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReservationID,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as OfferID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as StoreID,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as UserID,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as OfferID,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,itemImageUrl: freezed == itemImageUrl ? _self.itemImageUrl : itemImageUrl // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReservationID id,  OfferID offerId,  StoreID storeId,  UserID customerId,  OfferID itemId,  String itemName,  String storeName,  String? itemImageUrl,  double unitPrice,  String currencyCode,  String currencySymbol,  int quantity,  ReservationStatus status,  String? paymentIntentId, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.offerId,_that.storeId,_that.customerId,_that.itemId,_that.itemName,_that.storeName,_that.itemImageUrl,_that.unitPrice,_that.currencyCode,_that.currencySymbol,_that.quantity,_that.status,_that.paymentIntentId,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReservationID id,  OfferID offerId,  StoreID storeId,  UserID customerId,  OfferID itemId,  String itemName,  String storeName,  String? itemImageUrl,  double unitPrice,  String currencyCode,  String currencySymbol,  int quantity,  ReservationStatus status,  String? paymentIntentId, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.id,_that.offerId,_that.storeId,_that.customerId,_that.itemId,_that.itemName,_that.storeName,_that.itemImageUrl,_that.unitPrice,_that.currencyCode,_that.currencySymbol,_that.quantity,_that.status,_that.paymentIntentId,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReservationID id,  OfferID offerId,  StoreID storeId,  UserID customerId,  OfferID itemId,  String itemName,  String storeName,  String? itemImageUrl,  double unitPrice,  String currencyCode,  String currencySymbol,  int quantity,  ReservationStatus status,  String? paymentIntentId, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.offerId,_that.storeId,_that.customerId,_that.itemId,_that.itemName,_that.storeName,_that.itemImageUrl,_that.unitPrice,_that.currencyCode,_that.currencySymbol,_that.quantity,_that.status,_that.paymentIntentId,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reservation extends Reservation {
  const _Reservation({required this.id, required this.offerId, required this.storeId, required this.customerId, required this.itemId, required this.itemName, required this.storeName, this.itemImageUrl, required this.unitPrice, this.currencyCode = 'KZT', this.currencySymbol = '\u20B8', required this.quantity, required this.status, this.paymentIntentId, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.expiresAt}): super._();
  factory _Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);

@override final  ReservationID id;
@override final  OfferID offerId;
@override final  StoreID storeId;
@override final  UserID customerId;
@override final  OfferID itemId;
@override final  String itemName;
@override final  String storeName;
@override final  String? itemImageUrl;
@override final  double unitPrice;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  String currencySymbol;
@override final  int quantity;
@override final  ReservationStatus status;
@override final  String? paymentIntentId;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime expiresAt;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.itemImageUrl, itemImageUrl) || other.itemImageUrl == itemImageUrl)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offerId,storeId,customerId,itemId,itemName,storeName,itemImageUrl,unitPrice,currencyCode,currencySymbol,quantity,status,paymentIntentId,createdAt,expiresAt);

@override
String toString() {
  return 'Reservation(id: $id, offerId: $offerId, storeId: $storeId, customerId: $customerId, itemId: $itemId, itemName: $itemName, storeName: $storeName, itemImageUrl: $itemImageUrl, unitPrice: $unitPrice, currencyCode: $currencyCode, currencySymbol: $currencySymbol, quantity: $quantity, status: $status, paymentIntentId: $paymentIntentId, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 ReservationID id, OfferID offerId, StoreID storeId, UserID customerId, OfferID itemId, String itemName, String storeName, String? itemImageUrl, double unitPrice, String currencyCode, String currencySymbol, int quantity, ReservationStatus status, String? paymentIntentId,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime expiresAt
});




}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? offerId = null,Object? storeId = null,Object? customerId = null,Object? itemId = null,Object? itemName = null,Object? storeName = null,Object? itemImageUrl = freezed,Object? unitPrice = null,Object? currencyCode = null,Object? currencySymbol = null,Object? quantity = null,Object? status = null,Object? paymentIntentId = freezed,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(_Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReservationID,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as OfferID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as StoreID,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as UserID,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as OfferID,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,itemImageUrl: freezed == itemImageUrl ? _self.itemImageUrl : itemImageUrl // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
