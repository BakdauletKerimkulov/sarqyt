// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/offers/domain/badge.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';

part 'item.freezed.dart';
part 'item.g.dart';

typedef ItemID = String;

enum DietaryType { notSpecified, vegetarian }

enum PackagingOption { withBag, withBagOrOwnBag, noBag }

@freezed
abstract class Item with _$Item {
  @JsonSerializable(explicitToJson: true)
  const factory Item({
    @JsonKey(fromJson: _readRequiredId) required ItemID id,
    @JsonKey(fromJson: _readRequiredName) required String name,
    @JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice)
    required double price,
    @JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule)
    required WeeklySchedule schedule,
    @JsonKey(
      readValue: _readEstimatedValueSource,
      fromJson: _readOptionalPrice,
      toJson: _writeOptionalPrice,
    )
    double? estimatedValue,
    String? imageUrl,
    String? description,
    String? category,
    @JsonKey(unknownEnumValue: DietaryType.notSpecified)
    @Default(DietaryType.notSpecified)
    DietaryType dietaryType,
    @JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag)
    @Default(PackagingOption.withBagOrOwnBag)
    PackagingOption packagingType,
    String? collectionInstructions,
    @Default(false) bool isBuffetFood,
    String? storingAndAllergens,
    @Default([]) List<Badge> badges,
    Rating? averageOverallRating,
  }) = _Item;

  const Item._();

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  int get discountPercent {
    final ev = estimatedValue;
    if (ev == null || ev <= 0) return 0;
    final percent = ((1 - (price / ev)) * 100).round();
    return percent.clamp(0, 100);
  }

  Rating? get rating => averageOverallRating;
}

String _readRequiredId(Object? value) => _readRequiredString(value, field: 'id');

String _readRequiredName(Object? value) =>
    _readRequiredString(value, field: 'name');

String _readRequiredString(Object? value, {required String field}) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Item.$field is missing or invalid: $value');
}

double _readRequiredPrice(Object? value) {
  final parsed = _readOptionalPrice(value);
  if (parsed != null) return parsed;
  throw FormatException('Item.price is missing or invalid: $value');
}

double? _readOptionalPrice(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is Map) {
    final amount = value['amount'];
    if (amount is num) return amount.toDouble();
  }
  return null;
}

double _writePrice(double value) => value;

double? _writeOptionalPrice(double? value) => value;

WeeklySchedule _readRequiredSchedule(Object? value) {
  if (value is Map<String, dynamic>) return WeeklySchedule.fromJson(value);
  if (value is Map) {
    return WeeklySchedule.fromJson(Map<String, dynamic>.from(value));
  }
  throw FormatException('Item.schedule is missing or invalid: $value');
}

Map<String, dynamic> _writeSchedule(WeeklySchedule value) => value.toJson();

Object? _readEstimatedValueSource(Map<dynamic, dynamic> json, String key) {
  return json['estimatedValue'] ?? json['originalPrice'];
}
