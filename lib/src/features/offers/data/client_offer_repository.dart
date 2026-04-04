import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

part 'client_offer_repository.g.dart';

class ClientOfferRepository {
  const ClientOfferRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String offersPath() => 'offers';
  static String offerPath(String id) => 'offers/$id';

  Stream<List<Offer>> watchAllOffer({
    double latitude = 0.0,
    double longitude = 0.0,
    double radius = 10,
    List<String> itemCategories = const [],
    String? pickupEarliest,
    String? pickupLatest,
    bool hiddenOnly = false,
    bool weCareOnly = false,
  }) {
    final now = DateTime.now();
    final nowTs = Timestamp.fromDate(now);

    final ref = _firestore
        .collection(offersPath())
        .where('status', isEqualTo: OfferStatus.active.name)
        .where('pickupEndTime', isGreaterThan: nowTs)
        .orderBy('pickupEndTime')
        .withConverter(
          fromFirestore: (doc, _) => Offer.fromJson(doc.data()!),
          toFirestore: (Offer offer, _) => offer.toJson(),
        );

    return ref.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Future<List<Offer>> fetchAllOffer({
    double latitude = 0.0,
    double longitude = 0.0,
    double radius = 10,
    List<String> itemCategories = const [],
    String? pickupEarliest,
    String? pickupLatest,
    bool hiddenOnly = false,
    bool weCareOnly = false,
  }) async {
    final now = DateTime.now();
    final nowTs = Timestamp.fromDate(now);

    // Firestore allows range filters on only ONE field.
    // Use equality on status + range on pickupEndTime (must be in the future).
    // Filter visibleFrom client-side.
    final ref = _firestore
        .collection(offersPath())
        .where('status', isEqualTo: OfferStatus.active.name)
        .where('pickupEndTime', isGreaterThan: nowTs)
        .orderBy('pickupEndTime')
        .withConverter(
          fromFirestore: (doc, _) => Offer.fromJson(doc.data()!),
          toFirestore: (Offer offer, _) => offer.toJson(),
        );

    final snapshot = await ref.get();
    final offers = snapshot.docs
        .map((doc) => doc.data())
        .where((o) => o.visibleFrom == null || !o.visibleFrom!.isAfter(now))
        .toList();
    offers.sort((a, b) => a.pickupStartTime.compareTo(b.pickupStartTime));
    return offers;
  }

  Future<Offer?> getOfferById(String id) async {
    final ref = _offerRef(id);
    final snapshot = await ref.get();
    return snapshot.data();
  }

  DocumentReference<Offer> _offerRef(OfferID id) => _firestore
      .doc(offerPath(id))
      .withConverter(
        fromFirestore: (doc, _) => Offer.fromJson(doc.data()!),
        toFirestore: (Offer offer, _) => offer.toJson(),
      );
}

@riverpod
ClientOfferRepository offerRepository(Ref ref) => throw UnimplementedError();

@riverpod
FutureOr<List<Offer>> offersListFuture(Ref ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.fetchAllOffer();
}

@riverpod
Stream<List<Offer>> offersListStream(Ref ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.watchAllOffer();
}

@riverpod
FutureOr<Offer?> offerFuture(Ref ref, String id) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getOfferById(id);
}
