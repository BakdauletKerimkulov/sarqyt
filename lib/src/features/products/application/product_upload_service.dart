// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/products/data/image_upload_repository.dart';
import 'package:sarqyt/src/features/products/data/products_repoitory.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/features/products/domain/product_from_data.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:uuid/uuid.dart';

part 'product_upload_service.g.dart';

class ProductUploadService {
  const ProductUploadService({
    required this.imageRepo,
    required this.productRepo,
  });

  final ImageUploadRepository imageRepo;
  final ProductsRepoitory productRepo;

  Future<void> uploadProduct(
    ProductFromData product, {
    required StoreID storeId,
    Either<File, Uint8List>? image, // опционально
  }) async {
    ProductFromData finalProduct = product;

    // if image not null upload to storage and get url
    if (image != null) {
      final mimeType = image.fold(
        (file) => lookupMimeType(file.path),
        (bytes) => lookupMimeType('', headerBytes: bytes),
      );

      final extension = extensionFromMime(mimeType ?? 'image/jpeg');

      final fileName = '${const Uuid().v4()}.$extension';
      final path = 'stores/$storeId/products/$fileName';

      final downloadUrl = await imageRepo.uploadProductImage(
        data: image,
        path: path,
      );

      finalProduct = product.copyWith(imageUrl: downloadUrl);
    }

    // write to cloud firestore
    await productRepo.createProduct(storeId, product: finalProduct);
  }

  Future<void> deleteProduct({
    required Product product,
    required String storeId,
  }) async {
    final ProductID productId = product.id;
    final String? imageUrl = product.imageUrl;

    if (imageUrl != null) {
      await imageRepo.deleteProductImage(imageUrl);
    }

    await productRepo.deleteProduct(storeId, id: productId);
  }
}

@riverpod
ProductUploadService productUploadService(Ref ref) {
  return ProductUploadService(
    imageRepo: ref.read(imageUploadRepositoryProvider),
    productRepo: ref.read(productsRepoitoryProvider),
  );
}
