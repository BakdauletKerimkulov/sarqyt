import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/features/store/domain/location.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'offer.freezed.dart';

@freezed
abstract class Offer with _$Offer {
  const factory Offer({
    required Product product,
    required Store store,
    required Location pickupLocation,
    required int itemsAvailable,
    required bool newItem,
    required String displayName,
    double? distance,
  }) = _Offer;

  const Offer._();

  bool get isAvailable => itemsAvailable > 0;

  String get availableText {
    if (itemsAvailable > 0) {
      return 'Left $itemsAvailable';
    } else {
      return 'Sold out';
    }
  }

  String? get distanceFormatter {
    final d = distance;
    if (d == null) return null;

    if (d < 1000) {
      return '${d.round()} m';
    }

    final km = d / 1000;
    final formatter = NumberFormat('#,##0.0', 'ru_RU');
    return '${formatter.format(km)} km';
  }
}
