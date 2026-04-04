import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/routing/go_router_refresh_stream.dart';

void main() {
  group('GoRouterRefreshStream', () {
    test('single stream: notifies listener when stream emits', () async {
      final controller = StreamController<int>();
      final refresh = GoRouterRefreshStream(controller.stream);

      int notifyCount = 0;
      // Listener added AFTER constructor — initial notifyListeners() already fired
      refresh.addListener(() => notifyCount++);
      expect(notifyCount, 0);

      controller.add(1);
      await Future.microtask(() {});
      expect(notifyCount, 1);

      controller.add(2);
      await Future.microtask(() {});
      expect(notifyCount, 2);

      refresh.dispose();
      await controller.close();
    });

    test('merged: notifies when either stream emits', () async {
      final ctrl1 = StreamController<String>();
      final ctrl2 = StreamController<String>();
      final refresh = GoRouterRefreshStream.merged([ctrl1.stream, ctrl2.stream]);

      int notifyCount = 0;
      refresh.addListener(() => notifyCount++);
      expect(notifyCount, 0);

      ctrl1.add('a');
      await Future.microtask(() {});
      expect(notifyCount, 1, reason: 'stream 1 should trigger notify');

      ctrl2.add('b');
      await Future.microtask(() {});
      expect(notifyCount, 2, reason: 'stream 2 should trigger notify');

      ctrl1.add('c');
      await Future.microtask(() {});
      expect(notifyCount, 3, reason: 'stream 1 again should trigger notify');

      refresh.dispose();
      await ctrl1.close();
      await ctrl2.close();
    });

    test('merged: dispose cancels all subscriptions', () async {
      final ctrl1 = StreamController<int>();
      final ctrl2 = StreamController<int>();
      final refresh = GoRouterRefreshStream.merged([ctrl1.stream, ctrl2.stream]);

      int notifyCount = 0;
      refresh.addListener(() => notifyCount++);
      expect(notifyCount, 0);

      refresh.dispose();

      ctrl1.add(1);
      ctrl2.add(1);
      await Future.microtask(() {});

      expect(notifyCount, 0, reason: 'After dispose, no notifications expected');

      await ctrl1.close();
      await ctrl2.close();
    });
  });
}
