import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_repository.g.dart';

class CreatePaymentResult {
  final String paymentIntentId;
  final String paymentIntentClientSecret;
  final String ephemeralKey;
  final String stripeCustomerId;

  CreatePaymentResult({
    required this.paymentIntentId,
    required this.paymentIntentClientSecret,
    required this.ephemeralKey,
    required this.stripeCustomerId,
  });
}

class PaymentRepository {
  final FirebaseFunctions _functions;

  PaymentRepository(this._functions);

  /// Reserve without payment — creates order directly. For testing.
  Future<String> reserveOffer({
    required String offerId,
    required int quantity,
  }) async {
    final callable = _functions.httpsCallable(
      'reserveOffer',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    final result = await callable.call({
      'offerId': offerId,
      'quantity': quantity,
    });
    debugPrint('reserveOffer result: ${result.data}');
    debugPrint('reserveOffer type: ${result.data.runtimeType}');
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['orderId'] as String;
  }

  Future<CreatePaymentResult> createPayment({
    required String offerId,
    required int quantity,
  }) async {
    final callable = _functions.httpsCallable('createPayment');
    final result = await callable.call<Map<String, dynamic>>({
      'offerId': offerId,
      'quantity': quantity,
    });
    final data = result.data;
    return CreatePaymentResult(
      paymentIntentId: data['paymentIntentId'] as String,
      paymentIntentClientSecret: data['paymentIntentClientSecret'] as String,
      ephemeralKey: data['ephemeralKey'] as String,
      stripeCustomerId: data['stripeCustomerId'] as String,
    );
  }
}

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(FirebaseFunctions.instance);
}
