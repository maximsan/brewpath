import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repo;

  setUp(() => repo = ContentRepository());

  test('loads 5 modules', () async {
    final modules = await repo.getModules();
    expect(modules.length, 5);
  });

  test('loads 17 lessons', () async {
    final lessons = await repo.getLessons();
    expect(lessons.length, 17);
  });

  test('loads 17 cards', () async {
    final cards = await repo.getCards();
    expect(cards.length, 17);
  });

  test('all lessons have at least one step', () async {
    final lessons = await repo.getLessons();
    for (final lesson in lessons) {
      expect(lesson.steps, isNotEmpty, reason: '${lesson.id} has no steps');
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
