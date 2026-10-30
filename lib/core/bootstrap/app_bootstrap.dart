import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/core/constants/api_configuration.dart';
import '../../app/data/api/api_client.dart';
import '../../app/data/datasources/media_local_data_source.dart';
import '../../app/data/datasources/profile_local_data_source.dart';
import '../../app/data/datasources/remote/google_books_remote_data_source.dart';
import '../../app/data/datasources/remote/firebase_media_data_source.dart';
import '../../app/data/datasources/remote/tmdb_remote_data_source.dart';
import '../../app/data/services/firebase_auth_service.dart';
import '../../app/data/services/firebase_database_service.dart';
import '../../app/data/services/local_database_factory.dart';
import '../../app/data/services/network_info_service.dart';
import '../../app/data/services/sembast_local_storage_service.dart';
import '../../app/data/repositories/firebase_auth_repository.dart';
import '../../app/data/repositories/media_repository_impl.dart';
import '../../app/modules/authentication/domain/auth_use_cases.dart';
import '../../app/modules/media/domain/media_repository.dart';
import '../../app/theme_controller.dart';

/// The composition root for services shared across the application.
/// Local storage and repositories will be wired here in later phases.
final class AppDependencies {
  AppDependencies({
    required this.themeController,
    this.authService,
    this.databaseService,
    this.authUseCases,
    this.localStorage,
    this.mediaLocalDataSource,
    this.profileLocalDataSource,
    this.apiClient,
    this.networkInfo,
    this.tmdbRemoteDataSource,
    this.googleBooksRemoteDataSource,
    this.mediaRepository,
  });

  final ThemeController themeController;
  final FirebaseAuthService? authService;
  final FirebaseDatabaseService? databaseService;
  final AuthUseCases? authUseCases;
  final SembastLocalStorageService? localStorage;
  final MediaLocalDataSource? mediaLocalDataSource;
  final ProfileLocalDataSource? profileLocalDataSource;
  final ApiClient? apiClient;
  final NetworkInfo? networkInfo;
  final TmdbRemoteDataSource? tmdbRemoteDataSource;
  final GoogleBooksRemoteDataSource? googleBooksRemoteDataSource;
  final MediaRepository? mediaRepository;
}

abstract final class AppBootstrap {
  static Future<AppDependencies> initialize({
    FirebaseOptions? firebaseOptions,
    String? databaseUrl,
  }) async {
    final localStorage = SembastLocalStorageService(await openLocalDatabase());
    final storedTheme = await localStorage.read('preferences', 'theme');
    final initialTheme = switch (storedTheme?['mode']) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final themeController = ThemeController(
      initialMode: initialTheme,
      persistMode: (mode) =>
          localStorage.save('preferences', 'theme', {'mode': mode.name}),
    );
    final mediaLocalDataSource = MediaLocalDataSource(localStorage);
    final profileLocalDataSource = ProfileLocalDataSource(localStorage);
    final apiClient = ApiClient(http.Client());
    final networkInfo = ConnectivityNetworkInfo(Connectivity());
    final tmdbRemoteDataSource = ApiConfiguration.tmdbReadAccessToken.isEmpty
        ? null
        : TmdbRemoteDataSource(apiClient, ApiConfiguration.tmdbReadAccessToken);
    final googleBooksRemoteDataSource =
        ApiConfiguration.googleBooksApiKey.isEmpty
        ? null
        : GoogleBooksRemoteDataSource(
            apiClient,
            ApiConfiguration.googleBooksApiKey,
          );

    if (firebaseOptions == null) {
      return AppDependencies(
        themeController: themeController,
        localStorage: localStorage,
        mediaLocalDataSource: mediaLocalDataSource,
        profileLocalDataSource: profileLocalDataSource,
        apiClient: apiClient,
        networkInfo: networkInfo,
        tmdbRemoteDataSource: tmdbRemoteDataSource,
        googleBooksRemoteDataSource: googleBooksRemoteDataSource,
      );
    }

    final resolvedDatabaseUrl = databaseUrl ?? firebaseOptions.databaseURL;
    if (resolvedDatabaseUrl == null || resolvedDatabaseUrl.isEmpty) {
      throw StateError('Firebase Realtime Database URL is required.');
    }
    final app = await Firebase.initializeApp(options: firebaseOptions);
    final auth = FirebaseAuth.instanceFor(app: app);
    final database = FirebaseDatabase.instanceFor(
      app: app,
      databaseURL: resolvedDatabaseUrl,
    );
    final authService = FirebaseAuthService(auth);
    final databaseService = FirebaseDatabaseService(database, auth);
    final mediaRepository = MediaRepositoryImpl(
      local: mediaLocalDataSource,
      remote: FirebaseMediaDataSource(databaseService),
      network: networkInfo,
      currentUserId: () => authService.currentUser?.uid,
      tmdb: tmdbRemoteDataSource,
      googleBooks: googleBooksRemoteDataSource,
    );
    return AppDependencies(
      themeController: themeController,
      authService: authService,
      databaseService: databaseService,
      authUseCases: AuthUseCases(
        FirebaseAuthRepository(
          authService,
          databaseService,
          profileLocalDataSource,
        ),
      ),
      localStorage: localStorage,
      mediaLocalDataSource: mediaLocalDataSource,
      profileLocalDataSource: profileLocalDataSource,
      apiClient: apiClient,
      networkInfo: networkInfo,
      tmdbRemoteDataSource: tmdbRemoteDataSource,
      googleBooksRemoteDataSource: googleBooksRemoteDataSource,
      mediaRepository: mediaRepository,
    );
  }
}
