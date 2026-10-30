import 'package:sembast/sembast.dart';

import 'local_storage_service.dart';

final class SembastLocalStorageService implements LocalStorageService {
  SembastLocalStorageService(this._database);

  final Database _database;

  StoreRef<String, Map<String, Object?>> _store(String collection) {
    if (collection.isEmpty) {
      throw ArgumentError.value(collection, 'collection', 'Must not be empty');
    }
    return stringMapStoreFactory.store(collection);
  }

  void _validateKey(String key) {
    if (key.isEmpty) throw ArgumentError.value(key, 'key', 'Must not be empty');
  }

  @override
  Future<Map<String, Object?>?> read(String collection, String key) {
    _validateKey(key);
    return _store(collection).record(key).get(_database);
  }

  @override
  Future<Map<String, Map<String, Object?>>> readAll(String collection) async {
    final snapshots = await _store(collection).find(_database);
    return {for (final snapshot in snapshots) snapshot.key: snapshot.value};
  }

  @override
  Future<void> save(
    String collection,
    String key,
    Map<String, Object?> value,
  ) async {
    _validateKey(key);
    await _store(collection).record(key).put(_database, value);
  }

  @override
  Future<void> update(
    String collection,
    String key,
    Map<String, Object?> changes,
  ) async {
    _validateKey(key);
    final updated = await _store(
      collection,
    ).record(key).update(_database, changes);
    if (updated == null) throw StateError('Local record does not exist.');
  }

  @override
  Future<void> delete(String collection, String key) async {
    _validateKey(key);
    await _store(collection).record(key).delete(_database);
  }

  @override
  Future<void> clear(String collection) async {
    await _store(collection).delete(_database);
  }

  @override
  Future<void> replaceAll(
    String collection,
    Map<String, Map<String, Object?>> records,
  ) async {
    final store = _store(collection);
    for (final key in records.keys) {
      _validateKey(key);
    }
    await _database.transaction((transaction) async {
      await store.delete(transaction);
      for (final entry in records.entries) {
        await store.record(entry.key).put(transaction, entry.value);
      }
    });
  }

  Future<void> close() => _database.close();
}
