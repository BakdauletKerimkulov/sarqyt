@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/app_client.dart';

import '../../robot.dart';

void main() {
  for (final size in const [Size(390, 844), Size(834, 1194)]) {
    testWidgets(
      'discover screen — ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final r = Robot(tester);
        await r.pumpClientApp();

        await expectLater(
          find.byType(MyAppClient),
          matchesGoldenFile('discover_${size.width.toInt()}.png'),
        );
      },
    );
  }
}
