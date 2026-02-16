import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';

part "address.freezed.dart";

/// The [Address] contains the relevant information
/// about the [Location] of a [Store].
@freezed
abstract class Address with _$Address {
  const factory Address({
    required CountryD country,
    required String address,
    required String locality,
    required String postalCode,
  }) = _Address;

  const Address._();

  factory Address.fromMap(Map<String, dynamic> map) {
    final country = map['country'];

    if (country == null || country is! Map<String, dynamic>) {
      throw FormatException('Address.country is missing or invalid: $map');
    }

    return Address(
      country: CountryD.fromMap(country),
      address: map['address'] ?? '',
      locality: map['locality'] ?? '',
      postalCode: map['postalCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'country': country.toMap(),
    'address': address,
    'locality': locality,
    'postalCode': postalCode,
  };
}
