# init.habits Flutter App

This is the production Flutter app for init.habits. It delivers the mobile habit tracker, Android release build, unsigned iOS build artifact, local-first state, analytics, reminders, and Firebase-ready authentication.

## Current Release

App line: v2.1

Latest APK path:

```text
flutter_app/app-release.apk
```

## What It Includes

- Daily habit tracking for boolean, count, timer, and negative habits
- Schedule-aware routines with configurable grace period
- Focus Queue for prioritizing today's remaining habits
- XP, levels, achievements, streak shields, milestones, and habit chains
- Stats, insights, per-habit detail, contribution views, and score trends
- Templates, challenges, Pomodoro flow, journal, and milestone log
- Theme picker with terminal-inspired palettes
- Local notifications, reminders, CSV export, and JSON backup
- Firebase auth scaffold with Android Google services configuration

## Tech Stack

```text
Flutter / Dart
Provider
SharedPreferences
Firebase Core + Firebase Auth
Google Sign-In
flutter_local_notifications
timezone
fl_chart
share_plus
path_provider
google_fonts
uuid
```

## Build Android Locally

```powershell
cd D:\Habittracker\flutter_app
$env:JAVA_HOME = "D:\tools\java17"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;$env:Path"
flutter pub get
flutter build apk --release --no-shrink
Copy-Item build\app\outputs\flutter-apk\app-release.apk app-release.apk -Force
```

## Build iOS Locally

iOS builds require macOS and Xcode.

```bash
cd flutter_app
flutter pub get
flutter build ios --release --no-codesign
```

The unsigned build is useful for CI validation. To install on a physical iPhone, sign the app through Xcode, TestFlight, or another Apple signing flow.

## Firebase Auth Configuration

```bash
dart run tool/check_firebase_config.dart --strict
```

Android Google Sign-In needs an Android OAuth client in `android/app/google-services.json` with the SHA-1/SHA-256 of the APK signing key. iOS Google Sign-In needs `ios/Runner/GoogleService-Info.plist` and the `REVERSED_CLIENT_ID` URL scheme in `ios/Runner/Info.plist`.

## Validate

```powershell
cd D:\Habittracker\flutter_app
flutter analyze --no-fatal-infos
flutter test
```

## CI/CD

The release workflow lives at:

```text
D:\Habittracker\.github\workflows\flutter-build.yml
```

On push to `main`, GitHub Actions:

1. Checks out the repository
2. Installs Java 17 and Flutter stable
3. Restores dependencies
4. Formats Dart sources
5. Runs analysis and tests as non-blocking checks
6. Runs Firebase configuration diagnostics
7. Builds `flutter build apk --release --no-shrink`
8. Builds `flutter build ios --release --no-codesign`
9. Uploads Android and iOS artifacts
10. Commits the refreshed `flutter_app/app-release.apk` to `main`

## Source Layout

```text
lib/
  data/       Built-in templates
  models/     Habit, achievement, chain, challenge, milestone, settings models
  screens/    Habits, stats, insights, profile, templates, challenges, Pomodoro, journal
  services/   Auth, notifications, reminders, export
  stores/     HabitStore and analytics logic
  theme/      App theme controller and palettes
  widgets/    Shared UI components
```

init.habits is built for a dense, professional, terminal-style habit tracking experience.
