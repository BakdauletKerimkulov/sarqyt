import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';

part 'item_draft.freezed.dart';

@freezed
abstract class ItemDraft with _$ItemDraft {
  const factory ItemDraft({
    @Default('Surprise bag') String title,
    @Default('Lorem ipsum') String description,
    double? price,
    double? estimatedValue,
    String? imageUrl,
    int? defaultDailyStock,
    WeeklySchedule? schedule,
  }) = _ItemDraft;

  factory ItemDraft.initial() => const ItemDraft();
}
