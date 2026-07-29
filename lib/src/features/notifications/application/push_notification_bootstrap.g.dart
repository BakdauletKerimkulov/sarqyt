// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_bootstrap.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Registers the FCM message listeners exactly once per app session and
/// requests permission/tokens whenever the signed-in user changes.
///
/// Listener registration lives here rather than in `PushNotificationService`
/// (`data/`) so the one-time guarantee (R14) can depend on the
/// `pendingDeepLinkProvider` (`application/`) without `data/` importing
/// `application/` (architecture.md dependency direction).

@ProviderFor(PushNotificationBootstrap)
const pushNotificationBootstrapProvider = PushNotificationBootstrapProvider._();

/// Registers the FCM message listeners exactly once per app session and
/// requests permission/tokens whenever the signed-in user changes.
///
/// Listener registration lives here rather than in `PushNotificationService`
/// (`data/`) so the one-time guarantee (R14) can depend on the
/// `pendingDeepLinkProvider` (`application/`) without `data/` importing
/// `application/` (architecture.md dependency direction).
final class PushNotificationBootstrapProvider
    extends $NotifierProvider<PushNotificationBootstrap, void> {
  /// Registers the FCM message listeners exactly once per app session and
  /// requests permission/tokens whenever the signed-in user changes.
  ///
  /// Listener registration lives here rather than in `PushNotificationService`
  /// (`data/`) so the one-time guarantee (R14) can depend on the
  /// `pendingDeepLinkProvider` (`application/`) without `data/` importing
  /// `application/` (architecture.md dependency direction).
  const PushNotificationBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationBootstrapHash();

  @$internal
  @override
  PushNotificationBootstrap create() => PushNotificationBootstrap();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pushNotificationBootstrapHash() =>
    r'0dab716e8a4eeca5cf2e5ec073dacbcf9a944abc';

/// Registers the FCM message listeners exactly once per app session and
/// requests permission/tokens whenever the signed-in user changes.
///
/// Listener registration lives here rather than in `PushNotificationService`
/// (`data/`) so the one-time guarantee (R14) can depend on the
/// `pendingDeepLinkProvider` (`application/`) without `data/` importing
/// `application/` (architecture.md dependency direction).

abstract class _$PushNotificationBootstrap extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// Requests permission and (re)saves the FCM token when the signed-in user
/// changes. Message-listener registration is handled separately (above) so
/// it is not repeated on every emission.

@ProviderFor(initPushNotifications)
const initPushNotificationsProvider = InitPushNotificationsProvider._();

/// Requests permission and (re)saves the FCM token when the signed-in user
/// changes. Message-listener registration is handled separately (above) so
/// it is not repeated on every emission.

final class InitPushNotificationsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Requests permission and (re)saves the FCM token when the signed-in user
  /// changes. Message-listener registration is handled separately (above) so
  /// it is not repeated on every emission.
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
    r'ab32ed0b4040b7734fc1e0b9282233e8b212eaa5';
