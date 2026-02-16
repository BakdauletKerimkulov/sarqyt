// Список Offers
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/products/data/test_product.dart';
import 'package:sarqyt/src/features/store/data/test_store.dart';

final kTestOffers = [
  Offer(
    product: kTestProducts[0],
    store: kTestStores[0],
    pickupLocation: kTestStores[0].location,
    itemsAvailable: 10,
    newItem: true,
    displayName: 'Morning special',
    distance: 1400.0,
  ),
  Offer(
    product: kTestProducts[1],
    store: kTestStores[1],
    pickupLocation: kTestStores[1].location,
    itemsAvailable: 0,
    newItem: false,
    displayName: 'Organic treat',
    distance: 300.0,
  ),
  Offer(
    product: kTestProducts[2],
    store: kTestStores[2],
    pickupLocation: kTestStores[2].location,
    itemsAvailable: 5,
    newItem: true,
    displayName: 'Veggie pack',
    distance: 500.0,
  ),
];
