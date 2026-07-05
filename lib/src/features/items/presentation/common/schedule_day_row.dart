import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';

/// Single weekday row used inside the weekly schedule editor.
/// Displays inline HH:MM text fields for start and end time.
class ScheduleDayRow extends StatefulWidget {
  const ScheduleDayRow({
    super.key,
    required this.dayName,
    required this.schedule,
    this.enabled = true,
    this.onToggle,
    this.onStartHourChanged,
    this.onStartMinuteChanged,
    this.onEndHourChanged,
    this.onEndMinuteChanged,
    this.errorText,
  });

  final String dayName;
  final DaySchedule schedule;
  final bool enabled;
  final ValueChanged<bool>? onToggle;
  final ValueChanged<int>? onStartHourChanged;
  final ValueChanged<int>? onStartMinuteChanged;
  final ValueChanged<int>? onEndHourChanged;
  final ValueChanged<int>? onEndMinuteChanged;
  final String? errorText;

  @override
  State<ScheduleDayRow> createState() => _ScheduleDayRowState();
}

class _ScheduleDayRowState extends State<ScheduleDayRow> {
  late final TextEditingController _startHourCtl;
  late final TextEditingController _startMinuteCtl;
  late final TextEditingController _endHourCtl;
  late final TextEditingController _endMinuteCtl;

  @override
  void initState() {
    super.initState();
    _startHourCtl = TextEditingController(
      text: _pad(widget.schedule.startHour),
    );
    _startMinuteCtl = TextEditingController(
      text: _pad(widget.schedule.startMinute),
    );
    _endHourCtl = TextEditingController(
      text: _pad(widget.schedule.endHour),
    );
    _endMinuteCtl = TextEditingController(
      text: _pad(widget.schedule.endMinute),
    );
  }

  @override
  void didUpdateWidget(covariant ScheduleDayRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final s = widget.schedule;
    final o = oldWidget.schedule;
    if (s.startHour != o.startHour) _startHourCtl.text = _pad(s.startHour);
    if (s.startMinute != o.startMinute) {
      _startMinuteCtl.text = _pad(s.startMinute);
    }
    if (s.endHour != o.endHour) _endHourCtl.text = _pad(s.endHour);
    if (s.endMinute != o.endMinute) _endMinuteCtl.text = _pad(s.endMinute);
  }

  @override
  void dispose() {
    _startHourCtl.dispose();
    _startMinuteCtl.dispose();
    _endHourCtl.dispose();
    _endMinuteCtl.dispose();
    super.dispose();
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');

  void _onChanged(
    TextEditingController ctl,
    int max,
    ValueChanged<int>? callback,
  ) {
    final text = ctl.text;
    if (text.isEmpty) return;
    final value = int.tryParse(text);
    if (value == null || value < 0 || value > max) return;
    callback?.call(value);
  }

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
                child: Text(widget.dayName, style: textTheme.bodyMedium),
              ),
              Switch(
                value: widget.schedule.enabled,
                onChanged: widget.enabled ? widget.onToggle : null,
                activeThumbColor: AppColors.primary,
              ),
              const Spacer(),
              if (widget.schedule.enabled) ...[
                _TimeField(
                  controller: _startHourCtl,
                  enabled: widget.enabled,
                  semanticLabel: '${widget.dayName} start hour',
                  max: 23,
                  onChanged: (v) => _onChanged(
                    _startHourCtl,
                    23,
                    widget.onStartHourChanged,
                  ),
                ),
                Text(' : ', style: textTheme.bodyMedium),
                _TimeField(
                  controller: _startMinuteCtl,
                  enabled: widget.enabled,
                  semanticLabel: '${widget.dayName} start minute',
                  max: 59,
                  onChanged: (v) => _onChanged(
                    _startMinuteCtl,
                    59,
                    widget.onStartMinuteChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.p4),
                  child: Text('–', style: textTheme.bodyMedium),
                ),
                _TimeField(
                  controller: _endHourCtl,
                  enabled: widget.enabled,
                  semanticLabel: '${widget.dayName} end hour',
                  max: 23,
                  onChanged: (v) => _onChanged(
                    _endHourCtl,
                    23,
                    widget.onEndHourChanged,
                  ),
                ),
                Text(' : ', style: textTheme.bodyMedium),
                _TimeField(
                  controller: _endMinuteCtl,
                  enabled: widget.enabled,
                  semanticLabel: '${widget.dayName} end minute',
                  max: 59,
                  onChanged: (v) => _onChanged(
                    _endMinuteCtl,
                    59,
                    widget.onEndMinuteChanged,
                  ),
                ),
              ],
            ],
          ),
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: Sizes.p4),
              child: Text(
                widget.errorText!,
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

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.controller,
    required this.enabled,
    required this.semanticLabel,
    required this.max,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final String semanticLabel;
  final int max;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Semantics(
        label: semanticLabel,
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Sizes.p4,
              vertical: Sizes.p8,
            ),
          ),
          onChanged: onChanged,
          validator: (v) {
            if (v == null || v.isEmpty) return '';
            final n = int.tryParse(v);
            if (n == null || n < 0 || n > max) return '';
            return null;
          },
        ),
      ),
    );
  }
}
