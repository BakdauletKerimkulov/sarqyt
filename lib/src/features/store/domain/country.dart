import 'package:freezed_annotation/freezed_annotation.dart';

part "country.freezed.dart";

/// The [Country] contains the `isoCode` and the `name` of a nation.
@freezed
abstract class CountryD with _$CountryD {
  const factory CountryD({required String isoCode, required String name}) =
      _CountryD;

  const CountryD._();

  factory CountryD.empty() => CountryD(isoCode: 'UNK', name: 'unknown');

  factory CountryD.fromMap(Map<String, dynamic> map) {
    return CountryD(isoCode: map['isoCode'] ?? '', name: map['name'] ?? '');
  }

  Map<String, dynamic> toMap() => {'isoCode': isoCode, 'name': name};
}

const countryList = [
  CountryD(isoCode: 'KZ', name: 'Kazakhstan'),
  CountryD(isoCode: 'RU', name: 'Russia'),
  CountryD(isoCode: 'UZ', name: 'Uzbekistan'),
  CountryD(isoCode: 'KG', name: 'Kyrgyzstan'),
];
