// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Offer _$OfferFromJson(Map<String, dynamic> json) => _Offer(
  id: json['id'] as String,
  storeId: json['storeId'] as String,
  productId: json['productId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  name: json['name'] as String,
  price: Offer._readPrice(json['price']),
  currencyCode: json['currencyCode'] as String,
  currencySymbol: json['currencySymbol'] as String,
  estimatedValue: Offer._readOptionalPrice(json['estimatedValue']),
  storeName: json['storeName'] as String,
  geohash: json['geohash'] as String?,
  geopoint: Offer._readGeoPoint(json['geopoint']),
  visibleFrom: Offer._readNullableDate(json['visibleFrom']),
  storeLogo: json['storeLogo'] as String?,
  storeAddress: Offer._readStoreAddress(json['storeAddress']),
  productImage: json['productImage'] as String?,
  pickupStartTime: Offer._readDate(json['pickupStartTime']),
  pickupEndTime: Offer._readDate(json['pickupEndTime']),
  createdAt: Offer._readDate(json['createdAt']),
  createdBy: json['createdBy'] as String,
  status: Offer._readStatus(json['status']),
);

Map<String, dynamic> _$OfferToJson(_Offer instance) => <String, dynamic>{
  'id': instance.id,
  'storeId': instance.storeId,
  'productId': instance.productId,
  'quantity': instance.quantity,
  'name': instance.name,
  'price': instance.price,
  'currencyCode': instance.currencyCode,
  'currencySymbol': instance.currencySymbol,
  'estimatedValue': instance.estimatedValue,
  'storeName': instance.storeName,
  'geohash': instance.geohash,
  'geopoint': Offer._writeGeoPoint(instance.geopoint),
  'visibleFrom': Offer._writeNullableDate(instance.visibleFrom),
  'storeLogo': instance.storeLogo,
  'storeAddress': instance.storeAddress,
  'productImage': instance.productImage,
  'pickupStartTime': Offer._writeDate(instance.pickupStartTime),
  'pickupEndTime': Offer._writeDate(instance.pickupEndTime),
  'createdAt': Offer._writeDate(instance.createdAt),
  'createdBy': instance.createdBy,
  'status': Offer._writeStatus(instance.status),
};
