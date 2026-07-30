import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/store/domain/address.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/location.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

Location _makeLocation({
  String address = 'Kabanbay Batyr 53',
  String locality = 'Astana',
  String country = 'Kazakhstan',
  String isoCode = 'KZ',
}) {
  return Location(
    address: Address(
      country: CountryD(isoCode: isoCode, name: country),
      address: address,
      locality: locality,
      postalCode: '010000',
    ),
    location: const LatLng(51.1694, 71.4491),
    geohash: 'v0m5y',
  );
}

void main() {
  group('Store.firstTwoWords', () {
    test('returns first two words', () {
      final store = Store(
        id: 's1',
        name: 'The Great Bakery',
        location: _makeLocation(),
      );
      expect(store.firstTwoWords, 'The Great');
    });

    test('returns single word if name has one word', () {
      final store = Store(id: 's1', name: 'Bakery', location: _makeLocation());
      expect(store.firstTwoWords, 'Bakery');
    });

    test('trims extra whitespace', () {
      final store = Store(
        id: 's1',
        name: '  Sunrise   Cafe   Downtown  ',
        location: _makeLocation(),
      );
      expect(store.firstTwoWords, 'Sunrise Cafe');
    });
  });

  group('Store.addressInfo', () {
    test('formats full address', () {
      final store = Store(
        id: 's1',
        name: 'Test',
        location: _makeLocation(
          address: 'Kabanbay Batyr 53',
          locality: 'Astana',
          country: 'Kazakhstan',
        ),
      );
      expect(store.addressInfo, 'Kabanbay Batyr 53, Astana, Kazakhstan');
    });
  });

  group('Store.fromMap reviewCount', () {
    Map<String, dynamic> makeStoreMap({double? avgRating, int? reviewCount}) =>
        {
          'id': 's1',
          'name': 'Test',
          'location': {
            'address': {
              'country': {'isoCode': 'KZ', 'name': 'Kazakhstan'},
              'address': 'Kabanbay 53',
              'locality': 'Astana',
              'postalCode': '010000',
            },
            'geo': {
              'geopoint': const GeoPoint(51.1694, 71.4491),
              'geohash': 'v0m5y',
            },
          },
          if (avgRating != null) 'avgRating': avgRating,
          if (reviewCount != null) 'reviewCount': reviewCount,
        };

    test('parses reviewCount when present', () {
      final store = Store.fromMap(
        makeStoreMap(avgRating: 4.2, reviewCount: 15),
      );
      expect(store.reviewCount, 15);
      expect(store.avgRating, 4.2);
    });

    test('defaults reviewCount to 0 when absent', () {
      final store = Store.fromMap(makeStoreMap());
      expect(store.reviewCount, 0);
    });
  });

  group('CountryD', () {
    test('empty factory', () {
      final country = CountryD.empty();
      expect(country.isoCode, 'UNK');
      expect(country.name, 'unknown');
    });

    test('fromMap / toMap roundtrip', () {
      final country = CountryD.fromMap({'isoCode': 'KZ', 'name': 'Kazakhstan'});
      expect(country.toMap(), {'isoCode': 'KZ', 'name': 'Kazakhstan'});
    });

    test('fromMap with missing values defaults to empty strings', () {
      final country = CountryD.fromMap({});
      expect(country.isoCode, '');
      expect(country.name, '');
    });
  });

  group('StoreDraftX', () {
    test('fullAdrres formats with postal code', () {
      const draft = StoreDraft(
        address: 'Kabanbay Batyr 53',
        locality: 'Astana',
        postalCode: '010000',
        country: CountryD(isoCode: 'KZ', name: 'Kazakhstan'),
      );
      expect(draft.fullAdrres, 'Kabanbay Batyr 53, Astana 010000, Kazakhstan');
    });

    test('fullAdrres returns No info without postal code', () {
      const draft = StoreDraft(
        address: 'Kabanbay Batyr 53',
        locality: 'Astana',
      );
      expect(draft.fullAdrres, 'No info');
    });

    test('toCallableMap includes geohash and location', () {
      const draft = StoreDraft(
        name: 'Test Store',
        storeType: StoreType.cafe,
        address: 'Kabanbay Batyr 53',
        locality: 'Astana',
        postalCode: '010000',
        country: CountryD(isoCode: 'KZ', name: 'Kazakhstan'),
        phoneNumber: '+77001234567',
        location: LatLng(51.1694, 71.4491),
      );

      final map = draft.toCallableMap();

      expect(map['storeName'], 'Test Store');
      expect(map['storeType'], 'cafe');
      expect(map['phoneNumber'], '+77001234567');
      expect(map['address'], 'Kabanbay Batyr 53');
      expect(map['locality'], 'Astana');
      expect(map['postalCode'], '010000');
      expect(map['country'], {'isoCode': 'KZ', 'name': 'Kazakhstan'});
      expect(map['location'], [51.1694, 71.4491]);
      expect(map['geohash'], isA<String>());
      expect((map['geohash'] as String).isNotEmpty, true);
    });
  });
}
