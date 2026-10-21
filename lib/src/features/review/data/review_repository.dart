import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/review/domain/review.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'review_repository.g.dart';

class ReviewRepository {
  const ReviewRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> submitReview({
    required OrderID orderId,
    required StoreID storeId,
    required UserID userId,
    required int storeRating,
    required int offerRating,
    ItemID? itemId,
    String? comment,
  }) async {
    // Deterministic ID: one review per order, enforced by firestore.rules
    // (create requires orderId == doc id; a second attempt becomes an
    // update, restricted to the review's own owner).
    final docRef = _firestore.collection('reviews').doc(orderId);
    await docRef.set({
      'id': docRef.id,
      'orderId': orderId,
      'storeId': storeId,
      'userId': userId,
      if (itemId != null) 'itemId': itemId,
      'storeRating': storeRating,
      'offerRating': offerRating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> hasReviewForOrder(OrderID orderId) async {
    final snap = await _firestore
        .collection('reviews')
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Stream<List<Review>> watchStoreReviews(StoreID storeId, {int? limit}) {
    var query = _firestore
        .collection('reviews')
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query
        .withConverter(
          fromFirestore: (doc, _) => Review.fromJson(doc.data()!),
          toFirestore: (Review r, _) => r.toJson(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Review>> watchItemReviews(ItemID itemId, {int? limit}) {
    var query = _firestore
        .collection('reviews')
        .where('itemId', isEqualTo: itemId)
        .orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query
        .withConverter(
          fromFirestore: (doc, _) => Review.fromJson(doc.data()!),
          toFirestore: (Review r, _) => r.toJson(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}

@Riverpod(keepAlive: true)
ReviewRepository reviewRepository(Ref ref) {
  return ReviewRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Review>> itemReviewsStream(Ref ref, ItemID itemId) {
  return ref.watch(reviewRepositoryProvider).watchItemReviews(itemId);
}
