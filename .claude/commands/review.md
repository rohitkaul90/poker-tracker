Review the TableLab codebase for issues, regressions, and quality problems. This is a Flutter + Supabase poker tracking app (brand name: TableLab).

## What to review

Run all checks below and report findings grouped by severity: 🔴 Bug / 🟡 Warning / 🔵 Info.

---

### 1. Recent changes
Check `git log --oneline -10` and `git diff HEAD~1` to understand what changed most recently. Focus the review on those files first.

### 2. Flutter / Dart checks
- Run `flutter analyze` and report any errors or warnings (ignore info-level lints that were pre-existing).
- Look for missing `mounted` checks after any `await` in StatefulWidget methods — a common crash source.
- Check that every `FAB` in the app has a unique `heroTag` (duplicate tags cause Hero animation exceptions).
- Verify `fl_chart` widgets (BarChart, LineChart) all have touch disabled on non-touch platforms: `barTouchData: BarTouchData(enabled: false)` / `lineTouchData: LineTouchData(enabled: false)`. Hover touch causes RangeError on Windows.
- Check that `Dismissible` widgets use optimistic removal (add to a `_deletingIds` set on `onDismissed`) to avoid "dismissed Dismissible still in tree" assertion errors.

### 3. Supabase edge functions
- Check `supabase/functions/*/index.ts` for TypeScript errors or obvious logic issues.
- Confirm rate limiting is present on AI functions (`analyze-hand`, `analyze-session`): 20/day and 5/day respectively; `rhtk.1234@gmail.com` is exempt.
- Confirm cache hits do NOT log usage (only real Claude API calls log to `ai_usage_log`).
- Confirm `computeDrawSummary` is present in `analyze-hand/index.ts` and injects `[FACT —` annotations into the prompt — this is the guard against AI hand misreading.
- Confirm `buildPrompt` tracks per-street pot and injects `(pot: X)` into street headers.

### 4. Security
- Confirm `lib/config/supabase_config.dart` is NOT tracked by git (`git ls-files lib/config/supabase_config.dart` should return empty).
- Check that no hardcoded API keys, secrets, or passwords appear in tracked files.
- Confirm all Supabase queries are scoped to the current user (RLS enforced at DB level, but double-check service layer).

### 5. Navigation / drawer
- Confirm `mainScaffoldKey` is exported from `app_drawer.dart` and used in `main.dart` on the outer Scaffold.
- Confirm no screen in the bottom nav bar has its own `drawer:` parameter (they should all use `mainScaffoldKey.currentState?.openDrawer()`).

### 6. All-in mechanics (hand recorder)
- Confirm `_allInSeats` is NOT cleared in `_initPostflop` (it must persist across streets).
- Confirm `_initPostflop` filters `_toAct` with `.where((s) => !_allInSeats.contains(s))`.
- Confirm `_isAllInRunout` getter exists and is used in `_dealNextStreet`.

### 7. Web deployment
- Confirm `docs/CNAME` contains `tablelab.app`.
- Confirm `docs/.nojekyll` exists.

---

## Output format

For each section, either write ✅ All good or list findings as:
- 🔴 **[file:line]** Description of bug and suggested fix
- 🟡 **[file:line]** Description of warning
- 🔵 **[file]** Info / minor improvement

End with a **Summary** of how many issues were found per severity and the top priority fix if any.
