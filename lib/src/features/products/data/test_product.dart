import 'package:sarqyt/src/features/offers/domain/badge.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';
import 'package:sarqyt/src/features/products/domain/money.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';

final kTestProducts = [
  Product(
    id: 'prod1',
    name: 'Chocolate Croissant',
    price: Money(code: '₸', amount: 500, currency: 'KZT'),
    description: 'Delicious chocolate croissant',
    badges: [Badge(type: BadgeType.special)],
    category: 'Bakery',
    buffet: false,
    rating: Rating(average: 4.4, ratingCount: 423),
    packagingOption: 'The store will provide packaging for your food,',
  ),
  Product(
    id: 'prod2',
    name: 'Organic Apple',
    price: Money(code: '₸', amount: 300, currency: 'KZT'),
    description: 'Juicy organic apple',
    badges: [Badge(type: BadgeType.special)],
    category: 'Fruit',
    buffet: false,
  ),
  Product(
    id: 'prod3',
    name: 'Vegetable Box',
    price: Money(code: '₸', amount: 1200, currency: 'KZT'),
    description: 'Seasonal vegetables box',
    badges: [
      Badge(type: BadgeType.special),
      Badge(type: BadgeType.popular),
    ],
    category: 'Vegetables',
    buffet: false,
  ),
];
