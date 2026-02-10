# Chunk MVP - Technical Architecture

## Overview

Chunk is a Flutter web application designed with a clear path to native iOS/Android apps. The MVP focuses on web deployment for rapid iteration while maintaining architectural patterns that translate cleanly to native platforms.

### Core Principles

1. **Privacy First**: Zero data collection, no analytics, no cloud storage
2. **Performance**: 60fps animations, responsive UI, minimal dependencies
3. **Simplicity**: Clear separation of concerns, minimal state management
4. **Scalability**: Structured for native migration without major refactoring
5. **ADHD-Friendly**: One-task-at-a-time design, calming visuals, no pressure

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         User Interface                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Start   │→ │  Timer   │→ │Completion│→ │  Break   │   │
│  │  Screen  │  │  Screen  │  │  Screen  │  │  Screen  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                       ↑              ↓              ↓        │
│                       └──────────────┴──────────────┘        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                │   Provider (State)    │
                │  ┌──────────────────┐ │
                │  │  SessionState    │ │  Question count, progress
                │  ├──────────────────┤ │
                │  │  TimerService    │ │  Start, stop, format time
                │  ├──────────────────┤ │
                │  │ ActivityService  │ │  Break activity selection
                │  └──────────────────┘ │
                └───────────┬───────────┘
                            │
                ┌───────────┴───────────┐
                │    Domain Models      │
                │  ┌──────────────────┐ │
                │  │  SessionState    │ │  State management
                │  ├──────────────────┤ │
                │  │  BreakActivity   │ │  Activity data model
                │  └──────────────────┘ │
                └───────────┬───────────┘
                            │
                ┌───────────┴───────────┐
                │     Data Layer        │
                │  ┌──────────────────┐ │
                │  │ activities.json  │ │  52 break activities
                │  └──────────────────┘ │
                └───────────────────────┘
```

## Component Breakdown

### 1. Models

#### SessionState (`models/session_state.dart`)
**Purpose**: Tracks current session progress and state.

**State Variables:**
- `_questionCount` (int): Total questions completed in current cycle (1-5)
- `_lastCompletedTime` (int?): Seconds taken on last question

**Key Methods:**
- `incrementQuestion()`: Increments count and checks for break trigger
- `shouldTriggerBreak()`: Returns true when count reaches 5
- `resetCycle()`: Resets count to 0 after break
- `questionsUntilBreak`: Computed property (5 - count % 5)

**State Management**: Extends `ChangeNotifier` for reactive UI updates.

#### BreakActivity (`models/break_activity.dart`)
**Purpose**: Data model for break activities.

**Properties:**
- `id` (String): Unique identifier
- `text` (String): Activity instruction
- `emoji` (String): Visual icon
- `category` (String): Activity type (physical, silly, creative, etc.)

**Serialization**: JSON serialization via `fromJson()` factory.

### 2. Services

#### TimerService (`services/timer_service.dart`)
**Purpose**: Manages question timer lifecycle and formatting.

**State:**
- `_elapsedSeconds` (int): Current elapsed time
- `_timer` (Timer?): Dart Timer instance
- `isRunning` (bool): Prevents concurrent timer starts

**Methods:**
- `start()`: Begins 1-second interval timer
- `stop()`: Stops timer and returns elapsed time
- `formatTime(seconds)`: Converts seconds to "Xm Ys" format

**Design Notes:**
- Uses Dart's `Timer.periodic` for web MVP
- Structured for easy migration to native background tasks
- Notifies listeners on each second tick for reactive UI

#### ActivityService (`services/activity_service.dart`)
**Purpose**: Loads and randomly selects break activities.

**State:**
- `_activities` (List<BreakActivity>): Full activity pool
- `_recentActivityIds` (List<String>): Last 10 shown (anti-repeat)

**Methods:**
- `loadActivities()`: Loads from JSON asset on startup
- `getRandomActivity()`: Returns random activity, filtered by recent history

**Anti-Repeat Logic:**
1. Filter out activities in `_recentActivityIds`
2. Random selection from filtered pool
3. Add selected ID to recent history (max 10)
4. If all filtered out, reset history and use full pool

### 3. Screens

#### StartScreen (`screens/start_screen.dart`)
**Purpose**: Entry point for starting a new question.

**UI Elements:**
- "Ready?" heading (large, centered)
- "Start" button (primary action)
- Settings icon (corner, future use)

**Navigation:**
- Button tap → `TimerScreen` (pushReplacement)

**Design Notes:**
- Minimal UI to reduce cognitive load
- No extraneous information or choices
- Returns here after each break cycle

#### TimerScreen (`screens/timer_screen.dart`)
**Purpose**: Work timer with calming breathing animation.

**UI Elements:**
- Full-screen breathing circle (BreathingCircle widget)
- "Done" button (bottom, large tap target)
- Timer runs invisibly (no time display)

**Lifecycle:**
- `initState()`: Starts timer via `TimerService.start()`
- `dispose()`: Stops timer (defensive cleanup)

**Navigation:**
- "Done" tap → `CompletionScreen` with elapsed time (pushReplacement)

**Design Notes:**
- No visible timer = no time pressure
- Breathing circle provides ambient focus aid
- Screen stays awake (prevent device sleep in future)

#### CompletionScreen (`screens/completion_screen.dart`)
**Purpose**: Shows time taken and progress toward break.

**UI Elements:**
- Time display: "That took Xm Ys" (large, centered)
- Progress indicator: "X/5 until break" (or hidden if break time)
- "Next question" or "Break time!" button

**Logic:**
- Increments question count via `SessionState`
- Checks if break should trigger
- Shows different button based on break status

**Navigation:**
- "Next question" → `TimerScreen` (pushReplacement)
- "Break time!" → `BreakScreen` (pushReplacement)

#### BreakScreen (`screens/break_screen.dart`)
**Purpose**: Mandatory 60-second break with activity suggestion.

**UI Elements:**
- "Break time!" header
- Countdown timer: "Xs" (large, counting down from 60)
- Activity suggestion: "How about: [activity] [emoji]"
- "Back to work" button (appears in last 3 seconds)

**Lifecycle:**
- `initState()`: Starts 60s countdown timer, fetches random activity
- Timer decrements every second
- Auto-navigation when countdown reaches 0
- `dispose()`: Cancels timer (important for cleanup)

**Navigation:**
- Countdown reaches 0 → `StartScreen` (pushAndRemoveUntil)
- "Back to work" → `StartScreen` (early exit option)

**Design Notes:**
- Mandatory break (no skip button in MVP)
- Activity is a suggestion, not prescription
- Clears navigation stack to prevent buildup

### 4. Widgets

#### BreathingCircle (`widgets/breathing_circle.dart`)
**Purpose**: Animated breathing circle following 4-7-8 pattern.

**Animation Specs:**
- **Total cycle**: 19 seconds (4s expand + 7s hold + 8s contract)
- **Expand phase**: 0-4s (scale 0.7 → 1.0, easeInOut)
- **Hold phase**: 4-11s (scale 1.0, linear)
- **Contract phase**: 11-19s (scale 1.0 → 0.7, easeInOut)
- **Color transition**: Blue (#6B9BD1) → Purple (#9B7BB5) throughout cycle

**Implementation:**
- Uses `AnimationController` with 19-second duration
- `CustomPainter` for high-performance rendering
- Tween animations for scale and color
- Repeats infinitely (`repeat()`)

**Performance:**
- Targets 60fps on web
- Hardware-accelerated via CustomPaint
- Minimal CPU usage (single animation controller)

### 5. Theme

#### AppTheme (`theme/app_theme.dart`)
**Purpose**: Centralized design system and styling.

**Color Palette:**
- Primary: Blue (#6B9BD1) - buttons, accents
- Secondary: Purple (#9B7BB5) - breathing circle gradient
- Background: White (#FFFFFF)
- Surface: Light gray (#F5F5F5)
- Text: Dark gray (#333333)

**Typography:**
- Display (48px): Large headings
- Headline (32px): Section titles
- Title (24px): Button text
- Body (18px): Instructions, descriptions
- Label (14px): Small text, hints

**Button Styles:**
- Large tap targets (60px height minimum)
- Rounded corners (12px radius)
- High contrast (white text on blue)
- Instant visual feedback on press

## Data Flow

### Question Completion Flow

```
1. User on StartScreen
   ↓ Taps "Start"
2. Navigate to TimerScreen
   ↓ TimerService.start()
3. Timer counts up (hidden from user)
   ↓ User works on question
4. User taps "Done"
   ↓ TimerService.stop() returns elapsed time
5. Navigate to CompletionScreen(elapsedTime)
   ↓ Display time, increment SessionState
6. SessionState.incrementQuestion()
   ↓ Check if shouldTriggerBreak()
7a. If count < 5:
    → Show "Next question" button
    → Navigate to TimerScreen (repeat)
7b. If count == 5:
    → Show "Break time!" button
    → Navigate to BreakScreen
```

### Break Flow

```
1. User on BreakScreen
   ↓ 60-second countdown starts
2. ActivityService.getRandomActivity()
   ↓ Display activity suggestion
3. Countdown ticks down (60 → 0)
   ↓ User takes break
4. Countdown reaches 0 (or user taps early exit)
   ↓ SessionState.resetCycle()
5. Navigate to StartScreen (clear stack)
   ↓ Ready for next cycle
```

## State Management Pattern

### Provider Architecture

Chunk uses Provider for simple, predictable state management:

**Why Provider?**
- Minimal boilerplate for small app scope
- Easy to understand and debug
- Direct listener pattern (reactive UI)
- Low learning curve for contributors

**Provider Setup (main.dart):**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SessionState()),
    ChangeNotifierProvider(create: (_) => TimerService()),
    Provider.value(value: activityService),
  ],
  child: MaterialApp(...)
)
```

**Consumption Pattern:**
```dart
// Read state
final sessionState = context.watch<SessionState>();

// Trigger actions
context.read<TimerService>().start();
```

**State Scope:**
- SessionState: App-wide (question count, cycle tracking)
- TimerService: App-wide (timer lifecycle)
- ActivityService: Read-only singleton (activity data)

## Animation Architecture

### Breathing Circle Technical Deep-Dive

**Animation Controller:**
- Duration: 19 seconds (4+7+8)
- Repeats: Infinitely
- Disposal: Cleaned up in widget dispose()

**Tween Configuration:**
```dart
// Scale animation (breathe in/out)
Tween<double>(begin: 0.7, end: 1.0)
  .chain(CurveTween(curve: Interval(0.0, 0.21, curve: Curves.easeInOut)))
  .animate(_controller)

// Hold at full scale
Interval(0.21, 0.58, curve: Curves.linear)

// Contract animation
Interval(0.58, 1.0, curve: Curves.easeInOut)

// Color transition (blue to purple)
ColorTween(begin: Color(0xFF6B9BD1), end: Color(0xFF9B7BB5))
  .animate(_controller)
```

**CustomPainter Rendering:**
```dart
canvas.drawCircle(
  center,
  radius * scale.value,
  Paint()..color = color.value
)
```

**Performance Considerations:**
- Single paint operation per frame
- No complex gradients or shadows (web optimization)
- Hardware-accelerated compositing
- Smooth on 60Hz displays

## Navigation Pattern

### Stack Management

Chunk uses careful navigation patterns to prevent stack buildup:

**pushReplacement (most transitions):**
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => NextScreen()),
)
```
- Replaces current screen with new screen
- Prevents back button stack buildup
- Used for: Start → Timer, Timer → Completion, Completion → Timer/Break

**pushAndRemoveUntil (reset to Start):**
```dart
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => StartScreen()),
  (route) => false,
)
```
- Clears entire navigation stack
- Used after break completes
- Ensures clean state for next cycle

**No Back Button:**
- Web MVP doesn't use browser back button
- Native apps will disable back gesture during timer
- User-driven flow only (no accidental exits)

## Data Persistence

### MVP Approach: No Persistence

**Why no persistence?**
- Simplifies MVP implementation
- No privacy concerns (truly zero data collection)
- No sync issues or migration headaches
- Faster development and testing

**What's NOT persisted:**
- Session history
- Cumulative statistics
- User preferences
- Break activity history (resets on reload)

**What IS persisted (future):**
- Settings (via shared_preferences)
- Optional parent insights (local-only, with clear opt-in)

## Testing Strategy

### Unit Tests
- Model logic (SessionState calculations)
- Service methods (timer formatting, activity selection)
- Pure functions (time conversion, string formatting)

### Widget Tests
- Screen rendering
- Button interactions
- Navigation flows
- State updates trigger UI changes

### Integration Tests (future)
- Complete user flow (Start → Break → Start)
- Multi-cycle testing
- Activity randomization over many selections
- Timer accuracy validation

## Future Considerations

### Native App Migration

**What changes:**
- Timer implementation (background tasks)
- Notification system (break alerts)
- Screen wake locks (prevent sleep during timer)
- Better touch gestures and haptics

**What stays the same:**
- UI layouts and screens
- State management (Provider works on native)
- Business logic (models, services)
- Assets (activities.json, icons)

**Migration path:**
1. Add platform-specific timer implementations
2. Implement background task handlers
3. Add notification permissions and handlers
4. Test on physical devices
5. Submit to App Store / Play Store

### Scalability

**Multiple profiles:**
- Extend SessionState to include profileId
- Add profile selection screen before Start
- Store profile-specific settings locally

**Configurable break frequency:**
- Add setting for questions per break (3-7 range)
- Update SessionState logic to use dynamic threshold
- Allow per-profile configuration

**Session history:**
- Add local SQLite database
- Store completed sessions with metadata
- Build parent insights dashboard (local-only)
- Export to CSV for external analysis

**Extended activity pool:**
- Support multiple activity files (categories)
- Allow custom user-added activities
- Implement activity favorites/blocking
- Add difficulty/age filtering

### Performance Optimizations

**Current bottlenecks (none critical for MVP):**
- JSON parsing on startup (52 activities = negligible)
- Timer tick notifications (1 per second = negligible)

**Future optimizations (if needed):**
- Lazy-load activity categories
- Cache formatted time strings
- Reduce animation complexity on low-end devices
- Add performance monitoring (local-only metrics)

## Security & Privacy

### Zero Data Collection

**What we DON'T collect:**
- No analytics or telemetry
- No crash reports to external services
- No user accounts or authentication
- No cloud storage or syncing
- No third-party SDKs

**What stays on device:**
- In-memory session state (cleared on close)
- Local activity history (for anti-repeat)
- Future: Local preferences and insights (opt-in)

**Privacy compliance:**
- COPPA compliant (no data = no parental consent needed)
- GDPR compliant (no data = no privacy policy needed)
- App Store privacy label: "No Data Collected"

### Web Security

**Current measures:**
- No cookies (beyond essential Flutter framework)
- No local storage (MVP)
- No external API calls
- Content Security Policy (default Flutter web)

**Future (native apps):**
- Device-local encryption for stored data
- No cloud sync (privacy-first principle)
- Clear data deletion in settings

## Development Guidelines

### Code Style

**Flutter/Dart conventions:**
- Follow official Dart style guide
- Use `flutter analyze` for linting
- Maximum line length: 80 characters
- Prefer const constructors where possible

**State management:**
- Keep state minimal and local
- Use ChangeNotifier for reactive state
- Call `notifyListeners()` after state changes
- Dispose controllers in dispose() methods

**Navigation:**
- Use pushReplacement to prevent stack buildup
- Clear stack with pushAndRemoveUntil when resetting
- Pass data via constructor parameters, not global state

### Performance Best Practices

**Animations:**
- Dispose AnimationControllers in dispose()
- Use const constructors for static widgets
- Avoid rebuilding entire widget tree unnecessarily
- Use RepaintBoundary for isolated animations

**Timers:**
- Cancel timers in dispose()
- Check if widget is mounted before calling setState
- Use Timer.periodic for consistent intervals
- Don't create multiple timers for same purpose

**State:**
- Keep Provider scope as local as possible
- Use context.watch() for reactive UI
- Use context.read() for one-time actions
- Avoid context.watch() in event handlers

## Conclusion

Chunk's architecture prioritizes simplicity, performance, and privacy while maintaining a clear path to native mobile apps. The MVP focuses on web deployment to enable rapid iteration and testing with real users, with every architectural decision considering future scalability and native migration.

Key architectural strengths:
- Clean separation of concerns (models, services, screens, widgets)
- Simple, predictable state management (Provider)
- High-performance animations (CustomPainter)
- Privacy-first design (zero data collection)
- Native-ready structure (easy migration path)

This architecture supports the core mission: helping ADHD kids succeed with homework through radical task chunking, calming visuals, and zero time pressure.
