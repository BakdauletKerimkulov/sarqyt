import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/domain/item_draft.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';

part 'item_draft_controller.g.dart';

@Riverpod(keepAlive: true)
class ItemDraftController extends _$ItemDraftController {
  @override
  ItemDraft build() => ItemDraft.initial();

  void saveImage(String imageUrl) {
    state = state.copyWith(imageUrl: imageUrl);
  }

  void saveTitleAndDescription(String title, String description) {
    state = state.copyWith(title: title, description: description);
  }

  void savePrice(double price) {
    state = state.copyWith(price: price);
  }

  void saveEstimatedValue(double value) {
    state = state.copyWith(estimatedValue: value);
  }

  void saveDefaultDailyStock(int stock) {
    state = state.copyWith(defaultDailyStock: stock);
  }

  void saveSchedule(WeeklySchedule schedule) {
    state = state.copyWith(schedule: schedule);
  }

  void reset() => state = ItemDraft.initial();
}
