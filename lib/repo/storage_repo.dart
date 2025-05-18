// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart' show immutable;
// import 'package:image_picker/image_picker.dart';

// @immutable
// class StorageRepository {
//   final FirebaseStorage _storage;

//    StorageRepository({
//     FirebaseStorage? storage,
//   }) : _storage = storage ?? FirebaseStorage.instance;

//   Future<String> saveImageToStorage({
//     required XFile image,
//     required String messageId,
//   }) async {
//     try {
//       final ref = _storage.ref('images').child(messageId);
//       final snapshot = await ref.putFile(File(image.path));
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       throw StorageException('Failed to upload image: ${e.toString()}');
//     }
//   }
// }

// class StorageException implements Exception {
//   final String message;
//   StorageException(this.message);

//   @override
//   String toString() => 'StorageException: $message';
// }