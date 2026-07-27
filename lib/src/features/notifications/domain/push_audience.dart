/// Which of the two apps this build is, for push-notification purposes.
///
/// The two entry points share one Firebase user, so they must not overwrite
/// each other's FCM token: each writes its own field on `users/{uid}` and the
/// server picks the field matching the notification's audience.
enum PushAudience {
  client('fcmTokenClient'),
  business('fcmTokenBusiness');

  const PushAudience(this.tokenField);

  /// Field on `users/{uid}` this app stores its FCM token in.
  final String tokenField;
}
