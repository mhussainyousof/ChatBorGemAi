import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:gemini_chat_bot/cloudaniry/data/fire_base_storage_repo.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '/extensions/extensions.dart';
import '/models/message.dart';

@immutable
class ChatRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final String cloudName;
  final String uploadPreset;

  ChatRepository({
    required this.cloudName,
    required this.uploadPreset,
  });

  //! This method sends an image alongside the text
  Future sendMessage({
    required String apiKey,
    required XFile? image,
    required String promptText,
  }) async {
    final textModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final imageModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey );
   
    final userId = _auth.currentUser!.uid;
    final sentMessageId = const Uuid().v4();

    Message message = Message(
      id: sentMessageId,
      message: promptText,
      createdAt: DateTime.now(),
      isMine: true,
    );

    if (image != null) {
      final downloadUrl = await StorageRepository(
        cloudName: cloudName,
        uploadPreset: uploadPreset,
      ).saveImageToStorage(
        image: image,
        messageId: sentMessageId,
      );

      message = message.copyWith(imageUrl: downloadUrl);
    }

    // Save message to Firebase
    await _firestore
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .doc(sentMessageId)
        .set(message.toMap());

    GenerateContentResponse response;

    try {
      if (image == null) {
        response = await textModel.generateContent([Content.text(promptText)]);
      } else {
        final imageBytes = await image.readAsBytes();
        final prompt = TextPart(promptText);
        final mimeType = image.getMimeTypeFromExtension();
        final imagePart = DataPart(mimeType, imageBytes);

        response = await imageModel.generateContent([
          Content.multi([
            prompt,
            imagePart,
          ])
        ]);
      }

      final responseText = response.text;

      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //! Send Text Only Prompt
  Future sendTextMessage({
    required String textPrompt,
    required String apiKey,
  }) async {
    try {
      final textModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      final userId = _auth.currentUser!.uid;
      final sentMessageId = const Uuid().v4();

      Message message = Message(
        id: sentMessageId,
        message: textPrompt,
        createdAt: DateTime.now(),
        isMine: true,
      );

      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(sentMessageId)
          .set(message.toMap());

      final response = await textModel.generateContent([Content.text(textPrompt)]);
      final responseText = response.text;
      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
