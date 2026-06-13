import 'package:coffee_quest/shared/models/lesson_step_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repo;

  setUp(() => repo = ContentRepository());

  test('loads 5 modules', () async {
    final modules = await repo.getModules();
    expect(modules.length, 5);
  });

  test('every module has at least 5 lessons', () async {
    final modules = await repo.getModules();
    for (final module in modules) {
      expect(
        module.lessonIds.length,
        greaterThanOrEqualTo(5),
        reason:
            '${module.id} has only ${module.lessonIds.length} lessons '
            '(need ≥5)',
      );
    }
  });

  test('every lesson referenced by a module exists', () async {
    final modules = await repo.getModules();
    final lessons = await repo.getLessons();
    final ids = lessons.map((l) => l.id).toSet();
    for (final module in modules) {
      for (final lessonId in module.lessonIds) {
        expect(
          ids.contains(lessonId),
          isTrue,
          reason: 'Module ${module.id} references missing lesson $lessonId',
        );
      }
    }
  });

  test('no duplicate lesson IDs', () async {
    final lessons = await repo.getLessons();
    final ids = lessons.map((l) => l.id).toList();
    expect(ids.length, ids.toSet().length, reason: 'duplicate lesson IDs');
  });

  test('every lesson has at least 5 steps', () async {
    final lessons = await repo.getLessons();
    for (final lesson in lessons) {
      expect(
        lesson.steps.length,
        greaterThanOrEqualTo(5),
        reason: '${lesson.id} has only ${lesson.steps.length} steps (need ≥5)',
      );
    }
  });

  test('every lesson uses at least 2 distinct game types', () async {
    final lessons = await repo.getLessons();
    for (final lesson in lessons) {
      final types = lesson.steps.map((s) => s.runtimeType).toSet();
      expect(
        types.length,
        greaterThanOrEqualTo(2),
        reason:
            '${lesson.id} uses only one game type ($types) — need ≥2 distinct',
      );
    }
  });

  test('getLessonById returns correct lesson', () async {
    final lesson = await repo.getLessonById('lesson_where_coffee');
    expect(lesson, isNotNull);
    expect(lesson!.moduleId, 'module_beans');
  });

  test('all 4 step types are present across lessons', () async {
    final lessons = await repo.getLessons();
    final allSteps = lessons.expand((l) => l.steps).toList();

    expect(allSteps.whereType<MultipleChoiceStep>(), isNotEmpty);
    expect(allSteps.whereType<DragDropStep>(), isNotEmpty);
    expect(allSteps.whereType<SliderStep>(), isNotEmpty);
    expect(allSteps.whereType<TapOrderStep>(), isNotEmpty);
  });
}
