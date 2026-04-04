// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
  id: json['id'] as String,
  offerId: json['offerId'] as String,
  storeId: json['storeId'] as String,
  customerId: json['customerId'] as String,
  itemId: json['itemId'] as String,
  itemName: json['itemName'] as String,
  storeName: json['storeName'] as String,
  itemImageUrl: json['itemImageUrl'] as String?,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  currencyCode: json['currencyCode'] as String? ?? 'KZT',
  currencySymbol: json['currencySymbol'] as String? ?? '\u20B8',
  quantity: (json['quantity'] as num).toInt(),
  status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
  paymentIntentId: json['paymentIntentId'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  expiresAt: const TimestampConverter().fromJson(
    json['expiresAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offerId': instance.offerId,
      'storeId': instance.storeId,
      'customerId': instance.customerId,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      'storeName': instance.storeName,
      'itemImageUrl': instance.itemImageUrl,
      'unitPrice': instance.unitPrice,
      'currencyCode': instance.currencyCode,
      'currencySymbol': instance.currencySymbol,
      'quantity': instance.quantity,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'paymentIntentId': instance.paymentIntentId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.paid: 'paid',
  ReservationStatus.expired: 'expired',
  ReservationStatus.cancelled: 'cancelled',
};
