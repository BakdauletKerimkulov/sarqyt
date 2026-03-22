import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class OfferSliverContent extends StatelessWidget {
  const OfferSliverContent({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p8,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TitleRow(offer.name),
                        gapH8,
                        _CollectRow(
                          'Collect: ${_pickupWindowText(context)}'.hardcoded,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${offer.price.round()} ${offer.currencySymbol}',
                    style: const TextStyle(
                      fontSize: Sizes.p20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              gapH12,
              const Divider(),
              ListTile(
                onTap: () => showNotImplementedAlertDialog(context: context),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on),
                title: Text(
                  offer.storeAddress ?? 'Address is not specified'.hardcoded,
                  style: const TextStyle(color: AppColors.primary),
                ),
                subtitle: Text('More information about store'.hardcoded),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              gapH8,
              Text(
                'Status: ${offer.status}'.hardcoded,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              gapH8,
              Text('Available items: ${offer.quantity}'.hardcoded),
              gapH16,
              const Divider(),
              gapH12,
              Text(
                'Offer details are loaded from store and product snapshot at creation time.'
                    .hardcoded,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ]),
      ),
    );
  }

  String _pickupWindowText(BuildContext context) {
    final start = TimeOfDay.fromDateTime(offer.pickupStartTime).format(context);
    final end = TimeOfDay.fromDateTime(offer.pickupEndTime).format(context);
    return '$start - $end';
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag_outlined),
        gapW12,
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.p16,
          ),
        ),
      ],
    );
  }
}

class _CollectRow extends StatelessWidget {
  const _CollectRow(this.collectWindow);

  final String collectWindow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.watch_later_outlined),
        gapW12,
        Text(collectWindow),
      ],
    );
  }
}
