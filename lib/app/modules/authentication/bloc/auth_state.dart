part of 'auth_bloc.dart';

enum AuthStage {
  checking,
  welcome,
  phone,
  sending,
  code,
  verifying,
  profile,
  savingProfile,
  authenticated,
  signingOut,
}

final class AuthState {
  const AuthState({
    required this.stage,
    this.phoneNumber,
    this.errorMessage,
    this.countryCode = '+1',
    this.otpCode = '',
    this.resendSeconds = 0,
    this.profileEmail = '',
  });

  final AuthStage stage;
  final String? phoneNumber;
  final String? errorMessage;
  final String countryCode;
  final String otpCode;
  final int resendSeconds;
  final String profileEmail;
}
