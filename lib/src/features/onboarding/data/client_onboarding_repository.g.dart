// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_onboarding_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientOnboardingRepository)
const clientOnboardingRepositoryProvider =
    ClientOnboardingRepositoryProvider._();

final class ClientOnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClientOnboardingRepository>,
          ClientOnboardingRepository,
          FutureOr<ClientOnboardingRepository>
        >
    with
        $FutureModifier<ClientOnboardingRepository>,
        $FutureProvider<ClientOnboardingRepository> {
  const ClientOnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientOnboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientOnboardingRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ClientOnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClientOnboardingRepository> create(Ref ref) {
    return clientOnboardingRepository(ref);
  }
}

String _$clientOnboardingRepositoryHash() =>
    r'bf712ab3138d72a37709685bb6f5a8338136d084';
