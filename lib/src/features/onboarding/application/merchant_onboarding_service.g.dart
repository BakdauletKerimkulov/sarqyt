// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_onboarding_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(merchantOnboardingService)
const merchantOnboardingServiceProvider = MerchantOnboardingServiceProvider._();

final class MerchantOnboardingServiceProvider
    extends
        $FunctionalProvider<
          MerchantOnboardingService,
          MerchantOnboardingService,
          MerchantOnboardingService
        >
    with $Provider<MerchantOnboardingService> {
  const MerchantOnboardingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'merchantOnboardingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$merchantOnboardingServiceHash();

  @$internal
  @override
  $ProviderElement<MerchantOnboardingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MerchantOnboardingService create(Ref ref) {
    return merchantOnboardingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MerchantOnboardingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MerchantOnboardingService>(value),
    );
  }
}

String _$merchantOnboardingServiceHash() =>
    r'7b2f758f84c0ec630345a49044bb2ba1d06c5e5c';
