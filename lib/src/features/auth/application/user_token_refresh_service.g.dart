// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token_refresh_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userTokenRefreshService)
const userTokenRefreshServiceProvider = UserTokenRefreshServiceProvider._();

final class UserTokenRefreshServiceProvider
    extends
        $FunctionalProvider<
          UserTokenRefreshService,
          UserTokenRefreshService,
          UserTokenRefreshService
        >
    with $Provider<UserTokenRefreshService> {
  const UserTokenRefreshServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userTokenRefreshServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userTokenRefreshServiceHash();

  @$internal
  @override
  $ProviderElement<UserTokenRefreshService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserTokenRefreshService create(Ref ref) {
    return userTokenRefreshService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserTokenRefreshService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserTokenRefreshService>(value),
    );
  }
}

String _$userTokenRefreshServiceHash() =>
    r'176c7d5e2f0dfb70602171f81f45b0651f52c0ae';
