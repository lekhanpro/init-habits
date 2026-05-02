# Building the APK

The Flutter source code is fully implemented and `flutter pub get` succeeded,
but the APK could **not** be built in this session.

## Why the build failed

Your current Android Gradle Plugin (8.11.1) and the project's `compileOptions`
(`JavaVersion.VERSION_17`) require **JDK 17**.

Available on this machine:
- `C:\Program Files\Java\jre1.8.0_351`  → JDK 8 (too old)
- `D:\tools\jre64`                       → JDK 11 (too old)
- **No JDK 17 installed**

## Fix it in 3 steps

### 1. Install JDK 17

**Easiest** — bundled with Android Studio:
- Open Android Studio → `File > Settings > Build, Execution, Deployment > Build Tools > Gradle`
- Note the "Gradle JDK" path (usually `C:\Program Files\Android\Android Studio\jbr`)

**Or** download separately:
- https://learn.microsoft.com/en-us/java/openjdk/download (Microsoft Build of OpenJDK 17)
- https://adoptium.net/temurin/releases/?version=17

### 2. Point Flutter at JDK 17

```bash
flutter config --jdk-dir="C:\path\to\jdk-17"
flutter doctor -v   # verify it picked it up
```

### 3. Build

```bash
cd D:\Habittracker\flutter_app
flutter pub get
flutter build apk --release
```

The APK will land at:
```
D:\Habittracker\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

## What's in this build (vs. the old `app-release.apk` in the repo)

The existing `flutter_app/app-release.apk` is the **OLD** version. It does
NOT have the new features. After you produce a new APK, replace it.

New features added in this pass:
- Weekly strip + motivational tagline + XP/level header on Habits screen
- Long-press a habit row → edit / archive / delete
- Tap a timer-type habit → built-in countdown timer sheet
- Tabbed Stats screen (overview / month / week / habits) with period filters
  (14/30/60/90/180/365/all), 52-week heatmap, weekday %, top-habit streak
- Habit detail screen with mini heatmap + 30-day cumulative trend (fl_chart)
- Daily journal screen (one entry per date)
- Achievements screen with 10 milestones, auto-unlocked
- 3 themes (dark / light / coder) — switch from Profile
- Per-habit reminder time picker (uses `flutter_local_notifications`)
- Notifications toggle in Profile
- Export weekly summary as CSV via system share
- Two new templates: Morning Athlete, Deep Work Pro
- Per-habit weekday scheduling with due-date aware Home, Stats, streaks,
  heatmaps, and weekly strip calculations
- GitHub Actions workflow at `.github/workflows/flutter-build.yml` that installs
  Java 17 + Flutter, runs dependency restore, formatting, analysis, tests, and
  builds/uploads the release APK artifact

## Notes

- Notifications are **best-effort**. On Android 13+ they'll prompt for the
  POST_NOTIFICATIONS permission. The app will keep working if denied.
- The `signingConfig = signingConfigs.getByName("debug")` in
  `android/app/build.gradle.kts` means the release APK is debug-signed.
  Fine for sideloading; not for Play Store.
- I could not run `dart`, `flutter analyze`, or `flutter build` locally because
  neither `dart` nor `flutter` is available on PATH in this shell. The GitHub
  workflow provisions those tools in CI.
