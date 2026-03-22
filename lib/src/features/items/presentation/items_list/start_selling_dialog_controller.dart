import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'start_selling_dialog_controller.g.dart';

@riverpod
class StartSellingDialogController extends _$StartSellingDialogController {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<bool> startSelling(Item item, {required StoreID storeId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(businessOfferRepositoryProvider).syncItemOffers(
            storeId: storeId,
            itemId: item.id,
          );
    });
    return !state.hasError;
  }
}
