# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Chunk** is an ADHD-friendly homework helper Flutter app that breaks tasks into manageable pieces. The core insight: showing one question at a time removes the overwhelm of seeing an entire worksheet.

**Key Differentiators:**
- No time pressure - count-up timer only, obfuscated during work
- Radical task chunking - one question at a time approach
- Structured breaks every 5 questions with silly activities (10s/30s/60s, selectable)
- Privacy-first - zero data collection, everything local

## Development Setup

This project uses **Flutter 3.x** developed on Windows, targeting web first (deployed to GitHub Pages), with iOS, iPadOS, and Android native apps planned. CI pins the Flutter version — see `.github/workflows/pages.yml`.

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run a specific target device
flutter devices
flutter run -d <device-id>

# Build for Android
flutter build apk --release
flutter build appbundle --release

# Build for iOS (requires Mac or cloud build service)
# Use Codemagic or App Center for iOS builds from Windows
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage

# Static analysis (must be clean)
flutter analyze
```

CI runs `flutter analyze` and `flutter test` on every push before building the Pages deploy. See [TESTING.md](TESTING.md) for the testing guide and manual verification checklist.

## Code Architecture

### Core Design Philosophy
- **ADHD-optimized UX**: Minimal friction, immediate feedback, no overwhelming choices
- **Anxiety reduction**: No visible countdown timers, no judgment on time taken, flexible pacing
- **Privacy-first**: No accounts, no cloud storage, no analytics, no ads. Everything stays on device.

### App Flow

Single-screen vertical swipe navigation (`lib/screens/session_screen.dart`): each session step is a full-screen card in a `PageView`. Swipe up (or tap the arrow) advances; swipe down revisits history.

```
Start → Timer → Completion → (Timer → Completion …) → Break → Start … → Summary
                     ↳ "all done" → Summary        ↳ "all done" → Summary
```

Cards live in `lib/widgets/` (`completion_card.dart`, `break_card.dart`, `summary_card.dart`). Step types are defined in `lib/models/session_step.dart`.

### Key Technical Components

**Timer System:**
- Count-up timer, hidden during work; elapsed time derived from the wall clock (`TimerService`), not tick counting, so background throttling doesn't corrupt timings
- Break countdown is derived from an end timestamp for the same reason
- Future native work: WorkManager (Android) / Background Tasks (iOS), wake locks

**Animation Layer:**
- Breathing circle with 4-7-8 pattern (4s expand, 7s hold, 8s contract) over a 19s cycle, plus a slow ambient orb background
- 60fps target; background lives in its own `RepaintBoundary`
- Respects OS reduced-motion setting (renders static when disabled)

**Break Activity System:**
- 50 activities in `assets/data/activities.json`, 5 categories (physical, silly, creative, breathing, low-energy)
- Random selection with history tracking (last 10 avoided, full-pool fallback)
- Single break-duration setting (10s/30s/60s); suggestions are flexible, no skip/refresh buttons

**Data Persistence:**
- Minimal by design: only `breakDuration` persists (SharedPreferences)
- Session state (counts, timings, history) is in-memory and resets on restart

### State Management

**Provider**, with four providers wired in `main.dart`:
- `SessionState` (`ChangeNotifier`) — counts, progress, per-question times, break duration
- `TimerService` (`ChangeNotifier`) — timer lifecycle, wall-clock elapsed, formatting
- `ActivityService` (plain provider) — activity pool, loaded once at startup
- `SoundService` (plain provider) — pop/chime/ding playback (native: audioplayers, web: Audio API)

## Voice, Tone & Copy Guidelines

When writing user-facing text, always follow these rules:

**DO:**
- Keep it short and direct
- Use "you" to speak to the kid
- Be specific: "Take a deep breath" not "Relax"
- Celebrate without pressure: "Nice work!" not "Great job! Keep it up!"
- Reinforce one-at-a-time: "Just this one" "One down"

**DON'T:**
- Use teacher voice: "Excellent work, you're doing great!"
- Create urgency: "Hurry up!" or "Almost done!"
- Add pressure: "You're on a 5-day streak!"
- Reference total work remaining: "Only 15 more to go!"

**Example Messages:**
✅ "That took 3m 24s"
✅ "Ready for the next one?"
✅ "Break time! Do 10 jumping jacks"
✅ "Nice! 2 down, 3 to go until break"

❌ "Awesome job! You're crushing it! 🎉"
❌ "You completed that in record time!"
❌ "You only have 12 more problems left!"

## Critical Technical Challenges

1. **Background Timer Accuracy**
   - Wall-clock-derived elapsed time keeps web timings honest under tab throttling
   - Handle interruptions (calls, notifications) gracefully
   - Native background tasks still needed for true background operation (v2.0)

2. **Animation Performance**
   - Smooth 60fps breathing circle on all devices (phone to tablet)
   - Low battery impact during extended sessions
   - Scalable across screen sizes (see `AppTheme.scaleFactor`)

3. **Accessibility**
   - Screen reader labels on navigation arrows and countdowns (Text content is read by default)
   - Color blind friendly palette (Catppuccin Mocha)
   - Reduced motion support for ambient animations
   - Large tap targets, high contrast

## Dependencies

**Core:**
- `provider` (^6.1.0) - State management
- `shared_preferences` (^2.2.0) - Break-duration setting persistence
- `audioplayers` (^6.5.1) - Sound effects on native platforms

**Dev:**
- `flutter_test` - Testing framework
- `flutter_lints` (^6.0.0) - Linting rules

Keep dependencies minimal for app size and simplicity.

## File Structure

```
lib/
├── main.dart             # App entry point, provider setup
├── models/               # SessionState, SessionStep, BreakActivity
├── services/             # TimerService, ActivityService, SoundService (native/web)
├── screens/              # SessionScreen (single-screen PageView flow)
├── widgets/              # Cards, BreathingCircle, AmbientBackground, AdvanceArrow, ...
└── theme/                # AppTheme (Catppuccin Mocha palette, type, scaling)
test/                     # Unit tests per service/model + widget tests
assets/
├── data/activities.json  # 50 break activities
└── sounds/               # chime.wav, ding.wav, pop.wav
```

## Development Principles

1. **Kids First**: Every design decision should reduce anxiety and increase engagement for ADHD kids
2. **Privacy is Sacred**: Never add features that require data collection
3. **No Over-Engineering**: Keep it simple - this is a single-purpose app
4. **Performance Matters**: 60fps animations and instant responsiveness are non-negotiable
5. **Fail Gracefully**: If something breaks, reset cleanly - never make kids feel bad

## Platform-Specific Notes

**Web (current target):**
- Deployed automatically to GitHub Pages on every `main` push (`.github/workflows/pages.yml`)
- PWA manifest enables "Add to Home Screen"

**iOS Builds from Windows:**
- Use Codemagic or App Center for cloud builds
- No local Mac required for development
- TestFlight for beta distribution

**Android:**
- Can build directly from Windows
- Easy sideloading for testing
- Google Play Console for distribution

## Open Design Questions

Resolved since the MVP design (kept for context):
- ~~Completion Reveal~~: shows elapsed time + progress counter; session summary adds per-question recap
- ~~Session End~~: explicit "all done" button on completion/break cards → summary card
- ~~Skip Limits~~: no skip buttons; break suggestions are flexible by design

Still open:
1. **Break Cadence**: Is 5 questions right for all ages? Should it be configurable? (Break *duration* is now configurable: 10s/30s/60s.)
2. **Question variation**: Should very quick (<30s) or very long (>10min) questions be handled differently?
3. **Activity refresh**: Do kids want a "different activity" button even though suggestions are flexible?

When implementing features that touch these areas, consider discussing approach first.

## Testing Strategy

**Target Testers**: Caleb (10) and Asher (8) - primary users

**Success Metrics:**
- Kid uses it without being told
- Less homework resistance
- Kid seems calmer during homework
- Kid naturally starts covering worksheets (one-at-a-time method)

**Watch For:**
- Gaming the system
- Breaks becoming more distracting than helpful
- New anxiety creation (obsessing over times)

## Coming from JavaScript?

Dart will feel familiar:
- Similar syntax to JavaScript/TypeScript
- Strong typing (like TypeScript)
- Async/await works identically
- Main differences: sound null safety (no `null` by default), pub package manager

Learning curve: ~2-3 days to productivity with Claude assistance.

## Current Status

**Working app, deployed to GitHub Pages.** Swipe-navigation session flow (start → timer → completion → break → summary), wall-clock timer, 4-7-8 breathing animation, 50 break activities, sounds/haptics, dark Catppuccin Mocha theme. Unit + widget tests with a CI gate (`flutter analyze` + `flutter test` before deploy).

Next horizons (see README "What's Next"): v1.1 experience polish (animation styles, sound toggle, activity refresh, 100+ activities), v2.0 native apps with true background timer support.
