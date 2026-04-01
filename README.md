<div align="center">

# `> init.habits_`

**A terminal-aesthetic habit tracker PWA for disciplined minds.**

[Live Demo](https://app-lake-psi-78.vercel.app) &nbsp;&middot;&nbsp; [Report Bug](https://github.com/lekhanpro/init-habits/issues) &nbsp;&middot;&nbsp; [Request Feature](https://github.com/lekhanpro/init-habits/issues)

![Next.js](https://img.shields.io/badge/Next.js-16-000000?style=for-the-badge&logo=nextdotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)
![Vercel](https://img.shields.io/badge/Deployed_on-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![PWA](https://img.shields.io/badge/PWA-Ready-00FF9F?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-A855F7?style=for-the-badge)

</div>

---

## About

**init.habits** is a dark, terminal-inspired habit tracker that feels like a hacker's personal OS dashboard. No bubbly cards, no glassmorphism, no generic SaaS design — just dense, elegant, information-rich tracking built for people who take discipline seriously.

```
user@init.habits:~$ habits.today()
> loading morning_routine... ████████░░ 80%
> loading deep_work...       ██████░░░░ 60%
> loading wind_down...       ████░░░░░░ 40%
```

### Why this exists

Most habit trackers look like toy apps. This one looks like it belongs on the screen of someone who actually ships. Terminal aesthetics, monospace typography, neon accents on near-black — because your productivity tools should match your intensity.

---

## Live Demo

**https://app-lake-psi-78.vercel.app**

> Mobile-first. Open it on your phone for the intended experience.

---

## Design Philosophy

| Principle | Implementation |
|-----------|---------------|
| **Terminal aesthetic** | Monospace fonts, CLI-style prompts (`user@init.habits:~$`), neon accents on `#0A0A0F` |
| **Information density** | See everything at a glance — no wasted space, no empty cards |
| **Section-based flow** | Habits organized into Morning Routine / Deep Work / Wind Down |
| **Stats-driven** | Contribution heatmaps, streak chips, weekday breakdowns, progress bars |
| **Zero decoration** | No shadows, no gradients, no rounded bubbly UI — just data and color |

---

## Features

### Core Tracking
- **Daily habit tracking** with time-based sections (Morning, Deep Work, Wind Down)
- **Multiple habit types** — boolean (yes/no), count-based, timer, negative (habits to avoid)
- **Streak tracking** with fire chip indicators on active streaks
- **Section progress bars** showing completion rate per group
- **Date navigation** to review past days

### Analytics
- **Contribution heatmap** — GitHub-style activity grid for the last 20 weeks
- **Weekday breakdown** — bar chart showing which days you're most consistent
- **Stats grid** — current streak, best streak, 7-day rate, perfect days, total completions
- **Category breakdown** — progress bars per section with percentage

### Interface
- **Terminal header** with CLI-style prompts and timestamps
- **Bottom navigation** with animated active indicator
- **Mode selector** — Standard, Minimal, Focus, Deep Work, Study, Fitness, Monk, Detox
- **Create habit form** with type and section selection
- **Empty states** with terminal-style messaging

### Technical
- **PWA installable** — add to home screen on mobile
- **Mobile-first** — designed for phone viewports, adapts to desktop
- **Local-first architecture** — works offline, data stays on device
- **60fps animations** via Framer Motion

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | [Next.js 16](https://nextjs.org) | App Router, SSG, file-based routing |
| Language | [TypeScript](https://typescriptlang.org) | Type safety across the codebase |
| Styling | [Tailwind CSS v4](https://tailwindcss.com) | Utility-first with custom design tokens |
| Animation | [Framer Motion](https://motion.dev) | Checkbox scales, nav indicator, transitions |
| State | [Zustand](https://zustand.docs.pmnd.rs) | Lightweight global state management |
| Database | [Dexie](https://dexie.org) | IndexedDB wrapper for local-first persistence |
| Forms | [React Hook Form](https://react-hook-form.com) + [Zod](https://zod.dev) | Validated habit creation |
| Icons | [Lucide React](https://lucide.dev) | Consistent 1.5px stroke icons |
| Dates | [date-fns](https://date-fns.org) | Lightweight date manipulation |
| Font | [JetBrains Mono](https://www.jetbrains.com/lp/mono/) | Monospace typography throughout |
| Deploy | [Vercel](https://vercel.com) | Edge deployment with automatic CI/CD |

---

## Project Structure

```
src/
├── app/
│   ├── layout.tsx              # Root layout, fonts, metadata, PWA config
│   ├── page.tsx                # Daily habits screen
│   ├── globals.css             # Design tokens, scrollbar, base styles
│   ├── stats/page.tsx          # Analytics dashboard
│   ├── profile/page.tsx        # User profile, modes, settings
│   └── habit/new/page.tsx      # Create new habit form
├── components/
│   ├── layout/
│   │   ├── BottomNav.tsx       # Tab navigation with animated indicator
│   │   ├── TerminalHeader.tsx  # CLI-style header with user@host prompt
│   │   └── PageShell.tsx       # Page wrapper with nav
│   ├── habits/
│   │   ├── HabitRow.tsx        # Individual habit with checkbox + streak
│   │   ├── HabitSection.tsx    # Section group (Morning/Deep Work/Wind Down)
│   │   ├── HabitCheckbox.tsx   # Animated checkbox with accent colors
│   │   ├── DateNav.tsx         # Date picker with arrows
│   │   └── StreakChip.tsx      # Fire emoji badge for active streaks
│   └── stats/
│       ├── StatsGrid.tsx       # 2-column stat cards
│       ├── ContributionHeatmap.tsx  # SVG activity grid
│       └── WeekdayBars.tsx     # 7-day completion bar chart
├── stores/
│   └── habitStore.ts           # Zustand store for habits + completions
├── lib/
│   └── types.ts                # TypeScript interfaces + section config
├── data/
│   └── mockHabits.ts           # 13 habits + 90 days of generated data
└── public/
    └── manifest.json           # PWA manifest
```

---

## Screens

### `/` — Daily Habits
The main screen. Habits grouped into color-coded sections with checkboxes, streak indicators, and per-section progress bars. Terminal header shows current date and command prompt.

### `/stats` — Analytics
Dashboard with contribution heatmap (20 weeks), weekday completion bars, stat cards (streak, rate, perfect days), and category breakdown with progress bars.

### `/profile` — Profile & Modes
User session info, 8-mode selector grid (Standard, Minimal, Focus, Deep Work, Study, Fitness, Monk, Detox), and settings links for export/import.

### `/habit/new` — Create Habit
Terminal-styled form to add a new habit. Select type (boolean/count/timer/negative) and section assignment. Submit button styled as a shell command.

---

## Color System

| Token | Hex | Usage |
|-------|-----|-------|
| `bg-primary` | `#0A0A0F` | Main background |
| `bg-secondary` | `#12121A` | Headers, nav, elevated surfaces |
| `bg-tertiary` | `#1A1A25` | Cards, chart backgrounds |
| `accent-green` | `#00FF9F` | Success, active states, primary accent |
| `accent-yellow` | `#FFB800` | Morning section |
| `accent-blue` | `#00B4FF` | Deep Work section |
| `accent-purple` | `#A855F7` | Wind Down section |
| `accent-red` | `#FF4444` | Negative habits, warnings |
| `accent-cyan` | `#22D3EE` | Info, links, custom section |
| `accent-orange` | `#FF6B2C` | Streak indicators, highlights |

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org) 18+
- [pnpm](https://pnpm.io) 9+

### Installation

```bash
# Clone the repository
git clone https://github.com/lekhanpro/init-habits.git
cd init-habits

# Install dependencies
pnpm install

# Start development server
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build for Production

```bash
pnpm build
pnpm start
```

### Deploy to Vercel

The project auto-deploys on push to `main` via Vercel Git integration. For manual deployment:

```bash
vercel --prod
```

---

## Roadmap

### V2
- [ ] IndexedDB persistence with Dexie (replace mock data)
- [ ] Timer habits with live countdown
- [ ] Count-based habit increments (tap to +1)
- [ ] Notes per completion
- [ ] Custom habit schedules (weekdays only, specific days)
- [ ] Habit archive/restore

### V3
- [ ] Export/import data as JSON
- [ ] Notification reminders
- [ ] Mood and energy logging
- [ ] Journal entries
- [ ] Deep analytics (momentum score, burnout detection, discipline score)
- [ ] Desktop adaptive layout

### V4
- [ ] Supabase auth + cloud sync
- [ ] Habit templates and presets
- [ ] Social sharing of streaks
- [ ] Custom mode builder
- [ ] Keyboard shortcuts for desktop

---

## Contributing

Contributions are welcome. Please open an issue first to discuss what you'd like to change.

1. Fork the repository
2. Create your branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">

**Built with discipline.**

`user@init.habits:~$ exit`

</div>
