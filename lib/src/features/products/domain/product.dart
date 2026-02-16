import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/offers/domain/badge.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';
import 'package:sarqyt/src/features/products/domain/money.dart';

part 'product.freezed.dart';

typedef ProductID = String;

@freezed
abstract class Product with _$Product {
  const factory Product({
    required ProductID id,
    required String name,
    required Money price,
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
  }) = _Product;

  const Product._();

  String get priceWithCurrency {
    return '${price.amount} ${price.code}';
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: Money.fromMap(map['money'] as Map<String, dynamic>),
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      badges: (map['badges'] as List<dynamic>)
          .map((e) => Badge.fromMap(e as Map<String, dynamic>))
          .toList(),
      category: map['category'] as String?,
      foodHandlingInstructions: map['foodHandlingInstructions'] as String?,
      canUserSupplyPackaging: map['canUserSupplyPackaging'] as bool?,
      packagingOption: map['packagingOption'] as String?,
      collectionInfo: map['collectionInfo'] as String?,
      rating: map['rating'] != null
          ? Rating.fromMap(map['rating'] as Map<String, dynamic>)
          : null,
      buffet: map['buffet'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'money': price.toMap(),
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

extension ProductX on Product {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'money': price.toMap(),
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
