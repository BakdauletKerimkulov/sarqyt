// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_offer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(businessOfferRepository)
const businessOfferRepositoryProvider = BusinessOfferRepositoryProvider._();

final class BusinessOfferRepositoryProvider
    extends
        $FunctionalProvider<
          BusinessOfferRepository,
          BusinessOfferRepository,
          BusinessOfferRepository
        >
    with $Provider<BusinessOfferRepository> {
  const BusinessOfferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessOfferRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessOfferRepositoryHash();

  @$internal
  @override
  $ProviderElement<BusinessOfferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BusinessOfferRepository create(Ref ref) {
    return businessOfferRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessOfferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessOfferRepository>(value),
    );
  }
}

String _$businessOfferRepositoryHash() =>
    r'8f9bd6420a24d6e3a4403212d50f9f791f93541f';
