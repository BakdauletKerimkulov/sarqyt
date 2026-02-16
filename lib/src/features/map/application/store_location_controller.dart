import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/map/data/map_repository.dart';

part 'store_location_controller.g.dart';

@riverpod
class StoreLocation extends _$StoreLocation {
  String? _lastQuery;

  @override
  FutureOr<LatLng?> build() => null;

  Future<void> getCoordinates({
    required String address,
    required String locality,
    required String isoCode,
    required String postalCode,
  }) async {
    debugPrint('getCoordinates method has been called');

    final query = '$address $locality $isoCode $postalCode';
    if (query == _lastQuery) return;
    _lastQuery = query;

    state = const AsyncLoading();

    final mapRepo = ref.read(mapRepositoryProvider);

    state = await AsyncValue.guard(() => mapRepo.getCoordinates(query));
  }
}
