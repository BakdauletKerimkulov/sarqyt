// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/common_widgets/responsive_scrollable_card.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/checkout/presentation/item_quantity_selector.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/create_offer_screen_controller.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class CreateOfferScreen extends ConsumerWidget {
  const CreateOfferScreen({
    super.key,
    required this.productId,
    required this.storeId,
  });

  final ProductID productId;
  final StoreID storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateOfferContent(productId: productId, storeId: storeId);
  }
}

class CreateOfferContent extends ConsumerStatefulWidget {
  const CreateOfferContent({
    super.key,
    required this.productId,
    required this.storeId,
  });

  final ProductID productId;
  final StoreID storeId;

  @override
  ConsumerState<CreateOfferContent> createState() => _CreateOfferContentState();
}

enum PickupDay { today, tomorrow }

class _CreateOfferContentState extends ConsumerState<CreateOfferContent> {
  final _startPickupTimeController = TextEditingController();
  final _endPickupTimeController = TextEditingController();

  final now = DateTime.now();

  DateTime get today => DateTime(now.year, now.month, now.day);
  DateTime get tomorrow => now.add(const Duration(days: 1));

  @override
  void dispose() {
    _startPickupTimeController.dispose();
    _endPickupTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      createOfferControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(offerFormControllerProvider(widget.productId));
    final controller = ref.read(
      offerFormControllerProvider(widget.productId).notifier,
    );
    final createOfferState = ref.watch(createOfferControllerProvider);

    final isLoading = createOfferState.isLoading;

    final selectedDayEnum =
        (state.selectedDay != null &&
            DateUtils.isSameDay(state.selectedDay, tomorrow))
        ? PickupDay.tomorrow
        : PickupDay.today;

    return ResponsiveScrollableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back),
              ),
              gapW16,
              Text(
                'Create offer'.hardcoded,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          gapH24,

          Text(
            'Choose pickup day'.hardcoded,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          gapH8,
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<PickupDay>(
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.comfortable,
              ),
              showSelectedIcon: false,
              segments: [
                ButtonSegment<PickupDay>(
                  value: PickupDay.today,
                  label: Text('Today'.hardcoded),
                  icon: Icon(Icons.today_outlined),
                ),

                ButtonSegment<PickupDay>(
                  value: PickupDay.tomorrow,
                  label: Text('Tomorrow'.hardcoded),
                  icon: Icon(Icons.calendar_month_outlined),
                ),
              ],
              selected: {selectedDayEnum},
              onSelectionChanged: (value) {
                final index = value.first;

                index == PickupDay.today
                    ? controller.selectToday()
                    : controller.selectTomorrow();
              },
            ),
          ),

          gapH16,

          Text(
            'Choose pickup time'.hardcoded,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          gapH8,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('From:'),
                    TextField(
                      readOnly: true,
                      controller: _startPickupTimeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.p16),
                        ),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (time != null) {
                          final error = controller.selectStartTime(time);

                          if (error != null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              _startPickupTimeController.text = time.format(
                                context,
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              gapW16,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('To:'),
                    TextField(
                      readOnly: true,
                      controller: _endPickupTimeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.p16),
                        ),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (time != null) {
                          final error = controller.selectEndTime(time);

                          if (error != null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              _endPickupTimeController.text = time.format(
                                context,
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          gapH16,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ItemQuantitySelector(
                quantity: state.quantity,
                maxQuantity: 10,
                onChanged: (value) => controller.selectQuantity(value),
              ),
              const VerticalDivider(),
              PrimaryWebButton(
                text: 'Create'.hardcoded,
                onPressed: isLoading
                    ? null
                    : () {
                        if (controller.isValid) {
                          ref
                              .read(createOfferControllerProvider.notifier)
                              .createOffer(state, widget.storeId);
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
