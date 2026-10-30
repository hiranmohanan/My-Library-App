typedef AuthUser = ({String id, String? phoneNumber});

final class AuthActionException implements Exception {
  const AuthActionException(this.message);

  final String message;
}

abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<bool> sendOtp(String phoneNumber, {bool resend = false});

  Future<void> verifyOtp(String code);

  Future<bool> hasProfile();

  Future<void> saveProfile(String name, {String? email});

  Future<void> signOut();
}
