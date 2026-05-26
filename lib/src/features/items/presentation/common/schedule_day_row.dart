import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';

/// Single weekday row used inside the weekly schedule editor.
/// Shared between dashboard "Create item" form and other schedule editors.
class ScheduleDayRow extends StatelessWidget {
  const ScheduleDayRow({
    super.key,
    required this.dayName,
    required this.schedule,
    this.enabled = true,
    this.onToggle,
    this.onPickStart,
    this.onPickEnd,
    this.errorText,
  });

  final String dayName;
  final DaySchedule schedule;
  final bool enabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onPickStart;
  final VoidCallback? onPickEnd;
  final String? errorText;

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(dayName, style: textTheme.bodyMedium),
              ),
              Switch(
                value: schedule.enabled,
                onChanged: enabled ? onToggle : null,
                activeThumbColor: AppColors.primary,
              ),
              const Spacer(),
              if (schedule.enabled) ...[
                TextButton(
                  onPressed: enabled ? onPickStart : null,
                  child: Text(_fmt(schedule.startTime)),
                ),
                Text(' – ', style: textTheme.bodyMedium),
                TextButton(
                  onPressed: enabled ? onPickEnd : null,
                  child: Text(_fmt(schedule.endTime)),
                ),
              ],
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: Sizes.p4),
              child: Text(
                errorText!,
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
