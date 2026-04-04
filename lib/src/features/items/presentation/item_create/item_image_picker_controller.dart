import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_image_picker_controller.g.dart';

@Riverpod(keepAlive: true)
class ItemImagePickerController extends _$ItemImagePickerController {
  @override
  FutureOr<Either<File, Uint8List>?> build(String id) async {
    final byteData = await rootBundle.load('assets/sarqyt_item.png');
    return Right(byteData.buffer.asUint8List());
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
