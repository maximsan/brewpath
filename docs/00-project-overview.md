# Coffee Quest — Project Overview

## Product Vision

Coffee Quest teaches coffee fundamentals to beginners through short, structured, interactive lessons — the same way Duolingo teaches languages. The app rewards consistency, not mastery. Users finish a session feeling like they learned something concrete and practical, not overwhelmed.

## Value Proposition

- Structured beginner curriculum (not a blog, not a YouTube rabbit hole)
- 2–3 minute lessons that fit into a morning routine
- Offline-first: no account, no internet required for MVP content
- XP and collectible Coffee Cards as lightweight progress markers
- No professional jargon, no barista-level complexity in v1

## Target Audience

- Coffee beginners who just bought their first V60, AeroPress, or moka pot
- Home-brewing enthusiasts who want to understand what they're doing, not just follow a recipe
- People who spend money at specialty coffee shops and want to understand why
- Users comfortable with app-based learning (Duolingo, Khan Academy, Brilliant)

## Core UX Principles

| Do | Don't |
|---|---|
| Short, focused lessons | Long articles |
| Concrete, practical knowledge | Abstract theory |
| Visible progress (XP, streaks, cards) | Invisible progress |
| Simple, clean UI | Heavy gamification, RPG mechanics |
| Offline-first | Require login or internet |
| One action per screen | Cluttered multi-action flows |

The app should feel structured and educational — closer to a well-designed textbook than a game.

## Platform Strategy

### Version 1 — iOS MVP
- Target: iPhone, iOS 16.0+
- Distribution: App Store + TestFlight
- No iPad-specific layout (let it scale gracefully)

### Future — Android
- Dart/Flutter logic is already portable
- Only platform-specific wiring needed (signing, google-services.json, Play Store)
- See `15-future-android-web-plan.md`

### Future — Web
- go_router supports URL strategy natively
- Isar needs replacement with IndexedDB-compatible persistence for web
- See `15-future-android-web-plan.md`

## Feature Pillars

### Learn Tab
The entry point. Shows today's suggested lesson and all available modules. Users start or resume lessons here.

### Path Tab
Structured learning progression. Modules unlock sequentially. Shows which lessons are complete, in progress, or locked.

### Cards Tab
Collectible Coffee Cards earned by completing lessons. Each card represents a coffee concept. Locked cards show an outline until earned.

### Profile Tab
XP total, current streak, completed lesson count, app settings, and debug/version info.

## MVP Boundaries

The following are explicitly **out of scope for v1**:

- User accounts or authentication
- Cloud sync or backend
- Social features (sharing, leaderboards)
- Real payment processing
- Ads in lessons
- Push notifications
- iPad-specific layouts
- Android build
- Web build
- Onboarding flow beyond first-launch state
- Subscription management

## Definition of Done

- [ ] Product vision is understood and agreed by the developer
- [ ] Platform strategy (iOS-first, Android/web later) is documented
- [ ] MVP boundaries are explicit — no scope creep from this list
- [ ] All four tabs (Learn, Path, Cards, Profile) are scoped
- [ ] UX tone ("structured educational, not RPG") is clear to anyone reading this doc
