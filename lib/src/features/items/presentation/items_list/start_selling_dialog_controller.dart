import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'start_selling_dialog_controller.g.dart';

@riverpod
class StartSellingDialogController extends _$StartSellingDialogController {
  @override
  FutureOr<void> build() {}

  /// Sets item.isActive = true. The Firestore trigger onItemStatusChanged
  /// will automatically create offers for today + tomorrow.
  Future<bool> startSelling({
    required ItemID itemId,
    required StoreID storeId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(itemsRepositoryProvider)
          .setItemActive(storeId, id: itemId, isActive: true);
    });
    return !state.hasError;
  }

  /// Sets item.isActive = false. The Firestore trigger onItemStatusChanged
  /// will automatically pause all active offers for this item.
  Future<bool> stopSelling({
    required ItemID itemId,
    required StoreID storeId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(itemsRepositoryProvider)
          .setItemActive(storeId, id: itemId, isActive: false);
    });
    return !state.hasError;
  }
}
