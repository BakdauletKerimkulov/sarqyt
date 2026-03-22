// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/sales_window.dart';

class WeeklyScheduleCard extends StatelessWidget {
  const WeeklyScheduleCard({
    super.key,
    required this.schedule,
    required this.onDayChanged,
    required this.onSave,
    this.isLoading = false,
  });

  final WeeklySchedule schedule;
  final void Function(int day, DaySchedule) onDayChanged;
  final VoidCallback? onSave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final textTheme = Theme.of(context).textTheme;

    return OutlinedSectionWidgetWithHeader(
      header: 'Weekly schedule',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose which days of the week your Surprise Bags will be available for customers to reserve.',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          gapH16,
          for (int day = 1; day <= 7; day++) ...[
            if (day > 1) Divider(height: 1, color: lineColor),
            DayRow(
              dayName: WeeklySchedule.dayNames[day - 1],
              schedule: schedule.days[day]!,
              onChanged: (updated) => onDayChanged(day, updated),
            ),
          ],
          const Divider(),
          gapH16,
          PrimaryWebButton(
            text: 'Update schedule',
            onPressed: onSave,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class DayRow extends StatelessWidget {
  static const double _salesWindowWidth = 260;

  const DayRow({
    super.key,
    required this.dayName,
    required this.schedule,
    required this.onChanged,
  });

  final String dayName;
  final DaySchedule schedule;
  final ValueChanged<DaySchedule> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              dayName,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          gapW16,
          CollectionToggle(
            enabled: schedule.enabled,
            onChanged: (enabled) =>
                onChanged(schedule.copyWith(enabled: enabled)),
          ),
          gapW16,
          QuantityBox(
            quantity: schedule.quantity,
            onChanged: (q) => onChanged(schedule.copyWith(quantity: q)),
          ),
          gapW16,
          SizedBox(
            width: _salesWindowWidth,
            child: SalesWindow(
              start: schedule.startTime,
              end: schedule.endTime,
              onChanged: (start, end) => onChanged(
                schedule.copyWith(
                  startHour: start.hour,
                  startMinute: start.minute,
                  endHour: end.hour,
                  endMinute: end.minute,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionToggle extends StatelessWidget {
  const CollectionToggle({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
          gapH8,
          Text(
            enabled ? 'Collection' : 'No collection',
            style: TextStyle(
              color: enabled ? AppColors.primary : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class QuantityBox extends StatefulWidget {
  const QuantityBox({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  State<QuantityBox> createState() => _QuantityBoxState();
}

class _QuantityBoxState extends State<QuantityBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant QuantityBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      final newText = widget.quantity.toString();
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitValue() {
    final raw = int.tryParse(_controller.text);
    if (raw == null || raw < 1) {
      _controller.text = '1';
      widget.onChanged(1);
      return;
    }
    final clamped = raw.clamp(1, DaySchedule.maxQuantity);
    if (raw != clamped) {
      _controller.text = clamped.toString();
    }
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Sizes.p4,
                vertical: Sizes.p8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Sizes.p8),
              ),
              isDense: true,
            ),
            onEditingComplete: _commitValue,
            onTapOutside: (_) {
              _commitValue();
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        gapH4,
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Daily limits: ',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
              ),
              TextSpan(
                text: '${DaySchedule.maxQuantity}',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
