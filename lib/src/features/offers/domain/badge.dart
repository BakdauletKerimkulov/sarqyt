import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';

enum BadgeType { popular, topRated, newItem, trending, eco, special }

@freezed
abstract class Badge with _$Badge {
  const factory Badge({
    required BadgeType type,
    int? percentage,
    int? userCount,
  }) = _Badge;

  const Badge._();

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      type: BadgeType.values.byName(map['type'] as String),
      percentage: map['percentage'] as int?,
      userCount: map['userCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'percentage': percentage,
    'userCount': userCount,
  };
}

extension BadgeX on Badge {
  bool get requiresStats =>
      type == BadgeType.topRated || type == BadgeType.trending;

  bool get isDecorative => type == BadgeType.eco || type == BadgeType.special;
}
