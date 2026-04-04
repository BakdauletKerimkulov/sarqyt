import 'package:latlong2/latlong.dart';
import 'package:sarqyt/src/features/store/domain/address.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/location.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

final kTestStores = [
  Store(
    id: 'store1',
    name: 'Green Bakery adsfasdfaffdsa',
    description: 'Fresh bakery in the city center',
    location: Location(
      address: Address(
        country: CountryD(isoCode: 'KZ', name: 'Kazakhstan'),
        address: '123 Main St',
        locality: 'Almaty',
        postalCode: '050000',
      ),
      location: LatLng(43.273208, 76.938070),
      geohash: 'ucg3f7',
      timezone: 'Asia/Almaty',
    ),
    phoneNumber: '+777523523423',
    logoUrl: 'assets/stores/cafeteria.jpg',
    coverUrl: 'assets/stores/cafeteria.jpg',
  ),
  Store(
    id: 'store2',
    name: 'Healthy Market',
    description: 'Organic food and snacks',
    location: Location(
      address: Address(
        country: CountryD(isoCode: 'KZ', name: 'Kazakhstan'),
        address: '45 Green Ave',
        locality: 'Almaty',
        postalCode: '050010',
      ),
      location: LatLng(43.237208, 76.938070),
      geohash: 'ucg3ef',
      timezone: 'Asia/Almaty',
    ),
    logoUrl: null,
    coverUrl: 'assets/stores/coffee-boom.jpg',
  ),
  Store(
    id: 'store3',
    name: 'Fruit Paradise',
    description: 'Fresh fruits and vegetables',
    location: Location(
      address: Address(
        country: CountryD(isoCode: 'KZ', name: 'Kazakhstan'),
        address: '78 Fruit St',
        locality: 'Almaty',
        postalCode: '050020',
      ),
      location: LatLng(43.264208, 76.864070),
      geohash: 'ucg38x',
      timezone: 'Asia/Almaty',
    ),
    logoUrl: null,
    coverUrl: 'assets/stores/pizza-hut.jpg',
  ),
];
