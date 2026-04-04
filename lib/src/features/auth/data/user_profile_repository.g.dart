// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfileRepository)
const userProfileRepositoryProvider = UserProfileRepositoryProvider._();

final class UserProfileRepositoryProvider
    extends
        $FunctionalProvider<
          UserProfileRepository,
          UserProfileRepository,
          UserProfileRepository
        >
    with $Provider<UserProfileRepository> {
  const UserProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileRepository create(Ref ref) {
    return userProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileRepository>(value),
    );
  }
}

String _$userProfileRepositoryHash() =>
    r'9888fa450b39aad4384083ed30f8a4ae33168c7e';

@ProviderFor(userProfileStream)
const userProfileStreamProvider = UserProfileStreamFamily._();

final class UserProfileStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          Stream<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $StreamProvider<Map<String, dynamic>?> {
  const UserProfileStreamProvider._({
    required UserProfileStreamFamily super.from,
    required UserID super.argument,
  }) : super(
         retry: null,
         name: r'userProfileStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileStreamHash();

  @override
  String toString() {
    return r'userProfileStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, dynamic>?> create(Ref ref) {
    final argument = this.argument as UserID;
    return userProfileStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileStreamHash() => r'7d10e1ddba7053b21d78cff05fc2389b19517e70';

final class UserProfileStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, dynamic>?>, UserID> {
  const UserProfileStreamFamily._()
    : super(
        retry: null,
        name: r'userProfileStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserProfileStreamProvider call(UserID uid) =>
      UserProfileStreamProvider._(argument: uid, from: this);

  @override
  String toString() => r'userProfileStreamProvider';
}
