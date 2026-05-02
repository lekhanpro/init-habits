# HABITTRACKER — Terminal-Aesthetic Habit Tracker PWA

## 1. PRODUCT INTERPRETATION

The reference UI is a **terminal-inspired habit tracker** that organizes daily habits into time-based sections (Morning Routine, Deep Work, Wind Down). It uses a dark, information-dense layout with:

- **Design Language**: Terminal/CLI aesthetic — monospace fonts, command-line prompts (`user@init.module $`), neon accent colors on near-black backgrounds, thin separators, no cards or shadows.
- **Core Screens**: Daily habits view (with sections + checkboxes), Stats/Analytics (heatmap, streaks, weekday bars), Profile/Settings.
- **Uniqueness**: The UI feels like a hacker's personal OS dashboard — dense but legible, text-driven, color-coded by category, with progress bars and heatmaps replacing typical tracker UIs.

## 2. VISUAL REPLICATION SPEC

### Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| `bg-primary` | `#0A0A0F` | Main background |
| `bg-secondary` | `#12121A` | Section backgrounds |
| `bg-tertiary` | `#1A1A25` | Elevated surfaces |
| `bg-input` | `#0F0F18` | Input fields |
| `border-primary` | `#1E1E2E` | Main dividers |
| `border-secondary` | `#2A2A3A` | Subtle dividers |
| `text-primary` | `#E8E8ED` | Main text |
| `text-secondary` | `#6B6B80` | Secondary/muted text |
| `text-tertiary` | `#4A4A5A` | Disabled/hint text |
| `accent-green` | `#00FF9F` | Success, streaks, stats |
| `accent-yellow` | `#FFB800` | Morning section |
| `accent-blue` | `#00B4FF` | Deep work section |
| `accent-purple` | `#A855F7` | Wind down section |
| `accent-red` | `#FF4444` | Negative habits, warnings |
| `accent-cyan` | `#22D3EE` | Info, links |
| `accent-orange` | `#FF6B2C` | Highlights |
| `heatmap-0` | `#1A1A25` | No activity |
| `heatmap-1` | `#0D3320` | Low activity |
| `heatmap-2` | `#166534` | Medium activity |
| `heatmap-3` | `#22C55E` | High activity |
| `heatmap-4` | `#00FF9F` | Full activity |

### Typography
- **Primary Font**: JetBrains Mono (monospace)
- **Fallback**: `'JetBrains Mono', 'Fira Code', 'IBM Plex Mono', monospace`
- **Scale**: 10px / 11px / 12px / 13px / 14px / 16px / 20px / 24px
- **Weights**: 400 (regular), 500 (medium), 700 (bold)
- **Line height**: 1.4 for body, 1.2 for headings

### Spacing Scale
`2px / 4px / 6px / 8px / 12px / 16px / 20px / 24px / 32px / 40px / 48px`

### Radius Scale
`0px / 2px / 4px / 6px / 8px` — prefer 2-4px, never rounded/pill

### Borders
- 1px solid `#1E1E2E` for section dividers
- No box shadows anywhere
- No gradients on surfaces

### Progress Bars
- Height: 4px
- Background: `#1E1E2E` (track)
- Fill: section accent color
- Border-radius: 2px

### Icons
- Lucide React, 14-16px, stroke-width 1.5
- Color: `text-secondary` default, accent on active

### Motion
- Duration: 150ms for micro-interactions, 300ms for page transitions
- Easing: `cubic-bezier(0.4, 0, 0.2, 1)`
- No bouncy or spring animations

## 3. SCREEN MAP

### S1: Daily Habits (`/`)
- **Purpose**: Main screen — view and complete today's habits
- **Blocks**: Terminal header, date nav, section groups (Morning/Deep Work/Wind Down), habit rows with checkboxes
- **Interactions**: Tap checkbox to complete, swipe row for actions, tap habit for details

### S2: Stats (`/stats`)
- **Purpose**: Analytics dashboard
- **Blocks**: Summary stats row, contribution heatmap, weekday breakdown bars, streak info, category completion
- **Interactions**: Tap stat for detail, swipe heatmap for months, filter by period

### S3: Profile (`/profile`)
- **Purpose**: User info, settings, mode selector
- **Blocks**: Terminal-style user info, mode selector, settings links, export/import
- **Interactions**: Tap mode to switch, tap setting to navigate

### S4: Habit Detail (`/habit/[id]`)
- **Purpose**: Individual habit analytics and editing
- **Blocks**: Habit header, mini heatmap, streak info, completion log, notes, edit button

### S5: Create/Edit Habit (`/habit/new`, `/habit/[id]/edit`)
- **Purpose**: Form to create or modify a habit
- **Blocks**: Name input, type selector, section assignment, schedule, color, icon

### S6: Settings (`/settings`)
- **Purpose**: App configuration
- **Blocks**: Theme, notifications, data management, about

## 4. UI COMPONENT BREAKDOWN

### TerminalHeader
- Text: `user@habits:~$` in accent-green, followed by command text
- Font: 12px monospace, padding: 12px 16px
- Background: bg-secondary, border-bottom: 1px solid border-primary

### SectionHeader
- Left: colored dot (8px) + section name in section accent color
- Right: completion count (e.g., "3/5")
- Font: 13px bold, padding: 12px 16px 8px
- Border-top: 1px solid border-primary

### HabitRow
- Left: checkbox (18px, square, 2px radius, border: accent color)
- Center: habit name (13px), streak chip if active
- Right: metadata (time/count)
- Padding: 10px 16px, border-bottom: 1px solid border-primary
- Completed state: text gets text-secondary, strikethrough

### StreakChip
- Inline badge: "🔥 12" in 10px, bg: accent-orange/10, color: accent-orange
- Padding: 2px 6px, border-radius: 2px

### ContributionHeatmap
- Grid of 4px squares with 2px gap
- 52 columns (weeks) × 7 rows (days)
- Colors from heatmap palette
- Month labels above in text-tertiary 10px

### WeekdayBars
- 7 vertical bars, each labeled Mon-Sun
- Height proportional to completion rate
- Color: accent-green, background: bg-tertiary
- Width: calc((100% - 48px) / 7)

### StatsRow
- Label in text-secondary 11px
- Value in accent color 20px bold
- Arranged in 2-column grid

### BottomNav
- 3-4 tabs: Habits, Stats, Profile
- Icons 20px, labels 10px
- Active: accent-green, inactive: text-tertiary
- Height: 56px, bg: bg-secondary, border-top

## 5. WEBSITE ARCHITECTURE

```
src/
├── app/
│   ├── layout.tsx          # Root layout with providers
│   ├── page.tsx            # Daily habits screen
│   ├── stats/page.tsx      # Stats screen
│   ├── profile/page.tsx    # Profile screen
│   ├── habit/
│   │   ├── new/page.tsx    # Create habit
│   │   └── [id]/
│   │       ├── page.tsx    # Habit detail
│   │       └── edit/page.tsx
│   ├── settings/page.tsx
│   ├── manifest.ts         # PWA manifest
│   └── globals.css
├── components/
│   ├── layout/
│   │   ├── TerminalHeader.tsx
│   │   ├── BottomNav.tsx
│   │   └── PageShell.tsx
│   ├── habits/
│   │   ├── HabitRow.tsx
│   │   ├── HabitSection.tsx
│   │   ├── HabitCheckbox.tsx
│   │   ├── HabitForm.tsx
│   │   └── StreakChip.tsx
│   ├── stats/
│   │   ├── ContributionHeatmap.tsx
│   │   ├── WeekdayBars.tsx
│   │   ├── StatsGrid.tsx
│   │   └── StreakCard.tsx
│   ├── ui/
│   │   ├── ProgressBar.tsx
│   │   ├── Divider.tsx
│   │   ├── Badge.tsx
│   │   └── IconButton.tsx
│   └── shared/
│       ├── DateNav.tsx
│       └── ModeIndicator.tsx
├── stores/
│   ├── habitStore.ts       # Zustand habit state
│   ├── uiStore.ts          # UI state (active tab, mode)
│   └── analyticsStore.ts   # Computed analytics
├── db/
│   ├── index.ts            # Dexie database
│   ├── habits.ts           # Habit table
│   └── completions.ts      # Completion table
├── lib/
│   ├── analytics.ts        # Analytics calculations
│   ├── dates.ts            # date-fns helpers
│   ├── constants.ts        # Design tokens, enums
│   └── types.ts            # TypeScript types
├── hooks/
│   ├── useHabits.ts
│   ├── useCompletions.ts
│   ├── useAnalytics.ts
│   └── useCurrentDate.ts
└── data/
    └── mockHabits.ts       # Mock data for development
```

## 6. CORE FEATURES

### MVP (Phase 1-3)
- Create/edit/delete habits
- Grouped sections (Morning, Deep Work, Wind Down, Custom)
- Check/uncheck daily completion
- Streak tracking
- Contribution heatmap
- Basic stats (current streak, best streak, completion rate)
- Local-first IndexedDB storage
- PWA installable

### V2 (Phase 4-5)
- Count-based habits (e.g., "Drink 8 glasses")
- Timer habits (e.g., "Meditate 10min")
- Negative habits (e.g., "No social media")
- Notes per completion
- Weekday/custom schedules
- Analytics engine (7d/30d/90d filters)
- Multiple modes (Focus, Deep Work, Minimal, etc.)
- Archive/restore habits

### Advanced (Phase 6-7)
- Reminders/notifications
- Export/import JSON
- Supabase auth + cloud sync
- Mood/energy logging
- Journal entries
- Habit templates
- Desktop adaptive layout

## 7. MODES

| Mode | Purpose | Layout Changes |
|------|---------|---------------|
| Standard | Default balanced view | All sections visible |
| Minimal | Reduce to essentials | Single flat list, no stats |
| Focus | One section at a time | Expanded single section |
| Deep Work | Work habits only | Only Deep Work section, timer prominent |
| Study | Learning-focused | Pomodoro timer, study habits |
| Fitness | Health habits | Exercise + nutrition sections |
| Dopamine Detox | Avoidance habits | Negative habits prominent, blockers |
| Recovery | Gentle restart | Reduced habit count, encouragement |
| Monk | Maximum discipline | All habits, strict tracking, no skips |
| Custom | User-defined | Configurable sections and widgets |

## 8. DATA MODEL

```typescript
interface Habit {
  id: string;
  name: string;
  type: 'boolean' | 'count' | 'timer' | 'negative';
  section: 'morning' | 'deep_work' | 'wind_down' | 'custom';
  color: string;
  icon?: string;
  targetCount?: number;
  targetMinutes?: number;
  schedule: number[]; // 0-6 for days of week, empty = daily
  order: number;
  archived: boolean;
  createdAt: string;
  updatedAt: string;
}

interface Completion {
  id: string;
  habitId: string;
  date: string; // YYYY-MM-DD
  completed: boolean;
  value?: number; // for count/timer
  note?: string;
  createdAt: string;
}

interface ModeConfig {
  id: string;
  mode: string;
  visibleSections: string[];
  widgets: string[];
  isActive: boolean;
}

interface Settings {
  id: string;
  theme: 'dark'; // only dark for now
  mode: string;
  weekStartsOn: 0 | 1;
  notificationsEnabled: boolean;
  userName: string;
}
```

## 9. ANALYTICS ENGINE

- **Current Streak**: Count consecutive days with ≥1 completion backward from today
- **Best Streak**: Max consecutive days ever
- **Perfect Days**: Days where ALL scheduled habits completed
- **Completion Rate**: (completed / scheduled) × 100 for period
- **Weekday Breakdown**: Avg completion rate per day of week
- **Heatmap**: Daily completion count mapped to 0-4 intensity scale
- **Momentum Score**: Weighted avg of last 7 days (recent days weighted more)
- **Discipline Score**: `(currentStreak / bestStreak) × completionRate30d`

## 10. INTERACTION RULES

- **Tap checkbox**: Toggle completion with 150ms scale animation
- **Tap habit row**: Navigate to detail
- **Long-press row**: Show quick actions (edit, archive, skip)
- **Swipe left**: Archive
- **Swipe right**: Add note
- **Pull down**: Refresh date
- **All animations**: 150ms ease-out, no spring physics
- **Loading**: Skeleton with bg-tertiary pulse
- **Empty**: Terminal-style message "no habits found. run `add --habit` to begin."

## 11-12. IMPLEMENTATION PHASES & BUILD ORDER

### Phase 1: Static UI (Tasks 1-10)
1. Initialize Next.js + TypeScript + Tailwind
2. Configure fonts (JetBrains Mono)
3. Set up design tokens in Tailwind config
4. Create globals.css with base styles
5. Build PageShell + BottomNav layout
6. Build TerminalHeader component
7. Build HabitSection + HabitRow components
8. Build mock data
9. Assemble Daily Habits screen
10. Build Stats screen with heatmap + bars

### Phase 2: Interactive Frontend (Tasks 11-17)
11. Set up Zustand stores
12. Wire checkbox interactions
13. Build DateNav for day switching
14. Build HabitForm (create/edit)
15. Build habit detail page
16. Add Framer Motion animations
17. Build Profile screen

### Phase 3: Persistence (Tasks 18-22)
18. Set up Dexie database
19. Migrate stores to use Dexie
20. Implement CRUD operations
21. Add date-based queries
22. Test offline behavior

### Phase 4: Analytics (Tasks 23-26)
23. Implement streak calculations
24. Build analytics computation layer
25. Wire stats screen to real data
26. Add period filters

### Phase 5: Polish + PWA (Tasks 27-30)
27. PWA manifest + service worker
28. Add meta tags + icons
29. Responsive desktop adaptation
30. Final polish pass

## 13. CODE GENERATION STRATEGY

- Build layout shell first (PageShell, BottomNav) — validates overall feel
- Then atomic components (HabitRow, ProgressBar, Badge)
- Then composite screens assembled from components
- Mock data in `/data/mockHabits.ts` — never inline fake data
- Validate against reference at each component level
- Keep all colors in Tailwind config, never hardcode hex in components

## 14. FINAL STACK

| Concern | Choice |
|---------|--------|
| Framework | Next.js 15 App Router |
| Language | TypeScript |
| Styling | Tailwind CSS v4 |
| Animation | Framer Motion |
| State | Zustand |
| Database | Dexie (IndexedDB) |
| Forms | React Hook Form + Zod |
| Charts | Custom SVG/CSS |
| Dates | date-fns |
| Icons | Lucide React |
| Auth (later) | Supabase |
| Deploy | Vercel |
