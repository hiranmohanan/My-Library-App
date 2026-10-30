part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthWelcomeContinued extends AuthEvent {
  const AuthWelcomeContinued();
}

final class AuthBackToWelcome extends AuthEvent {
  const AuthBackToWelcome();
}

final class AuthBackToPhone extends AuthEvent {
  const AuthBackToPhone();
}

final class AuthCountrySelected extends AuthEvent {
  const AuthCountrySelected(this.code);
  final String code;
}

final class AuthOtpChanged extends AuthEvent {
  const AuthOtpChanged(this.code);
  final String code;
}

final class AuthResendTicked extends AuthEvent {
  const AuthResendTicked();
}

final class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AuthUser? user;
}

final class AuthPhoneSubmitted extends AuthEvent {
  const AuthPhoneSubmitted(this.phoneNumber);

  final String phoneNumber;
}

final class AuthOtpSubmitted extends AuthEvent {
  const AuthOtpSubmitted(this.code);

  final String code;
}

final class AuthOtpResent extends AuthEvent {
  const AuthOtpResent();
}

final class AuthProfileSubmitted extends AuthEvent {
  const AuthProfileSubmitted(this.name, {this.email});

  final String name;
  final String? email;
}

final class AuthProfileEmailChanged extends AuthEvent {
  const AuthProfileEmailChanged(this.email);
  final String email;
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthProfileRetried extends AuthEvent {
  const AuthProfileRetried();
}
