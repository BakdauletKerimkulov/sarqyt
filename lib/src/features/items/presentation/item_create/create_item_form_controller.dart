import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/items/data/image_upload_repository.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:uuid/uuid.dart';

part 'create_item_form_controller.g.dart';

/// Controller for the dashboard "Create item" form.
/// Tracks loading/error state via [AsyncValue]; the widget only listens.
@riverpod
class CreateItemFormController extends _$CreateItemFormController {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required StoreID storeId,
    required String name,
    required String description,
    required double price,
    required double? estimatedValue,
    required WeeklySchedule schedule,
    Either<File, Uint8List>? image,
    String? storingAndAllergens,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Upload image first (if provided), then create item with imageUrl.
      String? imageUrl;
      if (image != null) {
        final imageRepo = ref.read(imageUploadRepositoryProvider);
        final mimeType = image.fold(
          (file) => lookupMimeType(file.path),
          (bytes) => lookupMimeType('', headerBytes: bytes),
        );
        final ext = extensionFromMime(mimeType ?? 'image/jpeg');
        final fileName = '${const Uuid().v4()}.$ext';
        final path = 'stores/$storeId/items/$fileName';
        imageUrl = await imageRepo.uploadProductImage(
          data: image,
          path: path,
        );
      }

      try {
        await ref.read(itemsRepositoryProvider).createItem(
              storeId,
              name: name,
              description: description,
              price: price,
              estimatedValue: estimatedValue,
              schedule: schedule,
              imageUrl: imageUrl,
              storingAndAllergens: storingAndAllergens,
            );
      } catch (e) {
        // Best-effort cleanup of uploaded image if createItem fails.
        if (imageUrl != null) {
          try {
            await ref
                .read(imageUploadRepositoryProvider)
                .deleteItemImage(imageUrl);
          } catch (_) {
            // ignore — orphaned image is acceptable
          }
        }
        rethrow;
      }

      // Optimistically flip hasFirstItem on the storeShip so the welcome
      // screen / dashboard checklist updates immediately. Only fires once.
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        final ships =
            ref.read(currentPartnerStoreShipsProvider).value ?? [];
        final ship = ships.where((s) => s.storeId == storeId).firstOrNull;
        if (ship != null && !ship.hasFirstItem) {
          try {
            await ref
                .read(storeShipRepositoryProvider)
                .markHasFirstItem(storeId: storeId, uid: user.uid);
          } catch (_) {
            // ignore — flag is best-effort
          }
        }
      }
    });
  }
}
