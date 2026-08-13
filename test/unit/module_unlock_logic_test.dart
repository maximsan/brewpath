import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Module unlock logic lives in `modulesWithProgressProvider`: a module is
/// locked when its `unlockRequirement` module is not fully complete.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
  });

  tearDown(() => db.close());

  /// Reads the unlock state keyed by module id, from a fresh container.
  Future<Map<String, bool>> lockedByModule() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final modules = await container.read(modulesWithProgressProvider.future);
    return {for (final m in modules) m.module.id: m.isLocked};
  }

  test('first module (no unlockRequirement) is always unlocked', () async {
    final locked = await lockedByModule();
    expect(locked['module_beans'], isFalse);
  });

  test('a module is locked while its required module is incomplete', () async {
    final locked = await lockedByModule();
    expect(locked['module_processing'], isTrue);
    expect(locked['module_roast'], isTrue);
  });

  test('partially completing the required module keeps it locked', () async {
    final repo = ProgressRepository();
    // module_beans has 5 lessons — complete only 2.
    await repo.saveCompletion(
      lessonId: 'lesson_where_coffee',
      xpEarned: 10,
      mastery: const MasteryResult(correct: 5, total: 5),
    );
    await repo.saveCompletion(
      lessonId: 'lesson_arabica_robusta',
      xpEarned: 20,
      mastery: const MasteryResult(correct: 5, total: 5),
    );

    final locked = await lockedByModule();
    expect(locked['module_processing'], isTrue);
  });

  test(
    'completing every lesson of the required module unlocks the next',
    () async {
      final repo = ProgressRepository();
      for (final id in const [
        'lesson_where_coffee',
        'lesson_arabica_robusta',
        'lesson_green_coffee',
        'lesson_coffee_plant',
        'lesson_altitude_quality',
      ]) {
        await repo.saveCompletion(
          lessonId: id,
          xpEarned: 10,
          mastery: const MasteryResult(correct: 5, total: 5),
        );
      }

      final locked = await lockedByModule();
      expect(locked['module_beans'], isFalse);
      expect(locked['module_processing'], isFalse);
      // module_roast stays locked — its requirement (processing) isn't done.
      expect(locked['module_roast'], isTrue);
    },
  );
}
