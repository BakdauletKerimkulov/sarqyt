import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/converters.dart';

part 'order.freezed.dart';
part 'order.g.dart';

typedef OrderID = String;

enum OrderStatus { confirmed, preparing, readyForPickup, completed, cancelled }

enum PaymentStatus { paid, refunded }

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
    required PaymentStatus paymentStatus,
    @NullableTimestampConverter() DateTime? pickupStartTime,
    @NullableTimestampConverter() DateTime? pickupEndTime,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
    int? orderNumber,
    String? reservationId,
    String? paymentIntentId,
  }) = _Order;

  const Order._();

  String get totalFormatted =>
      '${(unitPrice * itemQuantity).round()} $currencySymbol';

  /// Remaining time until pickup window closes. Null if no pickupEndTime.
  Duration? get timeUntilPickupEnd {
    if (pickupEndTime == null) return null;
    final remaining = pickupEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isPickupExpired =>
      pickupEndTime != null && DateTime.now().isAfter(pickupEndTime!);

  /// "Сегодня, 18:00 – 20:00" or null
  String? get pickupLabel {
    if (pickupStartTime == null || pickupEndTime == null) return null;
    final start = pickupStartTime!;
    final end = pickupEndTime!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final pickupDay = DateTime(start.year, start.month, start.day);

    final dayLabel = pickupDay == today
        ? 'Сегодня'
        : pickupDay == tomorrow
            ? 'Завтра'
            : '${pickupDay.day}.${pickupDay.month.toString().padLeft(2, '0')}';

    final startStr =
        '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
    return '$dayLabel, $startStr – $endStr';
  }

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
