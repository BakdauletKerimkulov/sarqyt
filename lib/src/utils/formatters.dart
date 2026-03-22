import 'package:flutter/material.dart';

/// Formats a [TimeOfDay] as "HH:mm" (24-hour).
String timeFormatterHourMinute(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
