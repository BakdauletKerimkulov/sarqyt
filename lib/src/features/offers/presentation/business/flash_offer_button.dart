import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/features/offers/presentation/business/create_one_time_offer_dialog.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Opens [CreateOneTimeOfferDialog] to create a flash (one-time) offer.
class FlashOfferButton extends StatelessWidget {
  const FlashOfferButton({super.key, required this.storeId});

  final StoreID storeId;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.flash_on, size: 18),
      label: Text(context.loc.flashOffer),
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      onPressed: () => showDialog<bool>(
        context: context,
        builder: (_) => CreateOneTimeOfferDialog(storeId: storeId),
      ),
    );
  }
}
