# Swipe Navigation Design

## Context

The current app uses separate screens with large purple buttons ("Start", "Done", "Next question") to navigate between steps. This feels more like a form than a device interface. The goal is to replace button-driven navigation with a vertical swipe/scroll paradigm — elegant, minimal, and natural on mobile.

## Interaction Model

The app becomes a single-screen vertical `PageView` with snap-to-card physics. Each step in the homework flow is a full-screen card. The user advances by:

1. **Swiping up** — primary interaction, especially on mobile
2. **Tapping the down-arrow** — a small chevron at bottom center with a lowercase label above
3. **Swiping down** — goes back to a previous card (bidirectional)

The large purple buttons are removed entirely. The arrow is the only navigation affordance.

### Arrow Design

- Thin chevron icon (~32px), `foreground` color (#F8F8F2)
- Label above the arrow: 14px, lowercase, `comment` color (#6272A4)
- Subtle bounce animation: drifts down 4px and back over 2 seconds, easeInOut, looping
- On tap: triggers `PageController.nextPage()` with 300ms duration, easeOutCubic

### Transition

Smooth vertical slide with iOS-style snap physics. Outgoing card slides up and off-screen, incoming card slides up from below. `PageScrollPhysics` for snap behavior.

## Card Layout

### Start Card
- Center: "Ready?" heading
- Bottom center: down-chevron with "start" label
- Settings icon top-right

### Timer Card
- Center: Breathing circle animation (~50% of screen)
- Bottom center: down-chevron with "finished" label
- Timer starts when user arrives on this card, stops when they leave

### Completion Card
- Center: "That took 3m 24s" + progress counter ("2/5 until break")
- Bottom center: down-chevron with "ready" label (or "break time" when break triggers)

### Break Card
- Center: countdown timer + activity suggestion
- No arrow until final 3 seconds, then "back to work" chevron appears
- Auto-advances to a fresh start card when countdown hits 0

## Architecture

### Single PageView

Replace the 4 separate screens (`StartScreen`, `TimerScreen`, `CompletionScreen`, `BreakScreen`) with a single `SessionScreen` containing a vertical `PageView`.

### Dynamic Step List

The page list grows as the session progresses. Each time the user advances past a completion card, the next step is appended:

```
steps: [start, timer, completion, timer, completion, ..., break, start, ...]
```

An enum `StepType { start, timer, completion, break_ }` defines the step types. The PageView builder renders the appropriate card widget for each step.

### State Management

- `SessionState` (existing Provider) — tracks question count, break triggers, recent activities
- `PageController` — local to `SessionScreen`, not in Provider
- `TimerService` (existing Provider) — start/stop triggered by page change events

### Timer Lifecycle

- Timer starts when the PageView settles on a timer card (detected via `PageController` listener / `onPageChanged`)
- Timer stops when the user leaves the timer card (swipe forward = "finished")
- Timer keeps running if user swipes back (it's Provider-managed, not tied to the widget)

### Swipe Restriction

The user can swipe back to any previous card but cannot swipe forward past the current active step. Enforced by checking in `onPageChanged`: if the target page index exceeds the current step count, animate back.

## Edge Cases

- **Break auto-advance**: When 60-second countdown hits 0, programmatically call `PageController.nextPage()` to slide to a fresh start card
- **Session reset after break**: A new start step is appended after break. Previous cards remain in history (scrollable back) but inert
- **App backgrounding**: Timer pauses. When foregrounding, the timer card is still active — no state lost
- **Accidental swipe during timer**: Swiping back is fine — timer keeps running. Swiping forward triggers "finished" and stops the timer (intentional — forward swipe = done)
- **Breathing animation persistence**: The `BreathingCircle` widget should persist across timer cards so the animation never restarts mid-breath

## Files to Modify

- **New**: `lib/screens/session_screen.dart` — the single PageView screen
- **New**: `lib/widgets/advance_arrow.dart` — reusable arrow + label widget
- **New**: `lib/models/session_step.dart` — step type enum and step list model
- **Modify**: `lib/main.dart` — point home to `SessionScreen` instead of `StartScreen`
- **Remove** (or keep for reference): `lib/screens/start_screen.dart`, `timer_screen.dart`, `completion_screen.dart`, `break_screen.dart` — functionality absorbed into card builders within `SessionScreen`

## Verification

1. Swipe up from start to timer — timer starts, breathing animation plays
2. Swipe up from timer to completion — timer stops, elapsed time shown
3. Swipe up from completion to next timer — timer restarts
4. After 5 questions, completion shows "break time" — swipe to break card
5. Break countdown reaches 0 — auto-advances to fresh start card
6. Swipe down at any point — goes back to previous card
7. Cannot swipe forward past current step
8. Arrow tap works same as swipe up
9. Works on mobile with touch gestures
