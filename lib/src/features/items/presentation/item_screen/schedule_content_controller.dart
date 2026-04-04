import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'schedule_content_controller.g.dart';

@riverpod
class ScheduleContentController extends _$ScheduleContentController {
  @override
  FutureOr<void> build() {}

  Future<void> updateSchedule({
    required StoreID storeId,
    required Item updatedItem,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(itemsRepositoryProvider);
      return repo.updateItem(storeId, item: updatedItem);
    });
  }

  Future<void> updateDailyQuantity({
    required StoreID storeId,
    required Item item,
    required int quantity,
  }) async {
    var schedule = item.schedule;
    for (final entry in schedule.days.entries) {
      if (entry.value.enabled) {
        schedule = schedule.copyWithDay(
          entry.key,
          entry.value.copyWith(quantity: quantity),
        );
      }
    }
    final updatedItem = item.copyWith(schedule: schedule);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(itemsRepositoryProvider);
      return repo.updateItem(storeId, item: updatedItem);
    });
  }
}
