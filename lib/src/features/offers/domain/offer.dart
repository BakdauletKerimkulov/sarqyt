// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:equatable/equatable.dart';

typedef OfferID = String;

enum Category { bakery, hotDish, desert, drink, sushi, fastfood, product }

class Offer extends Equatable {
  const Offer({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.origPrice,
    required this.currPrice,
    required this.availableQuantity,
    required this.avgRating,
    required this.storeId,
    required this.storeName,
    required this.storeImage,
    required this.expiresAt,
    required this.category,
  });

  final OfferID id;
  final String? imageUrl;
  final String title;
  final String description;
  final double? origPrice;
  final double currPrice;
  final int availableQuantity;
  final double avgRating;
  final String storeId;
  final String storeName;
  final String storeImage;
  final DateTime expiresAt;
  final Category category;

  @override
  List<Object?> get props {
    return [
      id,
      imageUrl,
      title,
      description,
      origPrice,
      currPrice,
      availableQuantity,
      avgRating,
      storeId,
      storeName,
      storeImage,
      expiresAt,
      category,
    ];
  }

  Offer copyWith({
    OfferID? id,
    String? imageUrl,
    String? title,
    String? description,
    double? origPrice,
    double? currPrice,
    int? availableQuantity,
    double? avgRating,
    String? storeId,
    String? storeName,
    String? storeImage,
    DateTime? expiresAt,
    Category? category,
  }) {
    return Offer(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      origPrice: origPrice ?? this.origPrice,
      currPrice: currPrice ?? this.currPrice,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      avgRating: avgRating ?? this.avgRating,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeImage: storeImage ?? this.storeImage,
      expiresAt: expiresAt ?? this.expiresAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'origPrice': origPrice,
      'currPrice': currPrice,
      'availableQuantity': availableQuantity,
      'avgRating': avgRating,
      'storeId': storeId,
      'storeName': storeName,
      'storeImage': storeImage,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'category': category.name,
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: OfferID as String,
      imageUrl: map['imageUrl'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      origPrice: map['origPrice']?.toDouble() ?? 0.0,
      currPrice: map['currPrice']?.toDouble() ?? 0.0,
      availableQuantity: map['availableQuantity']?.toInt() ?? 0,
      avgRating: map['avgRating'] as double,
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String,
      storeImage: map['storeImage'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int),
      category: Category.values.byName(map['category'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Offer.fromJson(String source) =>
      Offer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
