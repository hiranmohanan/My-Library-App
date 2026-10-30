import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library_app/app/app.dart';
import 'package:my_library_app/app/modules/authentication/domain/auth_repository.dart';
import 'package:my_library_app/app/modules/authentication/domain/auth_use_cases.dart';
import 'package:my_library_app/app/theme_controller.dart';
import 'package:my_library_app/core/bootstrap/app_bootstrap.dart';

final class FakeAuthRepository implements AuthRepository {
  final _changes = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;
  bool _hasProfile = false;
  String? savedName;
  String? savedEmail;
  int sentCodes = 0;
  String? lastPhoneNumber;
  bool lastRequestWasResend = false;
  bool failSend = false;
  bool failVerify = false;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<bool> sendOtp(String phoneNumber, {bool resend = false}) async {
    if (failSend) {
      throw const AuthActionException(
        'Check your internet connection and try again.',
      );
    }
    sentCodes++;
    lastPhoneNumber = phoneNumber;
    lastRequestWasResend = resend;
    return true;
  }

  @override
  Future<void> verifyOtp(String code) async {
    if (failVerify) {
      throw const AuthActionException('That code is incorrect. Try again.');
    }
    _user = (id: 'test-user', phoneNumber: '+919876543210');
    _changes.add(_user);
  }

  @override
  Future<bool> hasProfile() async => _hasProfile;

  @override
  Future<void> saveProfile(String name, {String? email}) async {
    savedName = name;
    savedEmail = email;
    _hasProfile = true;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}

void main() {
  testWidgets('compact dark auth screens render through profile setup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      MediaLibraryApp(
        dependencies: AppDependencies(
          themeController: ThemeController(initialMode: ThemeMode.dark),
          authUseCases: AuthUseCases(repository),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your\nMedia Library'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '+91 9876543210');
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter Verification Code'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.pumpAndSettle();
    expect(find.text('Complete Your Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await repository.dispose();
  });

  testWidgets('phone, OTP, profile, and sign out flow', (tester) async {
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      MediaLibraryApp(
        dependencies: AppDependencies(
          themeController: ThemeController(),
          authUseCases: AuthUseCases(repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your\nMedia Library'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();
    expect(repository.sentCodes, 0);
    expect(find.textContaining('country code'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '+91 9876543210');
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();

    expect(find.text('Enter Verification Code'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Resend code'))
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 60));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle();
    expect(repository.sentCodes, 2);
    expect(repository.lastPhoneNumber, '+919876543210');
    expect(repository.lastRequestWasResend, isTrue);

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.pumpAndSettle();

    expect(find.text('Complete Your Profile'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '  Alex  ');
    await tester.enterText(find.byType(TextFormField).last, 'alex@example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(repository.savedName, 'Alex');
    expect(repository.savedEmail, 'alex@example.com');
    expect(find.text('Your Library'), findsOneWidget);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Your\nMedia Library'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repository.dispose();
  });

  testWidgets('returning user opens the library without another OTP', (
    tester,
  ) async {
    final repository = FakeAuthRepository()
      .._user = (id: 'returning-user', phoneNumber: '+919876543210')
      .._hasProfile = true;
    await tester.pumpWidget(
      MediaLibraryApp(
        dependencies: AppDependencies(
          themeController: ThemeController(),
          authUseCases: AuthUseCases(repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Library'), findsOneWidget);
    expect(repository.sentCodes, 0);
    await tester.pumpWidget(const SizedBox());
    await repository.dispose();
  });

  testWidgets('phone and OTP failures remain recoverable', (tester) async {
    final repository = FakeAuthRepository()..failSend = true;
    await tester.pumpWidget(
      MediaLibraryApp(
        dependencies: AppDependencies(
          themeController: ThemeController(),
          authUseCases: AuthUseCases(repository),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '+919876543210');
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();
    expect(find.textContaining('internet connection'), findsOneWidget);

    repository.failSend = false;
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter Verification Code'), findsOneWidget);

    repository.failVerify = true;
    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.pumpAndSettle();
    expect(find.textContaining('code is incorrect'), findsOneWidget);

    repository.failVerify = false;
    await tester.enterText(find.byType(TextFormField), '654321');
    await tester.pumpAndSettle();
    expect(find.text('Complete Your Profile'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repository.dispose();
  });
}
