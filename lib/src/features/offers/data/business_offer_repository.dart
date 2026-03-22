import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

part 'business_offer_repository.g.dart';

class BusinessOfferRepository {
  const BusinessOfferRepository(this._functions, this._firestore);
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  Future<void> createOffer(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable("createOffer");

    final result = await callable.call(data);
    log(result.data.toString());
  }

  /// Sync offers for the next 7 days based on item schedule.
  Future<void> syncItemOffers({
    required String storeId,
    required String itemId,
  }) async {
    final callable = _functions.httpsCallable("sincItemOffers");
    final result = await callable.call({
      'storeId': storeId,
      'itemId': itemId,
    });
    log(result.data.toString());
  }

  /// Stream of active offers for a given store.
  Stream<List<Offer>> watchStoreActiveOffers(String storeId) {
    return _firestore
        .collection('offers')
        .where('storeId', isEqualTo: storeId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
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
  return repo.watchStoreActiveOffers(storeId).map(
    (offers) => offers.map((o) => o.productId).toSet(),
  );
}
