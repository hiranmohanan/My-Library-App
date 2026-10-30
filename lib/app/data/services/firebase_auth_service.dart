import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Keeps Firebase Authentication out of BLoCs and widgets.
final class FirebaseAuthService {
  FirebaseAuthService(this._auth);

  final FirebaseAuth _auth;
  String? _verificationId;
  ConfirmationResult? _webConfirmation;
  int? _resendToken;

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Returns true when a code was sent. Native auto-verification may sign in
  /// without a code, in which case this returns false.
  Future<bool> sendOtp(String phoneNumber, {bool resend = false}) async {
    _verificationId = null;
    _webConfirmation = null;
    if (kIsWeb) {
      _webConfirmation = await _auth.signInWithPhoneNumber(phoneNumber);
      return true;
    }

    final result = Completer<bool>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resend ? _resendToken : null,
      verificationCompleted: (credential) async {
        try {
          await _auth.signInWithCredential(credential);
          if (!result.isCompleted) result.complete(false);
        } on FirebaseAuthException catch (error) {
          if (!result.isCompleted) result.completeError(error);
        }
      },
      verificationFailed: (error) {
        if (!result.isCompleted) result.completeError(error);
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!result.isCompleted) result.complete(true);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        if (!result.isCompleted) result.complete(true);
      },
    );
    return result.future;
  }

  Future<UserCredential> verifyOtp(String smsCode) {
    if (kIsWeb) {
      final confirmation = _webConfirmation;
      if (confirmation == null) throw StateError('Request a new code first.');
      return confirmation.confirm(smsCode);
    }
    final verificationId = _verificationId;
    if (verificationId == null) throw StateError('Request a new code first.');
    return _auth.signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
    );
  }

  Future<void> signOut() => _auth.signOut();
}
