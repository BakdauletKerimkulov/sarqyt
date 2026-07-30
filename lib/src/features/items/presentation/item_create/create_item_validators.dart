import 'package:sarqyt/l10n/app_localizations.dart';

/// Client-side validation for the "Create item" form text fields.
mixin CreateItemValidators {
  bool canSubmitName(String name) => name.trim().isNotEmpty;

  bool canSubmitPrice(String price) {
    final value = double.tryParse(price);
    return value != null && value > 0;
  }

  /// Estimated value is optional. If present, must parse, be > 0 and > price.
  bool canSubmitEstimatedValue(String estimatedValue, String price) {
    if (estimatedValue.isEmpty) return true;
    final ev = double.tryParse(estimatedValue);
    if (ev == null || ev <= 0) return false;
    final p = double.tryParse(price);
    if (p == null) return true;
    return ev > p;
  }

  String? nameErrorText(String name, AppLocalizations loc) {
    if (canSubmitName(name)) return null;
    return loc.nameCantBeEmpty;
  }

  String? priceErrorText(String price, AppLocalizations loc) {
    if (price.isEmpty) return loc.priceCantBeEmpty;
    if (!canSubmitPrice(price)) return loc.enterValidPrice;
    return null;
  }

  String? estimatedValueErrorText(
    String estimatedValue,
    String price,
    AppLocalizations loc,
  ) {
    if (estimatedValue.isEmpty) return null;
    final ev = double.tryParse(estimatedValue);
    if (ev == null || ev <= 0) {
      return loc.estimatedValuePositive;
    }
    final p = double.tryParse(price);
    if (p != null && ev <= p) {
      return loc.estimatedValueGreater;
    }
    return null;
  }
}
