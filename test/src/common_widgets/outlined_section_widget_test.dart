import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';

/// The dashboard's trailing: several action buttons whose natural width
/// exceeds the compact content width, laid out so they can break onto a
/// second run once the header gives them the full width.
const _wideTrailing = Wrap(
  children: [
    SizedBox(width: 200, height: 40),
    SizedBox(width: 200, height: 40),
  ],
);

void _useCompactViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('section header on a compact viewport', () {
    testWidgets('OutlinedSectionWidgetWithHeader does not overflow', (
      tester,
    ) async {
      _useCompactViewport(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OutlinedSectionWidgetWithHeader(
              header: 'Your surprise bags',
              trailing: _wideTrailing,
              child: SizedBox(height: 40),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('OutlinedSectionSliverWidgetWithHeader does not overflow', (
      tester,
    ) async {
      _useCompactViewport(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                OutlinedSectionSliverWidgetWithHeader(
                  header: 'Your surprise bags',
                  trailing: _wideTrailing,
                  sliver: SliverToBoxAdapter(child: SizedBox(height: 40)),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
