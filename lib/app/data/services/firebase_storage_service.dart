import 'dart:typed_data';

/// Future image storage boundary. No Storage SDK is needed in the first build.
abstract interface class FirebaseStorageService {
  Future<String> uploadImage(String path, Uint8List bytes);

  Future<void> deleteImage(String path);

  Future<String> getDownloadUrl(String path);
}
