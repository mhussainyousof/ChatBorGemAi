
import 'package:flutter/foundation.dart' show immutable;

@immutable
class Message {
  final String id;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isMine;

  const Message({
    required this.id,
    required this.message,
    this.imageUrl,
    required this.createdAt,
    required this.isMine,
  });

Message copyWith({
  String? id,
  String? message,
  String? imageUrl,
  DateTime? createdAt,
  bool? isMine,
}) {
  return Message(
    id: id ?? this.id,
    message: message ?? this.message,
    imageUrl: imageUrl ?? this.imageUrl,
    createdAt: createdAt ?? this.createdAt,
    isMine: isMine ?? this.isMine,
  );
}


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'message': message,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isMine': isMine,
    };
    }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      message: map['message'] as String,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isMine: map['isMine'] as bool,
    );
    }
    }
