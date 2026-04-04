// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/start_selling_dialog_controller.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class StartSellingDialog extends ConsumerWidget {
  const StartSellingDialog({
    super.key,
    required this.item,
    required this.storeId,
  });

  final Item item;
  final StoreID storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      startSellingDialogControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final formatted = DateFormat('d MMMM y').format(DateTime.now());
    final state = ref.watch(startSellingDialogControllerProvider);
    final isLoading = state.isLoading;

    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm and start selling'.hardcoded,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gapH16,
              const Divider(),
              gapH16,

              // Item info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.p8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: CustomImage(imageUrl: item.imageUrl),
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        gapH4,
                        Text(
                          '${item.price.round()} ₸'.hardcoded,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              gapH16,

              // Schedule info
              Text(
                'Daily quantity'.hardcoded,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              gapH4,
              Text('${item.schedule.maxDayQuantity} per day'),
              gapH16,

              // Start date
              Text(
                'Start date'.hardcoded,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              gapH8,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Sizes.p12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(Sizes.p8),
                ),
                child: Text(formatted),
              ),
              gapH24,

              PrimaryWebButton(
                text: 'Confirm and start selling'.hardcoded,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(
                                startSellingDialogControllerProvider.notifier)
                            .startSelling(itemId: item.id, storeId: storeId);
                        if (context.mounted && success) {
                          Navigator.of(context).pop(true);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
