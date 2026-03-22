// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 OrderID get id; ItemID get itemId; StoreID get storeId; UserID get customerId; String get itemName; String get storeName; String? get itemImageUrl; double get unitPrice; String get currencyCode; String get currencySymbol; int get itemQuantity; OrderStatus get status; PaymentStatus get paymentStatus;@TimestampConverter() DateTime get createdAt;@NullableTimestampConverter() DateTime? get updatedAt; int? get orderNumber;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.itemImageUrl, itemImageUrl) || other.itemImageUrl == itemImageUrl)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.itemQuantity, itemQuantity) || other.itemQuantity == itemQuantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,storeId,customerId,itemName,storeName,itemImageUrl,unitPrice,currencyCode,currencySymbol,itemQuantity,status,paymentStatus,createdAt,updatedAt,orderNumber);

@override
String toString() {
  return 'Order(id: $id, itemId: $itemId, storeId: $storeId, customerId: $customerId, itemName: $itemName, storeName: $storeName, itemImageUrl: $itemImageUrl, unitPrice: $unitPrice, currencyCode: $currencyCode, currencySymbol: $currencySymbol, itemQuantity: $itemQuantity, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, updatedAt: $updatedAt, orderNumber: $orderNumber)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 OrderID id, ItemID itemId, StoreID storeId, UserID customerId, String itemName, String storeName, String? itemImageUrl, double unitPrice, String currencyCode, String currencySymbol, int itemQuantity, OrderStatus status, PaymentStatus paymentStatus,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt, int? orderNumber
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? storeId = null,Object? customerId = null,Object? itemName = null,Object? storeName = null,Object? itemImageUrl = freezed,Object? unitPrice = null,Object? currencyCode = null,Object? currencySymbol = null,Object? itemQuantity = null,Object? status = null,Object? paymentStatus = null,Object? createdAt = null,Object? updatedAt = freezed,Object? orderNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as OrderID,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as ItemID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as StoreID,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as UserID,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,itemImageUrl: freezed == itemImageUrl ? _self.itemImageUrl : itemImageUrl // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,itemQuantity: null == itemQuantity ? _self.itemQuantity : itemQuantity // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderID id,  ItemID itemId,  StoreID storeId,  UserID customerId,  String itemName,  String storeName,  String? itemImageUrl,  double unitPrice,  String currencyCode,  String currencySymbol,  int itemQuantity,  OrderStatus status,  PaymentStatus paymentStatus, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt,  int? orderNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.itemId,_that.storeId,_that.customerId,_that.itemName,_that.storeName,_that.itemImageUrl,_that.unitPrice,_that.currencyCode,_that.currencySymbol,_that.itemQuantity,_that.status,_that.paymentStatus,_that.createdAt,_that.updatedAt,_that.orderNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderID id,  ItemID itemId,  StoreID storeId,  UserID customerId,  String itemName,  String storeName,  String? itemImageUrl,  double unitPrice,  String currencyCode,  String currencySymbol,  int itemQuantity,  OrderStatus status,  PaymentStatus paymentStatus, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt,  int? orderNumber)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.itemId,_that.storeId,_that.customerId,_that.itemName,_that.storeName,_that.itemImageUrl,_that.unitPrice,_that.currencyCode,_that.currencySymbol,_that.itemQuantity,_that.status,_that.paymentStatus,_that.createdAt,_that.updatedAt,_that.orderNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderID id,  ItemID itemId,  StoreID storeId,  UserID customerId,  String itemName,  String storeName,  String? itemImageUrl,  double unitPrice,  String currencyCode,  String currencySymbol,  int itemQuantity,  OrderStatus status,  PaymentStatus paymentStatus, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt,  int? orderNumber)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.itemId,_that.storeId,_that.customerId,_that.itemName,_that.storeName,_that.itemImageUrl,_that.unitPrice,_that.currencyCode,_that.currencySymbol,_that.itemQuantity,_that.status,_that.paymentStatus,_that.createdAt,_that.updatedAt,_that.orderNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order extends Order {
  const _Order({required this.id, required this.itemId, required this.storeId, required this.customerId, required this.itemName, required this.storeName, this.itemImageUrl, required this.unitPrice, this.currencyCode = 'KZT', this.currencySymbol = '₸', required this.itemQuantity, required this.status, required this.paymentStatus, @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.updatedAt, this.orderNumber}): super._();
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  OrderID id;
@override final  ItemID itemId;
@override final  StoreID storeId;
@override final  UserID customerId;
@override final  String itemName;
@override final  String storeName;
@override final  String? itemImageUrl;
@override final  double unitPrice;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  String currencySymbol;
@override final  int itemQuantity;
@override final  OrderStatus status;
@override final  PaymentStatus paymentStatus;
@override@TimestampConverter() final  DateTime createdAt;
@override@NullableTimestampConverter() final  DateTime? updatedAt;
@override final  int? orderNumber;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.itemImageUrl, itemImageUrl) || other.itemImageUrl == itemImageUrl)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.itemQuantity, itemQuantity) || other.itemQuantity == itemQuantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,storeId,customerId,itemName,storeName,itemImageUrl,unitPrice,currencyCode,currencySymbol,itemQuantity,status,paymentStatus,createdAt,updatedAt,orderNumber);

@override
String toString() {
  return 'Order(id: $id, itemId: $itemId, storeId: $storeId, customerId: $customerId, itemName: $itemName, storeName: $storeName, itemImageUrl: $itemImageUrl, unitPrice: $unitPrice, currencyCode: $currencyCode, currencySymbol: $currencySymbol, itemQuantity: $itemQuantity, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, updatedAt: $updatedAt, orderNumber: $orderNumber)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 OrderID id, ItemID itemId, StoreID storeId, UserID customerId, String itemName, String storeName, String? itemImageUrl, double unitPrice, String currencyCode, String currencySymbol, int itemQuantity, OrderStatus status, PaymentStatus paymentStatus,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt, int? orderNumber
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? storeId = null,Object? customerId = null,Object? itemName = null,Object? storeName = null,Object? itemImageUrl = freezed,Object? unitPrice = null,Object? currencyCode = null,Object? currencySymbol = null,Object? itemQuantity = null,Object? status = null,Object? paymentStatus = null,Object? createdAt = null,Object? updatedAt = freezed,Object? orderNumber = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as OrderID,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as ItemID,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as StoreID,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as UserID,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,itemImageUrl: freezed == itemImageUrl ? _self.itemImageUrl : itemImageUrl // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,itemQuantity: null == itemQuantity ? _self.itemQuantity : itemQuantity // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
