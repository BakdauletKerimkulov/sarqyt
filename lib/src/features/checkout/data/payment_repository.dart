import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/firebase_functions_provider.dart';

part 'payment_repository.g.dart';

class PaymentRepository {
  final FirebaseFunctions _functions;

  PaymentRepository(this._functions);

  /// Reserve without payment — creates order directly.
  /// [idempotencyKey] must be stable across retries for the same attempt.
  Future<String> reserveOffer({
    required String offerId,
    required int quantity,
    required String idempotencyKey,
  }) async {
    final callable = _functions.httpsCallable(
      'reserveOffer',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    final result = await callable.call({
      'offerId': offerId,
      'quantity': quantity,
      'idempotencyKey': idempotencyKey,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['orderId'] as String;
  }
}

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(ref.watch(firebaseFunctionsProvider));
}
