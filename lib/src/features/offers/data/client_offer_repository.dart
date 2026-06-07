import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

part 'client_offer_repository.g.dart';

/// Geohash precision → approximate cell size (lat × lng):
///   4 → ~39 km × 20 km    (covers a large city)
///   5 → ~5 km × 5 km      (neighbourhood)
///   6 → ~1.2 km × 600 m   (a few blocks)
const _defaultGeohashPrecision = 4;

class ClientOfferRepository {
  const ClientOfferRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String offersPath() => 'offers';
  static String offerPath(String id) => 'offers/$id';

  // ---------------------------------------------------------------------------
  // Geo-filtered queries
  // ---------------------------------------------------------------------------

  /// Streams offers whose geohash falls within the cell (and its 8 neighbours)
  /// around [center]. pickupEndTime is filtered client-side because Firestore
  /// only allows range inequality on one field per query.
  Stream<List<Offer>> watchNearbyOffers({
    required double latitude,
    required double longitude,
    int precision = _defaultGeohashPrecision,
  }) {
    final centerHash = GeoFirePoint(
      GeoPoint(latitude, longitude),
    ).geohash.substring(0, precision);

    final prefixes = [centerHash, ...neighborGeohashesOf(geohash: centerHash)];
    final now = DateTime.now();

    // One Firestore listener per geohash tile (9 total at given precision).
    // Each query uses equality on status + geohash prefix range.
    final streams = prefixes.map((prefix) {
      return _firestore
          .collection(offersPath())
          .where('status', isEqualTo: OfferStatus.active.name)
          .orderBy('geohash')
          .startAt([prefix])
          .endAt(['$prefix\uf8ff'])
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => Offer.fromJson(d.data()))
              .where((o) => o.pickupEndTime.isAfter(now))
              .where(
                  (o) => o.visibleFrom == null || !o.visibleFrom!.isAfter(now))
              .toList());
    });

    // Merge all tile streams, deduplicate by offer id.
    return _mergeStreams(streams.toList());
  }

  /// One-shot fetch of nearby offers.
  Future<List<Offer>> fetchNearbyOffers({
    required double latitude,
    required double longitude,
    int precision = _defaultGeohashPrecision,
  }) async {
    final centerHash = GeoFirePoint(
      GeoPoint(latitude, longitude),
    ).geohash.substring(0, precision);

    final prefixes = [centerHash, ...neighborGeohashesOf(geohash: centerHash)];
    final now = DateTime.now();

    final futures = prefixes.map((prefix) {
      return _firestore
          .collection(offersPath())
          .where('status', isEqualTo: OfferStatus.active.name)
          .orderBy('geohash')
          .startAt([prefix])
          .endAt(['$prefix\uf8ff'])
          .get()
          .then((snap) => snap.docs
              .map((d) => Offer.fromJson(d.data()))
              .where((o) => o.pickupEndTime.isAfter(now))
              .where(
                  (o) => o.visibleFrom == null || !o.visibleFrom!.isAfter(now))
              .toList());
    });

    final results = await Future.wait(futures);
    return _dedup(results.expand((l) => l).toList());
  }

  // ---------------------------------------------------------------------------
  // Fallback: all offers (no geo, used when location unavailable)
  // ---------------------------------------------------------------------------

  Stream<List<Offer>> watchAllOffers() {
    final now = DateTime.now();
    final nowTs = Timestamp.fromDate(now);

    return _firestore
        .collection(offersPath())
        .where('status', isEqualTo: OfferStatus.active.name)
        .where('pickupEndTime', isGreaterThan: nowTs)
        .orderBy('pickupEndTime')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Offer.fromJson(d.data()))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Single offer
  // ---------------------------------------------------------------------------

  Future<Offer?> getOfferById(String id) async {
    final ref = _offerRef(id);
    final snapshot = await ref.get();
    return snapshot.data();
  }

  Stream<Offer?> watchOfferByIdStream(String id) {
    final ref = _offerRef(id);
    return ref.snapshots().map((snapshot) => snapshot.data());
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  DocumentReference<Offer> _offerRef(OfferID id) => _firestore
      .doc(offerPath(id))
      .withConverter(
        fromFirestore: (doc, _) => Offer.fromJson(doc.data()!),
        toFirestore: (Offer offer, _) => offer.toJson(),
      );

  /// Merges N streams into one, deduplicating offers by id.
  static Stream<List<Offer>> _mergeStreams(
    List<Stream<List<Offer>>> streams,
  ) async* {
    // Accumulate latest snapshot from each tile.
    final buckets = List<List<Offer>>.filled(streams.length, const []);
    // Listen to all streams, yield merged list on any update.
    await for (final _ in _anyOf(streams, buckets)) {
      yield _dedup(buckets.expand((l) => l).toList());
    }
  }

  /// Yields an event whenever any of [streams] emits, updating [buckets].
  static Stream<void> _anyOf(
    List<Stream<List<Offer>>> streams,
    List<List<Offer>> buckets,
  ) async* {
    // Create a broadcast stream that forwards events from all tile streams.
    final controller = StreamController<void>();
    final subs = <StreamSubscription>[];
    for (var i = 0; i < streams.length; i++) {
      subs.add(streams[i].listen((data) {
        buckets[i] = data;
        controller.add(null);
      }));
    }
    yield* controller.stream;
    for (final s in subs) {
      await s.cancel();
    }
    await controller.close();
  }

  static List<Offer> _dedup(List<Offer> offers) {
    final seen = <String>{};
    return offers.where((o) => seen.add(o.id)).toList();
  }
}

@riverpod
ClientOfferRepository offerRepository(Ref ref) => throw UnimplementedError();

@riverpod
FutureOr<Offer?> offerFuture(Ref ref, String id) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getOfferById(id);
}

@riverpod
Stream<Offer?> offerStream(Ref ref, String id) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.watchOfferByIdStream(id);
}
