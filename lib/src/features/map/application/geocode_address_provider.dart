import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/map/data/map_repository.dart';

part 'geocode_address_provider.g.dart';

/// Универсальный провайдер геокодинга.
/// Принимает строку адреса, возвращает координаты.
/// Кэшируется Riverpod по значению query — повторный запрос с тем же адресом
/// не вызывает API, пока провайдер жив.
@riverpod
Future<LatLng?> geocodeAddress(Ref ref, {required String query}) async {
  if (query.trim().isEmpty) return null;
  final mapRepo = ref.read(mapRepositoryProvider);
  return mapRepo.getCoordinates(query);
}
