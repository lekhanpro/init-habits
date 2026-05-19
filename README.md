# init.habits

![init.habits logo](flutter_app/assets/brand/init_habits_logo_512.png)

init.habits is a professional Flutter habit tracker for people who want a focused, data-rich routine system instead of a toy checklist. The app uses a terminal-inspired interface, local-first storage, analytics, reminders, challenges, XP, achievements, and release automation for Android and iOS build artifacts.

[Repository](https://github.com/lekhanpro/init-habits) | [Actions](https://github.com/lekhanpro/init-habits/actions) | [Issues](https://github.com/lekhanpro/init-habits/issues)

## Status

- Production mobile app: `flutter_app/`
- Latest Android APK: `flutter_app/app-release.apk`
- Latest Play Store App Bundle: `flutter_app/app-release.aab`
- iOS CI artifact: unsigned `Runner.app` zip from GitHub Actions
- Web/PWA experiment: `app/`
- Current app line: v2.1+

## Product Highlights

- Daily habit tracking for boolean, count, timer, and negative habits
- Schedule-aware routines with grace-period support
- Focus Queue for prioritizing today's remaining habits
- XP, levels, achievements, streak shields, milestones, and habit chains
- Stats, insights, contribution heatmaps, projections, and correlations
- Built-in habit templates, challenges, Pomodoro, journal, and milestone log
- Theme picker with terminal-style palettes
- Local notifications, per-habit reminders, CSV export, and JSON backup
- Firebase Auth with email/password and Google Sign-In support

## Tech Stack

| Layer | Technology |
| --- | --- |
| App | Flutter, Dart |
| State | Provider, ChangeNotifier |
| Storage | SharedPreferences local persistence |
| Auth | Firebase Auth, Google Sign-In |
| Charts | fl_chart |
| Notifications | flutter_local_notifications, timezone |
| Sharing | share_plus, path_provider |
| CI | GitHub Actions |
| Android build | Java 17, Gradle, Flutter stable |
| iOS build | macOS runner, Flutter stable, unsigned artifact by default |

## Repository Layout

```text
.
├── .github/workflows/flutter-build.yml
├── BUILD_INSTRUCTIONS.md
├── README.md
├── app/                    # Earlier web/PWA implementation
└── flutter_app/            # Production Flutter app
    ├── android/
    ├── ios/
    ├── lib/
    │   ├── data/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   ├── stores/
    │   ├── theme/
    │   └── widgets/
    ├── tool/
    ├── app-release.apk
    └── app-release.aab
```

## Android Release Files

The workflow builds Android on every push to `main` and uploads:

- `init-habits-release-apk` for sideload testing
- `init-habits-release-aab` for Google Play Console

On `main`, it also commits the refreshed release files back to:

```text
flutter_app/app-release.apk
flutter_app/app-release.aab
```

Local build:

```powershell
cd D:\Habittracker\flutter_app
$env:JAVA_HOME = "D:\tools\java17"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;$env:Path"
flutter pub get
flutter build apk --release --no-shrink
flutter build appbundle --release --no-shrink
Copy-Item build\app\outputs\flutter-apk\app-release.apk app-release.apk -Force
Copy-Item build\app\outputs\bundle\release\app-release.aab app-release.aab -Force
```

## Android Signing And Google Sign-In

Android package name:

```text
com.inithabits.app
```

Google Sign-In on Android depends on the SHA-1/SHA-256 fingerprint of the signing key. A debug-signed APK and a release-signed APK have different fingerprints.

Recommended production setup:

1. Create a release keystore.
2. Add an Android app in Firebase with package `com.inithabits.app`.
3. Add the keystore SHA-1 and SHA-256 to that Android app in Firebase.
4. Download the updated `google-services.json`.
5. Replace `flutter_app/android/app/google-services.json`.
6. Add these GitHub Actions secrets:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

`ANDROID_KEYSTORE_BASE64` should be the base64-encoded contents of the `.jks` file. When these secrets exist, CI signs the APK with the stable release key. Without them, the workflow falls back to debug signing and prints a warning.

Current CI release signing key configured in GitHub Actions secrets:

```text
SHA-1:   FA:FD:B7:2B:62:18:80:84:B8:24:1E:C5:D1:77:75:E8:33:F3:1E:99
SHA-256: E1:AE:91:65:58:2C:19:CE:60:7F:50:97:B1:75:A4:1B:C5:09:F4:BE:77:13:AE:CD:E5:11:38:19:67:4E:0F:E8
```

Add these two fingerprints to Firebase for the production CI APK, then download the refreshed `google-services.json` and replace `flutter_app/android/app/google-services.json`.

After the package rename to `com.inithabits.app`, the Firebase Android app must use that exact package name. A `google-services.json` generated for the old `com.habittracker` package will not build or sign in correctly.

If Google Sign-In shows `Google Sign-In is not configured for this build`, the APK package name, signing key, and Firebase Android OAuth client do not all match. The current CI APK is signed with:

```text
SHA-1:   FA:FD:B7:2B:62:18:80:84:B8:24:1E:C5:D1:77:75:E8:33:F3:1E:99
SHA-256: E1:AE:91:65:58:2C:19:CE:60:7F:50:97:B1:75:A4:1B:C5:09:F4:BE:77:13:AE:CD:E5:11:38:19:67:4E:0F:E8
```

Add those fingerprints to the `com.inithabits.app` Android app in Firebase, refresh `google-services.json`, and configure the GitHub Actions signing secrets above. Debug signing keys are not a dependable release strategy because local and GitHub runner debug keys can differ.

The config checker can be run locally:

```powershell
cd D:\Habittracker\flutter_app
dart run tool/check_firebase_config.dart --strict
```

The APK signer/Firebase matcher can be run after an APK build:

```powershell
cd D:\Habittracker\flutter_app
dart run tool/verify_apk_firebase_sha.dart --apk build\app\outputs\flutter-apk\app-release.apk
```

## iOS Build And Installation

GitHub Actions builds an unsigned iOS release app on macOS and uploads `init-habits-ios-unsigned-app`. This artifact is useful for verification and later signing, but Apple does not allow installing an unsigned app on a physical iPhone.

Practical install options:

1. TestFlight, recommended:
   Use an Apple Developer account, create signing certificates and provisioning profiles, then build a signed IPA with `flutter build ipa`. Upload it through Xcode Organizer, Transporter, Fastlane, or a future signed CI step.

2. Xcode direct install:
   Open `flutter_app/ios/Runner.xcworkspace` on a Mac, select your Apple team, connect your iPhone, and run the app. A free Apple ID can work for personal testing, but provisioning expires quickly.

3. Simulator:
   Run the app on an iOS Simulator from a Mac:

```bash
cd flutter_app
flutter pub get
flutter run -d ios
```

4. Sideloading tools:
   Tools such as AltStore or Sideloadly can install an IPA signed with your Apple ID. You still need a signed IPA, not the unsigned CI artifact.

## iOS Firebase And Google Sign-In

For iOS Google Sign-In:

1. Add an iOS app in Firebase with bundle ID `com.inithabits.initHabits`.
2. Download `GoogleService-Info.plist`.
3. Put it at `flutter_app/ios/Runner/GoogleService-Info.plist`.
4. Copy its `REVERSED_CLIENT_ID` into `CFBundleURLTypes` in `flutter_app/ios/Runner/Info.plist`.
5. Rebuild on macOS.

An example template is included at:

```text
flutter_app/ios/Runner/GoogleService-Info.plist.example
```

## Development

```powershell
cd D:\Habittracker\flutter_app
flutter pub get
dart format lib test tool
flutter analyze --no-fatal-infos
flutter test
flutter run
```

## CI Workflow

`.github/workflows/flutter-build.yml` currently:

- Builds Android APK and Play Store AAB on Ubuntu
- Builds unsigned iOS app on macOS
- Runs Firebase configuration diagnostics
- Verifies the APK and AAB signing certificates match the Android OAuth SHA in Firebase config
- Runs formatting, analysis, and tests
- Uploads Android and iOS artifacts
- Commits `flutter_app/app-release.apk` and `flutter_app/app-release.aab` back to `main`

## Notes

- `flutter_app/app-release.apk` is committed for easy direct download.
- `flutter_app/app-release.aab` is committed for Google Play Console releases.
- The iOS artifact is intentionally unsigned until Apple signing credentials are configured.
- Firebase API keys in mobile config files identify the Firebase project; access control still belongs in Firebase rules and OAuth configuration.
- The nested `app/` directory is a separate web/PWA implementation and is not the source of the Android/iOS builds.

## License

The project uses the MIT license. See `app/LICENSE`.
