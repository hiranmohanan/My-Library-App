import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/core/constants/firebase_options.dart';
import 'app/widgets/app_text.dart';
import 'core/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final dependencies = await AppBootstrap.initialize(
      firebaseOptions: AppFirebaseOptions.currentPlatform,
    );
    runApp(MediaLibraryApp(dependencies: dependencies));
  } catch (error, stackTrace) {
    developer.log('App startup failed', error: error, stackTrace: stackTrace);
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppText('The app could not start. Please reopen it.'),
          ),
        ),
      ),
    );
  }
}
