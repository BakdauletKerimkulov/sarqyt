import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/store/domain/address.dart';

part "location.freezed.dart";

/// The [Location] contains the [Address] and geographic coordinates with
/// a geohash for geo-queries.
@freezed
abstract class Location with _$Location {
  const factory Location({
    required Address address,
    required LatLng location,
    required String geohash,
    String? timezone,
  }) = _Location;

  const Location._();

  factory Location.fromMap(Map<String, dynamic> map) {
    final address = map['address'];
    final geoMap = map['geo'];

    if (address == null || address is! Map<String, dynamic>) {
      throw FormatException('Location.address is missing or invalid: $map');
    }

    if (geoMap == null || geoMap is! Map<String, dynamic>) {
      throw FormatException('Location.geo is missing or invalid: $map');
    }

    final geopoint = geoMap['geopoint'];
    final geohash = geoMap['geohash'];
    final timezoneValue = geoMap['timezone'];

    if (geopoint == null || geopoint is! GeoPoint) {
      throw FormatException('Location.geo.geopoint is missing: $map');
    }

    if (geohash == null || geohash is! String) {
      throw FormatException('Location.geo.geohash is missing: $map');
    }

    return Location(
      address: Address.fromMap(address),
      location: LatLng(geopoint.latitude, geopoint.longitude),
      geohash: geohash,
      timezone: timezoneValue is String && timezoneValue.trim().isNotEmpty
          ? timezoneValue.trim()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final geoPoint = GeoPoint(location.latitude, location.longitude);
    return {
      'address': address.toMap(),
      'geo': {
        'geopoint': geoPoint,
        'geohash': geohash,
        if (timezone != null) 'timezone': timezone,
      },
    };
  }

  /// Creates a [GeoFirePoint] for use with geoflutterfire_plus queries.
  GeoFirePoint get geoFirePoint =>
      GeoFirePoint(GeoPoint(location.latitude, location.longitude));
}
