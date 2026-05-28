# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run

# Build
flutter build apk
flutter build web --base-href /poker-tracker/   # GitHub Pages deployment

# Dependencies
flutter pub get

# Static analysis (lint)
flutter analyze

# Tests
flutter test

# Code generation (Riverpod @riverpod annotations, if added)
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

**TableLab** is a Flutter poker bankroll tracker. Package name: `tablelab`. Dark Material 3 theme, seed color `#1B5E20`.

### State management — Riverpod

All providers live in `lib/providers/`. Pattern: service classes are plain Dart (no Riverpod), wrapped in `Provider<>` at the provider layer.

- `providers.dart` — sessions, filter, hands, AI service providers
- `reads_provider.dart` — player reads stream
- `profile_provider.dart` — user profile

Key providers:
- `sessionsProvider` — `StreamProvider` backed by Supabase realtime
- `filteredSessionsProvider` — derived from `sessionsProvider` + `filterProvider`
- `handsProvider` — `FutureProvider` (fetch-once, not realtime)

### Navigation

`main.dart → AuthGate → MainNavigation`

`MainNavigation` is an `IndexedStack` with a `NavigationBar` (5 tabs: Dashboard, Sessions, Hands, Reads, Calendar). The side drawer (`AppDrawer`) is mounted on the root scaffold via `mainScaffoldKey` (a `GlobalKey<ScaffoldState>` in `app_drawer.dart`) — any screen can open the drawer using this key.

Drawer sections: **Home** (pops to root) → **Tools** (Equity Calculator, ICM Calculator) → **App** (Help, About, Privacy, Feedback) → **Sign Out** (pinned).

### Backend — Supabase

All data is user-scoped via Row Level Security. Every table has `user_id uuid references auth.users` with RLS policies. Credentials are hardcoded in `lib/config/supabase_config.dart` (anon key — public by design for Supabase).

**Tables:**
- `sessions` — core session records
- `hands` — poker hands stored as JSONB in `hand_data` column; `session_id` is nullable (hands can exist without a session)
- `player_reads` + `player_read_notes` — opponent profiling
- `rake_presets` — saved rake amounts per location/game/stakes combo
- `profiles` — display name, phone, preferences
- `ai_analyses` / `ai_hand_analyses` — cached AI results
- `ai_usage_log` — rate-limit tracking (10 calls/day enforced in Edge Functions)
- `tournament_listings` — scraped tournament schedule (shared, not user-scoped)

**Supabase Edge Functions** (Deno, in `supabase/functions/`):
- `analyze-session` — calls Claude API, caches result in `ai_analyses`
- `analyze-hand` — calls Claude API, caches result in `ai_hand_analyses`
- `scrape-tournaments` — scrapes tournament listings

### Services

All Supabase calls go through `withSupabaseRetry()` (`lib/services/supabase_retry.dart`), which retries once on PGRST303 (JWT issued-at-future, caused by device clock skew).

- `SupabaseService` — session CRUD + realtime stream, rake presets, tournament listings
- `HandService` — hand CRUD; generates UUIDs client-side
- `ReadsService` — player read profiles + individual observation notes
- `ProfileService` — profile fetch/upsert
- `AiService` — invokes the two Edge Functions; throws if response contains `error` key

### Pure Dart subsystems

- **`lib/equity/`** — offline equity calculator: `card.dart` (card encoding), `evaluator.dart` (7-card evaluator via brute-force 5-card combinations), `simulator.dart` (Monte Carlo), `gto_ranges.dart` (preflop range matrices)
- **`lib/reads/`** — `insights_engine.dart` (rule-based coaching tips from player tags), `tag_definitions.dart` (archetype/tendency tag metadata)

### Models

`SessionModel` uses `fromMap()` (snake_case DB columns → camelCase Dart). `PokerHand` uses `fromJson()`/`toJson()` (the entire hand is serialized as JSONB). Models are immutable plain classes — no code generation.

### Import/Export

`ImportExportScreen` handles CSV and Excel (`.xlsx`) via the `csv` and `excel` packages. `ImportSourceScreen` + `ImportMappingScreen` handle the column-mapping flow for third-party exports.

### Web deployment

Built with `flutter build web --base-href /poker-tracker/` and deployed to GitHub Pages. The `--base-href` flag is required; omitting it breaks asset loading.
