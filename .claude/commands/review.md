You are performing a deep, multi-pass code review of the entire **TableLab** codebase — a Flutter + Supabase poker tracking app. You will find issues AND implement the fixes directly. Do not stop at suggestions.

## Project context (read before starting)

- **Stack:** Flutter (Dart) + Supabase (Postgres + Edge Functions in Deno/TypeScript) + Riverpod + fl_chart
- **Platforms:** Android, Web (tablelab.app via GitHub Pages), Windows desktop
- **Auth:** Supabase email/password, RLS on all tables
- **AI features:** `analyze-hand` and `analyze-session` Supabase Edge Functions calling Claude Sonnet via Anthropic SDK
- **Key architectural decisions to preserve:**
  - `mainScaffoldKey` (GlobalKey) in `app_drawer.dart` — all tabs share one drawer via this key, never add per-screen `drawer:` params
  - `_allInSeats` in hand recorder persists across streets (never cleared between streets)
  - `computeDrawSummary` in `analyze-hand/index.ts` injects deterministic `[FACT —` annotations — do not remove
  - `buildPrompt` tracks per-street pot contributions for accurate pot-size injection
  - `fl_chart` touch must be disabled on all charts (causes Windows RangeError otherwise)
  - `lib/config/supabase_config.dart` is gitignored — never reference or recreate it

$ARGUMENTS

---

## PHASE 0 — Map the codebase

Before any pass, read the full project structure:

1. Read `pubspec.yaml` — understand all dependencies and their versions
2. Glob `lib/**/*.dart` — list every Dart file
3. Glob `supabase/functions/**/*.ts` — list every edge function file
4. Read `lib/main.dart` — understand routing and provider scope
5. Read `lib/providers/providers.dart` — understand all Riverpod providers
6. Read `lib/services/supabase_service.dart` and `lib/services/hand_service.dart`
7. Read every file in `lib/models/`
8. Read every file in `lib/utils/`
9. Read every screen file in `lib/screens/` (including subdirectories)
10. Read every widget file in `lib/widgets/`
11. Read every edge function: `supabase/functions/analyze-hand/index.ts`, `supabase/functions/analyze-session/index.ts`, `supabase/functions/scrape-tournaments/index.ts`

Do not skip files. Build a complete mental model before Pass 1.

---

## PASS 1 — Correctness

Find and fix all bugs, crashes, and incorrect behaviour. For each issue: read the file, understand the full context, then edit it.

### 1.1 Async / mounted safety (Dart)
- Every `async` method in a `State<>` or `ConsumerState<>` that calls `setState`, `Navigator`, `ScaffoldMessenger`, or `ref.read/invalidate` after an `await` must guard with `if (!mounted) return;`
- Check all `initState` overrides that call async functions
- Check all `Future<void>` handlers (button `onPressed`, `onRefresh`, etc.)

### 1.2 Null safety and null dereference
- Find every `!` (bang operator) that is not guaranteed safe by surrounding logic
- Find every `.first` / `.last` call on a potentially-empty collection — replace with `.firstOrNull` / `.lastOrNull`
- Find map lookups used without null checks: `map[key].someMethod()` where key might be absent

### 1.3 Race conditions
- In `HandsScreen` / `SessionHistoryScreen`, confirm the Dismissible optimistic-removal pattern is used: `_deletingIds.add(id)` before any async call, filter in build
- Confirm `ref.invalidate()` is only called after the service operation completes successfully, not before
- Check all `StreamProvider` and `FutureProvider` for proper cancellation / disposal

### 1.4 State management correctness
- Every `ConsumerStatefulWidget` that reads a provider in `initState` must use `ref.read`, not `ref.watch`
- Find any `ref.watch` calls inside callbacks, `Future.then`, or `Timer` — these are bugs
- Confirm providers that depend on auth state are invalidated on sign-out

### 1.5 Hand recorder logic
- Confirm `_toAct` in `_initPostflop` filters out `_allInSeats`
- Confirm `_isAllInRunout` getter is correct: `_activeSeats.where((s) => !_allInSeats.contains(s)).length <= 1`
- Confirm `_dealNextStreet` takes the runout path when `_isAllInRunout` is true
- Confirm `_undoStack` snapshots capture `allInSeats` correctly
- Confirm `_doRaise` re-computes `_toAct` excluding `_allInSeats`

### 1.6 Edge function correctness (TypeScript)
- In `analyze-hand/index.ts`: confirm `computeDrawSummary` scans windows HIGH→LOW for made straights before looking for draws
- Confirm `buildPrompt` uses `streetContrib: Map<number, number>` per street to compute incremental call amounts
- Confirm pot label `(pot: X)` is injected at each postflop street header
- In `analyze-session/index.ts`: confirm rate limit check happens before the Claude API call
- In `scrape-tournaments/index.ts`: confirm the scraper only inserts upcoming tournaments and deduplicates on upsert

### 1.7 Supabase / RLS
- In `supabase_service.dart`: confirm every query filters by `user_id` or relies on RLS (check for any query missing `.eq('user_id', _uid)` on tables that have RLS)
- Confirm sign-out clears all cached provider state

---

## PASS 2 — Performance

Find and fix inefficiencies. Read the file fully before editing.

### 2.1 Unnecessary rebuilds (Flutter)
- Find `ref.watch` calls that trigger rebuilds of large widget trees — consider splitting into smaller widgets or using `select`
- Find `ListView` without `const` constructors on static children
- Find `build()` methods that create `TextEditingController`, `FocusNode`, `AnimationController`, or other objects that should be in `initState` / `State` fields
- Find expensive computations (sorts, filters, string formatting) inside `build()` — move to `didUpdateWidget` or computed getters with memoisation

### 2.2 Redundant network calls
- In providers, confirm `FutureProvider` results are not re-fetched on every navigation (check `autoDispose` usage — remove it where persistence across nav is desirable)
- In analytics screen, confirm session filtering is done once, not inside multiple `map()` calls

### 2.3 Collection efficiency
- Replace `list.where(...).toList()` followed by `.length` with `list.where(...).length` (avoids allocation)
- Replace `list.map(...).toList().where(...)` chains with single-pass operations
- Replace `Set` lookups on `List` (O(n)) with actual `Set<>` types

### 2.4 Edge function performance
- Confirm `SYSTEM_PROMPT` uses `cache_control: { type: "ephemeral" }` (prompt caching) on both AI edge functions
- Confirm cache lookup (Supabase select) happens BEFORE the rate-limit check and BEFORE the Claude API call — cache hits should be free and instant

### 2.5 Image and asset loading
- Check `pubspec.yaml` assets — confirm no unused assets are bundled

---

## PASS 3 — Maintainability

Improve clarity without changing behaviour. Read before editing.

### 3.1 Naming
- Rename any variable/function whose name doesn't clearly describe its purpose
- Rename `_step` enum values or methods that use abbreviations without context
- Ensure all `Provider` names end in `Provider` and all `Notifier` names end in `Notifier`

### 3.2 Duplication
- Find repeated UI patterns across screens (error state, loading state, empty state) — extract into shared widgets if used 3+ times
- Find repeated Supabase query boilerplate — consider extracting helpers
- Find repeated string constants (stake presets, position names, tag keys) — confirm they live in one place

### 3.3 Complexity reduction
- Find methods longer than ~60 lines — break into named private methods
- Find `switch` statements that could be `Map` lookups
- Find nested ternary expressions (more than 2 levels) — extract to if/else or local variables
- Find deeply nested `Column > Column > Row > Column` widget trees — flatten or extract

### 3.4 Dead code
- Find any `import` statements referencing files or packages that are not used in that file
- Find any private methods, getters, or fields that are never called
- Find any commented-out code blocks — remove them

---

## PASS 4 — Production Readiness

Harden the app for real-world use. Read before editing.

### 4.1 Error handling
- Every `try/catch` block that silently swallows exceptions must at minimum log the error
- Supabase calls that can fail (network, RLS, timeout) must show a user-facing error (SnackBar or error widget), not silently fail
- Edge functions must return structured error JSON with appropriate HTTP status codes for all failure modes (auth failure → 401, rate limit → 429, validation → 400, server error → 500)

### 4.2 Input validation
- Text fields that accept numeric input (stacks, blinds, buy-ins) must validate before use — confirm `int.tryParse` is always used (never `int.parse`)
- Confirm stake strings from user input are trimmed before parsing
- In edge functions, validate required fields on the incoming request body before processing

### 4.3 Retry and resilience
- Confirm `withSupabaseRetry` (or equivalent) wraps all Supabase service calls that could fail transiently
- Edge functions calling the Claude API should handle `anthropic.messages.create` errors gracefully with a 500 response (not an unhandled throw)

### 4.4 Security
- Confirm no secrets, tokens, or API keys appear in any tracked file (`git ls-files | xargs grep -l "key\|secret\|password"` — review matches)
- Confirm edge functions verify the user JWT before processing any request
- Confirm RLS policies exist for all tables that store user data

### 4.5 Observability
- Confirm `console.error` is called in edge function catch blocks so errors appear in Supabase logs
- Confirm the Flutter app shows meaningful error messages (not raw exception strings) to users

---

## PASS 5 — Refactor and implement

After completing Passes 1–4, make targeted rewrites of the most complex or problematic code sections identified. This is not about cosmetic changes — rewrite logic that is structurally unsound.

Prioritise in this order:
1. Any bug found in Pass 1 that has not yet been fixed
2. The highest-complexity methods identified in Pass 3 (longest, most nested, hardest to reason about)
3. The most impactful performance issues from Pass 2
4. Error handling gaps from Pass 4

For each rewrite:
- Read the original code fully
- Write the replacement using the Edit tool
- Confirm the replacement is functionally equivalent (or better) and handles all the same cases

---

## Output format

After completing all passes, produce a final report:

```
## Review Complete

### Changes made
- [file:line] What was changed and why

### Issues found but not fixed (require human decision)
- Description and location

### PASS 1 Correctness    — N issues fixed
### PASS 2 Performance    — N issues fixed
### PASS 3 Maintainability — N issues fixed
### PASS 4 Prod Readiness — N issues fixed
### PASS 5 Refactor       — N rewrites done
```

If `$ARGUMENTS` specifies a particular pass (e.g. `pass1`) or file path, scope the review to that pass or file only.
