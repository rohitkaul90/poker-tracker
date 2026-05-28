# TableLab

A Flutter poker bankroll tracker and study tool for live cash games and tournaments.

## Features

- **Session tracking** — log cash game and tournament sessions with buy-in, cash-out, rake, location, and notes
- **Hand history** — record and replay individual hands with street-by-street action
- **Reads** — build opponent profiles with tags and observations; get GTO-grounded coaching tips per player type
- **Analytics** — profit/loss charts, win rate by stakes and location, session history with filtering
- **AI analysis** — Claude-powered session and hand coaching via Supabase Edge Functions (10 analyses/day)
- **Equity calculator** — offline hand-vs-range equity via Monte Carlo simulation
- **ICM calculator** — fair chip-chop deal calculations at final tables
- **Tournament calendar** — scraped upcoming tournament listings
- **Import/Export** — CSV and Excel import (with column mapping) and export

## Tech stack

- Flutter (Dart) — Material 3, dark theme
- Riverpod — state management
- Supabase — Postgres database, auth (email + Google OAuth), realtime, Edge Functions
- Claude API — AI coaching via Supabase Edge Functions (Deno)

## Getting started

**Prerequisites:** Flutter SDK ≥ 3.12, a Supabase project

```bash
flutter pub get
flutter run
```

**Web (GitHub Pages):**
```bash
flutter build web --base-href /poker-tracker/
```
The `--base-href` flag is required for correct asset resolution on GitHub Pages.

## Project structure

```
lib/
  auth/           # AuthGate (Supabase session gating)
  config/         # Supabase credentials
  equity/         # Offline hand evaluator + Monte Carlo simulator
  models/         # Immutable data models
  providers/      # Riverpod providers
  reads/          # Insights engine + tag definitions
  screens/        # One file per screen
  services/       # Supabase service layer
  widgets/        # Shared UI components
supabase/
  functions/      # Deno Edge Functions (analyze-session, analyze-hand, scrape-tournaments)
  migrations/     # SQL migrations
```
