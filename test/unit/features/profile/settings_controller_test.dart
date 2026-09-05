import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The name seam Settings writes through, against the real settings row.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String?> greetedAs() => container.read(learnerNameProvider.future);

  test(
    'a set name is written down and the greeting provider follows',
    () async {
      await container
          .read(settingsControllerProvider.notifier)
          .setLearnerName('  Maya ');

      expect((await SettingsRepository().getSettings()).learnerName, 'Maya');
      expect(await greetedAs(), 'Maya');
    },
  );

  test('a changed name replaces the old one', () async {
    final controller = container.read(settingsControllerProvider.notifier);
    await controller.setLearnerName('Maya');

    await controller.setLearnerName('Mia');

    expect((await SettingsRepository().getSettings()).learnerName, 'Mia');
    expect(await greetedAs(), 'Mia');
  });

  test('blank clears the name rather than keeping an empty one', () async {
    // Empty and skipped are one answer, as they are on the onboarding step:
    // the greeting falls back to its plain form, not to `Hello, .`
    final controller = container.read(settingsControllerProvider.notifier);
    await controller.setLearnerName('Maya');

    await controller.setLearnerName('   ');

    expect((await SettingsRepository().getSettings()).learnerName, isNull);
    expect(await greetedAs(), isNull);
  });

  test('the other preferences are left as they were', () async {
    final before = await SettingsRepository().getSettings();
    before.hapticsEnabled = false;
    await SettingsRepository().saveSettings(before);

    await container
        .read(settingsControllerProvider.notifier)
        .setLearnerName('Maya');

    final after = await SettingsRepository().getSettings();
    expect(after.hapticsEnabled, isFalse);
    expect(after.learnerName, 'Maya');
  });
}
