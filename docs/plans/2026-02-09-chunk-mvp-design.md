# Chunk MVP Design
**Date:** 2026-02-09
**Status:** Approved
**Target:** Web-first MVP, designed for eventual iOS/Android native apps

## Overview

Chunk is an ADHD-friendly homework helper that removes time pressure anxiety through radical task chunking. Kids work one question at a time with a calming ambient timer, then take structured 60-second breaks every 5 questions.

**Core Philosophy:**
- No time pressure (count-up timer hidden during work)
- One question at a time (but app doesn't enforce physical covering)
- Regular breaks to reset attention (mandatory, not optional)
- Zero data collection (privacy-first, local-only)
- Utility over artificial encouragement (show facts, not fake praise)

## User Flow

```
1. Launch → "Ready?" screen with Start button
2. Tap Start → Timer screen (breathing circle + Done button)
3. Work on question → Tap Done
4. Completion screen ("That took 3m 24s" + "2/5 until break")
5. Tap "Next question" → back to Timer screen
6. After 5th question → 60s Break countdown + activity suggestion
7. Auto-return to "Ready?" screen
8. Repeat or close app when finished with homework
```

**Key Insight:** Breaks are mandatory (every 5 questions), but WHAT you do during the break is up to you. Activity suggestions are fun ideas, not prescriptions.

## Core Architecture

### Timer Service
- Tracks elapsed time per question
- Start/stop only (no pause functionality)
- Designed for web initially, structured for native background handling later
- Uses Dart's Timer class, wrapped in service layer

### Session State (In-Memory)
- Question count in current cycle (1-5)
- Cumulative time (for future analytics)
- Break activity history (last 10 shown to avoid repeats)
- Resets completely on app close (no persistence in MVP)

### Break Activity System
- 50+ activities stored as JSON array
- Random selection filtered by recent history
- Format: `{id, text, emoji, category}`
- Categories: physical, silly, creative, breathing, low-energy

### Breathing Animation
- 4-7-8 breathing pattern (4s expand, 7s hold, 8s contract)
- CustomPainter + AnimationController
- Continuous 60fps loop
- Soft blue-to-purple gradient
- Ambient presence, not meant to be actively watched

## Screen Specifications

### Start Screen
- Large "Start" button (centered)
- Settings gear icon (corner) - contains "How to use" and future settings
- Minimal, clean design
- Appears: first launch, after each 5-question break cycle, when kid reopens app

### Timer Screen (Work Time)
- Full-screen breathing circle (60-70% of screen height)
- "Done" button at bottom (large tap target)
- No time display, no progress counter
- Circle animates continuously
- Screen stays awake (prevent device sleep)

### Completion Screen
- Time taken: "That took 3m 24s" (large, centered)
- Progress: "2/5 until break" (below time)
- "Next question" button (bottom)
- No animations or celebrations
- Pure information, move on quickly

### Break Screen
- "Break time!" header
- Countdown timer: "48s" (large, centered, counting down)
- Activity suggestion: "How about: Do 10 jumping jacks 🤸"
- After countdown hits 0: auto-transition to Start screen (or brief "Back to work" button)
- Playful but focused

## Visual Design System

### Colors
- Breathing circle: soft blues → purples (calming gradient)
- Background: white or very light gray (neutral)
- Text: dark gray/black (high contrast)
- Buttons: accent color (blue), large and clear

### Typography
- Sans-serif fonts
- Large, readable sizes
- Generous spacing between elements
- Minimal text overall

### Interaction Design
- Large tap targets (minimum 60px height)
- Rounded corner buttons
- Instant feedback on taps
- No loading states (everything is fast)

### Animation Philosophy
- Only the breathing circle animates
- Everything else is static/instant for clarity
- No page transitions, no slide-ins - just appear/disappear
- 60fps target for breathing circle

## Break Activity Content

### Activity Structure
```json
{
  "id": "jump-jacks",
  "text": "Do 10 jumping jacks",
  "emoji": "🤸",
  "category": "physical"
}
```

### Selection Logic
1. Random selection from full pool
2. Filter out last 10 activities shown
3. If pool exhausted (>50 questions in session), reset history
4. No difficulty/age filtering in MVP

### Activity Tone
- Short and punchy: "Do 10 jumping jacks"
- One emoji per activity (visual interest)
- No detailed instructions (kids figure it out)
- Range from high-energy to low-energy

### MVP Activity Pool (50+ needed)
**Physical:** jumping jacks, high knees, arm circles, toe touches, wall push-ups, hop on one foot, invisible jump rope, march in place, windmill arms, dance for 10 seconds

**Silly:** chicken dance, robot walk, make 3 funny faces, pretend you're a penguin, walk backwards 10 steps, spin around 5 times, zombie walk, superhero pose, wiggle like jelly

**Creative:** draw a squiggle, write your name backwards, make up a silly word, count backwards from 20, spell a word in the air, think of 3 animals that start with B

**Breathing/Stretching:** big arm stretch overhead, shoulder rolls, 5 deep breaths, reach for the ceiling, touch your toes, neck rolls, shake out your hands, stretch like a cat

**Low-Energy:** wiggle your toes, blink really fast 10 times, make circles with your thumbs, drum your fingers, touch each finger to your thumb, squeeze your fists tight then release

## Technical Implementation

### Stack
- **Framework:** Flutter 3.x (web initially, iOS/Android later)
- **State Management:** Provider (simple, sufficient for scope)
- **Storage:** shared_preferences (settings only, no session data)
- **Timer:** Dart Timer class in service wrapper
- **Animation:** AnimationController + CustomPainter

### Dependencies (Minimal)
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  shared_preferences: ^2.0.0
```

### Project Structure
```
lib/
├── main.dart
├── models/
│   ├── session_state.dart
│   └── break_activity.dart
├── services/
│   ├── timer_service.dart
│   └── activity_service.dart
├── screens/
│   ├── start_screen.dart
│   ├── timer_screen.dart
│   ├── completion_screen.dart
│   └── break_screen.dart
├── widgets/
│   └── breathing_circle.dart
├── theme/
│   └── app_theme.dart
└── data/
    └── activities.json
```

### Web-Specific Considerations
- Prevent tab sleep with Page Visibility API
- Timer continues if tab backgrounded (acknowledge imperfection)
- Test extensively on mobile Safari (iOS) and Chrome (Android)
- PWA manifest for "Add to Home Screen" capability
- Keep bundle size small (no heavy dependencies)

### Native Readiness
- Avoid web-only packages
- Structure timer service for background task migration
- Design for touch/mobile from start (even on web)
- Test on actual mobile browsers regularly
- Use Flutter's platform abstraction patterns

## MVP Scope

### IN Scope ✅
- Start screen with single button
- Timer screen with breathing circle + Done button
- Completion screen with time + progress counter
- 60-second break with countdown + activity suggestion
- 50+ break activities (varied and fun)
- Fixed 5 questions per break cycle
- Session state (in-memory, no persistence)
- Basic settings screen with "How to use" page
- Responsive design (phone, tablet, desktop web)

### OUT of Scope ❌
- Onboarding flow (go straight to Start)
- Parent insights/dashboard
- Session history or analytics
- Configurable break frequency
- Multiple animation styles
- Sound effects or haptics
- Multi-user profiles
- Subject categorization
- Data persistence (beyond basic settings)
- Skip/refresh break buttons (suggestions are flexible)
- Distraction detection or restart buttons

## Success Criteria

**Quantitative:**
- Caleb and Asher use it for 3+ homework sessions each
- Kids complete 10+ questions per session on average
- Break system triggers correctly every 5 questions
- Breathing animation maintains 60fps on tested devices

**Qualitative:**
- Kids use it without parental prompting
- Less homework resistance at start of session
- Calmer demeanor during homework time
- Parents report less homework-related conflict
- Kids say "Can I use the homework app?"

**Technical:**
- Timer accuracy within ±2 seconds over 20-minute session
- Animation remains smooth on low-end Android devices
- Works reliably on Safari iOS, Chrome Android
- No crashes or freezes during testing period

## Development Plan

### Phase 1: Foundation (Days 1-2)
1. Initialize Flutter project with web support
2. Set up routing for 4 screens
3. Implement Provider state management
4. Create basic screen scaffolds (no content yet)

### Phase 2: Core Animation (Days 2-3)
1. Build breathing circle CustomPainter
2. Implement 4-7-8 animation pattern
3. Test 60fps performance across browsers
4. Refine gradient and timing curves

### Phase 3: Timer Flow (Days 3-4)
1. Implement TimerService (start, stop, elapsed time)
2. Wire up Start → Timer → Done → Completion → Next
3. Add question counter and progress tracking
4. Test timer accuracy on web

### Phase 4: Break System (Day 4)
1. Create activities.json with 50+ activities
2. Implement ActivityService (random selection + history)
3. Build break countdown UI
4. Wire up 5-question trigger

### Phase 5: Polish (Day 5)
1. Refine spacing, colors, button sizes
2. Test on mobile browsers (Safari iOS, Chrome Android)
3. Add settings screen with "How to use"
4. Optimize bundle size

### Phase 6: Testing (Days 5-7)
1. Deploy to test URL
2. Test with Caleb and Asher
3. Observe usage, gather feedback
4. Iterate on pain points

## Technical Risks & Mitigations

### Risk: Timer Accuracy on Web
**Issue:** Browsers throttle background tabs, affecting timer precision.
**Mitigation:**
- Test extensively on mobile Safari and Chrome
- Accept slight inaccuracy for MVP (this is homework, not rocket science)
- Document issue for native app migration

### Risk: Animation Performance
**Issue:** 60fps may drop on low-end devices.
**Mitigation:**
- Profile on older Android devices via Chrome
- Simplify gradient if needed (solid color fallback)
- Reduce animation complexity before launch

### Risk: Touch Targets on Mobile Web
**Issue:** Buttons may feel unresponsive compared to native apps.
**Mitigation:**
- Large tap targets (60px minimum)
- Instant visual feedback on tap
- Test with actual kids tapping

### Risk: PWA Install Friction
**Issue:** "Add to Home Screen" is not obvious on iOS.
**Mitigation:**
- Accept that some users will just bookmark URL
- Add simple instructions in settings
- Don't optimize for this in MVP

## Open Questions (Deferred)

These questions arose during design but are intentionally deferred post-MVP:

1. **Break duration:** Is 60s right for all ages? Should it vary?
2. **Question variation:** Should very quick (<30s) or very long (>10min) questions be handled differently?
3. **Break cadence:** Will 5 questions feel right for everyone, or do we need configurability?
4. **Activity refresh:** Do kids want a "different activity" button even though suggestions are flexible?
5. **Session summary:** Should there be an explicit end screen showing total questions completed?

**Decision:** Ship MVP, gather data from real usage, then decide.

## Next Steps

1. **Document approved** ✅
2. Initialize Flutter project with web config
3. Create git worktree for implementation
4. Write detailed implementation plan
5. Begin Phase 1 development

---

**Design validated with:** Primary user (parent of Caleb, 10 and Asher, 8)
**Ready for implementation planning:** Yes
