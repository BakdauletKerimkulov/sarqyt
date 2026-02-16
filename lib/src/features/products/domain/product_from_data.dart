import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/products/domain/money.dart';

part 'product_from_data.freezed.dart';

@freezed
abstract class ProductFromData with _$ProductFromData {
  const factory ProductFromData({
    required String name,
    required Money price,
    String? description,
    String? packagingOption,
    String? imageUrl,
  }) = _ProductFromData;
}
