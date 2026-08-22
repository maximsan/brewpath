import 'package:brew_path/features/onboarding/data/onboarding_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late OnboardingRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    repo = OnboardingRepository(SettingsRepository());
  });

  tearDown(() async {
    await db.close();
  });

  test('getState defaults to incomplete on a fresh database', () async {
    final state = await repo.getState();
    expect(state.completed, isFalse);
    expect(state.goal, isNull);
    expect(state.brewer, isNull);
  });

  test(
    'markOnboardingComplete persists goal + brewer + completion gate',
    () async {
      await repo.markOnboardingComplete(goal: 'brew_better', brewer: 'v60');
      final state = await repo.getState();
      expect(state.completed, isTrue);
      expect(state.goal, 'brew_better');
      expect(state.brewer, 'v60');
    },
  );

  test('subsequent reads return the persisted selections', () async {
    await repo.markOnboardingComplete(
      goal: 'understand_tasting',
      brewer: 'aeropress',
    );
    final first = await repo.getState();
    final second = await repo.getState();
    expect(second.completed, first.completed);
    expect(second.goal, first.goal);
    expect(second.brewer, first.brewer);
  });

  test(
    'resetOnboarding clears the gate, the selections and the Tour',
    () async {
      // The third wipe path the fate-sharing rule names. This one clears by
      // field rather than by dropping the row, so it is the path where the two
      // bits *can* drift apart — and the only place a test can see it.
      final settings = SettingsRepository();
      await repo.markOnboardingComplete(goal: 'brew_better', brewer: 'v60');
      final seen = await settings.getSettings()
        ..tourSeen = true;
      await settings.saveSettings(seen);

      await repo.resetOnboarding();

      final state = await repo.getState();
      expect(state.completed, isFalse);
      expect(state.goal, isNull);
      expect(state.brewer, isNull);
      expect((await settings.getSettings()).tourSeen, isFalse);
    },
  );
}
