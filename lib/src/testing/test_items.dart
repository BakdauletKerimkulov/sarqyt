import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/offers/domain/badge.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';

final kTestItems = [
  Item(
    id: 'prod1',
    name: 'Chocolate Croissant',
    price: 500,
    estimatedValue: 700,
    imageUrl: 'https://picsum.photos/seed/prod1/600/400',
    description: 'Delicious chocolate croissant',
    badges: [Badge(type: BadgeType.special)],
    category: 'Bakery',
    averageOverallRating: Rating(average: 4.4, ratingCount: 423),
    schedule: WeeklySchedule.defaultSchedule(),
  ),
  Item(
    id: 'prod2',
    name: 'Organic Apple',
    price: 300,
    estimatedValue: 450,
    imageUrl: 'https://picsum.photos/seed/prod2/600/400',
    description: 'Juicy organic apple',
    badges: [Badge(type: BadgeType.special)],
    category: 'Fruit',
    averageOverallRating: Rating(average: 4.8, ratingCount: 97),
    schedule: WeeklySchedule.defaultSchedule().copyWithDay(
      6,
      const DaySchedule(
        enabled: true,
        startHour: 11,
        startMinute: 0,
        endHour: 12,
        endMinute: 30,
        quantity: 5,
      ),
    ),
  ),
  Item(
    id: 'prod3',
    name: 'Vegetable Box',
    price: 1200,
    estimatedValue: 1800,
    imageUrl: 'https://picsum.photos/seed/prod3/600/400',
    description: 'Seasonal vegetables box',
    badges: [
      Badge(type: BadgeType.special),
      Badge(type: BadgeType.popular),
    ],
    category: 'Vegetables',
    averageOverallRating: Rating(average: 4.1, ratingCount: 58),
    schedule: WeeklySchedule.defaultSchedule().copyWithDay(
      7,
      const DaySchedule(
        enabled: true,
        startHour: 19,
        startMinute: 0,
        endHour: 20,
        endMinute: 30,
        quantity: 3,
      ),
    ),
  ),
];
