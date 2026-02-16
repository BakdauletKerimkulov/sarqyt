import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/store/domain/address.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/location.dart';
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

  Map<String, dynamic> toFirestore({
    required UserID ownerId,
    required String storeId,
  }) {
    final storeMap = {
      'ownerId': ownerId,
      'storeId': storeId,
      'rating': 0,
      'storeType': storeType!.name,
      'phoneNumber': phoneNumber,
      'name': name,
      'location': Location(
        address: Address(
          country: CountryD(isoCode: country!.isoCode, name: country!.name),
          address: address!,
          locality: locality!,
          postalCode: postalCode!,
        ),
        location: location!,
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    };

    return storeMap;
  }
}
