# Release validation — 2026-10-29

## Verified in this workspace

- `flutter test --no-pub`: 25 tests passed. This includes returning-user and
  recoverable OTP failures, plus repository checks for remote failures,
  duplicate entries, reconnect, and 1,000 cached items offline.
- Targeted Dart analysis of `lib/main.dart`, `tool/graphify.dart`, and
  `test/media_repository_test.dart`, and `test/auth_flow_test.dart`: no issues.
- `flutter analyze --no-pub lib`: six `prefer_initializing_formals` info
  notices in `media_repository_impl.dart`; no reported errors or warnings.
- Signed Android release APK built with local TMDB configuration at
  `build/app/outputs/flutter-apk/app-release.apk`. Android SDK `apksigner`
  verified the signature, and `aapt` confirmed the release APK requests
  `android.permission.INTERNET`.
- Graphify generated its import graph, report, and Mermaid diagram in
  `graphify-out/`.

## Still required before release

- Publish `database.rules.json` manually in Firebase Console. Test ownership
  with two accounts and invalid writes. The local rules file has not been
  evaluated by Firebase's rules engine.
- Enable and verify Phone Authentication, Firebase test numbers, and the
  required Android certificate fingerprints in Console.
- Provide a restricted Google Books API key and test book search on a device.
- Run fresh-install, returning-session, OTP, sign-out, network loss, reconnect,
  edit, and delete flows on a device with the signed release build.
- Complete iOS signing and device validation on macOS.
- Prepare and publish privacy policy, terms, contact information, store text,
  screenshots, and data-disclosure answers for the final app behavior.
- Review Firebase plugin upgrades before a future Flutter version removes
  support for plugins that apply the Kotlin Gradle Plugin. The current build
  succeeds but emits a future-compatibility warning.
- Decide whether the local media/profile cache needs application-level
  encryption or clearing on sign-out for the intended privacy model. It is
  stored as a Sembast file in application support storage and is scoped by
  user ID, but this project does not add its own encryption layer.

## Device test limitation

An `adb install -r` attempt on the connected Android device was rejected with
`INSTALL_FAILED_UPDATE_INCOMPATIBLE`: the installed app has a different signing
certificate. Android left that installation and its data untouched. A device
test of this release APK needs a device without that package, or removal of the
existing installation after its data is backed up.

This directory is not a Git repository, so `git diff` review is unavailable.
