# init.habits

```
 ██╗███╗   ██╗██╗████████╗   ██╗  ██╗ █████╗ ██████╗ ██╗████████╗███████╗
 ██║████╗  ██║██║╚══██╔══╝   ██║  ██║██╔══██╗██╔══██╗██║╚══██╔══╝██╔════╝
 ██║██╔██╗ ██║██║   ██║      ███████║███████║██████╔╝██║   ██║   ███████╗
 ██║██║╚██╗██║██║   ██║      ██╔══██║██╔══██║██╔══██╗██║   ██║   ╚════██║
 ██║██║ ╚████║██║   ██║      ██║  ██║██║  ██║██████╔╝██║   ██║   ███████║
 ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝   ╚═╝   ╚══════╝
                         v2.0.0 — built with discipline
```

> A terminal-aesthetic habit tracker with CLI look-and-feel, monospace fonts, 12 colour themes, GitHub-style contribution graphs, streaks, habit scoring, chains, and a full XP/levelling system.

---

## Features

### Core Tracking
- **Daily habit check-in** — boolean, count, and timer habits
- **Grace period** — completions logged before N:00 AM count for the previous day
- **Schedule-aware** — set habits to specific weekdays or `x per week`
- **Negative habits** — track things you want to stop

### Habit Intelligence
- **Habit Score (EMA)** — Loop Habit Tracker algorithm, converges to 100% after ~13 perfect days, visualised as a live bar `[████████░░] 82%`
- **14-day sparkline** — mini bar chart showing score momentum on each habit detail screen
- **Predictive insights** — streak projection, weakest habit of the week, best performance window, weekday vs weekend ratio
- **Habit correlations** — automatically surfaces which habits you tend to do together

### Streak System
- **Current & best streak** tracked per-habit and globally
- **Streak Shields** — earned at 7 / 14 / 30-day milestones (bronze / silver / gold), consume instead of breaking a streak
- **Habit Chains** — link habits that you always do in sequence; chain progress bar shows completion flow

### XP & Levelling 2.0
| Level | Name | XP Required |
|-------|------|-------------|
| 1 | Initiate | 0 |
| 2 | Apprentice | 200 |
| 3 | Journeyman | 400 |
| 4 | Specialist | 600 |
| 5 | Expert | 800 |
| 6 | Master | 1 000 |
| 7 | Grandmaster | 1 200 |
| 8 | Legend | 1 400 |
| 9 | Transcendent | 1 600 |
| 10 | [REDACTED] | 1 800 |

XP per completion = `base(10) × difficulty_multiplier × streak_multiplier`  
Streak multiplier caps at 2× after 140 days.

### Difficulty System
Each habit carries a multiplier that scales XP and affects leaderboard ranking:

| Difficulty | XP Multiplier |
|-----------|--------------|
| Easy      | ×0.5         |
| Normal    | ×1.0         |
| Hard      | ×1.5         |
| Extreme   | ×2.0         |

### Achievements (38 total, 3 hidden)
Organised into 5 categories: **Consistency**, **Volume**, **Diversity**, **Time**, **Hidden**

Hidden achievements include 🦉 *Night Owl* (5 late-night completions), 🌅 *Early Bird* (7 before-6am days), and 💯 *The Hundred* (100-day current streak).

### 12 Colour Themes
| Theme | Description |
|-------|-------------|
| 🌑 dark | Default dark terminal |
| ☀️ light | Clean light mode |
| 💻 coder | Classic green-on-black |
| 🌊 synthwave | Purple neon cyberpunk |
| 🐇 matrix | Deep green matrix rain |
| 🌤 solarized | Ethan Schoonover's Solarized |
| 🪵 gruvbox | Warm retro woodland |
| ☕ catppuccin | Catppuccin Mocha pastel |
| ❄️ nord | Arctic blue-grey |
| 🧛 dracula | Purple-green dracula |
| 🔵 one dark | Atom One Dark |
| 🌆 tokyo night | Pastel city at night |

### Navigation
- **Habits** — daily check-in with week strip and contribution graph
- **Stats** — overview, monthly, weekly, and per-habit breakdowns
- **+ Add** — create or edit habits with schedule, difficulty, reminders
- **Insights** — EMA scores, leaderboard (sort by streak / score / xp), predictive analysis, correlations
- **Profile** — theme picker, templates, achievements, chains, settings, export

### Settings
- Grace period (0–3 h)
- Notifications toggle
- Export: weekly CSV or full JSON backup

---

## Tech Stack

```
Flutter 3.x (Dart)
Provider           — state management
SharedPreferences  — local persistence
fl_chart           — trend & bar charts
google_fonts       — JetBrains Mono + Fira Code
flutter_local_notifications — reminders
share_plus         — CSV / JSON export
firebase_core      — optional auth scaffold
uuid               — stable IDs
```

## Build

```bash
# Prerequisites: Flutter SDK, Android Studio / Xcode

cd flutter_app
flutter pub get
flutter run            # debug
flutter build apk --release --no-shrink   # Android release
flutter build ios --release               # iOS release
```

## CI/CD

GitHub Actions workflow at `.github/workflows/flutter-build.yml`:

1. Sets up Java 17 + Flutter stable
2. Runs `flutter analyze` (non-blocking) and `flutter test`
3. Generates placeholder `google-services.json` for CI
4. Builds release APK with `--no-shrink`
5. Uploads APK as workflow artifact
6. Commits `app-release.apk` back to `main` branch

---

## Project Structure

```
flutter_app/
├── lib/
│   ├── models/
│   │   ├── habit.dart          # Habit, Completion, enums (v2 + difficulty + shield + chain)
│   │   ├── chain.dart          # HabitChain
│   │   ├── achievement.dart    # 38 achievements across 5 categories
│   │   ├── settings.dart       # AppSettings + 12 AppThemeMode values
│   │   └── mode.dart           # Preset habit templates
│   ├── stores/
│   │   └── habit_store.dart    # All state, analytics, EMA scoring, chains, XP 2.0
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── stats_screen.dart
│   │   ├── insights_screen.dart   ← NEW
│   │   ├── chains_screen.dart     ← NEW
│   │   ├── settings_screen.dart   ← NEW
│   │   ├── habit_detail_screen.dart
│   │   ├── add_habit_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── achievements_screen.dart
│   │   └── journal_screen.dart
│   ├── theme/
│   │   └── app_theme.dart      # 12 palettes + ThemeController + AppColors
│   └── widgets/
│       └── terminal_header.dart
└── android/
    └── app/build.gradle.kts    # AGP 8.7.3, Kotlin 2.0.21, Java 17
```

---

*init.habits — because discipline compounds.*
