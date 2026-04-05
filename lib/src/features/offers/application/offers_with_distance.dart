import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/map/application/geolocator_service.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

part 'offers_with_distance.g.dart';

class OfferWithDistance {
  final Offer offer;
  final double? distanceKm;

  OfferWithDistance({required this.offer, this.distanceKm});

  String get distanceLabel {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }
}

double _haversineKm(LatLng a, LatLng b) {
  const r = 6371.0;
  final dLat = _rad(b.latitude - a.latitude);
  final dLng = _rad(b.longitude - a.longitude);
  final h =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(a.latitude)) *
          cos(_rad(b.latitude)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  return 2 * r * asin(sqrt(h));
}

double _rad(double deg) => deg * pi / 180;

@riverpod
Future<List<OfferWithDistance>> offersWithDistance(Ref ref) async {
  final offers = await ref.watch(offersListFutureProvider.future);
  return _addDistance(offers, ref);
}

@riverpod
Stream<List<OfferWithDistance>> offersWithDistanceStream(Ref ref) {
  final position = ref.watch(positionProvider).value;
  final userLatLng = position != null
      ? LatLng(position.latitude, position.longitude)
      : null;

  final repo = ref.watch(offerRepositoryProvider);
  return repo.watchAllOffer().map((offers) {
    return _mapWithDistance(offers, userLatLng);
  });
}

List<OfferWithDistance> _addDistance(List<Offer> offers, Ref ref) {
  final position = ref.watch(positionProvider).value;
  final userLatLng = position != null
      ? LatLng(position.latitude, position.longitude)
      : null;
  return _mapWithDistance(offers, userLatLng);
}

List<OfferWithDistance> _mapWithDistance(
  List<Offer> offers,
  LatLng? userLatLng,
) {
  final result = offers.map((offer) {
    final distance = userLatLng != null
        ? _haversineKm(userLatLng, offer.latLng)
        : null;
    return OfferWithDistance(offer: offer, distanceKm: distance);
  }).toList();

  if (userLatLng != null) {
    result.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
  }

  return result;
}
