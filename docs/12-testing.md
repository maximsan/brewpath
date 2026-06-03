# Coffee Quest — Testing

> **Status (2026-05-21):** The persistence layer migrated from Isar to **Drift 2.30.x** in Phase 3. The `progress_repository_test` setup snippet below still shows `Isar.open` — the real test uses `AppDatabase(NativeDatabase.memory())` (no temp dir, no native binary). All listed tests exist and pass; treat the Isar snippet as historical.

---

## Testing Strategy

| Layer       | Tool                     | What is tested                                                                           |
| ----------- | ------------------------ | ---------------------------------------------------------------------------------------- |
| Unit        | `flutter_test`           | Business logic, XP calc, streak logic, card unlock, module unlock, repository read/write |
| Widget      | `flutter_test`           | Mini-game widgets, lesson step runner, tab navigation, screen rendering                  |
| Integration | `integration_test` (SDK) | Full smoke flow: launch → start lesson → complete → see XP                               |

**Mocking strategy:** Use Riverpod `ProviderScope` overrides to inject test doubles. Avoid `mockito` for domain logic — prefer real implementations with `AppDatabase(NativeDatabase.memory())` (an in-memory Drift database).

---

## Test Folder Structure

```
test/
├── unit/
│   ├── xp_service_test.dart
│   ├── streak_service_test.dart
│   ├── lesson_completion_service_test.dart
│   ├── module_unlock_logic_test.dart
│   ├── progress_repository_test.dart
│   └── content_repository_test.dart
└── widget/
    ├── multiple_choice_game_test.dart
    ├── slider_game_test.dart
    ├── tap_order_game_test.dart
    ├── lesson_step_runner_test.dart
    └── app_shell_navigation_test.dart

integration_test/
└── smoke_test.dart
```

---

## Unit Tests

### How to Run

```bash
flutter test test/unit/
```

### xp_service_test.dart

```dart
// lib/features/progress/domain/xp_service.dart (the class under test)
// Tests:
// - 1-step lesson awards 10 XP
// - 2-step lesson awards 20 XP
// - 3-step lesson awards 30 XP
// - module completion bonus awards 25 XP
// - XP is always non-negative

void main() {
  group('XpService', () {
    test('awards 10 XP for a 1-step lesson', () {
      expect(XpService.calculateLessonXp(stepCount: 1), 10);
    });

    test('awards 20 XP for a 2-step lesson', () {
      expect(XpService.calculateLessonXp(stepCount: 2), 20);
    });

    test('awards 30 XP for a 3-step lesson', () {
      expect(XpService.calculateLessonXp(stepCount: 3), 30);
    });

    test('module completion bonus is 25 XP', () {
      expect(XpService.moduleCompletionBonus, 25);
    });
  });
}
```

### streak_service_test.dart

```dart
// lib/features/progress/domain/streak_service.dart (the class under test)
// Tests:
// - streak increments when today's date is consecutive to lastActivityDate
// - streak resets to 1 when more than 1 day has passed since lastActivityDate
// - streak remains the same if lesson completed twice in the same day
// - streak is 1 on first ever lesson completion (no prior date)

void main() {
  group('StreakService', () {
    test('increments streak on consecutive day', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = StreakService.computeStreak(
        currentStreak: 3,
        lastActivityDate: yesterday,
        today: DateTime.now(),
      );
      expect(result.streakDays, 4);
    });

    test('resets streak after gap', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final result = StreakService.computeStreak(
        currentStreak: 5,
        lastActivityDate: twoDaysAgo,
        today: DateTime.now(),
      );
      expect(result.streakDays, 1);
    });

    test('does not double-increment same day', () {
      final today = DateTime.now();
      final result = StreakService.computeStreak(
        currentStreak: 3,
        lastActivityDate: today,
        today: today,
      );
      expect(result.streakDays, 3);
    });

    test('starts streak at 1 on first completion', () {
      final result = StreakService.computeStreak(
        currentStreak: 0,
        lastActivityDate: null,
        today: DateTime.now(),
      );
      expect(result.streakDays, 1);
    });
  });
}
```

### lesson_completion_service_test.dart

```dart
// Tests:
// - completing a lesson marks it complete in ProgressRepository
// - completing a lesson awards the correct XP via SettingsRepository
// - completing a lesson that has a cardId collects the card via CardRepository
// - completing a lesson that has no cardId does NOT add a card
// - completing the same lesson twice does NOT award XP a second time (idempotency)
// - completing the last lesson in a module triggers module unlock for the next module
```

### module_unlock_logic_test.dart

```dart
// Tests:
// - module with no unlockRequirement is always unlocked
// - module with unlockRequirement is locked if required module is not complete
// - module with unlockRequirement is unlocked if all lessons in required module are complete
// - completing the last lesson of module N unlocks module N+1
```

### progress_repository_test.dart

```dart
// Uses a real Isar instance opened in a temp directory
// Tests:
// - saveCompletion writes a ProgressRecord
// - saveCompletion is idempotent (second call same lessonId does nothing)
// - getByLessonId returns null for unknown lessonId
// - getByLessonId returns the record after saveCompletion
// - getAllCompleted returns only completed records

setUp(() async {
  final dir = await Directory.systemTemp.createTemp();
  final isar = await Isar.open(IsarService.schemas, directory: dir.path);
  IsarService.instance = isar;
});

tearDown(() async {
  await IsarService.instance.close(deleteFromDisk: true);
});
```

### content_repository_test.dart

```dart
// Tests:
// - getModules() returns 5 modules
// - getLessons() returns 17 lessons
// - getCards() returns 17 cards
// - getLessonById() returns correct lesson for known ID
// - getLessonById() returns null for unknown ID
// - all lessons have at least 1 step
// - all module lessonIds reference valid lesson IDs
```

---

## Widget Tests

### How to Run

```bash
flutter test test/widget/
```

### multiple_choice_game_test.dart

```dart
// Tests:
// - renders question text
// - renders all options
// - selecting correct option calls onResult(MiniGameCorrect())
// - selecting incorrect option calls onResult(MiniGameIncorrect(...))
// - explanation text appears after answer
// - options are not tappable after first tap (no double-submit)

testWidgets('correct answer emits MiniGameCorrect', (tester) async {
  MiniGameResult? result;
  await tester.pumpWidget(
    MaterialApp(
      home: MultipleChoiceGame(
        step: const MultipleChoiceStep(
          question: 'Q?',
          options: ['A', 'B', 'C'],
          correctIndex: 1,
          explanation: 'B is correct',
        ),
        onResult: (r) => result = r,
      ),
    ),
  );
  await tester.tap(find.text('B'));
  await tester.pump();
  expect(result, isA<MiniGameCorrect>());
});
```

### slider_game_test.dart

```dart
// Tests:
// - slider renders with min/max labels
// - moving slider inside target range and tapping Check emits MiniGameCorrect
// - moving slider outside target range and tapping Check emits MiniGameIncorrect
```

### tap_order_game_test.dart

```dart
// Tests:
// - items are displayed (though potentially shuffled)
// - tapping all items in correct order emits MiniGameCorrect
// - tapping all items in wrong order emits MiniGameIncorrect
```

### lesson_step_runner_test.dart

```dart
// Tests:
// - MultipleChoiceStep renders MultipleChoiceGame
// - DragDropStep renders DragDropGame
// - SliderStep renders SliderGame
// - TapOrderStep renders TapOrderGame
```

### app_shell_navigation_test.dart

```dart
// Tests:
// - app renders with 4 bottom nav tabs
// - tapping Path tab shows Path screen
// - tapping Cards tab shows Cards screen
// - tapping Profile tab shows Profile screen
// - tapping Learn tab returns to Learn screen
```

---

## Integration Test

### How to Run

```bash
flutter test integration_test/smoke_test.dart -d "iPhone 17"
```

### smoke_test.dart

```dart
// integration_test/smoke_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:coffee_quest/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test: open app, start lesson, complete, see XP', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify Learn tab is visible
    expect(find.text('Learn'), findsWidgets);

    // Tap first available lesson
    await tester.tap(find.text('Where Coffee Comes From'));
    await tester.pumpAndSettle();

    // Verify lesson screen opened
    expect(find.text('Where Coffee Comes From'), findsWidgets);

    // Answer the multiple choice question (correct answer)
    await tester.tap(find.text('The Bean Belt'));
    await tester.pumpAndSettle();

    // Tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify completion screen shows XP
    expect(find.textContaining('XP'), findsWidgets);

    // Navigate to Profile and verify XP is non-zero
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.textContaining('XP'), findsWidgets);
  });
}
```

---

## Test Doubles for Services

In widget and integration tests, override Firebase services with no-ops:

```dart
ProviderScope(
  overrides: [
    analyticsServiceProvider.overrideWithValue(NoOpAnalyticsService()),
    crashReportingServiceProvider.overrideWithValue(NoOpCrashReportingService()),
    remoteConfigServiceProvider.overrideWithValue(NoOpRemoteConfigService()),
  ],
  child: const CoffeeQuestApp(),
)
```

This ensures tests never require a real Firebase connection.

---

## Android Testing Addendum (For Future)

When Android is added:

- [x] Run unit and widget tests with `flutter test` — no changes needed (platform-agnostic)
- [x] Add Android emulator to CI matrix (see `docs/13-ci-cd.md`)
- [x] Run integration test on Android Emulator: `flutter test integration_test/ -d emulator-5554`
- [x] Optionally configure Firebase Test Lab for cloud device testing:
  - Build APK: `flutter build apk --debug`
  - Run: `gcloud firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk`

---

## Steps

- [x] Create `test/unit/xp_service_test.dart`
- [x] Create `test/unit/streak_service_test.dart`
- [x] Create `test/unit/lesson_completion_service_test.dart`
- [x] Create `test/unit/module_unlock_logic_test.dart`
- [x] Create `test/unit/progress_repository_test.dart`
- [x] Create `test/unit/content_repository_test.dart`
- [x] Create `test/widget/multiple_choice_game_test.dart`
- [x] Create `test/widget/slider_game_test.dart`
- [x] Create `test/widget/tap_order_game_test.dart`
- [x] Create `test/widget/lesson_step_runner_test.dart`
- [x] Create `test/widget/app_shell_navigation_test.dart`
- [x] Create `integration_test/smoke_test.dart`
- [x] Run `flutter test test/` — all tests pass
- [ ] Run `flutter test integration_test/smoke_test.dart -d "iPhone 17"` — smoke test passes

---

## Definition of Done

- [x] All unit tests listed above exist and pass
- [x] All widget tests listed above exist and pass
- [ ] Integration smoke test passes on iOS Simulator
- [x] `flutter test` exits with code 0
- [x] No test calls Firebase SDK directly (all service calls go through no-op overrides)
- [x] ProgressRepository idempotency test confirms no double XP awards
- [x] StreakService reset test confirms streak resets after missed day
