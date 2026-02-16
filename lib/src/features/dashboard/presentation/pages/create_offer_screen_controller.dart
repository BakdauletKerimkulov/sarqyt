// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/dashboard/application/create_offer_service.dart';
import 'package:sarqyt/src/features/dashboard/domain/offer_form.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/routing/business_router.dart';

part 'create_offer_screen_controller.g.dart';

@riverpod
class CreateOfferController extends _$CreateOfferController {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<void> createOffer(OfferForm offer, StoreID storeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(createOfferServiceProvider)
          .createOffer(offer, storeId: storeId),
    );

    if (state.hasError == false) {
      ref.read(businessRouterProvider).pop();
    }
  }
}

@riverpod
class OfferFormController extends _$OfferFormController {
  @override
  OfferForm build(ProductID productId) {
    return OfferForm.empty().copyWith(
      productId: productId,
      selectedDay: DateTime.now(),
    );
  }

  bool get isValid =>
      state.productId != null &&
      state.quantity > 0 &&
      state.startPickupTime != null &&
      state.endPickupTime != null &&
      state.selectedDay != null;

  String? selectStartTime(TimeOfDay startPickupTime) {
    if (state.endPickupTime != null) {
      final start = _toDouble(startPickupTime);
      final end = _toDouble(state.endPickupTime!);

      if (start > end) {
        return 'Время начала должно быть раньше времени окончания';
      }
    }
    state = state.copyWith(startPickupTime: startPickupTime);
    return null;
  }

  String? selectEndTime(TimeOfDay endPickupTime) {
    if (state.startPickupTime == null) {
      // Можно либо разрешить, либо сказать "Сначала выберите старт"
      state = state.copyWith(endPickupTime: endPickupTime);
      return null;
    }

    final start = _toDouble(state.startPickupTime!);
    final end = _toDouble(endPickupTime);

    if (end <= start) {
      return 'Время окончания должно быть позже времени начала';
    }

    state = state.copyWith(endPickupTime: endPickupTime);
    return null;
  }

  void selectQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
    debugPrint('Quantity selected: ${state.quantity}');
  }

  void selectToday() {
    final now = DateTime.now();
    state = state.copyWith(selectedDay: _stripTime(now));
    log(state.selectedDay.toString());
  }

  void selectTomorrow() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    state = state.copyWith(selectedDay: _stripTime(tomorrow));
    log(state.selectedDay.toString());
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  double _toDouble(TimeOfDay time) => time.hour + time.minute / 60.0;
}
