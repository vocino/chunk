# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Chunk** is an ADHD-friendly homework helper Flutter app that breaks tasks into manageable pieces. The core insight: showing one question at a time removes the overwhelm of seeing an entire worksheet.

**Key Differentiators:**
- No time pressure - count-up timer only, obfuscated during work
- Radical task chunking - one question at a time approach
- Movement breaks every 5 questions with silly activities
- Privacy-first - zero data collection, everything local

## Development Setup

This project uses **Flutter 3.x** developed on Windows, targeting iOS, iPadOS, and Android.

```bash
# Install dependencies (once project initialized)
flutter pub get

# Run on connected device/emulator
flutter run

# Run with hot reload enabled (default)
flutter run --hot

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

# Run widget tests with verbose output
flutter test --verbose
```

## Code Architecture

### Core Design Philosophy
- **ADHD-optimized UX**: Minimal friction, immediate feedback, no overwhelming choices
- **Anxiety reduction**: No visible countdown timers, no judgment on time taken, flexible pacing
- **Privacy-first**: No accounts, no cloud storage, no analytics, no ads. Everything stays on device.

### Key Technical Components

**Timer System:**
- Count-up timer running invisibly in background
- Must handle app backgrounding/foregrounding gracefully
- Precise timing critical for session tracking
- Use WorkManager (Android) / Background Tasks (iOS) for reliability

**Animation Layer:**
- MVP: Breathing circle with 4-7-8 pattern (4s expand, 7s hold, 8s contract)
- Must maintain 60fps performance on all devices
- CustomPainter + AnimationController approach
- Battery efficiency critical for long homework sessions

**Break Activity System:**
- 50+ activities in MVP, 100+ in v1.1
- Random selection with history tracking (avoid repeats within session)
- Unlimited refresh, limited skip (2 per session)
- Activities must be: quick (20-60s), silly, physical, low-prep

**Data Persistence:**
- Local-only storage using Hive or SharedPreferences
- Session state (in-memory, cleared on end)
- Break activity history (last 10 to avoid repeats)
- Optional parent insights (local device only)

### State Management
TBD - likely Provider or Riverpod. Choose based on:
- Simplicity for timer state
- Performance for 60fps animations
- Ease of testing

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
   - Timer must continue accurately when app is backgrounded
   - Handle interruptions (calls, notifications) gracefully
   - Balance precision vs battery life

2. **Animation Performance**
   - Smooth 60fps breathing circle on all devices (phone to tablet)
   - Low battery impact during extended sessions
   - Scalable across screen sizes

3. **Accessibility**
   - Screen reader support (Semantics widgets throughout)
   - Color blind friendly palette
   - Reduced motion support for breathing circle
   - Adjustable animation intensity

## Dependencies (Planned)

**Core:**
- `provider` or `riverpod` - State management
- `hive` or `shared_preferences` - Local data persistence

**Features:**
- `flutter_local_notifications` - Break reminders (v1.1+)
- `workmanager` - Background timer management
- `audioplayers` - Sound effects (v1.1+)

Keep dependencies minimal for app size and simplicity.

## File Structure (To Be Established)

Recommended structure once initialized:
```
lib/
├── main.dart
├── models/           # Session, Activity, UserPreferences
├── services/         # TimerService, StorageService, ActivityService
├── screens/          # Onboarding, Timer, Break, Completion
├── widgets/          # BreathingCircle, ProgressIndicator
├── theme/            # Colors, typography, spacing
└── utils/            # Constants, helpers
```

## Development Principles

1. **Kids First**: Every design decision should reduce anxiety and increase engagement for ADHD kids
2. **Privacy is Sacred**: Never add features that require data collection
3. **No Over-Engineering**: Keep it simple - this is a single-purpose app
4. **Performance Matters**: 60fps animations and instant responsiveness are non-negotiable
5. **Fail Gracefully**: If something breaks, reset cleanly - never make kids feel bad

## Platform-Specific Notes

**iOS Builds from Windows:**
- Use Codemagic or App Center for cloud builds
- No local Mac required for development
- TestFlight for beta distribution

**Android:**
- Can build directly from Windows
- Easy sideloading for testing
- Google Play Console for distribution

## Open Design Questions

These need resolution during development:

1. **Break Cadence**: Is 5 questions right for all ages? Should it be configurable?
2. **Completion Reveal**: Just show time, or add context? Make it optional?
3. **Skip Limits**: 2 per session? Reset after breaks?
4. **Session End**: Explicit "End session" button or just close app?

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

**Project is in initial setup phase.** No Flutter project structure exists yet. README contains comprehensive product requirements and vision.

First steps:
1. Initialize Flutter project: `flutter create chunk`
2. Set up state management
3. Implement breathing circle animation (MVP focus)
4. Build timer system with background handling
5. Create break activity database
