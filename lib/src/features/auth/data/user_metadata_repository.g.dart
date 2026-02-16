// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_metadata_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userMetadataRepository)
const userMetadataRepositoryProvider = UserMetadataRepositoryProvider._();

final class UserMetadataRepositoryProvider
    extends
        $FunctionalProvider<
          UserMetadataRepository,
          UserMetadataRepository,
          UserMetadataRepository
        >
    with $Provider<UserMetadataRepository> {
  const UserMetadataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userMetadataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userMetadataRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserMetadataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserMetadataRepository create(Ref ref) {
    return userMetadataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserMetadataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserMetadataRepository>(value),
    );
  }
}

String _$userMetadataRepositoryHash() =>
    r'4c3854c56e4e0296c229730d6ea44e8c7d2a10f4';
