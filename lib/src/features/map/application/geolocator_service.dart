import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geolocator_service.g.dart';

class GeolocatorService {
  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Разрешение на местоположение отклонено.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Разрешения еще не предоставлены, запрашиваем их.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Разрешения отклонены.
        return Future.error('Разрешение на местоположение отклонено.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Разрешение отклонено навсегда. Пожалуйста, измените его в настройках.',
      );
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      debugPrint('Ошибка при получении местоположения: $e');
      return null;
    }
  }
}

@riverpod
GeolocatorService geolocatorService(Ref ref) {
  return GeolocatorService();
}

@riverpod
FutureOr<Position?> position(Ref ref) {
  final service = ref.read(geolocatorServiceProvider);
  return service.determinePosition();
}
