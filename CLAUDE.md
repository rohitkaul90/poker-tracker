# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run
flutter run -d emulator-5554     # Android emulator
flutter run -d windows            # Windows desktop

# Build
flutter build apk
flutter build appbundle --release                        # Play Store AAB
flutter build web --release --base-href "/"              # custom domain — PowerShell only
# IMPORTANT: run web build in PowerShell, not bash; bash on Windows mangles the bare /

# Deploy to GitHub Pages (after web build)
# Run in bash:
CNAME=$(cat docs/CNAME) && cp -r build/web/. docs/ && echo "$CNAME" > docs/CNAME && touch docs/.nojekyll
# Then commit and push docs/

# Dependencies / analysis / tests
flutter pub get
flutter analyze
flutter test
flutter test --coverage           # generates coverage/lcov.info

# Version bump (increments build number, commits, tags — triggers CI builds)
bash scripts/bump-version.sh 1.2.0

# Asset regeneration
dart run flutter_native_splash:create
dart run flutter_launcher_icons
dart run build_runner build --delete-conflicting-outputs   # only if @riverpod annotations added
```

## Slash-command agents

Twelve specialist agents live in `.claude/commands/`. Invoke with `/agent-name [args]`:

| Command | Role | Scope |
|---|---|---|
| `/release-orchestrator` | Phase gate status + 72h action plan | Read-only audit |
| `/security-analyst` | RLS, secrets, OWASP, data-flow doc | Reads + fixes code |
| `/cloud-architect` | Supabase scaling, schema, Edge Functions | Reads + migrations |
| `/platform-engineer` | Flutter features, GDPR, tests, analyzer | Full code changes |
| `/devops-engineer` | GitHub Actions CI/CD pipelines | Writes workflows |
| `/qa-reliability` | Test suite, 60-row manual matrix, sign-off | Reads + writes tests |
| `/web-engineer` | manifest.json, meta tags, Cloudflare | web/ + Dart fixes |
| `/mobile-specialist` | Android/iOS native, store submissions | Native configs |
| `/ai-data-engineer` | Claude API, cost model, PostHog analytics | Edge Functions |
| `/legal-compliance` | Privacy policy, GDPR, store labels | Docs + screens |
| `/bizops` | Unit economics, pricing, RevenueCat | Analysis + docs |
| `/growth` | ASO, Reddit/PH launch, viral loop spec | Copy + specs |

Start any new session on launch work with `/release-orchestrator` — it reads the actual codebase state and outputs a prioritized action plan.

## Architecture

**TableLab** is a Flutter poker bankroll tracker. Package name: `tablelab`. Dark Material 3 theme, seed color `#1B5E20`.

### Navigation flow

`main.dart → AuthGate → MainNavigation`

`AuthGate` uses `StreamBuilder<AuthState>` + `AnimatedSwitcher` to fade between `SplashScreen` (while auth resolves), `LoginScreen`, and `MainNavigation`. The splash is shown until Supabase emits the first valid auth event — no minimum timer.

`MainNavigation` is an `IndexedStack` with a `NavigationBar` (5 tabs: Dashboard, Sessions, Hands, Reads, Tournaments). The `AppDrawer` is mounted via `mainScaffoldKey` (a `GlobalKey<ScaffoldState>` exported from `app_drawer.dart`) so any screen can call `mainScaffoldKey.currentState?.openDrawer()`.

Drawer sections: **Home** (Navigator.popUntil isFirst) → **Profile** → **TOOLS** (Equity Calculator, ICM Calculator) → **APP** (Help, About, Terms of Service, Data & Privacy, Feedback) → **Sign Out** (pinned). Tool screens pushed via Navigator.push must include `drawer: const AppDrawer()` on their Scaffold.

`AuthGate` also handles `AuthChangeEvent.passwordRecovery` → shows `ResetPasswordScreen` (set new password + auto sign-out on success).

### State management — Riverpod

Service classes are plain Dart, wrapped in `Provider<>` at the provider layer. All providers live in `lib/providers/`.

| Provider | Type | Notes |
|---|---|---|
| `authUserIdProvider` | `StreamProvider<String?>` | emits current user ID on auth change |
| `sessionsProvider` | `StreamProvider` | Supabase stream; watches `authUserIdProvider` |
| `filteredSessionsProvider` | `Provider` | derived from sessions + filter |
| `filterProvider` | `StateProvider<SessionFilter>` | global session filter state |
| `handsProvider` | `FutureProvider` | fetch-once; watches `authUserIdProvider` |
| `tournamentListingsProvider` | `FutureProvider.autoDispose` | |
| `readsProvider` | `StreamProvider` | in `reads_provider.dart` |
| `profileProvider` | `FutureProvider` | in `profile_provider.dart`; watches `authUserIdProvider` |

**Cross-account scoping** — every user-scoped provider must `ref.watch(authUserIdProvider)` so it restarts when a different account signs in. After any write (insert/update/delete), call `ref.invalidate(sessionsProvider)` — Supabase `.stream()` requires Realtime enabled to push live changes; explicit invalidation is the reliable fallback.

### Backend — Supabase

All data is user-scoped via Row Level Security. Credentials live in `lib/config/supabase_config.dart` (anon key — public by design; file is gitignored). All Supabase calls go through `withSupabaseRetry<T>()` (`lib/services/supabase_retry.dart`), which retries once on PGRST303 (JWT clock-skew error).

**Tables:** `sessions`, `hands` (JSONB `hand_data`, nullable `session_id`), `player_reads`, `player_read_notes`, `rake_presets`, `profiles` (includes `starting_bankroll numeric`, `starting_bankroll_currency text`), `ai_analyses`, `ai_hand_analyses`, `ai_usage_log`, `tournament_listings`.

**Edge Functions** (Deno, `supabase/functions/`):
- `analyze-session` — Claude Sonnet call via tool use; result cached in `ai_analyses`; limit 5/day per user
- `analyze-hand` — Claude Sonnet call via tool use; result cached in `ai_hand_analyses`; limit 20/day per user
- `scrape-tournaments` — scrapes PokerNews, triggered by weekly GitHub Actions cron
- Rate limits in `ai_usage_log`; `rhtk.1234@gmail.com` is exempt

**Edge Function patterns:**
- `SYSTEM_PROMPT` is a `const` string with `cache_control: { type: "ephemeral" }` — must stay static (no per-user data) for Anthropic prompt caching to work
- Cache check → rate limit check → Claude API call (this order is critical — cache hits are free)
- `computeDrawSummary()` injects deterministic `[FACT —` annotations into the user prompt — do not remove; these ground the model's hand-reading
- `buildPrompt()` tracks per-street `streetContrib` maps for accurate incremental call amounts

### Firebase Crashlytics

Active on Android only. `lib/firebase_options.dart` is generated (not a stub) — do not overwrite it. `main.dart` routes `FlutterError` and `PlatformDispatcher` errors to Crashlytics, guarded by `if (!kIsWeb)` — Crashlytics throws on web. `android/app/google-services.json` is committed and required for Android builds.

### Splash screen

Three layers, all matching background `#111811`:
1. **Native** — generated by `flutter_native_splash`; assets in `android/app/src/main/res/` and `ios/Runner/`; Android 12+ uses Splash Screen API with icon on `#1B5E20` circle
2. **Flutter overlay** — `lib/widgets/splash_screen.dart`; shown by `AuthGate` until auth resolves; fades via `AnimatedSwitcher(duration: 350ms)`
3. **Web** — custom HTML/CSS in `web/index.html`; splash div fades out on `flutter-first-frame` event

### Equity Calculator

`lib/screens/equity_calculator_screen.dart` + `lib/widgets/equity/`.

Each player has two modes toggled in `PlayerRangeEditor`:
- **Range mode** — 13×13 matrix + GTO presets; `expandCombos()` expands to all concrete card pairs
- **Exact Hand mode** — two specific cards via `CardPickerSheet`; `expandCombos()` returns a single `[[card1, card2]]`

Board cards and other exact-hand players' cards are passed as `excludedCards`. Simulation runs via Monte Carlo (`lib/equity/simulator.dart`).

### Key subsystems

- **`lib/equity/`** — offline equity: card encoding (rank×4+suit), 7-card evaluator (brute-force 5-card combos), Monte Carlo simulator, GTO preflop ranges
- **`lib/reads/`** — `insights_engine.dart` (rule-based coaching from player tags), `tag_definitions.dart`
- **`lib/utils/helpers.dart`** — currency conversion, `parseBBFromStakes`, `calcBB100`, `formatPL`, `fieldSizeBucket`, all shared formatting

### Models

`SessionModel` — `fromMap()` (snake_case DB → camelCase Dart).  
`PokerHand` — `fromJson()`/`toJson()` (entire hand serialized as JSONB); has optional `tournamentStage` and `TableSetup.ante` fields.  
All models are plain immutable classes — no code generation.

### Hand recording

`HandInputScreen` supports tournament hands: `isTournamentSession` param shows stage dropdown, ante field, relabels stakes as "Blind Level". All-in runout: `_allInSeats` persists across streets; `_isAllInRunout` getter auto-deals remaining streets when ≤1 non-all-in player remains. Undo stack (`_HandSnapshot`) captures state before each action.

### Critical patterns

**Async + ref after widget disposal** — always guard `ref` usage after any `await` with `if (!context.mounted) return;`. `AppDrawer._confirmSignOut` is the canonical example.

**Dismissible + provider invalidation** — never call `ref.invalidate` in `onDismissed` without first removing the item from local state. Pattern: `ConsumerStatefulWidget` + `Set<String> _deletingIds`; add ID on dismiss, filter list in build, call service async. See `HandsScreen`.

**Save button guard** — any form with an async save must have `bool _saving` that disables the button during the call to prevent double-submission.

**fl_chart on Windows** — always set `barTouchData: BarTouchData(enabled: false)` and `lineTouchData: const LineTouchData(enabled: false)` on every chart. Default enabled state throws `RangeError` on Windows when mouse nears edge.

### Web deployment — critical details

- Custom domain `tablelab.app` → build with `--base-href /` (root, not `/tablelab/`)
- Web build output goes into `docs/` folder on `main` branch (GitHub Pages source)
- `docs/CNAME` must contain `tablelab.app` — preserve it on every deploy
- `docs/.nojekyll` must exist — recreate after every wipe
- PowerShell for the flutter build command; bash for the file copy

### Android build

- `compileSdk = 36` in `android/app/build.gradle.kts`; root `build.gradle.kts` forces compileSdk 36 on library subprojects via `gradle.afterProject`
- Release build currently uses **debug signing** (`signingConfigs.getByName("debug")`) — must be replaced with a proper release keystore before Play Store submission (see `/mobile-specialist signing`)
- `INTERNET` permission explicitly declared in `AndroidManifest.xml` (flutter merger sometimes drops it after icon regeneration)
- Package ID: `com.pokertracker.poker_tracker` (tied to Google OAuth — do not rename)
- `minSdk` should be 23 (flutter_secure_storage requires API 23+); `targetSdk` should be 35 (Play Store mandates ≥34)

### iOS build

- `ios/Runner/Info.plist` `CFBundleDisplayName` is currently `"Poker Tracker"` — must be changed to `"TableLab"` before any TestFlight/App Store build
- `flutter_launcher_icons` has `ios: false` in `pubspec.yaml` — change to `true` before the first iOS build, then run `dart run flutter_launcher_icons`
- `ios/Runner/PrivacyInfo.xcprivacy` does not yet exist — required by Apple since May 2024; see `/mobile-specialist privacy-manifest`
- iOS builds require a macOS machine; cannot be built on Windows

### Pending critical work (not yet implemented)

These are known gaps that will cause store rejection or legal issues:

| Item | Owner agent | Blocker for |
|---|---|---|
| Delete-account feature (GDPR right to erasure) | `/platform-engineer gdpr` | Apple App Store, GDPR |
| Release signing config in `build.gradle.kts` | `/mobile-specialist signing` | Play Store submission |
| `ios/Runner/Info.plist` display name fix | `/mobile-specialist ios` | All iOS builds |
| Privacy policy at `tablelab.app/privacy` (URL) | `/legal-compliance privacy-policy` | Apple App Store |
| `web/manifest.json` brand colors + description | `/web-engineer manifest` | Web quality |
| `<meta name="viewport">` in `web/index.html` | `/web-engineer meta` | Mobile web usability |
| Anthropic spend cap ($100/month hard limit) | Manual: console.anthropic.com | Cost control |
