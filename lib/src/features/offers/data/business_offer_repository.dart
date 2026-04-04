import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart' hide OfferID;

part 'business_offer_repository.g.dart';

class BusinessOfferRepository {
  const BusinessOfferRepository(this._functions, this._firestore);
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  /// Sync offers for the next 7 days based on item schedule.
  Future<void> syncItemOffers({
    required String storeId,
    required String itemId,
  }) async {
    final callable = _functions.httpsCallable("sincItemOffers");
    final result = await callable.call({'storeId': storeId, 'itemId': itemId});
    log(result.data.toString());
  }

  /// Create a one-time offer for a specific date and time window.
  Future<void> createOneTimeOffer({
    required String storeId,
    required String name,
    required double price,
    required String date,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int quantity,
  }) async {
    final callable = _functions.httpsCallable("createOneTimeOffer");
    await callable.call({
      'storeId': storeId,
      'name': name,
      'price': price,
      'date': date,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'quantity': quantity,
    });
  }

  /// Stream of active offers for a given store.
  Stream<List<Offer>> watchStoreActiveOffers(String storeId) {
    return _firestore
        .collection('offers')
        .where('storeId', isEqualTo: storeId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return Offer.fromJson(data);
          }).toList(),
        );
  }
}

@riverpod
BusinessOfferRepository businessOfferRepository(Ref ref) {
  return BusinessOfferRepository(
    FirebaseFunctions.instance,
    FirebaseFirestore.instance,
  );
}

/// Stream of active item IDs (productId) for a given store.
@riverpod
Stream<Set<ItemID>> storeActiveOfferItemIds(Ref ref, String storeId) {
  final repo = ref.watch(businessOfferRepositoryProvider);
  return repo
      .watchStoreActiveOffers(storeId)
      .map((offers) => offers.map((o) => o.productId).toSet());
}
