import 'package:firebase_auth/firebase_auth.dart';

import '../../modules/authentication/domain/auth_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_database_service.dart';

final class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._database, this._localProfile);

  final FirebaseAuthService _auth;
  final FirebaseDatabaseService _database;
  final ProfileLocalDataSource _localProfile;

  @override
  AuthUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() => _auth.authStateChanges().map(_toUser);

  AuthUser? _toUser(User? user) {
    if (user == null) return null;
    return (id: user.uid, phoneNumber: user.phoneNumber);
  }

  @override
  Future<bool> sendOtp(String phoneNumber, {bool resend = false}) =>
      _guard(() => _auth.sendOtp(phoneNumber, resend: resend));

  @override
  Future<void> verifyOtp(String code) async {
    await _guard(() => _auth.verifyOtp(code));
  }

  @override
  Future<bool> hasProfile() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final cached = await _localProfile.read(user.uid);
    if (cached != null) return true;
    final remote = await _guard(() => _database.read('profile'));
    if (remote is Map) {
      await _localProfile.save(
        user.uid,
        remote.map((key, value) => MapEntry(key.toString(), value)),
      );
      return true;
    }
    return false;
  }

  @override
  Future<void> saveProfile(String name, {String? email}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthActionException('Sign in again to save your profile.');
    }
    await _guard(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final existing = await _database.read('profile');
      final createdAt = existing is Map ? existing['createdAt'] : null;
      final profile = <String, Object?>{
        'name': name.trim(),
        'phoneNumber': user.phoneNumber ?? '',
        if (email?.trim().isNotEmpty == true) 'email': email!.trim(),
        if (email == null && existing is Map && existing['email'] is String)
          'email': existing['email'] as String,
        'createdAt': createdAt is num ? createdAt : now,
        'updatedAt': now,
      };
      await _database.set('profile', profile);
      await _localProfile.save(user.uid, profile);
    });
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthActionException(_messageForAuthCode(error.code));
    } on FirebaseException {
      throw const AuthActionException(
        'Could not reach your library. Please try again.',
      );
    } on StateError {
      throw const AuthActionException('Request a new code and try again.');
    }
  }

  String _messageForAuthCode(String code) => switch (code) {
    'invalid-phone-number' => 'Enter a valid phone number with country code.',
    'invalid-verification-code' => 'That code is incorrect. Try again.',
    'session-expired' => 'That code expired. Request a new one.',
    'too-many-requests' ||
    'quota-exceeded' => 'Too many attempts right now. Please try again later.',
    'network-request-failed' => 'Check your internet connection and try again.',
    'operation-not-allowed' => 'Phone sign-in is not enabled for this project.',
    _ => 'Something went wrong. Please try again.',
  };
}
