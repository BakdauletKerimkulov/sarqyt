import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';

void main() {
  group('Item model', () {
    test('discountPercent calculates correctly', () {
      final item = Item(
        id: 'i1',
        name: 'Bag',
        price: 1500,
        schedule: WeeklySchedule.defaultSchedule(),
        estimatedValue: 5000,
      );
      expect(item.discountPercent, 70);
    });

    test('discountPercent is 0 without estimatedValue', () {
      final item = Item(
        id: 'i1',
        name: 'Bag',
        price: 1500,
        schedule: WeeklySchedule.defaultSchedule(),
      );
      expect(item.discountPercent, 0);
    });

    test('default isActive is false', () {
      final item = Item(
        id: 'i1',
        name: 'Bag',
        price: 1500,
        schedule: WeeklySchedule.defaultSchedule(),
      );
      expect(item.isActive, false);
    });
  });

  group('WeeklySchedule', () {
    test('defaultSchedule has weekdays enabled', () {
      final schedule = WeeklySchedule.defaultSchedule();
      for (int i = 1; i <= 5; i++) {
        expect(schedule.days[i]!.enabled, true);
      }
    });

    test('defaultSchedule has weekends disabled', () {
      final schedule = WeeklySchedule.defaultSchedule();
      expect(schedule.days[6]!.enabled, false);
      expect(schedule.days[7]!.enabled, false);
    });

    test('maxDayQuantity returns highest enabled quantity', () {
      final schedule = WeeklySchedule({
        1: const DaySchedule(
          enabled: true,
          startHour: 18,
          startMinute: 0,
          endHour: 20,
          endMinute: 0,
          quantity: 5,
        ),
        2: const DaySchedule(
          enabled: true,
          startHour: 18,
          startMinute: 0,
          endHour: 20,
          endMinute: 0,
          quantity: 10,
        ),
        3: const DaySchedule(
          enabled: false,
          startHour: 18,
          startMinute: 0,
          endHour: 20,
          endMinute: 0,
          quantity: 20,
        ),
      });
      expect(schedule.maxDayQuantity, 10);
    });

    test('validationError returns null for valid schedule', () {
      final schedule = WeeklySchedule.defaultSchedule();
      expect(schedule.validationError, isNull);
    });

    test('DaySchedule validationError when start >= end', () {
      const day = DaySchedule(
        enabled: true,
        startHour: 20,
        startMinute: 0,
        endHour: 18,
        endMinute: 0,
        quantity: 5,
      );
      expect(day.validationError, isNotNull);
    });

    test('DaySchedule validationError null when disabled', () {
      const day = DaySchedule(
        enabled: false,
        startHour: 20,
        startMinute: 0,
        endHour: 18,
        endMinute: 0,
        quantity: 5,
      );
      expect(day.validationError, isNull);
    });
  });
}
