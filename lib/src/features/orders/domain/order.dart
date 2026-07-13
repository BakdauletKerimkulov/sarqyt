// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/converters.dart';

part 'order.freezed.dart';
part 'order.g.dart';

typedef OrderID = String;

enum OrderStatus { confirmed, preparing, readyForPickup, completed, cancelled, expired }

enum PaymentStatus { paid, refunded, refundPending, refundFailed }

enum CancelledBy { customer, store }

@freezed
abstract class Order with _$Order {
  const factory Order({
    required OrderID id,
    required ItemID itemId,
    required StoreID storeId,
    required UserID customerId,
    required String itemName,
    required String storeName,
    String? itemImageUrl,
    required double unitPrice,
    @Default('KZT') String currencyCode,
    @Default('₸') String currencySymbol,
    required int itemQuantity,
    required OrderStatus status,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    PaymentStatus? paymentStatus,
    String? cancellationReason,
    CancelledBy? cancelledBy,
    @NullableTimestampConverter() DateTime? pickupStartTime,
    @NullableTimestampConverter() DateTime? pickupEndTime,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
    int? orderNumber,
    OfferID? offerId,
    String? paymentIntentId,
  }) = _Order;

  const Order._();

  String get totalFormatted =>
      '${(unitPrice * itemQuantity).round()} $currencySymbol';

  /// Remaining time until pickup window closes. Null if no pickupEndTime.
  Duration? timeUntilPickupEnd(DateTime now) {
    if (pickupEndTime == null) return null;
    final remaining = pickupEndTime!.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isPickupExpired(DateTime now) =>
      pickupEndTime != null && now.isAfter(pickupEndTime!);

  /// Formatted pickup window, e.g. "14:00 – 16:00". Null if times missing.
  String? get pickupLabel {
    if (pickupStartTime == null || pickupEndTime == null) return null;
    final start = pickupStartTime!;
    final end = pickupEndTime!;
    final startStr =
        '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr – $endStr';
  }

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
