import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/store_draft_controller.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

void main() {
  const testCountry = CountryD(isoCode: 'KZ', name: 'Kazakhstan');
  final testLocation = LatLng(43.238949, 76.945465);

  ProviderContainer makeContainer() => ProviderContainer();

  group('StoreDraftController.saveStepOne', () {
    test('resets location to null when address fields change', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(storeDraftControllerProvider.notifier);

      // Set initial state with address + location
      notifier.saveStepOne(
        name: 'Test Store',
        storeType: StoreType.cafe,
        address: 'Street 1',
        postalCode: '050000',
        locality: 'Almaty',
        country: testCountry,
        phoneNumber: '+77771112233',
      );
      notifier.saveLocation(testLocation);

      // Verify location is set
      expect(container.read(storeDraftControllerProvider).location, testLocation);

      // Change address field
      notifier.saveStepOne(
        name: 'Test Store',
        storeType: StoreType.cafe,
        address: 'Street 2',
        postalCode: '050000',
        locality: 'Almaty',
        country: testCountry,
        phoneNumber: '+77771112233',
      );

      // Location should be reset
      expect(container.read(storeDraftControllerProvider).location, isNull);
    });

    test('preserves location when only name/phone/storeType change', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(storeDraftControllerProvider.notifier);

      // Set initial state with address + location
      notifier.saveStepOne(
        name: 'Test Store',
        storeType: StoreType.cafe,
        address: 'Street 1',
        postalCode: '050000',
        locality: 'Almaty',
        country: testCountry,
        phoneNumber: '+77771112233',
      );
      notifier.saveLocation(testLocation);

      // Change only non-address fields
      notifier.saveStepOne(
        name: 'New Name',
        storeType: StoreType.restaurant,
        address: 'Street 1',
        postalCode: '050000',
        locality: 'Almaty',
        country: testCountry,
        phoneNumber: '+77779998877',
      );

      // Location should be preserved
      expect(
        container.read(storeDraftControllerProvider).location,
        testLocation,
      );
    });
  });
}
