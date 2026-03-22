import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer.freezed.dart';

@freezed
abstract class Offer with _$Offer {
  const factory Offer({
    // IDs
    required String storeId,
    required String productId,
    // Offer content
    required int quantity,
    required String name,

    /// Price the customer pays.
    required double price,
    required String currencyCode,
    required String currencySymbol,

    /// Estimated retail value (optional).
    double? estimatedValue,
    // Store display
    required String storeName,
    String? storeLogo,
    String? storeAddress,
    // Product display
    String? productImage,
    // Pickup window
    required DateTime pickupStartTime,
    required DateTime pickupEndTime,
    // Metadata
    required DateTime createdAt,
    required String createdBy,
    @Default('active') String status,
  }) = _Offer;

  const Offer._();

  /// Computed discount percent from price vs estimatedValue.
  int get discountPercent {
    final ev = estimatedValue;
    if (ev == null || ev <= 0) return 0;
    final percent = ((1 - (price / ev)) * 100).round();
    return percent.clamp(0, 100);
  }

  /// Accepts DateTime, Firestore Timestamp, or ISO-8601 string.
  static DateTime _readDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.parse(v);
    throw ArgumentError('Unsupported date value: $v');
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  /// Writes DateTime to Firestore Timestamp.
  static Timestamp _writeDate(DateTime v) => Timestamp.fromDate(v);

  static String? _readStoreAddress(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;

    if (v is Map) {
      final map = v.cast<String, dynamic>();
      final addressMap = map['address'];
      if (addressMap is Map) {
        final data = addressMap.cast<String, dynamic>();
        final address = data['address']?.toString();
        final locality = data['locality']?.toString();
        final country = (data['country'] is Map)
            ? (data['country'] as Map)['name']?.toString()
            : null;

        final parts = <String>[
          if (address != null && address.isNotEmpty) address,
          if (locality != null && locality.isNotEmpty) locality,
          if (country != null && country.isNotEmpty) country,
        ];

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    }

    return null;
  }

  /// Reads a price value that may be a plain number or an old
  /// `{code, amount, currency}` map.
  static double _readPrice(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is Map) return (v['amount'] as num?)?.toDouble() ?? 0.0;
    return 0.0;
  }

  static double? _readOptionalPrice(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is Map) return (v['amount'] as num?)?.toDouble();
    return null;
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      storeId: json['storeId'] as String,
      productId: json['productId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      name: json['name'] as String,
      price: _readPrice(json['price']),
      currencyCode: (json['currencyCode'] as String?) ?? 'KZT',
      currencySymbol: (json['currencySymbol'] as String?) ?? '₸',
      estimatedValue: _readOptionalPrice(json['estimatedValue'] ?? json['originalPrice']),
      storeName: json['storeName'] as String,
      storeLogo: json['storeLogo'] as String?,
      storeAddress: _readStoreAddress(json['storeAddress']),
      productImage: json['productImage'] as String?,
      pickupStartTime: _readDate(json['pickupStartTime']),
      pickupEndTime: _readDate(json['pickupEndTime']),
      createdAt: _readDate(json['createdAt']),
      createdBy: json['createdBy'] as String,
      status: (json['status'] as String?) ?? 'active',
    );
  }

  /// JSON map that matches what you store in Firestore.
  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'productId': productId,
    'quantity': quantity,
    'name': name,
    'price': price,
    'currencyCode': currencyCode,
    'currencySymbol': currencySymbol,
    if (estimatedValue != null) 'estimatedValue': estimatedValue,
    'storeName': storeName,
    'storeLogo': storeLogo,
    'storeAddress': storeAddress,
    'productImage': productImage,
    'pickupStartTime': _writeDate(pickupStartTime),
    'pickupEndTime': _writeDate(pickupEndTime),
    'createdAt': _writeDate(createdAt),
    'createdBy': createdBy,
    'status': status,
  };

  bool get isActive => status == 'active';
  bool get isAvailable => quantity > 0;
  int get itemsAvailable => quantity;
  String get displayName => name;
  String get availableText => isAvailable ? 'Left $quantity' : 'Sold out';
  String? get distanceFormatter => null;
}
