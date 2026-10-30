import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_use_cases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._actions) : super(const AuthState(stage: AuthStage.checking)) {
    on<AuthStarted>(_onStarted);
    on<AuthWelcomeContinued>(
      (event, emit) => emit(const AuthState(stage: AuthStage.phone)),
    );
    on<AuthBackToWelcome>(
      (event, emit) => emit(const AuthState(stage: AuthStage.welcome)),
    );
    on<AuthBackToPhone>((event, emit) {
      _resendTimer?.cancel();
      emit(AuthState(stage: AuthStage.phone, countryCode: state.countryCode));
    });
    on<AuthCountrySelected>(
      (event, emit) =>
          emit(AuthState(stage: AuthStage.phone, countryCode: event.code)),
    );
    on<AuthOtpChanged>(_onOtpChanged);
    on<AuthResendTicked>((event, emit) {
      if (state.stage == AuthStage.code && state.resendSeconds > 0) {
        if (state.resendSeconds == 1) _resendTimer?.cancel();
        emit(
          AuthState(
            stage: AuthStage.code,
            phoneNumber: state.phoneNumber,
            countryCode: state.countryCode,
            otpCode: state.otpCode,
            resendSeconds: state.resendSeconds - 1,
          ),
        );
      }
    });
    on<AuthUserChanged>(_onUserChanged);
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthOtpResent>(_onOtpResent);
    on<AuthProfileSubmitted>(_onProfileSubmitted);
    on<AuthProfileEmailChanged>((event, emit) {
      if (state.stage == AuthStage.profile) {
        emit(
          AuthState(
            stage: AuthStage.profile,
            phoneNumber: state.phoneNumber,
            errorMessage: state.errorMessage,
            profileEmail: event.email,
          ),
        );
      }
    });
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthProfileRetried>(_onProfileRetried);
  }

  final AuthUseCases _actions;
  StreamSubscription<AuthUser?>? _subscription;
  Timer? _resendTimer;
  bool _otpRequestInFlight = false;

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    _subscription ??= _actions.authStateChanges().listen(
      (user) => add(AuthUserChanged(user)),
      onError: (_) => add(const AuthUserChanged(null)),
    );
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user == null) {
      _resendTimer?.cancel();
      emit(const AuthState(stage: AuthStage.welcome));
      return;
    }
    emit(AuthState(stage: AuthStage.checking, phoneNumber: state.phoneNumber));
    await _loadProfile(emit);
  }

  Future<void> _loadProfile(Emitter<AuthState> emit) async {
    try {
      final hasProfile = await _actions.hasProfile();
      emit(
        AuthState(
          stage: hasProfile ? AuthStage.authenticated : AuthStage.profile,
          phoneNumber: state.phoneNumber,
        ),
      );
    } on AuthActionException catch (error) {
      emit(
        AuthState(
          stage: AuthStage.profile,
          phoneNumber: state.phoneNumber,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> _onPhoneSubmitted(
    AuthPhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (_otpRequestInFlight) return;
    final entered = event.phoneNumber.replaceAll(RegExp(r'[\s()-]'), '');
    final phoneNumber = entered.startsWith('+')
        ? entered
        : '${state.countryCode}$entered';
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneNumber)) {
      emit(
        AuthState(
          stage: AuthStage.phone,
          errorMessage: 'Enter a phone number with country code, such as +91.',
          countryCode: state.countryCode,
        ),
      );
      return;
    }
    emit(
      AuthState(
        stage: AuthStage.sending,
        phoneNumber: phoneNumber,
        countryCode: state.countryCode,
      ),
    );
    await _sendOtp(phoneNumber, emit);
  }

  Future<void> _onOtpResent(
    AuthOtpResent event,
    Emitter<AuthState> emit,
  ) async {
    if (_otpRequestInFlight) return;
    if (state.resendSeconds > 0) return;
    final phoneNumber = state.phoneNumber;
    if (phoneNumber == null) return;
    emit(
      AuthState(
        stage: AuthStage.sending,
        phoneNumber: phoneNumber,
        countryCode: state.countryCode,
      ),
    );
    await _sendOtp(phoneNumber, emit, resend: true);
  }

  Future<void> _sendOtp(
    String phoneNumber,
    Emitter<AuthState> emit, {
    bool resend = false,
  }) async {
    if (_otpRequestInFlight) return;
    _otpRequestInFlight = true;
    try {
      final codeSent = await _actions.sendOtp(phoneNumber, resend: resend);
      if (codeSent && _actions.currentUser == null) {
        emit(
          AuthState(
            stage: AuthStage.code,
            phoneNumber: phoneNumber,
            countryCode: state.countryCode,
            resendSeconds: 60,
          ),
        );
        _resendTimer?.cancel();
        _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (isClosed) {
            _resendTimer?.cancel();
          } else {
            add(const AuthResendTicked());
          }
        });
      }
    } on AuthActionException catch (error) {
      emit(
        AuthState(
          stage: AuthStage.phone,
          phoneNumber: phoneNumber,
          countryCode: state.countryCode,
          errorMessage: error.message,
        ),
      );
    } finally {
      _otpRequestInFlight = false;
    }
  }

  void _onOtpChanged(AuthOtpChanged event, Emitter<AuthState> emit) {
    if (state.stage != AuthStage.code) return;
    emit(
      AuthState(
        stage: AuthStage.code,
        phoneNumber: state.phoneNumber,
        countryCode: state.countryCode,
        otpCode: event.code,
        resendSeconds: state.resendSeconds,
      ),
    );
    if (event.code.length == 6) add(AuthOtpSubmitted(event.code));
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.stage == AuthStage.verifying) return;
    final code = event.code.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      emit(
        AuthState(
          stage: AuthStage.code,
          phoneNumber: state.phoneNumber,
          countryCode: state.countryCode,
          resendSeconds: state.resendSeconds,
          errorMessage: 'Enter the 6-digit code.',
        ),
      );
      return;
    }
    emit(
      AuthState(
        stage: AuthStage.verifying,
        phoneNumber: state.phoneNumber,
        countryCode: state.countryCode,
        resendSeconds: state.resendSeconds,
      ),
    );
    try {
      await _actions.verifyOtp(code);
    } on AuthActionException catch (error) {
      emit(
        AuthState(
          stage: AuthStage.code,
          phoneNumber: state.phoneNumber,
          countryCode: state.countryCode,
          resendSeconds: state.resendSeconds,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> _onProfileSubmitted(
    AuthProfileSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.stage == AuthStage.savingProfile) return;
    final name = event.name.trim();
    final email = (event.email ?? state.profileEmail).trim();
    if (name.isEmpty || name.length > 120) {
      emit(
        AuthState(
          stage: AuthStage.profile,
          errorMessage: 'Enter a name of 1 to 120 characters.',
          profileEmail: email,
        ),
      );
      return;
    }
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emit(
        AuthState(
          stage: AuthStage.profile,
          errorMessage: 'Enter a valid email address.',
          profileEmail: email,
        ),
      );
      return;
    }
    emit(
      AuthState(stage: AuthStage.savingProfile, phoneNumber: state.phoneNumber),
    );
    try {
      await _actions.saveProfile(name, email: email);
      emit(
        AuthState(
          stage: AuthStage.authenticated,
          phoneNumber: state.phoneNumber,
        ),
      );
    } on AuthActionException catch (error) {
      emit(
        AuthState(
          stage: AuthStage.profile,
          phoneNumber: state.phoneNumber,
          errorMessage: error.message,
          profileEmail: email,
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(stage: AuthStage.signingOut));
    try {
      await _actions.signOut();
    } on AuthActionException catch (error) {
      emit(
        AuthState(stage: AuthStage.authenticated, errorMessage: error.message),
      );
    }
  }

  Future<void> _onProfileRetried(
    AuthProfileRetried event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(stage: AuthStage.checking, phoneNumber: state.phoneNumber));
    await _loadProfile(emit);
  }

  @override
  Future<void> close() async {
    _resendTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
