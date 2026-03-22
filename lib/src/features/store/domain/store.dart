import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/items/domain/money.dart';
import 'package:sarqyt/src/features/store/domain/location.dart';

part 'store.freezed.dart';

typedef StoreID = String;

@freezed
abstract class Store with _$Store {
  const factory Store({
    required StoreID id,
    required String name,
    required Location location,
    String? phoneNumber,
    String? description,
    String? logoUrl,
    String? coverUrl,
    @Default(0) double avgRating,
    @Default(Currency.kzt) Currency currency,
  }) = _Store;

  const Store._();

  String get firstTwoWords {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).join(' ');
  }

  String get addressInfo {
    final address = location.address;
    return '${address.address}, ${address.locality}, ${address.country.name}';
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    final locationMap = map['location'];
    if (locationMap == null || locationMap is! Map<String, dynamic>) {
      throw FormatException('Store.location is missing or invalid: $map');
    }

    return Store(
      id: map['id'] as String,
      name: map['name'] ?? '',
      location: Location.fromMap(locationMap),
      phoneNumber: map['phoneNumber'] as String?,
      description: map['description'] as String?,
      logoUrl: map['logoUrl'] as String?,
      coverUrl: map['coverUrl'] as String?,
      avgRating: (map['avgRating'] as num?)?.toDouble() ?? 0.0,
      currency: Currency.values.firstWhere(
        (c) => c.code == (map['currency'] as String?),
        orElse: () => Currency.kzt,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'location': location.toMap(),
    'phoneNumber': phoneNumber,
    'description': description,
    'logoUrl': logoUrl,
    'coverUrl': coverUrl,
    'avgRating': avgRating,
    'currency': currency.code,
  };
}
