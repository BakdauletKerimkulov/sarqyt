import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/products/application/product_upload_service.dart';
import 'package:sarqyt/src/features/products/domain/product_from_data.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/routing/business_router.dart';

part 'create_product_controller.g.dart';

@riverpod
class CreateProductController extends _$CreateProductController {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<void> createProduct(
    ProductFromData productForm, {
    required StoreID storeId,
    Either<File, Uint8List>? image,
  }) async {
    try {
      state = const AsyncLoading();

      await ref
          .read(productUploadServiceProvider)
          .uploadProduct(productForm, storeId: storeId, image: image);

      ref.read(businessRouterProvider).pop();
    } catch (e, st) {
      if (ref.mounted) {
        state = AsyncError(e, st);
      }
    }
  }
}

@riverpod
class ProductImagePickerController extends _$ProductImagePickerController {
  @override
  FutureOr<Either<File, Uint8List>?> build() {
    return null;
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200.0,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        return Right(bytes);
      } else {
        return Left(File(pickedFile.path));
      }
    });
  }

  void removeImage() {
    state = const AsyncData(null);
  }
}
