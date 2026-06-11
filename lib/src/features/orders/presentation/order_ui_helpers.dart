import 'package:flutter/widgets.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

extension OrderPickupX on Order {
  String? pickupLabelLocalized(BuildContext context) {
    if (pickupStartTime == null || pickupEndTime == null) return null;
    final loc = context.loc;
    final start = pickupStartTime!;
    final end = pickupEndTime!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final pickupDay = DateTime(start.year, start.month, start.day);

    final dayLabel = pickupDay == today
        ? loc.today
        : pickupDay == tomorrow
            ? loc.tomorrow
            : '${pickupDay.day}.${pickupDay.month.toString().padLeft(2, '0')}';

    final startStr =
        '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
    return '$dayLabel, $startStr – $endStr';
  }
}
