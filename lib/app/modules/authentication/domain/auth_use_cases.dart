import 'auth_repository.dart';

/// The authentication actions consumed by the presentation BLoC.
final class AuthUseCases {
  AuthUseCases(this._repository);

  final AuthRepository _repository;

  AuthUser? get currentUser => _repository.currentUser;

  Stream<AuthUser?> authStateChanges() => _repository.authStateChanges();

  Future<bool> sendOtp(String phoneNumber, {bool resend = false}) =>
      _repository.sendOtp(phoneNumber, resend: resend);

  Future<void> verifyOtp(String code) => _repository.verifyOtp(code);

  Future<bool> hasProfile() => _repository.hasProfile();

  Future<void> saveProfile(String name, {String? email}) =>
      _repository.saveProfile(name, email: email);

  Future<void> signOut() => _repository.signOut();
}
