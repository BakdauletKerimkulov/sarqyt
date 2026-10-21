import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

void main() {
  group('StoreRepository.additionalStorePayload', () {
    // Shape asserted against the callable's own interface in
    // functions/src/features/stores/functions/create-additional-store.ts.
    const draft = StoreDraft(
      name: 'Corner Bakery',
      storeType: StoreType.bakery,
      address: 'Abay 10',
      locality: 'Almaty',
      postalCode: '050000',
      country: CountryD(name: 'Kazakhstan', isoCode: 'KZ'),
      phoneNumber: '+77001234567',
      location: LatLng(43.238949, 76.889709),
    );

    test('nests address and geo the way the callable expects', () {
      final payload = StoreRepository.additionalStorePayload(
        draft: draft,
        businessId: 'biz_1',
      );

      expect(payload['name'], 'Corner Bakery');
      expect(payload['storeType'], StoreType.bakery.name);
      expect(payload['phoneNumber'], '+77001234567');
      expect(payload['businessId'], 'biz_1');

      final address = payload['address'] as Map<String, dynamic>;
      expect(address['address'], 'Abay 10');
      expect(address['locality'], 'Almaty');
      expect(address['postalCode'], '050000');
      expect(address['country'], {'name': 'Kazakhstan', 'isoCode': 'KZ'});

      final geo = payload['geo'] as Map<String, dynamic>;
      expect(geo['geopoint'], {'latitude': 43.238949, 'longitude': 76.889709});
      expect(geo['geohash'], isNotEmpty);
    });

    test('substitutes empty values when the draft is incomplete', () {
      final payload = StoreRepository.additionalStorePayload(
        draft: const StoreDraft(),
        businessId: 'biz_1',
      );

      expect(payload['name'], isNull);
      expect(payload['storeType'], '');
      expect(payload['phoneNumber'], '');

      final address = payload['address'] as Map<String, dynamic>;
      expect(address['address'], '');
      expect(address['country'], {'name': '', 'isoCode': ''});

      // A missing location must not throw — the server treats 0/0 as absent.
      final geo = payload['geo'] as Map<String, dynamic>;
      expect(geo['geohash'], '');
      expect(geo['geopoint'], {'latitude': 0, 'longitude': 0});
    });
  });
}
