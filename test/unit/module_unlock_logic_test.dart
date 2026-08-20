import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Module unlock lives in `modulesWithProgressProvider`: the first module is
/// always open, and every later one waits on the module before it.
///
/// The rule reads the module's **position**, not a flag in the bank — the
/// bank's `locked` is one imaginary learner's demo state, and honouring it
/// would lock four modules for everyone.
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

  /// The lessons a module holds, asked of the course rather than restated.
  Future<List<String>> lessonsOf(String moduleId) async {
    final modules = await ContentRepository().getModules();
    return modules.firstWhere((m) => m.id == moduleId).lessonIds;
  }

  Future<void> complete(Iterable<String> lessonIds) async {
    final repo = ProgressRepository();
    for (final id in lessonIds) {
      await repo.saveCompletion(
        lessonId: id,
        xpEarned: 10,
        mastery: const MasteryResult(correct: 5, total: 5),
      );
    }
  }

  test('the first module is always unlocked', () async {
    expect((await lockedByModule())['m1'], isFalse);
  });

  test('a module is locked while the one before it is incomplete', () async {
    final locked = await lockedByModule();
    expect(locked['m2'], isTrue);
    expect(locked['m3'], isTrue);
  });

  test('partially completing the module before keeps it locked', () async {
    final beans = await lessonsOf('m1');
    await complete(beans.take(2));

    expect((await lockedByModule())['m2'], isTrue);
  });

  test('completing every lesson of a module unlocks the next', () async {
    await complete(await lessonsOf('m1'));

    final locked = await lockedByModule();
    expect(locked['m1'], isFalse);
    expect(locked['m2'], isFalse);
    // m3 stays locked — m2 is not done.
    expect(locked['m3'], isTrue);
  });
}
