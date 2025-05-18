import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_chat_bot/repo/auth_repo.dart';
import 'package:gemini_chat_bot/repo/chat_repo.dart';

final chatProvider = Provider((ref) => ChatRepository(cloudName: 'dqdl8nui0', uploadPreset: 'ShopEasee'));
final authProvider = Provider((ref) => AuthRepository());