# Chunk - The ADHD Homework Helper

> One question at a time. No pressure. Just progress.

## Overview

Chunk is an ADHD-friendly homework helper that removes time pressure anxiety through radical task chunking. Kids work one question at a time with a calming breathing animation, then take structured 60-second breaks every 5 questions.

**Core Philosophy:**
- No time pressure (count-up timer hidden during work)
- One question at a time (but app doesn't enforce physical covering)
- Regular breaks to reset attention (mandatory, not optional)
- Zero data collection (privacy-first, local-only)
- Utility over artificial encouragement (show facts, not fake praise)

## Quick Start

### Prerequisites

- Flutter SDK 3.10.8 or higher
- Dart SDK
- Chrome or Edge (for web development)
- VS Code or Android Studio (recommended)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/chunk.git
cd chunk

# Switch to the MVP implementation worktree
cd .worktrees/mvp-implementation

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
│   ├── session_state.dart      # Session state (question count, progress)
│   └── break_activity.dart     # Break activity model
├── services/
│   ├── timer_service.dart      # Timer logic (start, stop, format)
│   └── activity_service.dart   # Activity selection and filtering
├── screens/
│   ├── start_screen.dart       # "Ready?" screen with Start button
│   ├── timer_screen.dart       # Work timer with breathing circle
│   ├── completion_screen.dart  # Show time taken and progress
│   └── break_screen.dart       # 60s break countdown + activity
├── widgets/
│   └── breathing_circle.dart   # Animated breathing circle (19s cycle)
└── theme/
    └── app_theme.dart          # Color palette and text styles

assets/
└── data/
    └── activities.json         # 52 break activities

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

### Dependencies

**Core:**
- `flutter` - UI framework
- `provider` (^6.1.0) - State management
- `shared_preferences` (^2.2.0) - Local storage (settings)

**Dev:**
- `flutter_test` - Testing framework
- `flutter_lints` (^6.0.0) - Linting rules

### State Management

Uses `provider` for state management with three providers:
- `SessionState` - Tracks question count, cycle progress
- `TimerService` - Handles timer start/stop and formatting
- `ActivityService` - Manages break activity selection

### Key Features Implemented

- **Start Screen**: Single "Start" button to begin a question
- **Timer Screen**: Breathing circle animation (4-7-8 pattern, 19s cycle)
- **Completion Screen**: Shows elapsed time ("3m 24s") and progress ("2/5 until break")
- **Break System**: Triggers automatically after 5 questions
- **Break Screen**: 60-second countdown with random activity suggestion
- **Activity Pool**: 52 varied activities with anti-repeat logic
- **Navigation Flow**: Clean navigation stack management
- **PWA Support**: Installable as progressive web app

## Current MVP Status

### What Works ✅

- Complete user flow (Start → Timer → Completion → Break → Repeat)
- Accurate timer (tested with code review)
- Smooth breathing animation (60fps on web)
- Break triggers correctly after 5th question
- Activity randomization with anti-repeat logic
- PWA installable on mobile devices
- Responsive design (phone, tablet, desktop)
- Zero data collection (privacy-first)

### What's Next 🚀

**v1.1 - Enhanced Experience:**
- Multiple animation styles (wave, particles, gradient)
- Sound effects toggle
- Activity refresh/skip buttons
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

- Web-based timer (slight inaccuracy if tab backgrounded)
- No session persistence (state resets on page refresh)
- Single user profile only
- Fixed 5-question break cadence
- No onboarding flow (jumps straight to Start)

## Testing

See [TESTING.md](TESTING.md) for complete testing report.

**Quick verification checklist:**
```bash
# 1. Run tests
flutter test

# 2. Run analyzer
flutter analyze

# 3. Run app and verify flow
flutter run -d chrome
# Then: Start → Done → Next (x5) → Break → Start (repeat)
```

## Deployment

See [docs/deployment.md](docs/deployment.md) for deployment instructions.

**Quick deploy to Firebase Hosting:**
```bash
flutter build web --release
firebase deploy
```

## Architecture

For detailed technical architecture, see [docs/architecture.md](docs/architecture.md).

**Key architectural decisions:**
- Flutter web for MVP (native apps later)
- Provider for simple state management
- No persistence (MVP simplification)
- CustomPainter for high-performance animations
- Privacy-first (zero data collection)

## Contributing

This is currently a private project in active development. Contributions will be opened after MVP launch.

## License

Proprietary - All rights reserved.

---

**Built with ❤️ for kids who think differently**
