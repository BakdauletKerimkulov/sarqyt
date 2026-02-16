import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';

enum Currency {
  kzt('₸', 'KZT');

  final String symbol;
  final String code;

  const Currency(this.symbol, this.code);
}

@freezed
abstract class Money with _$Money {
  const factory Money({
    required String code,
    required double amount,
    required String currency,
  }) = _Money;

  const Money._();

  factory Money.empty() => const Money(code: '', amount: 0.0, currency: 'USD');

  factory Money.fromMap(Map<String, dynamic> map) {
    return Money(
      code: map['code'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'code': code, 'amount': amount, 'currency': currency};
  }
}
