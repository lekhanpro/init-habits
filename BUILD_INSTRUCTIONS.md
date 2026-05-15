# Building Android And iOS

The production mobile app is in `flutter_app/`. The committed Android APK is kept at:

```text
D:\Habittracker\flutter_app\app-release.apk
```

## Local Build

This machine has a usable Flutter SDK at `D:\flutter` and JDK 17 at `D:\tools\java17`.

```powershell
cd D:\Habittracker\flutter_app
$env:JAVA_HOME = "D:\tools\java17"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;$env:Path"
flutter pub get
flutter build apk --release --no-shrink
Copy-Item build\app\outputs\flutter-apk\app-release.apk app-release.apk -Force
```

The build output is:

```text
D:\Habittracker\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

## GitHub Actions Build

The workflow at `.github/workflows/flutter-build.yml` builds Android and iOS artifacts:

1. Install Java 17 for Android
2. Install Flutter stable
3. Run `flutter pub get`
4. Run Firebase configuration diagnostics
5. Format Dart sources
6. Run analysis and tests as non-blocking checks
7. Build `flutter build apk --release --no-shrink`
8. Build `flutter build ios --release --no-codesign` on macOS
9. Upload Android and iOS artifacts
10. Commit `flutter_app/app-release.apk` back to `main`

## Android Signing

Google Sign-In requires the APK signing key SHA-1/SHA-256 to be registered in Firebase. For a stable CI APK, configure these GitHub secrets:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

Without those secrets, CI falls back to debug signing. The APK can still be installed, but Google Sign-In may fail unless Firebase has the debug key fingerprint for that exact build.

## iOS Install Path

CI uploads an unsigned iOS `Runner.app` zip. It cannot be installed on a physical iPhone until it is signed by Apple.

Use one of these paths:

- TestFlight for production-style testing
- Xcode direct install on a Mac for personal devices
- iOS Simulator for local validation
- AltStore or Sideloadly with a signed IPA

For Google Sign-In on iOS, add `ios/Runner/GoogleService-Info.plist` and the `REVERSED_CLIENT_ID` URL scheme in `ios/Runner/Info.plist`.

## Release Notes

The current app line is v2.1 and includes:

- Templates, challenges, Pomodoro, milestone log, and journal upgrades
- Focus Queue for prioritizing today's remaining habits
- Streak shields, sparkline progress, XP, achievements, and chains
- Stats, insights, heatmaps, projections, and habit correlations
- Theme picker, reminders, notifications toggle, CSV export, and JSON backup
- Firebase-ready auth configuration diagnostics

## Signing Note

`android/app/build.gradle.kts` uses the debug signing config for release builds. That is suitable for sideloading and testing, but a Play Store release should use a dedicated upload keystore.
