import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

enum Currency {
  kzt('₸', 'KZT');

  final String symbol;
  final String code;

  const Currency(this.symbol, this.code);
}

@freezed
abstract class Price with _$Price {
  const factory Price({
    required double amount,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}
