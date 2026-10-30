import 'dart:convert';

import '../services/local_storage_service.dart';

/// Raw cached media records. Models and domain mapping arrive in Phase 7.
final class MediaLocalDataSource {
  MediaLocalDataSource(this._storage);

  final LocalStorageService _storage;

  String _collection(String userId) {
    if (userId.isEmpty) throw ArgumentError.value(userId, 'userId');
    return 'media_${base64Url.encode(utf8.encode(userId))}';
  }

  Future<Map<String, Object?>?> read(String userId, String mediaId) =>
      _storage.read(_collection(userId), mediaId);

  Future<Map<String, Map<String, Object?>>> readAll(String userId) =>
      _storage.readAll(_collection(userId));

  Future<void> save(
    String userId,
    String mediaId,
    Map<String, Object?> value,
  ) => _storage.save(_collection(userId), mediaId, value);

  Future<void> update(
    String userId,
    String mediaId,
    Map<String, Object?> changes,
  ) => _storage.update(_collection(userId), mediaId, changes);

  Future<void> delete(String userId, String mediaId) =>
      _storage.delete(_collection(userId), mediaId);

  Future<void> clear(String userId) => _storage.clear(_collection(userId));

  Future<void> replaceAll(
    String userId,
    Map<String, Map<String, Object?>> records,
  ) => _storage.replaceAll(_collection(userId), records);
}
