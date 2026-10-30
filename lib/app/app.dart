import 'package:flutter/material.dart';

import '../core/bootstrap/app_bootstrap.dart';
import '../features/home/home_page.dart';
import 'modules/authentication/bloc/auth_bloc.dart';
import 'modules/authentication/auth_gate.dart';
import 'modules/connectivity/bloc/connectivity_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'theme_controller.dart';

class MediaLibraryApp extends StatelessWidget {
  const MediaLibraryApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    final themeController = dependencies.themeController;
    final application = BlocBuilder<ThemeController, ThemeMode>(
      bloc: themeController,
      builder: (context, mode) => MaterialApp(
        title: 'My Library',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        themeAnimationDuration: const Duration(milliseconds: 250),
        themeAnimationCurve: Curves.easeInOut,
        home: dependencies.authUseCases == null
            ? const HomePage()
            : BlocProvider(
                create: (_) =>
                    AuthBloc(dependencies.authUseCases!)
                      ..add(const AuthStarted()),
                child: AuthGate(dependencies: dependencies),
              ),
        onGenerateRoute: (route) =>
            AppRouter.onGenerateRoute(route, themeController),
      ),
    );
    final network = dependencies.networkInfo;
    return network == null
        ? application
        : BlocProvider(
            create: (_) =>
                ConnectivityBloc(network)..add(const ConnectivityStarted()),
            child: application,
          );
  }
}
