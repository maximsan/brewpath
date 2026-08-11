import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke-tests the on-create + on-upgrade story for the v3 onboarding
/// columns on `user_settings`. The full historical migration chain has its
/// own coverage in `test/database/schema_smoke_test.dart`; this file
/// focuses on the new columns' defaults and round-trip behavior.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
  });

  tearDown(() async {
    await db.close();
  });

  test('user_settings has the three onboarding columns', () async {
    final cols = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    final names = cols.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll(<String>[
        'onboarding_completed',
        'onboarding_goal',
        'onboarding_brewer',
      ]),
    );
  });

  test('default settings row reports onboarding incomplete', () async {
    final repo = SettingsRepository();
    final s = await repo.getSettings();
    expect(s.onboardingCompleted, isFalse);
    expect(s.onboardingGoal, isNull);
    expect(s.onboardingBrewer, isNull);
  });

  test('saveSettings round-trips the onboarding fields', () async {
    final repo = SettingsRepository();
    final s = await repo.getSettings()
      ..onboardingCompleted = true
      ..onboardingGoal = 'brew_better'
      ..onboardingBrewer = 'v60';
    await repo.saveSettings(s);

    final reloaded = await repo.getSettings();
    expect(reloaded.onboardingCompleted, isTrue);
    expect(reloaded.onboardingGoal, 'brew_better');
    expect(reloaded.onboardingBrewer, 'v60');
  });
}
