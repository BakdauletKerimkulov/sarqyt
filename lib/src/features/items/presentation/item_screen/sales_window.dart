import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/utils/formatters.dart';

class SalesWindow extends StatefulWidget {
  const SalesWindow({
    super.key,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final void Function(TimeOfDay start, TimeOfDay end) onChanged;

  @override
  State<SalesWindow> createState() => _SalesWindowState();
}

class _SalesWindowState extends State<SalesWindow> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  String? errorText;

  bool get hasError => errorText != null;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController();
    _endController = TextEditingController();
    _syncControllers();
    _validate(widget.start, widget.end);
  }

  @override
  void didUpdateWidget(covariant SalesWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.start != widget.start || oldWidget.end != widget.end) {
      _syncControllers();
      _validate(widget.start, widget.end);
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  String _format(TimeOfDay time) => timeFormatterHourMinute(time);

  void _syncControllers() {
    _startController.text = _format(widget.start);
    _endController.text = _format(widget.end);
  }

  bool _isEndInvalid(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes <= startMinutes;
  }

  void _validate(TimeOfDay start, TimeOfDay end) {
    errorText = _isEndInvalid(start, end)
        ? 'End time must be later than start time'
        : null;
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final defaultColor = Theme.of(context).dividerColor;
    final activeColor = Theme.of(context).colorScheme.primary;

    return InputDecoration(
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: hasError ? Colors.red : defaultColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: hasError ? Colors.red : activeColor),
      ),
      errorText: hasError ? '' : null,
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.start,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      _startController.text = _format(picked);
      _validate(picked, widget.end);
    });

    widget.onChanged(picked, widget.end);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.end,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      _endController.text = _format(picked);
      _validate(widget.start, picked);
    });

    widget.onChanged(widget.start, picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startController,
                decoration: _inputDecoration(context),
                readOnly: true,
                onTap: _pickStart,
              ),
            ),
            gapW16,
            Expanded(
              child: TextFormField(
                controller: _endController,
                decoration: _inputDecoration(context),
                readOnly: true,
                onTap: _pickEnd,
              ),
            ),
          ],
        ),
        gapH8,
        Text(
          errorText ?? 'Sales stop at ${_format(widget.end)}',
          style: TextStyle(color: hasError ? Colors.red : AppColors.primary),
        ),
      ],
    );
  }
}
