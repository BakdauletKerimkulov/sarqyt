import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_sheet_repository.g.dart';

class PaymentSheetRepository {
  Future<void> initPaymentSheet({
    required String paymentIntentClientSecret,
    required String ephemeralKey,
    required String stripeCustomerId,
    required String merchantDisplayName,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        customerEphemeralKeySecret: ephemeralKey,
        customerId: stripeCustomerId,
        merchantDisplayName: merchantDisplayName,
        style: ThemeMode.system,
        appearance: const PaymentSheetAppearance(
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
          ),
        ),
      ),
    );
  }

  /// Returns true if payment completed, false if user cancelled.
  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      rethrow;
    }
  }
}

@riverpod
PaymentSheetRepository paymentSheetRepository(Ref ref) {
  return PaymentSheetRepository();
}
