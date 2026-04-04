import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
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
    required int foodRating,
    String? comment,
  }) async {
    final docRef = _firestore.collection('reviews').doc();
    await docRef.set({
      'id': docRef.id,
      'orderId': orderId,
      'storeId': storeId,
      'userId': userId,
      'storeRating': storeRating,
      'foodRating': foodRating,
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

  Stream<List<Review>> watchStoreReviews(StoreID storeId) {
    return _firestore
        .collection('reviews')
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
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
