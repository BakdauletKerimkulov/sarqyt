// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'offer.freezed.dart';
part 'offer.g.dart';

enum OfferStatus { active, paused, expired }

extension OfferStatusX on OfferStatus {
  String label() {
    return switch (this) {
      OfferStatus.active => 'Active',
      OfferStatus.paused => 'Paused',
      OfferStatus.expired => 'Expired',
    };
  }
}

typedef OfferID = String;

@freezed
abstract class Offer with _$Offer {
  const factory Offer({
    // IDs
    required OfferID id,
    required String storeId,
    required String productId,
    // Offer content
    required int quantity,
    required String name,

    /// Price the customer pays.
    @JsonKey(fromJson: Offer._readPrice) required double price,
    required String currencyCode,
    required String currencySymbol,

    /// Estimated retail value (optional).
    @JsonKey(fromJson: Offer._readOptionalPrice) double? estimatedValue,
    // Store display
    required String storeName,
    String? geohash,
    @JsonKey(fromJson: Offer._readGeoPoint, toJson: Offer._writeGeoPoint)
    required GeoPoint geopoint,
    @JsonKey(
      fromJson: Offer._readNullableDate,
      toJson: Offer._writeNullableDate,
    )
    DateTime? visibleFrom,
    String? storeLogo,
    @JsonKey(fromJson: Offer._readStoreAddress) String? storeAddress,
    // Product display
    String? productImage,
    // Pickup window
    @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)
    required DateTime pickupStartTime,
    @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)
    required DateTime pickupEndTime,
    // Metadata
    @JsonKey(fromJson: Offer._readDate, toJson: Offer._writeDate)
    required DateTime createdAt,
    required String createdBy,
    @JsonKey(fromJson: Offer._readStatus, toJson: Offer._writeStatus)
    required OfferStatus status,
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

  static DateTime? _readNullableDate(dynamic v) {
    if (v == null) return null;
    return _readDate(v);
  }

  String get statusLabel {
    switch (status) {
      case OfferStatus.active:
        return 'Active';
      case OfferStatus.paused:
        return 'Paused';
      case OfferStatus.expired:
        return 'Expired';
    }
  }

  /// Writes DateTime to Firestore Timestamp.
  static Timestamp _writeDate(DateTime v) => Timestamp.fromDate(v);

  static Timestamp? _writeNullableDate(DateTime? v) {
    if (v == null) return null;
    return _writeDate(v);
  }

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

  static OfferStatus _readStatus(dynamic v) {
    if (v is OfferStatus) return v;

    switch (v?.toString()) {
      case 'active':
        return OfferStatus.active;
      case 'inactive':
      case 'paused':
        return OfferStatus.paused;
      case 'expired':
        return OfferStatus.expired;
      case null:
        return OfferStatus.active;
      default:
        throw ArgumentError('Unsupported offer status: $v');
    }
  }

  static GeoPoint _readGeoPoint(dynamic v) {
    if (v is GeoPoint) return v;
    if (v is Map) {
      final lat = (v['latitude'] ?? v['_latitude']) as num?;
      final lng = (v['longitude'] ?? v['_longitude']) as num?;
      if (lat != null && lng != null) {
        return GeoPoint(lat.toDouble(), lng.toDouble());
      }
    }
    throw ArgumentError('Unsupported geopoint value: $v');
  }

  static GeoPoint _writeGeoPoint(GeoPoint v) => v;

  static String _writeStatus(OfferStatus status) => status.name;

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  bool get isActive => status == OfferStatus.active;
  bool get isAvailable => quantity > 0;
  int get itemsAvailable => quantity;
  String get displayName => name;
  String get availableText => isAvailable ? 'Left $quantity' : 'Sold out';
  LatLng get latLng => LatLng(geopoint.latitude, geopoint.longitude);
  String? get distanceFormatter => null;

  /// "Сегодня", "Завтра", or formatted date.
  String get pickupDayLabel {
    final now = DateTime.now();
    final pickupDate = pickupStartTime;
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final pickupDay = DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
    );

    if (pickupDay == today) return 'Today';
    if (pickupDay == tomorrow) return 'Tomorrow';
    return '${pickupDay.day}.${pickupDay.month.toString().padLeft(2, '0')}';
  }

  /// "Сегодня, 18:00 – 20:00"
  String get pickupLabel {
    final start =
        '${pickupStartTime.hour}:${pickupStartTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${pickupEndTime.hour}:${pickupEndTime.minute.toString().padLeft(2, '0')}';
    return '$pickupDayLabel, $start – $end';
  }
}
