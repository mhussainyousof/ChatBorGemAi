abstract class ChatStorageRepo {
  Future<String?> saveImageToStorage(String path, String messageId);
}