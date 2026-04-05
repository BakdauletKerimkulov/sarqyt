// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
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

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      startSellingDialogControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final formatted = DateFormat('d MMMM y').format(DateTime.now());
    final state = ref.watch(startSellingDialogControllerProvider);
    final isLoading = state.isLoading;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Sizes.p24, Sizes.p20, Sizes.p8, Sizes.p8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Confirm and start selling'.hardcoded,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Sizes.p24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start date section
                    Icon(Icons.rocket_launch_outlined,
                        color: AppColors.primary, size: 32),
                    gapH12,
                    Text(
                      'Start date'.hardcoded,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    gapH8,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.p12,
                        vertical: Sizes.p4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(Sizes.p4),
                      ),
                      child: Text(formatted),
                    ),
                    gapH8,
                    Text(
                      'On this date, customers will be able to see your store and your available Surprise Bags in the Sarqyt app.'
                          .hardcoded,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    gapH24,
                    const Divider(),
                    gapH24,

                    // Surprise bag details
                    Icon(Icons.shopping_bag_outlined,
                        color: AppColors.primary, size: 32),
                    gapH12,
                    Text(
                      'Surprise Bag details'.hardcoded,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    gapH16,
                    _DetailRow(
                      label: 'Name'.hardcoded,
                      value: item.name,
                    ),
                    if (item.description != null) ...[
                      gapH12,
                      _DetailRow(
                        label: 'Description'.hardcoded,
                        value: item.description!,
                      ),
                    ],
                    if (item.estimatedValue != null) ...[
                      gapH12,
                      _DetailRow(
                        label: 'Estimated value'.hardcoded,
                        value: '${item.estimatedValue!.round()} ₸',
                      ),
                    ],
                    gapH12,
                    _DetailRow(
                      label: 'Price in app'.hardcoded,
                      value: '${item.price.round()} ₸',
                    ),
                    gapH24,
                    const Divider(),
                    gapH24,

                    // Schedule section
                    Icon(Icons.calendar_month_outlined,
                        color: AppColors.primary, size: 32),
                    gapH12,
                    Text(
                      'Schedule'.hardcoded,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    gapH4,
                    Text(
                      'Surprise Bags per day'.hardcoded,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    gapH4,
                    Text(
                      '${item.schedule.maxDayQuantity} x Surprise Bags will be made available on each of your selected days. You can always change this later.'
                          .hardcoded,
                      style: theme.textTheme.bodyMedium,
                    ),
                    gapH16,
                    Text(
                      'Collection times'.hardcoded,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    gapH8,
                    // Schedule table
                    for (int day = 1; day <= 7; day++)
                      _ScheduleRow(
                        dayName: _dayNames[day - 1],
                        schedule: item.schedule.days[day]!,
                      ),
                  ],
                ),
              ),
            ),

            // Bottom button
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p24,
                      vertical: Sizes.p12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.p24),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(startSellingDialogControllerProvider
                                  .notifier)
                              .startSelling(
                                  itemId: item.id, storeId: storeId);
                          if (context.mounted && success) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Confirm and start selling'.hardcoded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.dayName, required this.schedule});

  final String dayName;
  final DaySchedule schedule;

  @override
  Widget build(BuildContext context) {
    final time = schedule.enabled
        ? '${schedule.startHour.toString().padLeft(2, '0')}:${schedule.startMinute.toString().padLeft(2, '0')}'
            ' - '
            '${schedule.endHour.toString().padLeft(2, '0')}:${schedule.endMinute.toString().padLeft(2, '0')}'
        : 'Closed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              dayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: schedule.enabled ? null : Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
