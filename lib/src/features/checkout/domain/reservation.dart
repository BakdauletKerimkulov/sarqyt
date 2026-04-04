import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/converters.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

typedef ReservationID = String;

enum ReservationStatus { pending, paid, expired, cancelled }

@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required ReservationID id,
    required OfferID offerId,
    required StoreID storeId,
    required UserID customerId,
    required OfferID itemId,
    required String itemName,
    required String storeName,
    String? itemImageUrl,
    required double unitPrice,
    @Default('KZT') String currencyCode,
    @Default('\u20B8') String currencySymbol,
    required int quantity,
    required ReservationStatus status,
    String? paymentIntentId,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime expiresAt,
  }) = _Reservation;

  const Reservation._();

  double get totalPrice => unitPrice * quantity;

  bool get isPending => status == ReservationStatus.pending;
  bool get isPaid => status == ReservationStatus.paid;
  bool get isExpired => status == ReservationStatus.expired;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}
