# Chunk - The ADHD Homework Helper

> One question at a time. No pressure. Just progress.

## 🎯 Vision

Chunk helps ADHD kids stay engaged with homework by breaking tasks into manageable chunks, removing time pressure anxiety, and incorporating regular movement breaks. 

**The Core Insight: One Question at a Time**

Many ADHD kids freeze when they see a whole worksheet - 20 math problems feels impossible. But ONE problem? That's doable. Chunk makes this mental shift tangible: cover up the rest, focus on just this one question, complete it, celebrate, then move to the next.

It's not about speed—it's about sustainable focus and building positive homework habits through radical task chunking.

## ✨ Core Concept

Traditional pomodoro timers create pressure ("beat the clock!"). Focus Flow does the opposite:
- **One question at a time** - Never look at the whole worksheet, just this one problem
- **Obfuscated timing** - Kids see a calming visual pulse instead of ticking numbers
- **Question-by-question tracking** - Each problem is its own mini-victory
- **Movement breaks every 5 questions** - Silly activities that reset attention
- **Count-up only** - Pure discovery mode, no time pressure or failure states

**Why This Works:**
Looking at 20 problems = overwhelming and paralyzing
Looking at 1 problem = manageable and achievable

## 🎮 User Flow

### First-Time Onboarding (30 seconds max)

1. **Welcome Screen**
   - "Hey! Let's make homework less stressful"
   - Big friendly illustration
   - "Next" button

2. **How It Works (3 slides, swipeable)**
   - Slide 1: "Cover your worksheet, show just ONE question" (illustration of paper covering worksheet)
   - Slide 2: "Do that question, then take a silly break" (show break activity)
   - Slide 3: "No rushing, no pressure, just one at a time" (show completion screen)
   - "Got it!" button

3. **Ready to Start**
   - "Ready for your first question?"
   - Big "Start" button
   - → Goes directly to timer screen

**Skip option**: "Skip intro" button on welcome screen for returning users or parents setting up multiple devices

## 📖 How to Use With Homework

### The One-Question-at-a-Time Method

**For Worksheets:**
1. Cover the entire worksheet with a blank piece of paper
2. Slide the paper down to reveal ONLY the first question
3. Tap "Start" on the app
4. Work on just that one question
5. Tap "Done" when finished
6. Slide the paper to reveal the next question
7. Repeat

**For Digital Homework:**
1. Zoom in so only one question fills the screen
2. Or cover parts of the screen with sticky notes/paper
3. Follow the same start/done rhythm

**For Reading/Writing:**
1. One paragraph at a time
2. One practice problem at a time
3. One sentence to diagram at a time

**Why Physical Covering Helps:**
- Reduces visual overwhelm
- Creates a clear "this is all I have to do right now" boundary
- Makes the abstract concept of "one at a time" tangible
- Gives a sense of control and progress

### Normal Session Flow

1. **Setup Phase**
   - Kid taps "Start" to begin
   - (Optional: "What subject?" for future analytics)

2. **Focus Phase**
   - Screen shows calming pulse/breathing animation
   - Timer runs invisibly in background
   - No numbers, no pressure
   - Kid works on their homework question

3. **Completion**
   - Kid taps "Done" when question is finished
   - App reveals actual time taken
   - Brief encouraging message
   - Progress indicator (X/5 questions until break)

4. **Break Time** (every 5 questions)
   - Random silly activity appears
   - 30-60 second movement break
   - Resets focus and energy
   - Back to setup for next set

## 🧠 Design Principles

### ADHD-Friendly UX
- **Radical task chunking** - One question at a time, never show the whole scope
- **Minimal friction** - As few taps as possible to start
- **No overwhelming choices** - Simple binary decisions
- **Visual over text** - Heavy use of animation and color
- **Immediate feedback** - Quick rewards and acknowledgment
- **Novelty** - Randomized breaks prevent boredom
- **Autonomy** - Kid controls when to start/stop
- **Progress without pressure** - Show what's done, not what's left

### Anxiety Reduction
- **No visible countdown** - Removes "running out of time" stress
- **No judgment on time** - All times are neutral, no "too slow" messaging
- **Flexible pacing** - Kid sets their own rhythm
- **Positive reinforcement** - Celebrate completion, not speed

## 🗣️ Voice & Tone

### Personality
- **Friendly** - Like a supportive friend, not a teacher
- **Helpful** - Clear instructions, no confusion
- **Playful** - Fun without being annoying
- **Calm** - Never shouty, never urgent
- **Encouraging** - Celebrates effort, not perfection

### Writing Guidelines

**DO:**
- Keep it short and simple
- Use "you" to speak directly to the kid
- Be specific: "Take a deep breath" not "Relax"
- Celebrate milestones without pressure: "Nice work!" not "Great job! Keep it up!"
- Make break activities silly and fun: "Pretend you're a penguin!"
- Reinforce the one-at-a-time approach: "Just this one" "One down"

**DON'T:**
- Use teacher voice: "Excellent work, you're doing great!"
- Create urgency: "Hurry up!" or "Almost done!"
- Add pressure: "You're on a 5-day streak!"
- Be patronizing: "Wow, such a good job!"
- Use corporate speak: "Optimize your homework experience"
- Reference the total amount left: "Only 15 more to go!"

**Example Messages:**

✅ Good:
- "That took 3m 24s"
- "Ready for the next one?"
- "Break time! Do 10 jumping jacks"
- "Nice! 2 down, 3 to go until break"
- "Just this one question"
- "One at a time"

❌ Bad:
- "Awesome job! You're crushing it! 🎉"
- "You completed that in record time!"
- "Keep up the great work, champion!"
- "Don't give up now!"
- "You only have 12 more problems left!"
- "You're almost done with the whole worksheet!"

## 📱 Technical Considerations

### Platform
- **Cross-platform** via Flutter
- Targets: iOS, iPadOS, Android, Android tablets
- Development: Windows (VS Code/Cursor with Flutter extension)
- Deploy: iOS via cloud build services (Codemagic, App Center)

### Why Flutter for This App
- **Animation performance** - 60fps breathing circle is critical
- **Timer precision** - Rock solid background timer handling
- **Single codebase** - True write-once, deploy everywhere
- **Hot reload** - Instant iteration on animations and UX
- **Native feel** - Platform-specific UI conventions
- **Claude Code friendly** - Excellent VS Code/Cursor integration

### Key Technical Challenges

1. **Timer Accuracy & Background Handling**
   - Precise timing even when app is backgrounded
   - Handle app switching/interruptions gracefully
   - WorkManager (Android) / Background Tasks (iOS)
   - Precision vs. battery life trade-offs

2. **Animation Performance**
   - Smooth 60fps breathing circle animation
   - Low battery impact during long sessions
   - Scalable across device sizes (phone to tablet)
   - CustomPainter for breathing circle
   - AnimationController with Curves

3. **Data Persistence**
   - Session history (optional analytics for parents)
   - Break activity history (avoid repeats within session)
   - User preferences (break frequency, profiles)
   - Local-first: Hive or SharedPreferences

4. **Accessibility**
   - Screen reader support (Semantics widgets)
   - Color blind friendly palette
   - Adjustable animation intensity
   - Reduced motion support

## 🎨 Design System

**Note**: Full design system (colors, typography, spacing) will be provided separately.

### Visual Principles
- **Calming colors** - Soft blues, purples, greens (no harsh reds/oranges)
- **High contrast** - Accessibility-first, readable for all
- **Generous spacing** - Reduce visual overwhelm
- **Big tap targets** - Easy for kids to hit buttons
- **Minimal text** - Icons and illustrations over words when possible

### Key UI Components

### Timer Display

**MVP: Breathing Circle**
- Expands/contracts following 4-7-8 breathing pattern
- 4 seconds expand (inhale)
- 7 seconds hold
- 8 seconds contract (exhale)
- Soft, calming colors (blues/purples)

**Future Animation Options (v1.1+)**
- Wave Pattern - Flowing, meditative movement
- Particle Field - Gentle drifting dots
- Color Gradient - Slow morphing colors

### Break Activity Screen
- Full screen, impossible to miss
- Large, playful typography
- Animated instructions (optional demo GIF/video for complex activities)
- 🔄 **Refresh button** - "Different one" (no limit on refreshes)
- Skip button for activities that truly aren't feasible (limited to 2 per session)

## 🔒 Privacy & Data

**Principle: Collect Nothing**

Focus Flow is designed to work entirely without data collection:
- **No accounts** - No sign-up, no login, no email
- **No cloud storage** - Everything stays on device
- **No analytics** - No tracking, no usage data sent anywhere
- **No ads** - Free app, no monetization that requires data

### What We Store (Local Only)
- **Current session state** - In-memory only, cleared when session ends
- **Break activity history** - Last 10 activities shown (to avoid repeats), stored in local storage
- **Optional: Session history** - If parent enables insights, stored locally in device storage only
- **User preferences** - Break frequency, profile names (local storage)

### COPPA Compliance
- No data collection means automatic COPPA compliance
- No parental consent flow needed
- No privacy policy needed (though we'll include a simple "we collect nothing" statement)
- App Store privacy label: "No Data Collected"

### Parent Insights (Optional)
If parent enables the insights view:
- Data never leaves device
- No cloud sync, no backup
- Clear "Delete all data" button in settings
- Insights can be disabled at any time

## 🚀 Feature Roadmap

### MVP (v1.0)
- [ ] First-time onboarding (3 slides + welcome)
- [ ] Count Up timer
- [ ] Breathing circle animation (4-7-8 pattern)
- [ ] 50+ break activities
- [ ] Activity refresh button (unlimited)
- [ ] Activity skip button (2 per session max)
- [ ] Basic session tracking (in-memory only)
- [ ] Simple completion celebration
- [ ] Progress indicator (X/5 until break)
- [ ] Friendly, helpful copy throughout

### v1.1
- [ ] Multiple animation styles (wave, particles, gradient)
- [ ] 100+ break activities
- [ ] Sound effects toggle
- [ ] Distraction detection (auto-pause after inactivity)
- [ ] "I got distracted" button to restart question
- [ ] Activity history (avoid repeats within session)

### v2.0
- [ ] Parent insights dashboard (optional, local-only)
- [ ] Multiple kid profiles
- [ ] Subject categorization
- [ ] Customizable break frequency (every 3-7 questions)
- [ ] Activity favorites/blocking
- [ ] Configurable breathing pattern
- [ ] Apple Watch companion

### Future Ideas
- **Visual reminder to cover worksheet** - Optional splash screen showing "Cover everything except one question"
- Partner activities (for when sibling/parent is nearby)
- Seasonal/themed break activities
- "Focus music" integration (ambient sounds)
- Homework resistance tracker (how many times did they start before completing?)
- Integration with school assignment apps
- **Desktop version** (Windows/Mac) - Flutter makes this trivial
- **Web version** - For Chromebooks in schools
- **Digital worksheet helper** - Automatically show one question at a time for PDFs/images

## 🚀 Deployment Strategy

### iOS/iPadOS
- Build via cloud service (Codemagic or App Center)
- No Mac required for development
- TestFlight for beta testing
- App Store distribution

### Android
- Direct build from Windows
- Google Play Console for distribution
- Easy sideloading for testing

### Future Platforms
- **Web**: Same Flutter codebase compiles to web
- **Desktop**: Windows/Mac/Linux via Flutter Desktop

## 🎭 Break Activity Categories

Activities should be:
- **Quick** (20-60 seconds)
- **Silly** (fun, not serious)
- **Physical** (get the body moving)
- **Low-prep** (no props needed, or common household items)
- **Varied** (physical, vocal, creative, partner)

See `BREAK_ACTIVITIES.md` for full list

## 🤔 Open Questions

1. **Break Timing & Cadence**
   - Is 5 questions the right default for all ages?
   - Should we make it configurable per kid? (3 for Asher, 7 for Caleb?)
   - Should really quick questions (under 30 sec) count differently?
   - Or is adaptive based on total time better? (break every 15-20 minutes)

2. **Completion Reveal**
   - Just show time? "That took 3m 24s"
   - Add context? "Most questions today took 2-5 minutes"
   - Celebrate milestones? "This is your 10th question!"
   - Make reveal optional for anxious kids? (just show "Done!" instead)

3. **Motivation Without Pressure**
   - What encouragement messages feel supportive vs pressuring?
   - Should we show session totals? ("You've done 12 questions today!")
   - Visual progress (dots/circles) vs numerical?
   - How do we celebrate without creating streaks/obligations?

4. **Skip Limits**
   - Is 2 skips per session the right limit?
   - Does skip count reset after each break?
   - What happens when they're out of skips? (show message, keep showing same activity, allow refresh only?)

5. **Session Management**
   - How does a kid indicate they're truly done with homework?
   - "End session" button vs just close app?
   - Should we save incomplete sessions?
   - Session summary screen? ("You completed 17 questions in 42 minutes")

## ⚠️ Edge Cases & Error Handling

### To Be Determined
The following edge cases need consideration during development:

**Timer Issues:**
- What if the app crashes mid-question?
- What if device runs out of battery?
- What if kid force-quits the app?
→ *Likely approach: Don't try to recover, just start fresh. No guilt, no pressure.*

**Break Activity Issues:**
- What if all activities have been shown?
- What if kid skips repeatedly?
- What if break activity is impossible (e.g., "jump" when in wheelchair)?
→ *Likely approach: Refresh resets the pool, accessibility disclaimer in onboarding*

**Unusual Patterns:**
- What if a question takes 30 minutes? (kid walked away)
- What if a question takes 5 seconds? (accidental tap)
→ *Likely approach: Show the time neutrally, no judgment*

**Device Permissions:**
- What if notifications are disabled? (for v1.1 distraction detection)
- What if storage is full?
→ *Likely approach: App works without notifications, minimal storage needs*

### Principles for Error Handling
- **Never make the kid feel bad** - No error messages that create anxiety
- **Always offer a path forward** - "Try again" or "Start over"
- **Keep it simple** - Kids don't need technical explanations
- **Fail gracefully** - If something breaks, just reset to a clean state

## 💡 App Name

**Chosen: Chunk - The ADHD Homework Helper**

The name reflects the core strategy of breaking homework into manageable chunks, one question at a time.

Alternative names considered:
- OneStep, Nibble, Hop, Pop, Breathe, Ease, Steady
- Question Quest, Homework Hero, Task Pulse, Focus Bounce

## 🛠 Development Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **IDE**: VS Code / Cursor with Flutter extension
- **State Management**: Provider or Riverpod (TBD)
- **Storage**: Hive (lightweight, fast) or SharedPreferences
- **Animation**: CustomPainter + AnimationController
- **Background Tasks**: WorkManager (Android) / BackgroundTasks (iOS)
- **Analytics**: Local-only (privacy-first requirement)

### Key Flutter Packages
- `flutter_local_notifications` - Break reminders if app backgrounded
- `shared_preferences` or `hive` - Local data persistence
- `audioplayers` - Optional sound effects (v1.1+)
- `workmanager` - Background timer management
- Custom packages as needed (keeping dependencies minimal)

### Development Environment Setup
1. Install Flutter SDK on Windows
2. VS Code with Flutter + Dart extensions
3. Android Studio (for Android emulator)
4. iOS builds via cloud service (Codemagic recommended)
5. Claude Code for assisted development

### Coming from JavaScript?
Dart will feel familiar:
- Similar syntax to JavaScript/TypeScript
- Strong typing (like TypeScript)
- Async/await works the same way
- Classes, functions, arrow functions all similar
- Main differences: no `null` by default (sound null safety), different package manager (pub)

**Learning curve**: ~2-3 days to be productive with Claude Code's help

## 📝 Contributing Ideas

This is an early-stage concept. Key areas for input:
- Break activity ideas (we need TONS)
- Animation concepts for timer display
- ADHD-specific UX improvements
- Accessibility considerations
- Kid testing feedback

## 🧪 Testing & Validation

### Target Testers
- **Primary**: Caleb (10) and Asher (8)
- **Secondary**: Friends, family with ADHD kids
- **Later**: Beta testers via TestFlight/Play Store

### What to Test
- **Does the one-question-at-a-time method reduce overwhelm?** - Do kids stay calmer?
- **Does the breathing circle actually help?** - Do kids naturally sync with it?
- **Physical covering strategy** - Do kids actually cover their worksheets? Does it help?
- **Break cadence** - Is 5 questions too many? Too few?
- **Activity variety** - Which activities do kids love/hate/skip?
- **Completion messaging** - What feels encouraging vs pressuring?
- **Overall engagement** - Do kids actually use it for homework?

### Success Signals
- Kid uses it without being told
- Homework gets done with less resistance
- Kid seems calmer during homework time, less overwhelmed looking at worksheets
- Parent reports less homework-related conflict
- Kid asks to use the app ("Can I use the homework app?")
- Kid naturally starts covering worksheets even without the app

### Failure Signals
- Kid opens it once and never again
- Kid finds ways to game the system
- Breaks become more distracting than helpful
- App creates new anxiety (obsessing over time, etc.)

---

**Built with ❤️ for kids who think differently**