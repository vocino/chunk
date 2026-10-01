# Chunk - The ADHD Homework Helper

> One question at a time. No pressure. Just progress.

## Overview

Chunk is an ADHD-friendly homework helper that removes time pressure anxiety through radical task chunking. Kids work one question at a time with a calming breathing animation, then take structured breaks every 5 questions.

**Core Philosophy:**
- No time pressure (count-up timer hidden during work)
- One question at a time (but app doesn't enforce physical covering)
- Regular breaks to reset attention (mandatory, not optional)
- Zero data collection (privacy-first, local-only)
- Utility over artificial encouragement (show facts, not fake praise)

## Quick Start

### Prerequisites

- Flutter SDK (see `.github/workflows/pages.yml` for the pinned CI version)
- Dart SDK (bundled with Flutter)
- Chrome or Edge (for web development)
- VS Code or Android Studio (recommended)

A project-local SDK also works: unzip the pinned Flutter release to `.flutter/`
(gitignored) and run it as `.flutter/bin/flutter` with `PUB_CACHE` pointed at
the gitignored `.pub-cache/` dir to keep caches off the system drive.

### Installation

```bash
# Clone the repository
git clone https://github.com/vocino/chunk.git
cd chunk

# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Or run on Edge
flutter run -d edge
```

### Build for Production

```bash
# Build web version
flutter build web --release

# Output will be in build/web/
```

## Development

### Project Structure

```
lib/
├── main.dart                   # App entry point, provider setup
├── models/
│   ├── session_state.dart      # Session state (question count, progress, timings)
│   ├── session_step.dart       # Step types for the swipe-navigation flow
│   └── break_activity.dart     # Break activity model
├── services/
│   ├── timer_service.dart      # Wall-clock timer logic (start, stop, format)
│   ├── activity_service.dart   # Activity selection and filtering
│   └── sound_service*.dart     # Sound effects (native audioplayers / web Audio API)
├── screens/
│   └── session_screen.dart     # Single-screen vertical PageView flow
├── widgets/
│   ├── advance_arrow.dart      # Swipe-up / tap-to-advance affordance
│   ├── ambient_background.dart # Slow-drifting background orbs
│   ├── break_timer_selector.dart # 10s / 30s / 60s break duration pills
│   ├── breathing_circle.dart   # 4-7-8 breathing animation (19s cycle)
│   ├── completion_card.dart    # "That took ..." + progress until break
│   ├── break_card.dart         # Break countdown + activity suggestion
│   ├── summary_card.dart       # End-of-session per-question recap
│   └── glass_container.dart    # Translucent card surface
└── theme/
    └── app_theme.dart          # Catppuccin Mocha palette, type, scaling

assets/
├── data/
│   └── activities.json         # 50 break activities in 5 categories
├── fonts/                      # Bundled Nunito 400/600/700/800 (+ OFL.txt)
└── sounds/
    ├── chime.wav               # Break start
    ├── ding.wav                # Break end
    └── pop.wav                 # Question completed

test/
├── activity_service_test.dart  # Anti-repeat selection, pool fallback
├── session_state_test.dart     # Break cadence, counters, history cap
├── timer_service_test.dart     # Start/stop, wall-clock elapsed, formatting
├── card_widget_test.dart       # Completion + break card widget tests
├── desktop_input_test.dart     # Mouse drag, click, and wheel advance
└── widget_test.dart            # App launch smoke test

web/
├── index.html                  # PWA setup
├── manifest.json               # PWA manifest
└── icons/                      # App icons
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run analyzer
flutter analyze
```

CI runs `flutter analyze` and `flutter test` on every push (see `.github/workflows/pages.yml`), then builds and deploys the web app to GitHub Pages.

### Dependencies

**Core:**
- `flutter` - UI framework
- `provider` (^6.1.0) - State management
- `shared_preferences` (^2.2.0) - Local storage (break duration setting)
- `audioplayers` (^6.5.1) - Sound effects (native platforms; web uses the Audio API directly)

**Dev:**
- `flutter_test` - Testing framework
- `flutter_lints` (^6.0.0) - Linting rules

### State Management

Uses `provider` for state management with four providers:
- `SessionState` - Tracks question count, cycle progress, per-question times, break duration
- `TimerService` - Handles timer start/stop and formatting (wall-clock derived)
- `ActivityService` - Manages break activity selection
- `SoundService` - Plays pop/chime/ding feedback sounds

### Key Features Implemented

- **Swipe navigation**: Single-screen vertical `PageView` — swipe up (or tap the arrow) to advance
- **Start card**: "Ready?" prompt with selectable break duration (10s / 30s / 60s)
- **Timer card**: Breathing circle animation (4-7-8 pattern, 19s cycle), timer hidden
- **Completion card**: Shows elapsed time ("03:24") and progress ("2 more until break")
- **Break system**: Triggers automatically after 5 questions, with random activity suggestion
- **Break card**: Countdown with activity idea, "something else" refresh, early "back to work" exit
- **Summary card**: End-of-session recap with per-question times and total ("all done")
- **Sound + haptics**: Subtle feedback on completion, break start, and break end
- **Activity pool**: 50 varied activities with anti-repeat logic
- **PWA support**: Installable as progressive web app

## Current Status

### What Works ✅

- Complete user flow (Start → Timer → Completion → Break → Repeat → Summary)
- Wall-clock timer (robust to background throttling)
- Smooth breathing animation with reduced-motion support
- Break triggers correctly after 5th question
- Activity randomization with anti-repeat logic
- Break duration persists across restarts
- PWA installable on mobile devices
- Responsive design (phone, tablet, desktop)
- Zero data collection (privacy-first)

### What's Next 🚀

**v1.1 - Enhanced Experience:**
- Multiple animation styles (wave, particles, gradient)
- Sound effects toggle
- Activity skip button ("something else" refresh shipped)
- Extended activity pool (100+ activities)

**v2.0 - Native Apps:**
- iOS/iPadOS native app
- Android native app
- Background timer support
- Better mobile gestures

**v2.1 - Advanced Features:**
- Parent insights dashboard (local-only)
- Multiple kid profiles
- Configurable break frequency (3-7 questions)
- Subject categorization

### Known Limitations

- Web-based (native apps planned for v2.0)
- No session persistence across page refresh (only the break-duration setting persists)
- Single user profile only
- Fixed 5-question break cadence
- No onboarding flow (start card carries a one-line hint)

## Testing

See [TESTING.md](TESTING.md) for the testing guide.

**Quick verification checklist:**
```bash
# 1. Run tests
flutter test

# 2. Run analyzer
flutter analyze

# 3. Run app and verify flow
flutter run -d chrome
# Then swipe up through: Start → Timer → Completion (x5) → Break → Start, and "all done" → Summary
```

## Deployment

See [docs/deployment.md](docs/deployment.md) for deployment instructions.

**Production deploys automatically:** every push to `main` builds (`flutter build web --release`) and deploys to GitHub Pages via `.github/workflows/pages.yml`.

## Architecture

For detailed technical architecture, see [docs/architecture.md](docs/architecture.md).

**Key architectural decisions:**
- Flutter web first, deployed to GitHub Pages (native apps later)
- Single-screen swipe navigation (`SessionScreen` + card widgets)
- Provider for simple state management
- Wall-clock-derived elapsed time (robust to timer throttling)
- Minimal persistence: break-duration setting only (shared_preferences)
- Privacy-first (zero data collection)

## Contributing

This is currently a private project in active development. Contributions will be opened after MVP launch.

## License

Proprietary - All rights reserved.

---

**Built with ❤️ for kids who think differently**
