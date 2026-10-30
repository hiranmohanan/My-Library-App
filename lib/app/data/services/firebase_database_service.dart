import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Limits all application data access to the signed-in user's subtree.
/// Realtime Database rules must independently enforce the same ownership.
final class FirebaseDatabaseService {
  FirebaseDatabaseService(this._database, this._auth);

  final FirebaseDatabase _database;
  final FirebaseAuth _auth;

  DatabaseReference _userReference(String relativePath) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Authentication required.');

    final segments = relativePath.split('/');
    if (segments.isEmpty ||
        segments.any(
          (segment) =>
              segment.isEmpty ||
              segment == '.' ||
              segment == '..' ||
              RegExp(r'[.#$\[\]]').hasMatch(segment),
        )) {
      throw ArgumentError.value(relativePath, 'relativePath', 'Invalid path');
    }
    return _database.ref('users/$uid/${segments.join('/')}');
  }

  Future<Object?> read(String relativePath) async =>
      (await _userReference(relativePath).get()).value;

  Stream<DatabaseEvent> watch(String relativePath) =>
      _userReference(relativePath).onValue;

  Future<void> set(String relativePath, Object? value) =>
      _userReference(relativePath).set(value);

  Future<void> update(String relativePath, Map<String, Object?> values) =>
      _userReference(relativePath).update(values);

  Future<void> remove(String relativePath) =>
      _userReference(relativePath).remove();

  Query orderByChild(String relativePath, String child) =>
      _userReference(relativePath).orderByChild(child);
}
