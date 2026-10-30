import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/home/home_page.dart';
import '../../../core/bootstrap/app_bootstrap.dart';
import '../home/pages/home_shell_page.dart';
import 'bloc/auth_bloc.dart';
import 'pages/phone_page.dart';
import 'pages/otp_page.dart';
import 'pages/profile_setup_page.dart';
import 'pages/welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) => switch (state.stage) {
      AuthStage.welcome => const WelcomePage(),
      AuthStage.phone => PhonePage(
        errorMessage: state.errorMessage,
        countryCode: state.countryCode,
      ),
      AuthStage.code => OtpPage(
        phoneNumber: state.phoneNumber ?? '',
        errorMessage: state.errorMessage,
        otpCode: state.otpCode,
        resendSeconds: state.resendSeconds,
      ),
      AuthStage.profile => ProfileSetupPage(errorMessage: state.errorMessage),
      AuthStage.authenticated =>
        dependencies.mediaRepository == null ||
                dependencies.authUseCases?.currentUser == null
            ? HomePage(
                onSignOut: () =>
                    context.read<AuthBloc>().add(const AuthSignOutRequested()),
              )
            : HomeShellPage(
                dependencies: dependencies,
                userId: dependencies.authUseCases!.currentUser!.id,
              ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    },
  );
}
