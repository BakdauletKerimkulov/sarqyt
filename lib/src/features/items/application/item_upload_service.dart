// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/items/data/image_upload_repository.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/item_draft.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:uuid/uuid.dart';

part 'item_upload_service.g.dart';

class ItemUploadService {
  const ItemUploadService({required this.imageRepo, required this.productRepo});

  final ImageUploadRepository imageRepo;
  final ItemsRepository productRepo;

  Future<void> uploadItem(
    ItemDraft item, {
    required StoreID storeId,
    Either<File, Uint8List>? image,
  }) async {
    final price = item.price;
    final schedule = item.schedule;

    if (price == null || schedule == null) {
      throw ArgumentError('Item draft is incomplete: '
          'price=$price, schedule=$schedule');
    }

    String? imageUrl = item.imageUrl;

    if (image != null) {
      final mimeType = image.fold(
        (file) => lookupMimeType(file.path),
        (bytes) => lookupMimeType('', headerBytes: bytes),
      );

      final extension = extensionFromMime(mimeType ?? 'image/jpeg');

      final fileName = '${const Uuid().v4()}.$extension';
      final path = 'stores/$storeId/items/$fileName';

      imageUrl = await imageRepo.uploadProductImage(
        data: image,
        path: path,
      );
    }

    await productRepo.createItem(
      storeId,
      name: item.title,
      description: item.description,
      price: price,
      estimatedValue: item.estimatedValue,
      schedule: schedule,
      imageUrl: imageUrl,
    );
  }

  Future<void> deleteItem({required Item item, required String storeId}) async {
    final ItemID productId = item.id;
    final String? imageUrl = item.imageUrl;

    if (imageUrl != null) {
      await imageRepo.deleteItemImage(imageUrl);
    }

    await productRepo.deleteItem(storeId, id: productId);
  }
}

@riverpod
ItemUploadService itemUploadService(Ref ref) {
  return ItemUploadService(
    imageRepo: ref.read(imageUploadRepositoryProvider),
    productRepo: ref.read(itemsRepositoryProvider),
  );
}
