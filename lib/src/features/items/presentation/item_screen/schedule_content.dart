import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/savings_card.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/schedule_content_controller.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/weekly_schedule_card.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class ScheduleContent extends ConsumerStatefulWidget {
  const ScheduleContent({super.key, required this.item, required this.storeId});

  final Item item;
  final StoreID storeId;

  @override
  ConsumerState<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends ConsumerState<ScheduleContent> {
  late WeeklySchedule _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = widget.item.schedule;
  }

  @override
  void didUpdateWidget(covariant ScheduleContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.schedule != widget.item.schedule) {
      _schedule = widget.item.schedule;
    }
  }

  void _updateDay(int day, DaySchedule updated) {
    setState(() => _schedule = _schedule.copyWithDay(day, updated));
  }

  void _updateDailyQuantity(int quantity) {
    ref
        .read(scheduleContentControllerProvider.notifier)
        .updateDailyQuantity(
          storeId: widget.storeId,
          item: widget.item,
          quantity: quantity,
        );
  }

  void _save() {
    final updatedItem = widget.item.copyWith(schedule: _schedule);
    ref
        .read(scheduleContentControllerProvider.notifier)
        .updateSchedule(storeId: widget.storeId, updatedItem: updatedItem);
  }

  bool get _canSave =>
      _schedule.validationError == null && _schedule != widget.item.schedule;

  @override
  Widget build(BuildContext context) {
    ref.listen(
      scheduleContentControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final controllerState = ref.watch(scheduleContentControllerProvider);
    final isLoading = controllerState.isLoading;
    final onSave = _canSave && !isLoading ? _save : null;

    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= Breakpoint.desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: WeeklyScheduleCard(
                    schedule: _schedule,
                    onDayChanged: _updateDay,
                    onSave: onSave,
                    isLoading: isLoading,
                  ),
                ),
                gapW24,
                SizedBox(
                  width: 320,
                  child: SavingsCard(
                    item: widget.item,
                    maxDayQuantity: _schedule.maxDayQuantity,
                    onUpdateDailyQuantity: _updateDailyQuantity,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                WeeklyScheduleCard(
                  schedule: _schedule,
                  onDayChanged: _updateDay,
                  onSave: onSave,
                  isLoading: isLoading,
                ),
                gapH24,
                SavingsCard(
                  item: widget.item,
                  maxDayQuantity: _schedule.maxDayQuantity,
                  onUpdateDailyQuantity: _updateDailyQuantity,
                ),
              ],
            ),
    );
  }
}
