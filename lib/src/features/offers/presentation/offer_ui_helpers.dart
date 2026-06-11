import 'package:flutter/widgets.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

extension OfferPickupX on Offer {
  String pickupDayLabel(BuildContext context) {
    final loc = context.loc;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final pickupDay = DateTime(
      pickupStartTime.year,
      pickupStartTime.month,
      pickupStartTime.day,
    );

    if (pickupDay == today) return loc.today;
    if (pickupDay == tomorrow) return loc.tomorrow;
    return '${pickupDay.day}.${pickupDay.month.toString().padLeft(2, '0')}';
  }

  String pickupLabelLocalized(BuildContext context) {
    final start =
        '${pickupStartTime.hour}:${pickupStartTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${pickupEndTime.hour}:${pickupEndTime.minute.toString().padLeft(2, '0')}';
    return '${pickupDayLabel(context)}, $start – $end';
  }

  String availableTextLocalized(BuildContext context) {
    final loc = context.loc;
    return isAvailable ? loc.itemsLeft(quantity) : loc.soldOut;
  }
}

extension OfferStatusLabelX on OfferStatus {
  String localizedLabel(BuildContext context) {
    final loc = context.loc;
    return switch (this) {
      OfferStatus.active => loc.offerStatusActive,
      OfferStatus.paused => loc.offerStatusPaused,
      OfferStatus.expired => loc.offerStatusExpired,
    };
  }
}
