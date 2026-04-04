import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';

part 'push_notification_service.g.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  PushNotificationService(this._messaging, this._firestore);

  Future<void> initialize(String? uid) async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      log('Push notifications not authorized');
      return;
    }

    final token = await _messaging.getToken();
    if (token != null && uid != null) {
      await _saveToken(uid, token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      if (uid != null) _saveToken(uid, newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      log('FCM foreground: ${message.notification?.title}');
    });
  }

  Future<void> _saveToken(String uid, String token) {
    return _firestore.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }
}

@riverpod
PushNotificationService pushNotificationService(Ref ref) {
  return PushNotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
  );
}

/// Initialize push notifications when user is signed in.
@riverpod
Future<void> initPushNotifications(Ref ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return;
  await ref.read(pushNotificationServiceProvider).initialize(user.uid);
}
