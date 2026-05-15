# init.habits Flutter App

This is the production Flutter app for init.habits. It delivers the mobile habit tracker, Android release build, local-first state, analytics, reminders, and Firebase-ready authentication.

## Current Release

App line: v2.1

Latest APK path:

```text
flutter_app/app-release.apk
```

## What It Includes

- Daily habit tracking for boolean, count, timer, and negative habits
- Schedule-aware routines with configurable grace period
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

## Build Locally

```powershell
cd D:\Habittracker\flutter_app
$env:JAVA_HOME = "D:\tools\java17"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;$env:Path"
flutter pub get
flutter build apk --release --no-shrink
Copy-Item build\app\outputs\flutter-apk\app-release.apk app-release.apk -Force
```

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
6. Verifies `android/app/google-services.json`
7. Builds `flutter build apk --release --no-shrink`
8. Uploads the APK artifact
9. Commits the refreshed `flutter_app/app-release.apk` to `main`

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
