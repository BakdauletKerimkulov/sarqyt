import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/items/domain/money.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/offers/domain/badge.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';

part 'item.freezed.dart';

typedef ItemID = String;

@freezed
abstract class Item with _$Item {
  const factory Item({
    required ItemID id,
    required String name,
    required Money price,
    Money? originalPrice,
    int? discountPercent,
    String? imageUrl,
    String? description,
    @Default([]) List<Badge> badges,
    String? category,
    String? foodHandlingInstructions,
    bool? canUserSupplyPackaging,
    String? packagingOption,
    String? collectionInfo,
    Rating? rating,
    @Default(false) bool buffet,
    required WeeklySchedule schedule,
    required int quantity,
  }) = _Item;

  const Item._();

  String get priceWithCurrency {
    return '${price.amount} ${price.code}';
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      price: Money.fromMap(map['money'] as Map<String, dynamic>),
      originalPrice: map['originalPrice'] != null
          ? Money.fromMap(map['originalPrice'] as Map<String, dynamic>)
          : null,
      discountPercent: (map['discountPercent'] as num?)?.toInt(),
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      badges: (map['badges'] as List<dynamic>?)
              ?.map((e) => Badge.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      category: map['category'] as String?,
      foodHandlingInstructions: map['foodHandlingInstructions'] as String?,
      canUserSupplyPackaging: map['canUserSupplyPackaging'] as bool?,
      packagingOption: map['packagingOption'] as String?,
      collectionInfo: map['collectionInfo'] as String?,
      rating: map['rating'] != null
          ? Rating.fromMap(map['rating'] as Map<String, dynamic>)
          : null,
      buffet: map['buffet'] as bool? ?? false,
      schedule: WeeklySchedule.fromMap(map['schedule'] as Map<String, dynamic>),
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'money': price.toMap(),
    if (originalPrice != null) 'originalPrice': originalPrice!.toMap(),
    if (discountPercent != null) 'discountPercent': discountPercent,
    'imageUrl': imageUrl,
    'description': description,
    'badges': badges.map((e) => e.toMap()).toList(),
    'category': category,
    'foodHandlingInstructions': foodHandlingInstructions,
    'canUserSupplyPackaging': canUserSupplyPackaging,
    'packagingOption': packagingOption,
    'collectionInfo': collectionInfo,
    'rating': rating?.toMap(),
    'buffet': buffet,
    'schedule': schedule.toMap(),
    'quantity': quantity,
  };
}

extension ItemX on Item {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'money': price.toMap(),
      if (originalPrice != null) 'originalPrice': originalPrice!.toMap(),
      if (discountPercent != null) 'discountPercent': discountPercent,
      'imageUrl': imageUrl,
      'description': description,
      'badges': badges.map((e) => e.toMap()).toList(),
      'category': category,
      'foodHandlingInstructions': foodHandlingInstructions,
      'canUserSupplyPackaging': canUserSupplyPackaging,
      'packagingOption': packagingOption,
      'collectionInfo': collectionInfo,
      'rating': rating?.toMap(),
      'buffet': buffet,
    };
  }
}
