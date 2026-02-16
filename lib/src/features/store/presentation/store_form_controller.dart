import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/registration/registration_validators.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

part 'store_form_controller.g.dart';

@riverpod
class StoreDraftController extends _$StoreDraftController {
  @override
  StoreDraft build() => StoreDraft();

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
    state = state.copyWith(
      name: name,
      storeType: storeType,
      address: address,
      postalCode: postalCode,
      locality: locality,
      country: country,
      phoneNumber: phoneFormatted,
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
