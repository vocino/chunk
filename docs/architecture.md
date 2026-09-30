# Chunk - Technical Architecture

## Overview

Chunk is a Flutter web application (deployed to GitHub Pages) designed with a clear path to native iOS/Android apps. The UI is a single-screen vertical swipe flow: each step of a homework session is a full-screen card, and the user advances by swiping up or tapping the arrow.

### Core Principles

1. **Privacy First**: Zero data collection, no analytics, no cloud storage
2. **Performance**: Smooth animations, responsive UI, minimal dependencies
3. **Simplicity**: Clear separation of concerns, minimal state management
4. **Scalability**: Structured for native migration without major refactoring
5. **ADHD-Friendly**: One-task-at-a-time design, calming visuals, no pressure

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      SessionScreen                           │
│           (vertical PageView, dynamic step list)             │
│  ┌────────┐  ┌────────┐  ┌───────────┐  ┌───────┐  ┌────────┐│
│  │ Start  │→ │ Timer  │→ │Completion │→ │ Break │  │Summary ││
│  │  card  │  │  card  │  │   card    │  │ card  │  │  card  ││
│  └────────┘  └────────┘  └───────────┘  └───────┘  └────────┘│
│       swipe up / arrow tap advances; swipe down goes back    │
└───────────────────────────┬─────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                │   Provider (State)    │
                │  ┌──────────────────┐ │
                │  │  SessionState    │ │  Counts, progress, timings
                │  ├──────────────────┤ │
                │  │  TimerService    │ │  Wall-clock elapsed time
                │  ├──────────────────┤ │
                │  │ ActivityService  │ │  Break activity selection
                │  ├──────────────────┤ │
                │  │  SoundService    │ │  pop / chime / ding
                │  └──────────────────┘ │
                └───────────┬───────────┘
                            │
                ┌───────────┴───────────┐
                │     Data Layer        │
                │  ┌──────────────────┐ │
                │  │ activities.json  │ │  50 break activities
                │  ├──────────────────┤ │
                │  │ SharedPreferences│ │  breakDuration only
                │  └──────────────────┘ │
                └───────────────────────┘
```

## Component Breakdown

### 1. Models

#### SessionState (`models/session_state.dart`)
**Purpose**: Tracks current session progress and settings.

**State:**
- `_questionCount` (int): Questions completed in current cycle (resets after each break)
- `_totalQuestions` (int): Questions completed this session (never resets mid-session)
- `_breakDuration` (int): Break length in seconds (10/30/60, persisted)
- `_recentActivityIds` (List<String>): Last 10 shown activities (anti-repeat)
- `_questionTimes` (List<int>): Per-question elapsed seconds (for the summary card)
- `_sessionStart` (DateTime?): Set when the first question is recorded

**Key Methods:**
- `incrementQuestion()`: Increments per-cycle and total counts
- `recordQuestion(elapsed)`: Stores a per-question time for the summary
- `shouldTriggerBreak()`: Returns true when count reaches a multiple of 5
- `resetCycle()`: Resets per-cycle count to 0 after a break
- `setBreakDuration(seconds)`: Updates and persists the break length
- `loadPreferences()`: Restores persisted settings on startup
- `questionsUntilBreak`: Computed property (5 - count % 5)
- `totalSessionSeconds`: Wall-clock session length for the summary card

**State Management**: Extends `ChangeNotifier` for reactive UI updates.

#### SessionStep (`models/session_step.dart`)
**Purpose**: Step types for the swipe-navigation flow.

- `StepType { start, timer, completion, break_, summary }`
- `SessionStep` carries per-step payload: `elapsedSeconds`, `questionsUntilBreak`, `activity`

#### BreakActivity (`models/break_activity.dart`)
**Purpose**: Data model for break activities.

**Properties:**
- `id` (String): Unique identifier
- `text` (String): Activity instruction
- `emoji` (String): Visual icon
- `category` (String): Activity type (physical, silly, creative, breathing, low-energy)

**Serialization**: JSON via `fromJson()` factory and `toJson()`.

### 2. Services

#### TimerService (`services/timer_service.dart`)
**Purpose**: Manages question timer lifecycle and formatting.

**Design:** Elapsed time is derived from the wall clock (`DateTime.now()` difference from start), not by counting `Timer.periodic` ticks. The periodic timer only triggers UI refreshes once per second. This keeps timing accurate when the browser throttles background tabs.

**State:**
- `_startTime` (DateTime?): When the current question started
- `_stoppedElapsed` (int): Frozen elapsed value after `stop()`
- `isRunning` (bool): Prevents concurrent timer starts

**Methods:**
- `start()`: Records start time, begins 1-second refresh ticks
- `stop()`: Stops ticks and returns wall-clock elapsed seconds
- `formatElapsed(seconds)`: Converts seconds to "MM:SS" format

**Testability:** Accepts an optional `now` clock function so tests can control time without waiting.

#### ActivityService (`services/activity_service.dart`)
**Purpose**: Loads and randomly selects break activities.

**State:**
- `_activities` (List<BreakActivity>): Full activity pool (50 items)
- Selection history lives in `SessionState.recentActivityIds` (last 10 shown)

**Methods:**
- `loadActivities()`: Loads from JSON asset on startup
- `getRandomActivity(recentIds)`: Returns random activity, filtered by recent history

**Anti-Repeat Logic:**
1. Filter out activities in `recentIds`
2. Random selection from filtered pool
3. If all filtered out, fall back to the full pool

**Testability:** Accepts optional constructor injection (`activities`, `random`) so tests bypass `rootBundle`.

#### SoundService (`services/sound_service*.dart`)
**Purpose**: Short feedback sounds.

- `sound_service.dart`: Conditional export (native vs web)
- `sound_service_native.dart`: `audioplayers` with bundled WAV assets
- `sound_service_web.dart`: Browser `Audio` API via `dart:js_interop`
- Sounds: `pop` (question completed), `chime` (break starts), `ding` (break ends)

### 3. Screens

#### SessionScreen (`screens/session_screen.dart`)
**Purpose**: The entire app flow in one vertical `PageView`.

**Step machine** (`_createNextStep`):
- `start` → starts timer, appends `timer`
- `timer` → stops timer, records question, appends `completion`
- `completion` → break due? appends `break_` (with random activity) : restarts timer, appends `timer`
- `break_` → resets cycle, appends `start`
- `summary` → terminal (reached via "all done")

**Navigation:**
- Swipe up past a threshold or tap the arrow: create the next step and animate forward
- Swipe down: freely revisit previous cards (history is inert — the timer keeps running)
- Cannot swipe forward past the current step (`itemCount` caps the list)
- Outgoing cards fade and shift up slightly for parallax

**Cards** (one widget per step type, in `lib/widgets/`):
- **Start card**: "Ready?" heading, break-duration selector, "swipe to start" arrow
- **Timer card**: Full-screen breathing circle, "finished" arrow. No time display = no time pressure
- **Completion card** (`completion_card.dart`): "That took MM:SS" with staggered reveal, "N more until break" counter, "ready"/"break time" arrow, "all done" exit
- **Break card** (`break_card.dart`): Countdown from the selected duration (derived from an end timestamp, so throttled ticks don't stretch the break), activity suggestion, "back to work" early exit, "all done" exit. Auto-advances (with ding) at 0
- **Summary card** (`summary_card.dart`): Question count, per-question time list, total session time

### 4. Widgets

#### BreathingCircle (`widgets/breathing_circle.dart`)
**Purpose**: Ambient 4-7-8 breathing animation.

- **Total cycle**: 19 seconds (4s expand + 7s hold + 8s contract)
- Three translucent orbs (mauve/teal/sapphire) expand, spread, and drift over a fixed center glow; each instance gets a unique randomized arrangement
- Respects the OS reduced-motion setting: renders a static frame when animations are disabled

#### AmbientBackground (`widgets/ambient_background.dart`)
**Purpose**: Full-screen backdrop depth.

- Four large radial-gradient orbs (mauve/teal/sapphire/lavender) drift on slow 25s/31s loops via `CustomPainter`
- Lives in its own `RepaintBoundary` so card animations never repaint it
- Static when reduced-motion is enabled

#### AdvanceArrow (`widgets/advance_arrow.dart`)
**Purpose**: Reusable advance affordance.

- Thin chevron + lowercase label, subtle looping bounce, tap-scale feedback, light haptic
- Exposed to screen readers as a button labeled with its action ("swipe to start", "finished", ...)

#### BreakTimerSelector (`widgets/break_timer_selector.dart`)
**Purpose**: 10s / 30s / 60s break-duration pills on the start card.

#### GlassContainer (`widgets/glass_container.dart`)
**Purpose**: Translucent card surface with gradient border and glow.

### 5. Theme

#### AppTheme (`theme/app_theme.dart`)
**Purpose**: Centralized design system (Catppuccin Mocha, dark-only).

- **Base**: `#1E1E2E`, accents: mauve `#CBA6F7`, teal `#94E2D5`, sapphire, sky, pink, green
- Card-specific glow colors: green (completion/summary), pink (break)
- **Responsive scaling**: `scaleFactor(context)` from shortest side, clamped 0.85–1.6
- **Typography**: light-weight Roboto; heading 48, medium 32, body 24 (all scaled)
- Buttons: minimum 72px height, 16px radius, translucent mauve fill

## Data Flow

### Question Completion Flow

```
1. User on start card
   ↓ Swipes up / taps arrow
2. TimerService.start() records wall-clock start
   ↓ User works on question (timer hidden)
3. User swipes up / taps "finished"
   ↓ TimerService.stop() returns wall-clock elapsed
4. SessionState.incrementQuestion() + recordQuestion(elapsed)
   ↓ Check shouldTriggerBreak()
5a. If count % 5 != 0:
    → Completion card shows time + "N more until break"
    → Advance restarts timer for the next question
5b. If count % 5 == 0:
    → Completion card shows time, arrow reads "break time"
    → Advance appends break card with random activity
```

### Break Flow

```
1. User arrives on break card
   ↓ End timestamp = now + breakDuration; countdown ticks
2. ActivityService.getRandomActivity(recentIds)
   ↓ Display activity suggestion
3. Countdown reaches 0 (or user taps "back to work")
   ↓ ding plays; SessionState.resetCycle()
4. Fresh start card appended
   ↓ Ready for next cycle
```

### End-of-Session Flow

```
1. User taps "all done" (completion or break card)
   ↓ Summary step appended
2. Summary card shows count, per-question times, total time
   ↓ Terminal card — session over
```

## State Management Pattern

### Provider Architecture

**Provider setup (main.dart):**
```dart
final activityService = ActivityService();
await activityService.loadActivities();
final sessionState = SessionState();
await sessionState.loadPreferences();

MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: sessionState),
    ChangeNotifierProvider(create: (_) => TimerService()),
    Provider.value(value: activityService),
    Provider(create: (_) => SoundService()),
  ],
  child: MaterialApp(...),
)
```

**Consumption pattern:**
```dart
// Read state
final sessionState = context.watch<SessionState>();

// Trigger actions
context.read<TimerService>().start();
```

**State scope:**
- SessionState: App-wide (counts, progress, timings, break duration)
- TimerService: App-wide (timer lifecycle)
- ActivityService: Read-only after startup load (activity data)
- SoundService: Stateless playback

## Animation Architecture

- **Breathing circle**: 19s `TweenSequence` (inhale 4 / hold 7 / exhale 8) driving orb scale/opacity/spread, plus a 7s reversing drift controller. Rendered as a `Stack` of translucent circles, not a custom painter, so each orb composites independently.
- **Ambient background**: Two slow drift controllers (25s/31s, reversed) feeding one `CustomPainter`; isolated in a `RepaintBoundary`.
- **Card reveals**: One-shot staggered opacity/scale/slide controllers per card (800–1000ms).
- **Reduced motion**: `MediaQuery.disableAnimationsOf(context)` freezes ambient animations to a static frame.
- **Performance targets**: 60fps breathing on phone/tablet/desktop; single paint per frame for the background; per-second (not per-frame) timer notifications.

## Navigation Pattern

The step list only grows; `PageView.builder` renders `step[i]` for each index.

- **Forward**: allowed exactly one step past the current card (`itemCount = _currentStepIndex + 2`, with the extra slot rendering empty until the step is created). Forward motion always means "advance" and runs the step machine.
- **Backward**: unlimited scroll through history. Old cards are inert snapshots.
- **Guards**: `_isTransitioning` flag prevents double-advances from simultaneous swipe + tap; `_advance()` no-ops unless the settled page is the current step.
- **Haptics/sound**: medium haptic on every page settle; pop on completion cards, chime on break cards.

## Data Persistence

### Minimal by design

**Persisted (SharedPreferences):**
- `breakDuration` — the only setting; loaded in `main()` before `runApp`

**Not persisted (resets on restart):**
- Question counts, per-question times, activity history, step list

This keeps the privacy story simple (one local setting, no session data retained) while avoiding re-picking break length every launch.

## Testing Strategy

### Unit Tests (`test/*_test.dart`)
- `SessionState`: break fires at exactly 5 (not 4 or 6), countdown values, `resetCycle` semantics, 10-id history cap with eviction, break-duration persistence round-trip
- `TimerService`: start/stop transitions, wall-clock elapsed via injected clock (no ticks needed), `formatElapsed` edge cases
- `ActivityService`: anti-repeat filtering, full-pool fallback, throws when unloaded

### Widget Tests
- `widget_test.dart`: app launches on the start card
- `card_widget_test.dart`: completion card shows time/counter and advances on tap; break card counts down from wall-clock end time and exits early on tap

### CI Gate
`.github/workflows/pages.yml` runs `flutter analyze` + `flutter test` before building; the Pages deploy only runs on green.

### Manual Checks (see TESTING.md)
- Full swipe flow incl. break auto-advance and summary
- Timer accuracy over a 5+ minute question with the tab backgrounded mid-way
- Reduced-motion and screen-reader pass

## Future Considerations

### Native App Migration

**What changes:**
- Timer implementation (background tasks / wake locks)
- Notification system (break alerts)
- Haptics tuning per platform

**What stays the same:**
- Card layouts and swipe flow
- State management (Provider works on native)
- Business logic (models, services)
- Assets (activities.json, sounds, icons)

### Scalability

- **Multiple profiles**: add profile selection; scope `SessionState` per profile
- **Configurable break frequency**: replace the hard-coded 5 with a persisted setting
- **Session history**: local database + parent insights dashboard (local-only, opt-in)
- **Extended activity pool**: categories files, custom activities, favorites/blocking, age filtering

### Performance Optimizations

**Current non-issues:**
- JSON parsing on startup (50 activities = negligible)
- Timer notifications (1 per second = negligible)

**If needed later:**
- Lazy-load activity categories
- Reduce orb count on low-end devices (behind a capability check, not a setting)
