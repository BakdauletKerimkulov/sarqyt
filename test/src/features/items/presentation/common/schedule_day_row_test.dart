import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/common/schedule_day_row.dart';

/// Mirrors the horizontal padding the create-item form applies around the
/// schedule editor, so the widths below are the real content widths.
Widget _buildSubject() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Sizes.p32),
        child: ScheduleDayRow(
          dayName: 'Wednesday',
          schedule: DaySchedule(
            enabled: true,
            startHour: 10,
            startMinute: 0,
            endHour: 18,
            endMinute: 30,
            quantity: 1,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ScheduleDayRow fits the screen', () {
    // 320: smallest phone still in use; 430: largest. Both overflowed before
    // the compact layout existed.
    for (final width in [320.0, 375.0, 430.0]) {
      testWidgets('at ${width.toInt()}px wide', (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_buildSubject());

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('keeps the single-row layout on a wide window', (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_buildSubject());

      expect(tester.takeException(), isNull);
      // Day name, switch and all four time fields share one horizontal band.
      final dayCentre = tester.getCenter(find.text('Wednesday')).dy;
      final fieldCentre = tester
          .getCenter(find.bySemanticsLabel('Wednesday end minute'))
          .dy;
      expect(dayCentre, moreOrLessEquals(fieldCentre, epsilon: 1));
    });
  });
}
