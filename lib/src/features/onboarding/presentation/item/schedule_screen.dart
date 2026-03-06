import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/create_item_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/schedule_screen_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static String contentKey = 'shedule-content';

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/sarqyt_item.png',
      child: OnboardingPanel(
        onBackPressed: () => context.pop(),
        title: 'Set your pickup schedule'.hardcoded,
        child: ScheduleContent(key: ValueKey(contentKey)),
      ),
    );
  }
}

class ScheduleContent extends ConsumerWidget {
  const ScheduleContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      createItemControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(createItemControllerProvider);
    final schedule = ref.watch(scheduleScreenControllerProvider);
    final controller = ref.read(scheduleScreenControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int day = 1; day <= 7; day++) ...[
          _DayRow(
            dayName: WeeklySchedule.dayNames[day - 1],
            schedule: schedule.days[day]!,
            onToggle: (enabled) => controller.toggleDay(day, enabled: enabled),
            onPickStart: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: schedule.days[day]!.startTime,
              );
              if (picked != null) controller.updateStartTime(day, picked);
            },
            onPickEnd: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: schedule.days[day]!.endTime,
              );
              if (picked != null) controller.updateEndTime(day, picked);
            },
          ),
          if (day < 7) const Divider(height: 1),
        ],
        gapH24,
        PrimaryWebButton(
          text: 'Create Item'.hardcoded,
          isLoading: state.isLoading,
          onPressed: state.isLoading
              ? null
              : () {
                  final scheduleError = controller.validateAndSave();
                  if (scheduleError != null) {
                    showAlertDialog(
                      context: context,
                      title: 'Error',
                      content: scheduleError,
                    );
                    return;
                  }
                  final submitError = ref
                      .read(createItemControllerProvider.notifier)
                      .submitOnboardingItem();
                  if (submitError != null) {
                    showAlertDialog(
                      context: context,
                      title: 'Error',
                      content: submitError,
                    );
                  }
                },
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.dayName,
    required this.schedule,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String dayName;
  final DaySchedule schedule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasError = schedule.validationError != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(dayName, style: textTheme.bodyMedium),
              ),
              Switch(value: schedule.enabled, onChanged: onToggle),
              const Spacer(),
              if (schedule.enabled) ...[
                TextButton(
                  onPressed: onPickStart,
                  child: Text(_formatTime(schedule.startTime)),
                ),
                Text(' – ', style: textTheme.bodyMedium),
                TextButton(
                  onPressed: onPickEnd,
                  child: Text(_formatTime(schedule.endTime)),
                ),
              ],
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: Sizes.p4),
              child: Text(
                schedule.validationError!,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
