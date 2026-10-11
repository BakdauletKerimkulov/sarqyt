import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Read-only list of upcoming/past offers for this item, grouped by pickup
/// date. Offers are only synced ~2 days ahead (`DAYS_AHEAD` in
/// `daily-sync-offers.ts`), so a full month grid would mostly be empty —
/// a grouped list is the more honest representation of the data.
class CalendarContent extends ConsumerWidget {
  const CalendarContent({
    super.key,
    required this.storeId,
    required this.itemId,
  });

  final String storeId;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersForItemProvider(storeId, itemId));
    final theme = Theme.of(context);

    return AsyncValueWidget(
      value: offersAsync,
      data: (offers) {
        if (offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                gapH8,
                Text(
                  'No scheduled pickups yet'.hardcoded,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final grouped = _groupByDate(offers);
        final dates = grouped.keys.toList()..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final date in dates) ...[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: Sizes.p8,
                  top: Sizes.p16,
                ),
                child: Text(
                  DateFormat('EEEE, d MMMM').format(date),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (final offer in grouped[date]!) _OfferRow(offer: offer),
            ],
          ],
        );
      },
    );
  }

  Map<DateTime, List<Offer>> _groupByDate(List<Offer> offers) {
    final result = <DateTime, List<Offer>>{};
    for (final offer in offers) {
      final start = offer.pickupStartTime;
      final day = DateTime(start.year, start.month, start.day);
      result.putIfAbsent(day, () => []).add(offer);
    }
    return result;
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: Row(
        children: [
          Icon(_statusIcon, size: 18, color: _statusColor),
          gapW8,
          Text(
            '${timeFormat.format(offer.pickupStartTime)} — ${timeFormat.format(offer.pickupEndTime)}',
            style: theme.textTheme.bodyMedium,
          ),
          gapW12,
          Text(
            '${offer.quantity} left'.hardcoded,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData get _statusIcon => switch (offer.status) {
    OfferStatus.active => Icons.check_circle_outline,
    OfferStatus.soldOut => Icons.block,
    OfferStatus.paused => Icons.pause_circle_outline,
    OfferStatus.expired => Icons.history,
  };

  Color get _statusColor => switch (offer.status) {
    OfferStatus.active => AppColors.primary,
    OfferStatus.soldOut => Colors.orange,
    OfferStatus.paused => Colors.grey,
    OfferStatus.expired => Colors.grey,
  };
}
