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
    required this.onPickStart,
    required this.onPickEnd,
    this.enabled = true,
  });

  final WeeklySchedule schedule;
  final bool enabled;
  final void Function(int day, bool value) onToggleDay;
  final Future<void> Function(int day) onPickStart;
  final Future<void> Function(int day) onPickEnd;

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
            onPickStart: () => onPickStart(day),
            onPickEnd: () => onPickEnd(day),
          ),
          if (day < 7) const Divider(height: 1),
        ],
      ],
    );
  }
}
