import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/registration_validators.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

part 'store_draft_controller.g.dart';

@Riverpod(keepAlive: true)
class StoreDraftController extends _$StoreDraftController {
  @override
  StoreDraft build() {
    return StoreDraft();
  }

  void saveLocation(LatLng location) {
    state = state.copyWith(location: location);
  }

  void saveStepOne({
    required String name,
    required StoreType storeType,
    required String address,
    required String postalCode,
    required String locality,
    required CountryD country,
    required String phoneNumber,
  }) {
    final phoneFormatted = kzPhoneFormatter(phoneNumber);

    // Сбросить координаты если адрес изменился
    final addressChanged =
        address != state.address ||
        locality != state.locality ||
        postalCode != state.postalCode ||
        country != state.country;

    state = StoreDraft(
      name: name,
      storeType: storeType,
      address: address,
      postalCode: postalCode,
      locality: locality,
      country: country,
      phoneNumber: phoneFormatted,
      location: addressChanged ? null : state.location,
    );
  }
}

extension StoreDraftX on StoreDraft {
  bool get hasEnoughDataForCoordinates =>
      address != null &&
      locality != null &&
      country != null &&
      postalCode != null;

  bool get canGoToStep2 =>
      name != null &&
      locality != null &&
      address != null &&
      country != null &&
      postalCode != null &&
      phoneNumber != null;

  bool get canGoToStep3 =>
      name != null &&
      address != null &&
      locality != null &&
      country != null &&
      postalCode != null &&
      phoneNumber != null &&
      location != null;
}
