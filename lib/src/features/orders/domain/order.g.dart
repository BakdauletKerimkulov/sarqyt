// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  itemId: json['itemId'] as String,
  storeId: json['storeId'] as String,
  customerId: json['customerId'] as String,
  itemName: json['itemName'] as String,
  storeName: json['storeName'] as String,
  itemImageUrl: json['itemImageUrl'] as String?,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  currencyCode: json['currencyCode'] as String? ?? 'KZT',
  currencySymbol: json['currencySymbol'] as String? ?? '₸',
  itemQuantity: (json['itemQuantity'] as num).toInt(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
  pickupStartTime: const NullableTimestampConverter().fromJson(
    json['pickupStartTime'] as Timestamp?,
  ),
  pickupEndTime: const NullableTimestampConverter().fromJson(
    json['pickupEndTime'] as Timestamp?,
  ),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const NullableTimestampConverter().fromJson(
    json['updatedAt'] as Timestamp?,
  ),
  orderNumber: (json['orderNumber'] as num?)?.toInt(),
  reservationId: json['reservationId'] as String?,
  paymentIntentId: json['paymentIntentId'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'itemId': instance.itemId,
  'storeId': instance.storeId,
  'customerId': instance.customerId,
  'itemName': instance.itemName,
  'storeName': instance.storeName,
  'itemImageUrl': instance.itemImageUrl,
  'unitPrice': instance.unitPrice,
  'currencyCode': instance.currencyCode,
  'currencySymbol': instance.currencySymbol,
  'itemQuantity': instance.itemQuantity,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'pickupStartTime': const NullableTimestampConverter().toJson(
    instance.pickupStartTime,
  ),
  'pickupEndTime': const NullableTimestampConverter().toJson(
    instance.pickupEndTime,
  ),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
  'orderNumber': instance.orderNumber,
  'reservationId': instance.reservationId,
  'paymentIntentId': instance.paymentIntentId,
};

const _$OrderStatusEnumMap = {
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.readyForPickup: 'readyForPickup',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.refunded: 'refunded',
};
