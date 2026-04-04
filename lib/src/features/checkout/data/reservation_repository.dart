import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reservation_repository.g.dart';

class CreateReservationResult {
  final String reservationId;
  final String paymentIntentClientSecret;
  final String ephemeralKey;
  final String stripeCustomerId;

  CreateReservationResult({
    required this.reservationId,
    required this.paymentIntentClientSecret,
    required this.ephemeralKey,
    required this.stripeCustomerId,
  });
}

class ReservationRepository {
  final FirebaseFunctions _functions;

  ReservationRepository(this._functions);

  Future<CreateReservationResult> createReservation({
    required String offerId,
    required int quantity,
  }) async {
    final callable = _functions.httpsCallable('createReservation');
    final result = await callable.call<Map<String, dynamic>>({
      'offerId': offerId,
      'quantity': quantity,
    });
    final data = result.data;
    return CreateReservationResult(
      reservationId: data['reservationId'] as String,
      paymentIntentClientSecret: data['paymentIntentClientSecret'] as String,
      ephemeralKey: data['ephemeralKey'] as String,
      stripeCustomerId: data['stripeCustomerId'] as String,
    );
  }
}

@riverpod
ReservationRepository reservationRepository(Ref ref) {
  return ReservationRepository(FirebaseFunctions.instance);
}
