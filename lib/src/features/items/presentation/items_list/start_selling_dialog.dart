// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    final nowDate = DateTime.now();
    final formatted = DateFormat('d MMMM y').format(nowDate);

    final state = ref.watch(startSellingDialogControllerProvider);
    final isLoading = state.isLoading;

    return Dialog(
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
              // TODO: Реализовать показ данных айтема
              Text(
                'Start date'.hardcoded,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gapH16,
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
                child: Text(formatted),
              ),
              gapH16,
              Text('Price in app'.hardcoded),
              gapH24,

              PrimaryWebButton(
                text: 'Confirm and start selling'.hardcoded,
                isLoading: isLoading,
                onPressed: () async {
                  final success = await ref
                      .read(startSellingDialogControllerProvider.notifier)
                      .startSelling(item, storeId: storeId);
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
