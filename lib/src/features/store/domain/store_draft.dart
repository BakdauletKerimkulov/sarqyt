import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

part 'store_draft.freezed.dart';

@freezed
abstract class StoreDraft with _$StoreDraft {
  const factory StoreDraft({
    String? name,
    StoreType? storeType,
    String? address,
    String? locality,
    String? postalCode,
    CountryD? country,
    String? phoneNumber,
    LatLng? location,
  }) = _StoreDraft;
}

extension StoreDraftX on StoreDraft {
  String get fullAdrres {
    final address1 = address ?? '';
    final cityy = locality ?? '';
    final postal = postalCode ?? '';
    final countryy = country?.name ?? '';

    return postalCode != null
        ? '$address1, $cityy $postal, $countryy'
        : 'No info';
  }

  /// Serialises the draft to a plain JSON map matching [StoreDraftRequestDto]
  /// on the server. Must contain only primitives, lists and string-keyed maps
  /// — no [FieldValue] or [GeoPoint].
  Map<String, dynamic> toCallableMap() {
    return {
      'storeName': name,
      'storeType': storeType!.name,
      'phoneNumber': phoneNumber,
      'address': address!,
      'locality': locality!,
      'postalCode': postalCode!,
      'country': {'isoCode': country!.isoCode, 'name': country!.name},
      'location': [location!.latitude, location!.longitude],
      'geohash': GeoFirePoint(GeoPoint(location!.latitude, location!.longitude))
          .geohash,
    };
  }
}
