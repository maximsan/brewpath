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
    expect(
      (await SettingsRepository().getSettings()).onboardingCompleted,
      isFalse,
    );
  });

  test('saveSettings round-trips the onboarding gate', () async {
    // The gate is all the DTO carries now. The goal and brewer columns are
    // still in the table above — ADR-0010 retired the questions, and #407
    // took their two fields off the record rather than keep reading and
    // writing answers nothing asks for.
    final repo = SettingsRepository();
    final s = await repo.getSettings()
      ..onboardingCompleted = true;
    await repo.saveSettings(s);

    expect((await repo.getSettings()).onboardingCompleted, isTrue);
  });

  test('user_settings has the Tour column', () async {
    final cols = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    final names = cols.map((r) => r.read<String>('name')).toSet();
    expect(names, contains('tour_seen'));
  });

  test('default settings row reports the Tour unseen', () async {
    final repo = SettingsRepository();
    final s = await repo.getSettings();
    expect(s.tourSeen, isFalse);
  });

  test('saveSettings round-trips tourSeen', () async {
    final repo = SettingsRepository();
    final s = await repo.getSettings()
      ..tourSeen = true;
    await repo.saveSettings(s);

    expect((await repo.getSettings()).tourSeen, isTrue);
  });
}
