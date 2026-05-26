import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/features/onboarding/data/onboarding_repository.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';

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
}
