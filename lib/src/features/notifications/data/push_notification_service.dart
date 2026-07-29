import 'dart:developer';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/notifications/domain/push_audience.dart';

part 'push_notification_service.g.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('FCM background: ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final PushAudience _audience;

  PushNotificationService(this._messaging, this._firestore, this._audience);

  Future<void> initialize(String? uid) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      log('Push notifications not authorized');
      return;
    }

    // On iOS the APNs token must be available before requesting an FCM token.
    if (!kIsWeb && Platform.isIOS) {
      await _messaging.getAPNSToken();
    }

    final token = await _messaging.getToken();
    if (token != null && uid != null) {
      await _saveToken(uid, token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      if (uid != null) _saveToken(uid, newToken);
    });
  }

  /// Writes the token to this app's own field plus the legacy shared one.
  ///
  /// The legacy `fcmToken` keeps builds that predate the split working; it is
  /// dropped once both apps have rolled out.
  Future<void> _saveToken(String uid, String token) {
    return _firestore.collection('users').doc(uid).set({
      _audience.tokenField: token,
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}

/// Which app this build is. Overridden per entry point in `main*.dart`.
@Riverpod(keepAlive: true)
PushAudience pushAudience(Ref ref) {
  throw UnimplementedError('pushAudienceProvider must be overridden');
}

/// Registers the FCM background handler and constructs the service.
///
/// One-time message-listener registration (R14) lives in
/// `application/push_notification_bootstrap.dart`, which depends on this
/// service — keeping that dependency out of `data/` (architecture.md: `data/`
/// must not import `application/`).
@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  return PushNotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
    ref.watch(pushAudienceProvider),
  );
}
