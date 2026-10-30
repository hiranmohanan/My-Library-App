import '../services/local_storage_service.dart';

final class ProfileLocalDataSource {
  ProfileLocalDataSource(this._storage);

  final LocalStorageService _storage;

  static const _collection = 'profiles';

  Future<Map<String, Object?>?> read(String userId) =>
      _storage.read(_collection, userId);

  Future<void> save(String userId, Map<String, Object?> value) =>
      _storage.save(_collection, userId, value);

  Future<void> update(String userId, Map<String, Object?> changes) =>
      _storage.update(_collection, userId, changes);

  Future<void> delete(String userId) => _storage.delete(_collection, userId);
}
