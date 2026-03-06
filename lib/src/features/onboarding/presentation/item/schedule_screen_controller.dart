import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/item_draft_controller.dart';

part 'schedule_screen_controller.g.dart';

@riverpod
class ScheduleScreenController extends _$ScheduleScreenController {
  @override
  WeeklySchedule build() {
    final draft = ref.read(itemDraftControllerProvider);
    return draft.schedule ?? WeeklySchedule.defaultSchedule();
  }

  void toggleDay(int day, {required bool enabled}) {
    final current = state.days[day]!;
    state = state.copyWithDay(day, current.copyWith(enabled: enabled));
  }

  void updateStartTime(int day, TimeOfDay time) {
    final current = state.days[day]!;
    state = state.copyWithDay(
      day,
      current.copyWith(startHour: time.hour, startMinute: time.minute),
    );
  }

  void updateEndTime(int day, TimeOfDay time) {
    final current = state.days[day]!;
    state = state.copyWithDay(
      day,
      current.copyWith(endHour: time.hour, endMinute: time.minute),
    );
  }

  /// Validates schedule and saves it to draft.
  /// Returns validation error or null on success.
  String? validateAndSave() {
    final error = state.validationError;
    if (error != null) return error;

    ref.read(itemDraftControllerProvider.notifier).saveSchedule(state);
    return null;
  }
}
