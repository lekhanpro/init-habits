# init.habits

init.habits is a polished Flutter habit tracker with a terminal-inspired interface, local-first tracking, analytics, streak systems, templates, challenges, journaling, and Android APK delivery through GitHub Actions.

The repository also contains the earlier web/PWA experiment under `app/`, but the production mobile app and release APK live in `flutter_app/`.

## Highlights

- Daily habit tracking with boolean, count, timer, and negative habits
- Schedule-aware habits with grace-period support for early-morning completions
- XP, levels, achievements, streak shields, milestones, and habit chains
- Insights dashboard with scores, streak projections, correlations, and rankings
- Stats views for daily, weekly, monthly, and per-habit performance
- Built-in templates, challenges, Pomodoro flow, journal, and milestone log
- Theme system with terminal-style palettes
- Local reminders, CSV export, and JSON backup support
- Firebase-ready authentication scaffold with committed Android config

## Android APK

The latest committed APK is:

```text
flutter_app/app-release.apk
```

To build it locally:

```powershell
cd D:\Habittracker\flutter_app
$env:JAVA_HOME = "D:\tools\java17"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;$env:Path"
flutter pub get
flutter build apk --release --no-shrink
Copy-Item build\app\outputs\flutter-apk\app-release.apk app-release.apk -Force
```

The workflow in `.github/workflows/flutter-build.yml` runs the same release build on GitHub Actions, uploads the APK artifact, and commits `flutter_app/app-release.apk` back to `main` after successful pushes.

## Requirements

- Flutter 3.41 or newer
- Dart 3.11 or newer
- JDK 17
- Android SDK and platform tools

## Development

```powershell
cd D:\Habittracker\flutter_app
flutter pub get
flutter analyze
flutter test
flutter run
```

## Project Structure

```text
flutter_app/
  android/              Android project and release configuration
  assets/               App icon and generated visual assets
  lib/
    data/               Built-in habit templates
    models/             Habits, achievements, chains, challenges, settings
    screens/            Main app screens and workflows
    services/           Auth, notifications, reminders, export
    stores/             Local-first habit state and analytics
    theme/              App theme controller and palettes
    widgets/            Reusable UI components
  app-release.apk       Latest committed release APK

.github/workflows/
  flutter-build.yml     CI build, artifact upload, and APK commit workflow
```

## Release Notes

Current app line: v2.1

- Templates, challenges, Pomodoro, milestone log, and upgraded journal
- Streak shields and sparkline improvements
- Firebase-backed auth configuration for Android APK builds
- CI workflow aligned with Java 17 and Flutter stable

## License

See `app/LICENSE` for the MIT license used by the project.
