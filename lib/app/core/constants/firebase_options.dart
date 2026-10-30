import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase app registrations entered from Firebase Console.
/// These identifiers are client configuration, not private credentials.
abstract final class AppFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
        'Firebase is configured for Android, iOS, and Web only.',
      ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsiEj7TOifIpfOeulQj7PSYDtRwdLnE4w',
    appId: '1:482657847943:android:156d8d70a7233f89cf4622',
    messagingSenderId: '482657847943',
    projectId: 'my-library-app-ef604',
    databaseURL: 'https://my-library-app-ef604-default-rtdb.firebaseio.com',
    storageBucket: 'my-library-app-ef604.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6UfPE0OxIMLkZ2DIg8BXnFkB1lv4txMY',
    appId: '1:482657847943:ios:fa2c6d0f560e95b4cf4622',
    messagingSenderId: '482657847943',
    projectId: 'my-library-app-ef604',
    databaseURL: 'https://my-library-app-ef604-default-rtdb.firebaseio.com',
    storageBucket: 'my-library-app-ef604.firebasestorage.app',
    iosBundleId: 'com.hm.mymedialibrary',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACDpR402No_O2wGJSa1iyBt-eTqs1Zx-Y',
    appId: '1:482657847943:web:a012f1a4d085147acf4622',
    messagingSenderId: '482657847943',
    projectId: 'my-library-app-ef604',
    authDomain: 'my-library-app-ef604.firebaseapp.com',
    databaseURL: 'https://my-library-app-ef604-default-rtdb.firebaseio.com',
    storageBucket: 'my-library-app-ef604.firebasestorage.app',
  );
}
