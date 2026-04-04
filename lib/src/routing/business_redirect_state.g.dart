// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_redirect_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single provider that aggregates all data needed for business redirect.
/// Redirect reads this synchronously — no async in redirect callback.

@ProviderFor(businessRedirectState)
const businessRedirectStateProvider = BusinessRedirectStateProvider._();

/// Single provider that aggregates all data needed for business redirect.
/// Redirect reads this synchronously — no async in redirect callback.

final class BusinessRedirectStateProvider
    extends
        $FunctionalProvider<
          BusinessRedirectState,
          BusinessRedirectState,
          BusinessRedirectState
        >
    with $Provider<BusinessRedirectState> {
  /// Single provider that aggregates all data needed for business redirect.
  /// Redirect reads this synchronously — no async in redirect callback.
  const BusinessRedirectStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessRedirectStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessRedirectStateHash();

  @$internal
  @override
  $ProviderElement<BusinessRedirectState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BusinessRedirectState create(Ref ref) {
    return businessRedirectState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessRedirectState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessRedirectState>(value),
    );
  }
}

String _$businessRedirectStateHash() =>
    r'fc573f9a4bbdf47a3afb23d9d00819dbb6947b77';
