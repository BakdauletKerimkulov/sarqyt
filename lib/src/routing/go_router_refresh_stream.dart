import 'dart:async';

import 'package:flutter/foundation.dart';

/// Listens to one or more streams and notifies GoRouter to re-run redirect.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream)
      : this.merged([stream]);

  GoRouterRefreshStream.merged(List<Stream<dynamic>> streams) {
    notifyListeners();
    _subscriptions = streams
        .map((s) => s.asBroadcastStream().listen((_) => notifyListeners()))
        .toList();
  }

  late final List<StreamSubscription<dynamic>> _subscriptions;

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
