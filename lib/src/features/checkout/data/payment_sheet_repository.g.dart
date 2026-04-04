// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_sheet_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentSheetRepository)
const paymentSheetRepositoryProvider = PaymentSheetRepositoryProvider._();

final class PaymentSheetRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentSheetRepository,
          PaymentSheetRepository,
          PaymentSheetRepository
        >
    with $Provider<PaymentSheetRepository> {
  const PaymentSheetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentSheetRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentSheetRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentSheetRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentSheetRepository create(Ref ref) {
    return paymentSheetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentSheetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentSheetRepository>(value),
    );
  }
}

String _$paymentSheetRepositoryHash() =>
    r'87cbd465ee228dcb18bb9a2f2ead599bbeaaafb6';
