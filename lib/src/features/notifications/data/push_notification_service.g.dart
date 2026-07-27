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

@ProviderFor(pushNotificationService)
const pushNotificationServiceProvider = PushNotificationServiceProvider._();

final class PushNotificationServiceProvider
    extends
        $FunctionalProvider<
          PushNotificationService,
          PushNotificationService,
          PushNotificationService
        >
    with $Provider<PushNotificationService> {
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

/// Initialize push notifications when user is signed in.

@ProviderFor(initPushNotifications)
const initPushNotificationsProvider = InitPushNotificationsProvider._();

/// Initialize push notifications when user is signed in.

final class InitPushNotificationsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Initialize push notifications when user is signed in.
  const InitPushNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initPushNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initPushNotificationsHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return initPushNotifications(ref);
  }
}

String _$initPushNotificationsHash() =>
    r'abc9f55a072663518c8099e159bd3805cb775b40';
