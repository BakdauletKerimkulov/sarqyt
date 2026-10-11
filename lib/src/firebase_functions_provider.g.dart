// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_functions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single [FirebaseFunctions] instance the app talks to.
///
/// Repositories take it by constructor injection; nothing else reaches for
/// the SDK's default instance directly.
///
/// Lives outside `app_bootstrap_firebase.dart` on purpose: `data/`
/// repositories depend on this provider, and the bootstrap layer depends on
/// `data/` — putting it there would close an import cycle.

@ProviderFor(firebaseFunctions)
const firebaseFunctionsProvider = FirebaseFunctionsProvider._();

/// The single [FirebaseFunctions] instance the app talks to.
///
/// Repositories take it by constructor injection; nothing else reaches for
/// the SDK's default instance directly.
///
/// Lives outside `app_bootstrap_firebase.dart` on purpose: `data/`
/// repositories depend on this provider, and the bootstrap layer depends on
/// `data/` — putting it there would close an import cycle.

final class FirebaseFunctionsProvider
    extends
        $FunctionalProvider<
          FirebaseFunctions,
          FirebaseFunctions,
          FirebaseFunctions
        >
    with $Provider<FirebaseFunctions> {
  /// The single [FirebaseFunctions] instance the app talks to.
  ///
  /// Repositories take it by constructor injection; nothing else reaches for
  /// the SDK's default instance directly.
  ///
  /// Lives outside `app_bootstrap_firebase.dart` on purpose: `data/`
  /// repositories depend on this provider, and the bootstrap layer depends on
  /// `data/` — putting it there would close an import cycle.
  const FirebaseFunctionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseFunctionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseFunctionsHash();

  @$internal
  @override
  $ProviderElement<FirebaseFunctions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFunctions create(Ref ref) {
    return firebaseFunctions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFunctions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFunctions>(value),
    );
  }
}

String _$firebaseFunctionsHash() => r'866fd6d7269bd3d4fe3001f6c1fc7e4da7e6eb0d';
