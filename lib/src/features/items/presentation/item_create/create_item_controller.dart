import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/items/application/item_upload_service.dart';
import 'package:sarqyt/src/features/items/domain/item_draft.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/item_draft_controller.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/item_image_picker_controller.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'create_item_controller.g.dart';

@riverpod
class CreateItemController extends _$CreateItemController {
  @override
  FutureOr<void> build() {
    // no-op
  }

  /// Collects draft, image, and store context, then creates the item.
  /// Returns an error message for missing preconditions, or null if submitted.
  String? submitOnboardingItem({String imagePickerId = 'item'}) {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return 'User not authenticated';

    final ships = ref.read(currentPartnerStoreShipsProvider).value ?? [];
    final storeId = ships.pendingOnboarding?.storeId;
    if (storeId == null) return 'Store not found';

    final image = ref
        .read(itemImagePickerControllerProvider(imagePickerId))
        .value;
    final draft = ref.read(itemDraftControllerProvider);

    // Fire async — state is tracked via AsyncValue (isLoading / error).
    unawaited(createItem(
      draft,
      storeId: storeId,
      imagePickerId: imagePickerId,
      image: image,
    ));
    return null;
  }

  Future<void> createItem(
    ItemDraft productForm, {
    required StoreID storeId,
    required String imagePickerId,
    Either<File, Uint8List>? image,
  }) async {
    try {
      state = const AsyncLoading();

      await ref
          .read(itemUploadServiceProvider)
          .uploadItem(productForm, storeId: storeId, image: image)
          .timeout(const Duration(seconds: 30));

      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      if (uid != null) {
        await ref
            .read(storeShipRepositoryProvider)
            .updateOnboardingStatus(
              storeId: storeId,
              uid: uid,
              status: OnboardingStatus.completed,
            )
            .timeout(const Duration(seconds: 15));
      }

      // Mark success immediately — invalidates below may dispose this controller.
      if (ref.mounted) state = const AsyncData(null);

      // Clean up draft/image state.
      if (ref.mounted) ref.invalidate(itemDraftControllerProvider);
      if (ref.mounted) {
        ref.invalidate(itemImagePickerControllerProvider(imagePickerId));
      }

      // Force storeShips stream to re-fetch so router redirect picks up
      // the new onboardingStatus immediately. This may dispose this controller.
      if (ref.mounted && uid != null) {
        ref.invalidate(currentPartnerStoreShipsProvider);
      }
    } catch (e, st) {
      debugPrint('CreateItemController error: $e\n$st');
      if (ref.mounted) {
        state = AsyncError(e, st);
      }
    }
  }
}
