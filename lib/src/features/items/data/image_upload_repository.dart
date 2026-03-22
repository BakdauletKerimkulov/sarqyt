import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_upload_repository.g.dart';

class ImageUploadRepository {
  const ImageUploadRepository(this._storage);
  final FirebaseStorage _storage;

  /// Service method to get contentType
  static String getContentType(Either<File, Uint8List> data) {
    return data.fold(
      (file) => lookupMimeType(file.path) ?? 'application/octet-stream',
      (bytes) =>
          lookupMimeType('', headerBytes: bytes) ?? 'application/octet-stream',
    );
  }

  Future<String> uploadProductImage({
    required Either<File, Uint8List> data,
    required String path,
  }) async {
    final ref = _storage.ref(path);

    final metadata = SettableMetadata(contentType: getContentType(data));

    final task = data.fold(
      (file) => ref.putFile(file, metadata),
      (bytes) => ref.putData(bytes, metadata),
    );

    await task;

    return ref.getDownloadURL();
  }

  Future<void> deleteItemImage(String imageUrl) async {
    return _storage.refFromURL(imageUrl).delete();
  }
}

@riverpod
ImageUploadRepository imageUploadRepository(Ref ref) {
  return ImageUploadRepository(FirebaseStorage.instance);
}
