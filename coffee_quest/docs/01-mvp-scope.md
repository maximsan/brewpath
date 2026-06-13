# Coffee Quest — MVP Scope

## Tabs and Features

### Learn Tab

**Purpose:** Entry point for daily learning.

**Features:**
- [x] Show today's suggested lesson (first incomplete lesson in current module)
- [x] Show all modules in Beginner Foundations track
- [x] Each module card shows: title, lesson count, completion percentage, locked/unlocked state
- [x] Tap a module to see its lesson list
- [x] Tap a lesson to start it (if unlocked)
- [x] Tap a lesson to resume it (if in progress)
- [x] Completed lessons show a checkmark

**Not in scope for Learn Tab:**
- Search
- Filters
- Multiple learning tracks (only Beginner Foundations in MVP)
- Recommendations based on history

---

### Path Tab

**Purpose:** Visual map of structured progression.

**Features:**
- [x] Show all 5 modules in Beginner Foundations in order
- [x] Each module shows: title, locked/unlocked state, lesson dots (complete / incomplete)
- [x] Locked modules show a lock icon
- [x] Tapping an unlocked module navigates to its lesson list
- [x] Tapping a locked module shows a "Complete previous module to unlock" tooltip

**Not in scope for Path Tab:**
- Branching paths
- Optional modules
- Multiple tracks

---

### Cards Tab

**Purpose:** Collectible knowledge cards.

**Features:**
- [x] Show all cards in a grid layout
- [x] Unlocked cards show: card image (placeholder icon or illustration), card title, card tag
- [x] Locked cards show an outline/silhouette with "???" title
- [x] Tap an unlocked card to open card detail screen
- [x] Card detail shows: title, short description, module it belongs to

**Not in scope for Cards Tab:**
- Card trading or sharing
- Card rarity tiers in MVP (all equal)
- Animated card reveals in MVP (basic show/hide is sufficient)

---

### Profile Tab

**Purpose:** Progress summary and settings.

**Features:**
- [x] Show total XP
- [x] Show current streak (days in a row with at least one completed lesson)
- [x] Show total completed lessons count
- [x] Show total collected cards count
- [x] Settings section: (no account settings in MVP — just app preferences)
  - [x] Toggle: Haptic feedback on/off
  - [x] Toggle: Sound effects on/off (placeholder, no audio in MVP)
- [x] App info section: app version, build number

**Not in scope for Profile Tab:**
- Account or login
- Profile photo or name
- Achievements badges beyond XP/streak
- Social sharing

---

## Learning Content — Beginner Foundations Track

### Module 1: Beans
Lessons (3):
1. Where Coffee Comes From
2. Arabica vs Robusta
3. What Green Coffee Is

### Module 2: Processing
Lessons (3):
1. Washed Processing
2. Natural Processing
3. Honey Processing

### Module 3: Roast
Lessons (4):
1. What Roasting Does
2. Light Roast
3. Medium Roast
4. Dark Roast

### Module 4: Brewing Basics
Lessons (4):
1. Grind Size Matters
2. Water Temperature
3. Brew Ratio
4. Extraction Explained

### Module 5: Taste
Lessons (3):
1. Acidity, Body, Sweetness
2. How to Taste Coffee
3. Common Flavor Descriptors

**Total: 17 lessons across 5 modules.**

Each lesson:
- Has a title
- Has a short explanation paragraph
- Has 1–3 interaction steps (mini-games)
- Awards XP on completion (10–30 XP depending on step count)
- Optionally awards a Coffee Card on completion (not every lesson awards a card)

---

## Mini-Game Types In Scope

### 1. Multiple Choice
- Question text
- 2–4 answer options
- One correct answer
- Immediate feedback (correct/incorrect visual)

### 2. Drag & Drop Matching
- Left column: terms
- Right column: definitions or images
- User drags left items to match right items
- Feedback on all matches complete

### 3. Slider
- A labeled slider with min/max
- User moves slider to a target range or value
- Example: "Set the water temperature to between 90–96°C"
- Feedback when slider is in the correct range

### 4. Tap-Order Sequencing
- A set of items displayed in random order
- User taps them in the correct sequence
- Example: ordering roast levels from light to dark

---

## Coffee Cards In MVP

17 cards total — one per lesson. Each card has:
- Title (same as the lesson)
- A tag (e.g., "Beans", "Roast", "Brewing")
- A short one-sentence description
- An icon or placeholder illustration

Cards are awarded on first completion of their associated lesson.

---

## XP System

| Action | XP |
|---|---|
| Complete a 1-step lesson | 10 XP |
| Complete a 2-step lesson | 20 XP |
| Complete a 3-step lesson | 30 XP |
| Unlock a new module | Bonus 25 XP |

No XP multipliers or streak bonuses in MVP.

---

## Explicit Out-of-Scope List

- User accounts, login, or sign-up
- Cloud sync or backup
- Server-side content (all content is bundled in app assets)
- Push notifications
- Social features
- Real payment flow
- Ads in lessons
- iPad layouts
- Android support
- Web support
- Multiple learning tracks
- Advanced card rarity or card animations
- Audio lessons or voice narration
- Video content
- In-app chat or support

---

## Definition of Done

- [x] All 4 tabs implemented and navigable
- [x] All 17 lessons implemented with correct step types
- [x] All 5 modules unlock sequentially when all lessons in previous module are complete
- [x] All 17 Coffee Cards unlock on first lesson completion
- [x] XP is correctly calculated and persisted
- [x] Streak increments on days with at least one lesson completed and resets after a missed day
- [x] All mini-game types (MultipleChoice, DragDrop, Slider, TapOrder) render and function correctly
- [x] App works fully offline after first launch
- [x] Profile tab shows correct XP, streak, and completion counts
- [ ] App launches and passes smoke test on iOS Simulator
