import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'create_one_time_offer_controller.g.dart';

@riverpod
class CreateOneTimeOfferController extends _$CreateOneTimeOfferController {
  @override
  FutureOr<void> build() {}

  Future<bool> submit({
    required StoreID storeId,
    required String name,
    required double price,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int quantity,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      await ref.read(businessOfferRepositoryProvider).createOneTimeOffer(
            storeId: storeId,
            name: name,
            price: price,
            date: dateStr,
            startHour: startTime.hour,
            startMinute: startTime.minute,
            endHour: endTime.hour,
            endMinute: endTime.minute,
            quantity: quantity,
          );
    });
    return !state.hasError;
  }
}
