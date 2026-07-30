import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/features/notifications/application/push_deep_link.dart';
import 'package:sarqyt/src/features/notifications/domain/push_deep_link_target.dart';

/// Applies a pending push-notification deep link once the router accepts it.
///
/// Redirect guards (auth restore, role/store loading) may still be steering
/// the router away from the target right after a cold start, so this retries
/// on a short interval instead of navigating once — see `businessRedirect`
/// in `business_router.dart` for the guard chain a deep link may race
/// against. Gives up and drops the link after 30 seconds (spec 034, R14).
class DeepLinkApplier extends ConsumerStatefulWidget {
  const DeepLinkApplier({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<DeepLinkApplier> createState() => _DeepLinkApplierState();
}

class _DeepLinkApplierState extends ConsumerState<DeepLinkApplier> {
  static const _retryInterval = Duration(milliseconds: 300);
  static const _dropAfter = Duration(seconds: 30);

  Timer? _retryTimer;
  DateTime? _pendingSince;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _scheduleAttempts() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(_retryInterval, (_) => _attempt());
    _attempt();
  }

  void _attempt() {
    final target = ref.read(pendingDeepLinkProvider);
    if (target == null) {
      _stopRetrying();
      return;
    }

    _pendingSince ??= DateTime.now();
    if (DateTime.now().difference(_pendingSince!) > _dropAfter) {
      log('Deep link dropped after timeout: ${target.routeName}');
      ref.read(pendingDeepLinkProvider.notifier).clear();
      _stopRetrying();
      return;
    }

    widget.router.goNamed(
      target.routeName,
      pathParameters: target.pathParameters,
      queryParameters: target.queryParameters,
    );

    if (_arrivedAt(target)) {
      ref.read(pendingDeepLinkProvider.notifier).clear();
      _stopRetrying();
    }
  }

  bool _arrivedAt(PushDeepLinkTarget target) {
    final expectedPath = Uri.parse(
      widget.router.namedLocation(
        target.routeName,
        pathParameters: target.pathParameters,
      ),
    ).path;
    final currentPath =
        widget.router.routerDelegate.currentConfiguration.uri.path;
    return currentPath == expectedPath;
  }

  void _stopRetrying() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _pendingSince = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingDeepLinkProvider, (previous, next) {
      if (next != null) _scheduleAttempts();
    });

    // A deep link may already be pending by first build (cold-start
    // getInitialMessage resolves asynchronously) — ref.listen only reacts
    // to changes after this point, so check once for that race.
    if (_retryTimer == null && ref.read(pendingDeepLinkProvider) != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleAttempts());
    }

    return widget.child;
  }
}
