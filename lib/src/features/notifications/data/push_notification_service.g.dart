// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which app this build is. Overridden per entry point in `main*.dart`.

@ProviderFor(pushAudience)
const pushAudienceProvider = PushAudienceProvider._();

/// Which app this build is. Overridden per entry point in `main*.dart`.

final class PushAudienceProvider
    extends $FunctionalProvider<PushAudience, PushAudience, PushAudience>
    with $Provider<PushAudience> {
  /// Which app this build is. Overridden per entry point in `main*.dart`.
  const PushAudienceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushAudienceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushAudienceHash();

  @$internal
  @override
  $ProviderElement<PushAudience> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushAudience create(Ref ref) {
    return pushAudience(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushAudience value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushAudience>(value),
    );
  }
}

String _$pushAudienceHash() => r'815a6f0ab111f6db29557192a477c4441d49b2cd';

/// Registers the FCM background handler and constructs the service.
///
/// One-time message-listener registration (R14) lives in
/// `application/push_notification_bootstrap.dart`, which depends on this
/// service — keeping that dependency out of `data/` (architecture.md: `data/`
/// must not import `application/`).

@ProviderFor(pushNotificationService)
const pushNotificationServiceProvider = PushNotificationServiceProvider._();

/// Registers the FCM background handler and constructs the service.
///
/// One-time message-listener registration (R14) lives in
/// `application/push_notification_bootstrap.dart`, which depends on this
/// service — keeping that dependency out of `data/` (architecture.md: `data/`
/// must not import `application/`).

final class PushNotificationServiceProvider
    extends
        $FunctionalProvider<
          PushNotificationService,
          PushNotificationService,
          PushNotificationService
        >
    with $Provider<PushNotificationService> {
  /// Registers the FCM background handler and constructs the service.
  ///
  /// One-time message-listener registration (R14) lives in
  /// `application/push_notification_bootstrap.dart`, which depends on this
  /// service — keeping that dependency out of `data/` (architecture.md: `data/`
  /// must not import `application/`).
  const PushNotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<PushNotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushNotificationService create(Ref ref) {
    return pushNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushNotificationService>(value),
    );
  }
}

String _$pushNotificationServiceHash() =>
    r'e8e3710f4f52ccec73338b5c7d008fe7bcd63ec9';
