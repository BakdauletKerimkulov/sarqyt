import 'package:flutter/material.dart';
class DaySchedule {
  const DaySchedule({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.quantity,
  });

  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int quantity;

  TimeOfDay get startTime => TimeOfDay(hour: startHour, minute: startMinute);
  TimeOfDay get endTime => TimeOfDay(hour: endHour, minute: endMinute);

  DaySchedule copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    int? quantity,
  }) {
    return DaySchedule(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      quantity: quantity ?? this.quantity,
    );
  }

  static const int maxQuantity = 30;
  static const int maxWindowMinutes = 120;

  int get startInMinutes => startHour * 60 + startMinute;
  int get endInMinutes => endHour * 60 + endMinute;
  int get durationMinutes => endInMinutes - startInMinutes;

  /// Returns a validation error message if the schedule is invalid, or null.
  String? get validationError {
    if (!enabled) return null;
    if (startInMinutes >= endInMinutes) {
      return 'Start time must be before end time';
    }
    if (durationMinutes > maxWindowMinutes) {
      return 'Window cannot exceed 2 hours';
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaySchedule &&
          enabled == other.enabled &&
          startHour == other.startHour &&
          startMinute == other.startMinute &&
          endHour == other.endHour &&
          endMinute == other.endMinute &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(
        enabled, startHour, startMinute, endHour, endMinute, quantity,
      );

  Map<String, dynamic> toMap() => {
    'enabled': enabled,
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
    'quantity': quantity,
  };

  factory DaySchedule.fromMap(Map<String, dynamic> map) {
    return DaySchedule(
      enabled: map['enabled'] as bool? ?? false,
      startHour: map['startHour'] as int? ?? 0,
      startMinute: map['startMinute'] as int? ?? 0,
      endHour: map['endHour'] as int? ?? 0,
      endMinute: map['endMinute'] as int? ?? 0,
      quantity: map['quantity'] as int? ?? 1,
    );
  }

  factory DaySchedule.fromJson(Map<String, dynamic> json) =>
      DaySchedule.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  static const DaySchedule weekdayDefault = DaySchedule(
    enabled: true,
    startHour: 18,
    startMinute: 0,
    endHour: 20,
    endMinute: 0,
    quantity: 1,
  );

  static const DaySchedule weekendDefault = DaySchedule(
    enabled: false,
    startHour: 18,
    startMinute: 0,
    endHour: 20,
    endMinute: 0,
    quantity: 0,
  );
}

class WeeklySchedule {
  const WeeklySchedule(this.days);

  /// Map from day-of-week (1=Monday..7=Sunday) to DaySchedule.
  final Map<int, DaySchedule> days;

  factory WeeklySchedule.defaultSchedule() {
    return WeeklySchedule({
      for (int i = 1; i <= 5; i++) i: DaySchedule.weekdayDefault,
      for (int i = 6; i <= 7; i++) i: DaySchedule.weekendDefault,
    });
  }

  WeeklySchedule copyWithDay(int day, DaySchedule schedule) {
    return WeeklySchedule({...days, day: schedule});
  }

  /// Returns the highest quantity across all enabled days.
  int get maxDayQuantity {
    int max = 0;
    for (final day in days.values) {
      if (day.enabled && day.quantity > max) max = day.quantity;
    }
    return max;
  }

  /// Returns the first validation error across all enabled days, or null.
  String? get validationError {
    for (final entry in days.entries) {
      final error = entry.value.validationError;
      if (error != null) {
        final dayName = dayNames[entry.key - 1];
        return '$dayName: $error';
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklySchedule &&
          days.length == other.days.length &&
          days.entries.every((e) => other.days[e.key] == e.value);

  @override
  int get hashCode => Object.hashAll(
        days.entries.map((e) => Object.hash(e.key, e.value)),
      );

  Map<String, dynamic> toMap() => {
    for (final entry in days.entries)
      entry.key.toString(): entry.value.toMap(),
  };

  factory WeeklySchedule.fromMap(Map<String, dynamic> map) {
    return WeeklySchedule({
      for (final entry in map.entries)
        int.parse(entry.key): DaySchedule.fromMap(
          entry.value as Map<String, dynamic>,
        ),
    });
  }

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) =>
      WeeklySchedule.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  static const List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
