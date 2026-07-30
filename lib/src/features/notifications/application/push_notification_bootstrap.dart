import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/notifications/application/push_deep_link.dart';
import 'package:sarqyt/src/features/notifications/data/push_notification_service.dart';
import 'package:sarqyt/src/features/notifications/domain/push_audience.dart';

part 'push_notification_bootstrap.g.dart';

/// Registers the FCM message listeners exactly once per app session and
/// requests permission/tokens whenever the signed-in user changes.
///
/// Listener registration lives here rather than in `PushNotificationService`
/// (`data/`) so the one-time guarantee (R14) can depend on the
/// `pendingDeepLinkProvider` (`application/`) without `data/` importing
/// `application/` (architecture.md dependency direction).
@Riverpod(keepAlive: true)
class PushNotificationBootstrap extends _$PushNotificationBootstrap {
  @override
  void build() {
    final audience = ref.watch(pushAudienceProvider);
    final pendingDeepLink = ref.read(pendingDeepLinkProvider.notifier);

    // This provider's build() runs once for the whole app session — unlike
    // initialize() below, which re-runs on every authStateChanges emission
    // and must not touch these listeners (R14).
    final onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      log('FCM foreground: ${message.notification?.title}');
    });
    final onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      _handleIncomingMessage(message, audience, pendingDeepLink);
    });
    ref.onDispose(() {
      onMessageSub.cancel();
      onMessageOpenedSub.cancel();
    });

    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        _handleIncomingMessage(initialMessage, audience, pendingDeepLink);
      }
    });
  }
}

/// Maps a tapped/opened message to a deep link and records it as pending.
/// Never throws: an unknown or malformed payload just navigates nowhere.
void _handleIncomingMessage(
  RemoteMessage message,
  PushAudience audience,
  PendingDeepLink pendingDeepLink,
) {
  final target = mapPushToDeepLink(
    audience: audience,
    type: message.data['type'] as String?,
    data: message.data.map((key, value) => MapEntry(key, value.toString())),
  );
  if (target == null) {
    log('Push tap ignored: unmapped payload ${message.data}');
    return;
  }
  pendingDeepLink.set(target);
}

/// Requests permission and (re)saves the FCM token when the signed-in user
/// changes. Message-listener registration is handled separately (above) so
/// it is not repeated on every emission.
@Riverpod(keepAlive: true)
Future<void> initPushNotifications(Ref ref) async {
  ref.read(pushNotificationBootstrapProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return;
  await ref.read(pushNotificationServiceProvider).initialize(user.uid);
}
