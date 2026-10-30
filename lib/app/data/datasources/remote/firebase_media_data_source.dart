import '../../services/firebase_database_service.dart';

abstract interface class RemoteMediaDataSource {
  Future<Map<String, Map<String, Object?>>> readAll();
  Stream<Map<String, Map<String, Object?>>> watchAll();
  Future<Map<String, Object?>?> read(String id);
  Future<void> save(String id, Map<String, Object?> value);
  Future<void> delete(String id);
}

final class FirebaseMediaDataSource implements RemoteMediaDataSource {
  FirebaseMediaDataSource(this._database);

  final FirebaseDatabaseService _database;

  @override
  Future<Map<String, Map<String, Object?>>> readAll() async =>
      _decode(await _database.read('media'));

  @override
  Stream<Map<String, Map<String, Object?>>> watchAll() =>
      _database.watch('media').map((event) => _decode(event.snapshot.value));

  @override
  Future<Map<String, Object?>?> read(String id) async {
    final value = await _database.read('media/$id');
    return value is Map ? _record(value) : null;
  }

  @override
  Future<void> save(String id, Map<String, Object?> value) =>
      _database.set('media/$id', value);

  @override
  Future<void> delete(String id) => _database.remove('media/$id');

  Map<String, Map<String, Object?>> _decode(Object? value) {
    if (value == null) return {};
    if (value is! Map) throw const FormatException('Invalid media collection.');
    return value.map((key, item) {
      if (item is! Map) throw const FormatException('Invalid media record.');
      return MapEntry(key.toString(), _record(item));
    });
  }

  Map<String, Object?> _record(Map value) =>
      value.map((key, item) => MapEntry(key.toString(), item));
}
