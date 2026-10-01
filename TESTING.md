# Chunk - Testing Guide

## Gates

```bash
# Static analysis (must be clean)
flutter analyze

# Full test suite (must be green)
flutter test

# Targeted runs
flutter test test/timer_service_test.dart
flutter test --coverage
```

CI (`.github/workflows/pages.yml`) runs `flutter analyze` and `flutter test` on every push before building the Pages deploy. A red gate blocks deployment.

## What's Covered

### Unit tests

| File | Covers |
|---|---|
| `test/session_state_test.dart` | Break fires at exactly 5 (not 4 or 6); `questionsUntilBreak` countdown 5→1; `resetCycle` resets the cycle count but preserves totals; 10-id activity history cap with oldest-first eviction; break-duration persistence round-trip |
| `test/timer_service_test.dart` | Start/stop transitions; double-start no-op; elapsed derived from wall clock via injected `now` (no ticks needed); `formatElapsed` edge cases (0, sub-minute, exact minute, 61:01) |
| `test/activity_service_test.dart` | Never returns a recent activity; falls back to the full pool when everything is recent; throws when activities were never loaded |

### Widget tests

| File | Covers |
|---|---|
| `test/widget_test.dart` | App launches on the "Ready?" start card |
| `test/card_widget_test.dart` | Completion card shows the formatted time and "N more until break", tap advances; break card counts down from its end timestamp, early "back to work" tap exits; refresh swaps in a different activity |
| `test/desktop_input_test.dart` | Mouse drag, mouse click, and scroll wheel advance start → timer |

Sound-producing paths (break auto-complete, page-change chimes) are deliberately not exercised in widget tests — `audioplayers` has no platform implementation under `flutter test`.

## Manual Verification Checklist

Run `flutter run -d chrome` (or Edge) and walk the flow:

1. **Start card** → "Ready?" heading, break-duration pills (10s/30s/60s), "swipe to start" arrow
2. **Swipe up** → timer card, breathing animation plays, no time visible
3. **Swipe up ("finished")** → completion card shows elapsed time + "4 more until break"
4. **Repeat to 5 questions** → 5th completion card shows "break time" arrow, no counter
5. **Swipe up** → break card counts down with an activity suggestion (10s duration keeps this quick)
6. **Countdown hits 0** → ding plays, auto-advances to a fresh start card
7. **"all done"** (completion or break card) → summary card with per-question times and total
8. **Swipe down anywhere** → history scrolls back; timer keeps running
9. **Reload the page** → session resets (expected), break-duration setting persists

### Timer accuracy check (do after timer changes)

1. Start a question, background the tab for 5+ minutes, foreground it, finish
2. Completion time must be within a few seconds of real elapsed time
3. Repeat for a break countdown: total break length must match the selected duration

### Accessibility pass (do after UI changes)

1. Enable reduced motion in the OS → breathing circle and background orbs render static
2. Screen reader on → arrow announces its action ("finished", "break time", ...); break countdown announces remaining seconds

## Edge Cases (by design)

1. **Activity pool exhaustion**: falls back to the full pool when all 50 are recent
2. **Timer disposal**: services cancel timers on dispose; break card cancels its countdown on exit
3. **Double advance**: `_isTransitioning` guard makes simultaneous swipe + tap a single step
4. **Concurrent timer starts**: `start()` no-ops while running
5. **Stop without start**: returns 0, no crash
6. **Browser refresh**: session state resets; only the break-duration setting survives

## History

- **2026-02-09**: MVP code-review testing of the original 4-screen button flow (Start → Timer → Completion → Break). All checks passed; one widget-test compile issue fixed. The flow has since been replaced by swipe navigation — the findings above supersede that report.
