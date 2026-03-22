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
  /// Returns an error message for missing preconditions, or null on success.
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

    createItem(
      draft,
      storeId: storeId,
      imagePickerId: imagePickerId,
      image: image,
    );
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
          .uploadItem(productForm, storeId: storeId, image: image);

      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      if (uid != null) {
        await ref
            .read(storeShipRepositoryProvider)
            .updateOnboardingStatus(
              storeId: storeId,
              uid: uid,
              status: OnboardingStatus.itemCreated,
            );
      }

      // Clean up draft/image state before triggering redirect.
      ref.invalidate(itemDraftControllerProvider);
      ref.invalidate(itemImagePickerControllerProvider(imagePickerId));

      // Set success state BEFORE invalidate triggers router redirect + dispose.
      if (ref.mounted) state = const AsyncData(null);

      // Force storeShips stream to re-fetch so router redirect picks up
      // the new onboardingStatus immediately. This may dispose this controller.
      if (uid != null) ref.invalidate(currentPartnerStoreShipsProvider);
    } catch (e, st) {
      if (ref.mounted) {
        state = AsyncError(e, st);
      }
    }
  }
}
