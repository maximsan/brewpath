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
    expect((await repo.getState()).completed, isFalse);
  });

  test('markOnboardingComplete closes the gate and keeps the name', () async {
    await repo.markOnboardingComplete(name: 'Maya');

    expect((await repo.getState()).completed, isTrue);
    expect((await SettingsRepository().getSettings()).learnerName, 'Maya');
  });

  test('skipping leaves a name the learner already had', () async {
    // Reachable: Settings' *Restart onboarding* replays the flow and does not
    // touch `learnerName`, so a learner who set a name and then replays the
    // intro would have it erased by declining to type it again.
    final settings = SettingsRepository();
    final stored = await settings.getSettings()
      ..learnerName = 'Maya';
    await settings.saveSettings(stored);

    await repo.markOnboardingComplete();

    expect((await settings.getSettings()).learnerName, 'Maya');
  });

  test('a name given at the step replaces the stored one', () async {
    final settings = SettingsRepository();
    final stored = await settings.getSettings()
      ..learnerName = 'Maya';
    await settings.saveSettings(stored);

    await repo.markOnboardingComplete(name: 'Sam');

    expect((await settings.getSettings()).learnerName, 'Sam');
  });

  test('finishing without a name closes the gate all the same', () async {
    // The one question v1 asks is optional (ADR-0010).
    await repo.markOnboardingComplete();

    expect((await repo.getState()).completed, isTrue);
    expect((await SettingsRepository().getSettings()).learnerName, isNull);
  });

  test('resetOnboarding clears the gate and the Tour', () async {
    // The third wipe path the fate-sharing rule names. This one clears by
    // field rather than by dropping the row, so it is the path where the two
    // bits *can* drift apart — and the only place a test can see it.
    final settings = SettingsRepository();
    await repo.markOnboardingComplete(name: 'Maya');
    final seen = await settings.getSettings()
      ..tourSeen = true;
    await settings.saveSettings(seen);

    await repo.resetOnboarding();

    expect((await repo.getState()).completed, isFalse);
    expect((await settings.getSettings()).tourSeen, isFalse);
  });
}
