/// JSON-compatible records stored under a named collection.
/// Data sources depend on this interface rather than the database package.
abstract interface class LocalStorageService {
  Future<Map<String, Object?>?> read(String collection, String key);

  Future<Map<String, Map<String, Object?>>> readAll(String collection);

  Future<void> save(String collection, String key, Map<String, Object?> value);

  Future<void> update(
    String collection,
    String key,
    Map<String, Object?> changes,
  );

  Future<void> delete(String collection, String key);

  Future<void> clear(String collection);

  Future<void> replaceAll(
    String collection,
    Map<String, Map<String, Object?>> records,
  );
}
