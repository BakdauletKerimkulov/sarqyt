import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/store/domain/address.dart';

part "location.freezed.dart";

/// The [Location] contains the relevant like the [Address] and the [LatLng].
@freezed
abstract class Location with _$Location {
  const factory Location({required Address address, required LatLng location}) =
      _Location;

  const Location._();

  factory Location.fromMap(Map<String, dynamic> map) {
    final geo = map['point'];
    final address = map['address'];

    if (address == null || address is! Map<String, dynamic>) {
      throw FormatException('Location.address is missing or invalid: $map');
    }

    if (geo == null || geo is! GeoPoint) {
      throw FormatException('Location.point is missing or not GeoPoint: $map');
    }

    return Location(
      address: Address.fromMap(address),
      location: LocationMapper.toLatLng(geo),
    );
  }

  Map<String, dynamic> toMap() => {
    'address': address.toMap(),
    'point': LocationMapper.toGeo(location),
  };
}

class LocationMapper {
  static LatLng toLatLng(GeoPoint geo) {
    return LatLng(geo.latitude, geo.longitude);
  }

  static GeoPoint toGeo(LatLng ltn) {
    return GeoPoint(ltn.latitude, ltn.longitude);
  }
}
