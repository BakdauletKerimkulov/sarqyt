import 'package:flutter/material.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';

class OfferForm {
  const OfferForm({
    this.productId,
    this.quantity = 1,
    this.startPickupTime,
    this.endPickupTime,
    this.selectedDay,
  });

  factory OfferForm.empty() {
    return OfferForm();
  }

  final ItemID? productId;
  final int quantity;
  final TimeOfDay? startPickupTime;
  final TimeOfDay? endPickupTime;
  final DateTime? selectedDay;

  OfferForm copyWith({
    ItemID? productId,
    int? quantity,
    TimeOfDay? startPickupTime,
    TimeOfDay? endPickupTime,
    DateTime? selectedDay,
  }) {
    return OfferForm(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      startPickupTime: startPickupTime ?? this.startPickupTime,
      endPickupTime: endPickupTime ?? this.endPickupTime,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  @override
  String toString() {
    return 'OfferForm(productId: $productId, quantity: $quantity, startPickupTime: $startPickupTime, endPickupTime: $endPickupTime, selectedDay: $selectedDay)';
  }

  @override
  bool operator ==(covariant OfferForm other) {
    if (identical(this, other)) return true;

    return other.productId == productId &&
        other.quantity == quantity &&
        other.startPickupTime == startPickupTime &&
        other.endPickupTime == endPickupTime &&
        other.selectedDay == selectedDay;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        quantity.hashCode ^
        startPickupTime.hashCode ^
        endPickupTime.hashCode ^
        selectedDay.hashCode;
  }
}
