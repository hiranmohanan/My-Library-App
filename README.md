# My Library

Flutter app for a personal library of movies, TV series, and books. The product
and architecture plan is in
[media_library_firebase_complete_implementation_plan.md](media_library_firebase_complete_implementation_plan.md).

## Current implementation

- Material 3 light, dark, and system themes
- Home, Library, Search, and Profile navigation shell
- Settings route with a theme selector
- Bootstrap composition root for future services and repositories
- Phone sign-in, OTP, profile setup, session gate, and sign out via BLoC
- Persistent local media and profile cache with user-scoped records

Firebase Auth and Realtime Database initialize for Android, iOS, and Web using
`lib/app/core/constants/firebase_options.dart`. Phone sign-in supports native
verification and the Web confirmation flow. The library, search, add, details,
profile, and settings flows use BLoCs. Cached library entries remain readable
offline and refresh after reconnection. Theme selection persists locally.

The shared API client and TMDB/Google Books data sources are wired into media
search. TMDB requires a read access token; Google Books search requires the
separately configured API key. Run `flutter test` for the current automated
suite. Live phone verification, Firebase rules, offline device behavior, and
store-installed builds still require device and Console checks.

## Run

```sh
flutter pub get
flutter run
```

For external media APIs, create an ignored `private_api.json` file locally:

```json
{
  "TMDB_READ_ACCESS_TOKEN": "your-tmdb-read-token",
  "GOOGLE_BOOKS_API_KEY": "your-books-api-key"
}
```

Run with `flutter run --dart-define-from-file=private_api.json`. These values
are embedded in client builds, so use API restrictions and put any truly private
server credential behind a backend endpoint.

Firebase project: `my-library-app-ef604`.
Realtime Database: `https://my-library-app-ef604-default-rtdb.firebaseio.com/`.
Android package and iOS bundle ID: `com.hm.mymedialibrary`.

The Android and iOS console files are in `android/app/` and `ios/Runner/`.
Enable Phone sign-in in Firebase Console, register Android signing SHA
fingerprints, and configure iOS phone verification. For a development smoke
test, add a Firebase Authentication test phone number and code in Console.
The ownership and schema rules are staged in `database.rules.json` for review
and manual entry in Firebase Console; they have not been deployed or tested in
the Firebase emulator. Profile setup requires these rules to be published.

## Android signing

Release builds use `android/app/upload-keystore.jks` and the private
`android/key.properties`. Both are ignored by Git. Back up both files securely;
the key and password are needed for future releases. Add the upload key's SHA-1
and SHA-256 fingerprints to the Android app in Firebase Console. Add this
computer's debug-key fingerprints too when testing phone sign-in in a debug
build. If Google Play App Signing is enabled, the Play Console will also show
an app-signing certificate whose fingerprints may need to be registered for
store-installed builds.

## Release readiness

- Automated tests: run `flutter test`. The suite covers authentication UI,
  repository failures, duplicates, offline cache and reconnect, media flows,
  and a 1,000-item cached library.
- Android: `flutter build apk --release --dart-define-from-file=private_api.json`
  builds a signed APK. Verify its signature with Android SDK `apksigner` and
  test the installed release build on a device with network access.
- Firebase Console: publish and test `database.rules.json` manually. Verify
  one signed-in account cannot read or write another account's profile or media.
  Confirm Phone Authentication and all required Android signing fingerprints.
- Device checks: fresh install, returning session, real or Console test-number
  OTP, sign out, API/Firebase failures, airplane mode, reconnect, edit, and
  delete. These are not established by the automated widget tests alone.
- External APIs: TMDB is configured through the ignored local file. Supply a
  restricted Google Books key before testing book search. Dart defines are
  embedded in the client binary; move any credential requiring secrecy behind
  a server endpoint.
- iOS: complete signing and an iPhone release build on macOS, then test phone
  verification there.
- Store submission: provide a published privacy policy and terms, contact
  details, screenshots, descriptions, and platform data-disclosure answers
  after confirming the final app behavior.
# My-Library-App
