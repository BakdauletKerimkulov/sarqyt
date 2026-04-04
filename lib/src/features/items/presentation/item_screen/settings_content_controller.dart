import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/data/image_upload_repository.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:uuid/uuid.dart';

part 'settings_content_controller.g.dart';

@riverpod
class SettingsContentController extends _$SettingsContentController {
  @override
  FutureOr<void> build() {}

  Future<void> updateItem({
    required StoreID storeId,
    required Item updatedItem,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(itemsRepositoryProvider);
      return repo.updateItem(storeId, item: updatedItem);
    });
  }

  Future<void> updateItemImage({
    required StoreID storeId,
    required Item item,
    required Either<File, Uint8List> image,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final imageRepo = ref.read(imageUploadRepositoryProvider);
      final itemsRepo = ref.read(itemsRepositoryProvider);

      final mimeType = image.fold(
        (file) => lookupMimeType(file.path),
        (bytes) => lookupMimeType('', headerBytes: bytes),
      );
      final extension = extensionFromMime(mimeType ?? 'image/jpeg');
      final fileName = '${const Uuid().v4()}.$extension';
      final path = 'stores/$storeId/items/$fileName';

      final imageUrl = await imageRepo.uploadProductImage(
        data: image,
        path: path,
      );

      final updatedItem = item.copyWith(imageUrl: imageUrl);
      await itemsRepo.updateItem(storeId, item: updatedItem);
    });
  }
}
