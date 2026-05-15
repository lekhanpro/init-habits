# Building the APK

The production Android app is in `flutter_app/`. The committed APK is kept at:

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

The workflow at `.github/workflows/flutter-build.yml` mirrors the local release path:

1. Install Java 17
2. Install Flutter stable
3. Run `flutter pub get`
4. Format Dart sources
5. Run analysis and tests as non-blocking checks
6. Verify `android/app/google-services.json`
7. Build `flutter build apk --release --no-shrink`
8. Upload the APK artifact
9. Commit `flutter_app/app-release.apk` back to `main`

## Release Notes

The current app line is v2.1 and includes:

- Templates, challenges, Pomodoro, milestone log, and journal upgrades
- Streak shields, sparkline progress, XP, achievements, and chains
- Stats, insights, heatmaps, projections, and habit correlations
- Theme picker, reminders, notifications toggle, CSV export, and JSON backup
- Firebase-ready Android auth configuration

## Signing Note

`android/app/build.gradle.kts` uses the debug signing config for release builds. That is suitable for sideloading and testing, but a Play Store release should use a dedicated upload keystore.
