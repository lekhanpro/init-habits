# init.habits

> A terminal-aesthetic habit tracker PWA for disciplined minds.

![Next.js](https://img.shields.io/badge/Next.js-15-black?style=flat-square)
![TypeScript](https://img.shields.io/badge/TypeScript-5-blue?style=flat-square)
![Tailwind](https://img.shields.io/badge/Tailwind-4-06B6D4?style=flat-square)
![PWA](https://img.shields.io/badge/PWA-ready-00FF9F?style=flat-square)

## What is this?

A dark, terminal-inspired habit tracker that feels like a hacker's personal OS dashboard. No bubbly cards, no glassmorphism — just dense, elegant, information-rich tracking.

### Design Philosophy

- **Terminal aesthetic** — monospace fonts, CLI-style prompts, neon accents on near-black
- **Information density** — see everything at a glance without scrolling
- **Section-based** — Morning Routine / Deep Work / Wind Down habit groups
- **Stats-driven** — contribution heatmaps, streak tracking, weekday breakdowns

## Features

- Daily habit tracking with sections (Morning, Deep Work, Wind Down)
- Streak tracking with visual indicators
- Contribution heatmap (GitHub-style)
- Weekday completion breakdown
- Create habits (boolean, count, timer, negative)
- Multiple tracking modes (Standard, Focus, Monk, etc.)
- PWA installable, mobile-first
- Local-first architecture

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 15 (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS v4 |
| Animation | Framer Motion |
| State | Zustand |
| Icons | Lucide React |
| Font | JetBrains Mono |

## Getting Started

```bash
pnpm install
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000).

## Screens

- `/` — Daily habits with sections and checkboxes
- `/stats` — Analytics dashboard (heatmap, streaks, bars)
- `/profile` — User info, mode selector, settings
- `/habit/new` — Create a new habit

## License

MIT
