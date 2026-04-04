// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_button_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentButtonController)
const paymentButtonControllerProvider = PaymentButtonControllerProvider._();

final class PaymentButtonControllerProvider
    extends $AsyncNotifierProvider<PaymentButtonController, void> {
  const PaymentButtonControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentButtonControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentButtonControllerHash();

  @$internal
  @override
  PaymentButtonController create() => PaymentButtonController();
}

String _$paymentButtonControllerHash() =>
    r'1d1020ba3aa7a51396afe085664db14a0f5b27f9';

abstract class _$PaymentButtonController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
