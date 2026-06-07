import 'dart:developer';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';

part 'push_notification_service.g.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('FCM background: ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  PushNotificationService(this._messaging, this._firestore);

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

    FirebaseMessaging.onMessage.listen((message) {
      log('FCM foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('FCM opened from background: ${message.data}');
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      log('FCM opened from terminated: ${initialMessage.data}');
    }
  }

  Future<void> _saveToken(String uid, String token) {
    return _firestore.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }
}

@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  return PushNotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
  );
}

/// Initialize push notifications when user is signed in.
@Riverpod(keepAlive: true)
Future<void> initPushNotifications(Ref ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return;
  await ref.read(pushNotificationServiceProvider).initialize(user.uid);
}
