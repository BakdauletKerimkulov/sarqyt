import 'package:flutter/material.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/common/schedule_day_row.dart';

/// Stateless 7-day schedule editor. Owns no state — the parent passes the
/// current [schedule] and reacts to callbacks to mutate it.
class WeeklyScheduleEditor extends StatelessWidget {
  const WeeklyScheduleEditor({
    super.key,
    required this.schedule,
    required this.onToggleDay,
    required this.onTimeChanged,
    this.enabled = true,
    this.dayErrors,
  });

  final WeeklySchedule schedule;
  final bool enabled;
  final void Function(int day, bool value) onToggleDay;

  /// Called when any time field changes.
  /// [day] 1–7, [field] one of startHour/startMinute/endHour/endMinute.
  final void Function(int day, String field, int value) onTimeChanged;

  /// Per-day validation errors. Key = day (1–7), value = error or null.
  final Map<int, String?>? dayErrors;

  @override
  Widget build(BuildContext context) {
    final dayNames = WeeklySchedule.dayNames;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int day = 1; day <= 7; day++) ...[
          ScheduleDayRow(
            dayName: dayNames[day - 1],
            schedule: schedule.days[day]!,
            enabled: enabled,
            onToggle: (v) => onToggleDay(day, v),
            onStartHourChanged: (v) => onTimeChanged(day, 'startHour', v),
            onStartMinuteChanged: (v) => onTimeChanged(day, 'startMinute', v),
            onEndHourChanged: (v) => onTimeChanged(day, 'endHour', v),
            onEndMinuteChanged: (v) => onTimeChanged(day, 'endMinute', v),
            errorText: dayErrors?[day],
          ),
          if (day < 7) const Divider(height: 1),
        ],
      ],
    );
  }
}
