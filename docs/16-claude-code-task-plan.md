# Coffee Quest — Claude Code Task Plan

## How to Use This File

Hand this file to Claude Code with the instruction:

> "Execute the Coffee Quest task plan in `docs/16-claude-code-task-plan.md` phase by phase. Complete each phase fully before starting the next. Verify each phase's Definition of Done before proceeding."

Each phase is independently verifiable. Do not skip phases or reorder them — later phases depend on earlier ones.

---

## Phase 0: Prerequisites Check

Before starting, verify:

- [ ] Flutter SDK is installed: `flutter --version` → should show stable channel 3.22+
- [ ] Xcode 16+ is installed: `xcodebuild -version`
- [ ] CocoaPods is installed: `pod --version`
- [ ] Git is initialized in the project directory
- [ ] GitHub repository exists (for CI setup in Phase 11)

> Firebase is Phase 8 only. No Firebase project or `GoogleService-Info.plist` needed for Phases 1–7.

---

## Phase 1: Project Creation and Scaffold

**Reference:** `docs/03-project-scaffold.md`, `docs/04-folder-structure.md`, `docs/05-dependencies.md`

- [x] Run `flutter create --org dev.maximsan --project-name coffee_quest --platforms ios coffee_quest`
- [x] Set iOS minimum deployment target to 16.0 in `ios/Podfile` and Xcode
- [x] Set Bundle ID to `dev.maximsan.coffeequest` in Xcode
- [x] Replace `pubspec.yaml` with full version from `docs/05-dependencies.md`
- [x] Run `flutter pub get`
- [x] Create all directories from `docs/04-folder-structure.md` using the mkdir commands in `docs/03-project-scaffold.md`
- [x] Create `assets/content/.gitkeep`, `assets/images/.gitkeep`, `assets/icons/.gitkeep`
- [x] Create `lib/main.dart`
- [x] Create `lib/app/app_bootstrap.dart` (Isar only; Firebase deferred to Phase 8)
- [x] Create `lib/app/app.dart`
- [x] Create `lib/app/app_theme.dart`
- [x] Create `lib/app/app_router.dart` (stub routes)
- [x] Create `analysis_options.yaml`
- [x] Run `dart run build_runner build --delete-conflicting-outputs`
- [x] Run `cd ios && pod install && cd ..`
- [ ] Run `flutter run -d "iPhone 16 Pro"` → verify app launches with stub screens

**Phase 1 Done when:** App launches on iOS Simulator, no crash, stub screens visible, bundle ID is `dev.maximsan.coffeequest`.

---

## Phase 2: Content Data and Models

**Reference:** `docs/07-content-model.md`

- [x] Create `lib/shared/models/module_model.dart` (Freezed + fromJson)
- [x] Create `lib/shared/models/lesson_model.dart` (Freezed + fromJson)
- [x] Create `lib/shared/models/lesson_step_model.dart` (sealed Freezed union — 4 variants)
- [x] Create `lib/shared/models/coffee_card_model.dart` (Freezed + fromJson)
- [x] Create `assets/content/modules.json` with all 5 modules
- [x] Create `assets/content/lessons.json` with all 17 lessons:
  - Each lesson has: id, moduleId, title, summary, xpReward, cardId, and at least 1 step
  - All 4 mini-game step types present across the 17 lessons
- [x] Create `assets/content/cards.json` with all 17 card definitions
- [x] Create `lib/shared/repositories/content_repository.dart`
- [x] Add `@riverpod ContentRepository contentRepository(ContentRepositoryRef ref)` (inline in repository file)
- [x] Run `dart run build_runner build --delete-conflicting-outputs`
- [x] Write `test/unit/content_repository_test.dart`:
  - 5 modules loaded ✓
  - 17 lessons loaded ✓
  - 17 cards loaded ✓
  - all lessons have ≥ 1 step ✓
  - getLessonById works ✓
  - all 4 step types present ✓
- [x] Run `flutter test test/unit/content_repository_test.dart` → 6/6 passed

**Phase 2 Done when:** All content loads from JSON, unit tests pass. ✅

---

## Phase 3: Local Persistence (Isar)

**Reference:** `docs/06-local-persistence.md`

- [ ] Create `lib/shared/storage/progress_record.dart` (`@collection`)
- [ ] Create `lib/shared/storage/card_record.dart` (`@collection`)
- [ ] Create `lib/shared/storage/settings_record.dart` (`@collection`, singleton ID 0)
- [ ] Create `lib/shared/storage/isar_service.dart`
- [ ] Create `lib/shared/repositories/progress_repository.dart`
- [ ] Create `lib/shared/repositories/card_repository.dart`
- [ ] Create `lib/shared/repositories/settings_repository.dart`
- [ ] Create `lib/shared/repositories/repository_providers.dart` with Riverpod providers
- [ ] Update `lib/app/app_bootstrap.dart` to open Isar with `IsarService.schemas`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Write `test/unit/progress_repository_test.dart` (idempotency, read/write)
- [ ] Run `flutter test test/unit/progress_repository_test.dart` → passes
- [ ] Run app on Simulator, enable Airplane Mode, verify app still launches

**Phase 3 Done when:** Isar opens at startup, persistence tests pass, app works offline.

---

## Phase 4: Domain Logic (Riverpod Providers + Services)

**Reference:** `docs/02-architecture.md`, `docs/01-mvp-scope.md`

- [ ] Create `lib/core/constants/xp_values.dart` (XP per step count, module bonus)
- [ ] Create `lib/core/utils/xp_utils.dart` → `XpService.calculateLessonXp(stepCount)`
- [ ] Create `lib/core/utils/date_utils.dart` → streak date helpers
- [ ] Create `lib/features/progress/domain/xp_service.dart`
- [ ] Create `lib/features/progress/domain/streak_service.dart`
- [ ] Create `lib/features/lessons/domain/lesson_completion_service.dart`:
  - Calls `ProgressRepository.saveCompletion`
  - Calls `SettingsRepository.addXp`
  - Calls `CardRepository.collectCard` if `lesson.cardId != null`
  - Checks if all lessons in the module are complete → awards module bonus XP
  - Fires analytics events via `AnalyticsService` (injected)
- [ ] Create `lib/features/progress/domain/progress_providers.dart`:
  - `totalXpProvider` → reads from `SettingsRepository`
  - `streakProvider` → reads from `SettingsRepository`
  - `completedLessonsProvider` → reads from `ProgressRepository`
  - `collectedCardsProvider` → reads from `CardRepository`
- [ ] Create `lib/features/learn/domain/learn_providers.dart`:
  - `modulesWithProgressProvider` → combines `contentRepository` + `progressRepository`
  - `todayLessonProvider` → first incomplete lesson in current module
- [ ] Write `test/unit/xp_service_test.dart`
- [ ] Write `test/unit/streak_service_test.dart`
- [ ] Write `test/unit/lesson_completion_service_test.dart`
- [ ] Run `flutter test test/unit/` → all pass

**Phase 4 Done when:** All domain services exist, unit tests pass, providers compile.

---

## Phase 5: Navigation and App Shell

**Reference:** `docs/02-architecture.md` (navigation section), `docs/03-project-scaffold.md`

- [ ] Replace stub `lib/app/app_router.dart` with full `StatefulShellRoute` implementation:
  ```dart
  // Shell route with 4 tabs: /learn, /path, /cards, /profile
  // Each tab uses StatefulShellBranch to preserve scroll position
  // Sub-routes: /learn/module/:moduleId, /learn/lesson/:lessonId, /cards/:cardId
  ```
- [ ] Create `lib/core/constants/route_names.dart` with all route path constants
- [ ] Create the `AppShell` widget with `BottomNavigationBar` (4 tabs: Learn, Path, Cards, Profile)
- [ ] Add `NavigatorObserver` to go_router for `AnalyticsService.logScreen` (call no-op in MVP until Firebase is wired)
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Write `test/widget/app_shell_navigation_test.dart`
- [ ] Run `flutter test test/widget/app_shell_navigation_test.dart` → passes
- [ ] Run app on Simulator → 4 tabs navigate correctly, tab state preserved on switch

**Phase 5 Done when:** All 4 tabs navigate correctly, tab state is preserved, navigation test passes.

---

## Phase 6: Feature Screens

**Reference:** `docs/01-mvp-scope.md`

### Learn Tab
- [ ] Create `lib/features/learn/presentation/learn_screen.dart`:
  - Today's lesson card at top
  - Module list below (use `modulesWithProgressProvider`)
  - Each module card: title, lesson count, progress bar, locked/unlocked state
- [ ] Create `lib/features/learn/presentation/module_card_widget.dart`
- [ ] Create `lib/features/learn/presentation/module_detail_screen.dart`:
  - List of lessons with completion checkmarks
  - Tap unlocked lesson → navigate to `/learn/lesson/:lessonId`

### Path Tab
- [ ] Create `lib/features/path/presentation/path_screen.dart`:
  - Vertical list of 5 module nodes
  - Each node: title, lesson dots, locked/unlocked icon
  - Locked module tapped → show snackbar "Complete previous module to unlock"
- [ ] Create `lib/features/path/presentation/path_module_node_widget.dart`

### Cards Tab
- [ ] Create `lib/features/cards/presentation/cards_screen.dart`:
  - GridView of all 17 cards
  - Unlocked: show title + tag + icon
  - Locked: show silhouette + "???"
- [ ] Create `lib/features/cards/presentation/card_grid_item_widget.dart`
- [ ] Create `lib/features/cards/presentation/card_detail_screen.dart`:
  - Card title, description, module tag

### Profile Tab
- [ ] Create `lib/features/profile/presentation/profile_screen.dart`:
  - XP display (from `totalXpProvider`)
  - Streak display (from `streakProvider`)
  - Completed lessons count
  - Collected cards count
  - Settings section: Haptics toggle, Sound toggle (both stored in `SettingsRepository`)
  - App info: version from `packageInfo_plus` or hardcoded string

- [ ] Run app on Simulator, navigate all 4 tabs, verify data displays correctly
- [ ] Verify locked modules show lock icon on both Learn and Path tabs

**Phase 6 Done when:** All 4 tab screens render with real data from providers. Navigate to all screens without crashes.

---

## Phase 7: Lesson Runner and Mini-Games

**Reference:** `docs/08-mini-games.md`

- [ ] Create `lib/features/mini_games/domain/mini_game_result.dart` (sealed class)
- [ ] Create `lib/features/mini_games/presentation/lesson_step_runner.dart`
- [ ] Create `lib/features/mini_games/presentation/multiple_choice_game.dart` (full UI)
- [ ] Create `lib/features/mini_games/presentation/drag_drop_game.dart` (full UI)
- [ ] Create `lib/features/mini_games/presentation/slider_game.dart` (full UI)
- [ ] Create `lib/features/mini_games/presentation/tap_order_game.dart` (full UI)
- [ ] Create `lib/features/lessons/presentation/lesson_screen.dart`:
  - Full-screen lesson flow
  - Shows lesson title + summary paragraph
  - Shows step progress indicator (e.g., "Step 1 of 2")
  - Renders `LessonStepRunner` for current step
  - On `MiniGameCorrect`: advance to next step or go to completion screen
  - On `MiniGameIncorrect`: show feedback, allow retry
- [ ] Create `lib/features/lessons/presentation/lesson_completion_screen.dart`:
  - Shows XP earned
  - Shows Coffee Card (if awarded)
  - "Continue" button → pops back to Learn tab
  - Calls `LessonCompletionService` on first display (once, not on every build)
- [ ] Wire lesson navigation: `learn_screen.dart` → lesson tapped → push `/learn/lesson/:lessonId`
- [ ] Write `test/widget/multiple_choice_game_test.dart`
- [ ] Write `test/widget/slider_game_test.dart`
- [ ] Write `test/widget/tap_order_game_test.dart`
- [ ] Write `test/widget/lesson_step_runner_test.dart`
- [ ] Run `flutter test test/widget/` → all pass
- [ ] Run on Simulator: complete a full lesson end-to-end, verify XP appears on Profile tab

**Phase 7 Done when:** A full lesson can be started, completed, and XP is persisted and visible on Profile.

---

## Phase 8: Firebase Services

**Reference:** `docs/09-firebase.md`

- [ ] Complete Firebase iOS setup (GoogleService-Info.plist, firebase_options.dart)
- [ ] Create `lib/services/analytics/analytics_service.dart`
- [ ] Create `lib/services/analytics/firebase_analytics_service.dart`
- [ ] Create `lib/services/analytics/noop_analytics_service.dart`
- [ ] Create `lib/services/analytics/analytics_provider.dart`
- [ ] Create `lib/services/crash_reporting/crash_reporting_service.dart`
- [ ] Create `lib/services/crash_reporting/firebase_crashlytics_service.dart`
- [ ] Create `lib/services/crash_reporting/crash_reporting_provider.dart`
- [ ] Create `lib/services/remote_config/remote_config_service.dart`
- [ ] Create `lib/services/remote_config/remote_config_keys.dart`
- [ ] Create `lib/services/remote_config/firebase_remote_config_service.dart`
- [ ] Create `lib/services/remote_config/remote_config_provider.dart`
- [ ] Update `lib/app/app_bootstrap.dart` to call `Firebase.initializeApp()` and `remoteConfigService.fetchAndActivate()`
- [ ] Add Flutter/platform error handlers in `lib/main.dart`
- [ ] Wire analytics events in `LessonCompletionService` (`lesson_started`, `lesson_completed`, `card_unlocked`, `xp_earned`)
- [ ] Wire screen tracking in router observer
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Override services with `NoOpAnalyticsService` in all widget tests
- [ ] Run all tests → pass
- [ ] Verify Firebase Analytics DebugView shows events on Simulator

**Phase 8 Done when:** Firebase initializes without error, analytics events visible in DebugView, all tests pass with no-op service overrides.

---

## Phase 9: Service Stubs (Ads and Payments)

**Reference:** `docs/10-payments.md`, `docs/11-ads.md`

- [ ] Create `lib/services/payments/payments_service.dart`
- [ ] Create `lib/services/payments/store_product.dart`
- [ ] Create `lib/services/payments/noop_payments_service.dart`
- [ ] Create `lib/services/payments/in_app_purchase_service.dart`
- [ ] Create `lib/services/payments/payments_provider.dart` (active: NoOpPaymentsService)
- [ ] Create `lib/services/ads/ads_service.dart`
- [ ] Create `lib/services/ads/noop_ads_service.dart`
- [ ] Create `lib/services/ads/admob_ads_service.dart`
- [ ] Create `lib/services/ads/ads_provider.dart` (active: NoOpAdsService)
- [ ] Create `lib/core/constants/ad_unit_ids.dart`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Run `flutter analyze` → no warnings
- [ ] Confirm no ads or purchase UI appears anywhere in the app

**Phase 9 Done when:** Both service stubs compile, providers resolve to no-ops, no purchase or ad UI visible.

---

## Phase 10: Tests

**Reference:** `docs/12-testing.md`

- [ ] Verify all unit tests from Phase 4 exist and pass
- [ ] Verify all widget tests from Phase 7 exist and pass
- [ ] Write any missing tests from `docs/12-testing.md` that weren't written in earlier phases
- [ ] Create `integration_test/smoke_test.dart` (content from `docs/12-testing.md`)
- [ ] Run `flutter test` → all unit and widget tests pass (exit code 0)
- [ ] Run `flutter test integration_test/smoke_test.dart -d "iPhone 16 Pro"` → smoke test passes
- [ ] Verify coverage with `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`

**Phase 10 Done when:** `flutter test` exits 0, integration smoke test passes on Simulator.

---

## Phase 11: CI Workflow

**Reference:** `docs/13-ci-cd.md`

- [ ] Create `.github/workflows/ci.yml` (full YAML from `docs/13-ci-cd.md`)
- [ ] Add `GOOGLE_SERVICE_INFO_PLIST` secret in GitHub Repository Settings
- [ ] Push branch to GitHub → verify all 4 CI jobs run
- [ ] Verify `format` job passes
- [ ] Verify `analyze` job passes
- [ ] Verify `test` job passes
- [ ] Verify `ios-build` job produces `Runner.app` on macOS runner
- [ ] Enable branch protection on `main` requiring all 4 jobs to pass

**Phase 11 Done when:** All CI jobs green on GitHub Actions, branch protection enabled.

---

## Final Verification

Run this full verification sequence before declaring the MVP scaffold complete:

```bash
# 1. Format
dart format --output=none --set-exit-if-changed .

# 2. Analyze
flutter analyze --fatal-infos

# 3. All tests
flutter test

# 4. Build release (no code signing)
flutter build ios --release --no-codesign

# 5. Run integration test
flutter test integration_test/smoke_test.dart -d "iPhone 16 Pro"
```

- [ ] All 5 commands exit with code 0
- [ ] No warnings or errors in any command output
- [ ] App navigates all 4 tabs on Simulator
- [ ] Full lesson completion flow works end-to-end
- [ ] XP is persisted and visible after lesson completion
- [ ] Coffee Card is unlocked after first lesson completion
- [ ] Module 2 is locked until Module 1 is complete
- [ ] Streak increments correctly
- [ ] App works in Airplane Mode

---

## Definition of Done — Full MVP Scaffold

- [ ] All 11 phases completed
- [ ] `flutter test` exits 0
- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] `flutter build ios --release --no-codesign` exits 0
- [ ] Integration smoke test passes on iOS Simulator
- [ ] GitHub Actions CI is green
- [ ] All 17 lessons are playable
- [ ] All 17 Coffee Cards can be unlocked
- [ ] All 4 mini-game types are functional
- [ ] XP, streak, and card progress persists across app restarts
- [ ] Firebase Analytics receives events (visible in DebugView)
- [ ] Firebase Crashlytics is initialized (confirm in Firebase Console)
- [ ] No ads or purchase UI visible anywhere
- [ ] App is ready for TestFlight distribution (see `docs/14-ios-release-checklist.md`)
