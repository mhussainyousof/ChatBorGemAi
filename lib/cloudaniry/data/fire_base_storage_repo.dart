import 'package:cloudinary_public/cloudinary_public.dart';

import 'package:flutter/foundation.dart' show immutable;
import 'package:image_picker/image_picker.dart';
@immutable
class StorageRepository {
  final CloudinaryPublic _cloudinary;

  StorageRepository({
    required String cloudName,
    required String uploadPreset,
  }) : _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  Future<String> saveImageToStorage({
    required XFile image,
    required String messageId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: "images",        // folder in your Cloudinary account
          publicId: messageId,     // unique public ID for the image
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw StorageException('Failed to upload image: ${e.toString()}');
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
