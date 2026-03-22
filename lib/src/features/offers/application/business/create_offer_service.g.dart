// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_offer_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(createOfferService)
const createOfferServiceProvider = CreateOfferServiceProvider._();

final class CreateOfferServiceProvider
    extends
        $FunctionalProvider<
          CreateOfferService,
          CreateOfferService,
          CreateOfferService
        >
    with $Provider<CreateOfferService> {
  const CreateOfferServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createOfferServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createOfferServiceHash();

  @$internal
  @override
  $ProviderElement<CreateOfferService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateOfferService create(Ref ref) {
    return createOfferService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateOfferService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateOfferService>(value),
    );
  }
}

String _$createOfferServiceHash() =>
    r'49249674a57169b00bf48e9acb6425dad56a0ee6';
