import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/common/weekly_schedule_editor.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Extracted schedule section for the create item form.
/// Displays a label, description, and the weekly schedule editor.
class ScheduleFormSection extends StatelessWidget {
  const ScheduleFormSection({
    super.key,
    required this.schedule,
    required this.enabled,
    required this.onToggleDay,
    required this.onTimeChanged,
    this.dayErrors,
  });

  final WeeklySchedule schedule;
  final bool enabled;
  final void Function(int day, bool value) onToggleDay;
  final void Function(int day, String field, int value) onTimeChanged;
  final Map<int, String?>? dayErrors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.weeklySchedule,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        gapH4,
        Text(
          loc.setPickupWindowAndQuantity,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        gapH16,
        WeeklyScheduleEditor(
          schedule: schedule,
          enabled: enabled,
          onToggleDay: onToggleDay,
          onTimeChanged: onTimeChanged,
          dayErrors: dayErrors,
        ),
      ],
    );
  }
}
