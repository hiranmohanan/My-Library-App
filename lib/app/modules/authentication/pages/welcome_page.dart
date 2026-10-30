import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_text.dart';
import '../bloc/auth_bloc.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height:
                  constraints.maxHeight *
                  (constraints.maxHeight < 700 ? 0.38 : 0.53),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    dark
                        ? 'assets/images/welcome_dark.png'
                        : 'assets/images/welcome_light.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    semanticLabel: 'A reader in a library',
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withValues(alpha: 0),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Your\nMedia Library',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    'Discover, organize and keep track of your movies, series and books all in one place.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 6, height: 6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.read<AuthBloc>().add(
                        const AuthWelcomeContinued(),
                      ),
                      child: const AppText('Get Started'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => context.read<AuthBloc>().add(
                        const AuthWelcomeContinued(),
                      ),
                      child: const AppText('Sign In'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
