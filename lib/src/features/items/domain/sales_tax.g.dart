// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_tax.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalesTax _$SalesTaxFromJson(Map<String, dynamic> json) => _SalesTax(
  taxDescription: json['taxDescription'] as String?,
  taxPercentage: (json['taxPercentage'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SalesTaxToJson(_SalesTax instance) => <String, dynamic>{
  'taxDescription': instance.taxDescription,
  'taxPercentage': instance.taxPercentage,
};
