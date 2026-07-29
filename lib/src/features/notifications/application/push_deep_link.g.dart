// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_deep_link.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The deep link a tapped push is waiting to apply, or `null` if none is
/// pending. Survives across the app's whole session (`keepAlive`) so a tap
/// from a background/terminated state reaches the router once it is ready.

@ProviderFor(PendingDeepLink)
const pendingDeepLinkProvider = PendingDeepLinkProvider._();

/// The deep link a tapped push is waiting to apply, or `null` if none is
/// pending. Survives across the app's whole session (`keepAlive`) so a tap
/// from a background/terminated state reaches the router once it is ready.
final class PendingDeepLinkProvider
    extends $NotifierProvider<PendingDeepLink, PushDeepLinkTarget?> {
  /// The deep link a tapped push is waiting to apply, or `null` if none is
  /// pending. Survives across the app's whole session (`keepAlive`) so a tap
  /// from a background/terminated state reaches the router once it is ready.
  const PendingDeepLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingDeepLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingDeepLinkHash();

  @$internal
  @override
  PendingDeepLink create() => PendingDeepLink();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushDeepLinkTarget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushDeepLinkTarget?>(value),
    );
  }
}

String _$pendingDeepLinkHash() => r'90ebda3ea9d646ef1a4f260b8c4b9ae6427324bf';

/// The deep link a tapped push is waiting to apply, or `null` if none is
/// pending. Survives across the app's whole session (`keepAlive`) so a tap
/// from a background/terminated state reaches the router once it is ready.

abstract class _$PendingDeepLink extends $Notifier<PushDeepLinkTarget?> {
  PushDeepLinkTarget? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PushDeepLinkTarget?, PushDeepLinkTarget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PushDeepLinkTarget?, PushDeepLinkTarget?>,
              PushDeepLinkTarget?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
