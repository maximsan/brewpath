import 'package:brew_path/features/lessons/domain/first_completion_fold.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const day = 20000;
  const mastery = MasteryResult(correct: 4, total: 5);

  late CourseBank course;
  late ModuleModel first;
  late LessonModel opening;
  late LessonModel closing;

  setUpAll(() async {
    final content = ContentRepository();
    course = (
      modules: await content.getModules(),
      cards: await content.getCards(),
    );
    first = course.modules.reduce((a, b) => a.n < b.n ? a : b);
    opening = (await content.getLessonById(first.lessonIds.first))!;
    closing = (await content.getLessonById(first.lessonIds.last))!;
  });

  test('the completion, its card and the tree stage land in one fold', () {
    final fold = foldFirstCompletion(
      ClearedByReset.empty,
      lesson: opening,
      day: day,
      mastery: mastery,
      course: course,
    );

    expect(fold.progress.completedLessons, {opening.id: day});
    expect(fold.progress.bestResults[opening.id], mastery);
    expect(fold.card, isNotNull);
    expect(fold.progress.ownedCollectibles, {fold.card!.id});
    expect(fold.stageBefore, freshTreeStage);
    expect(fold.progress.treeStage, greaterThan(freshTreeStage));
    expect(fold.closedModule, isNull);
    expect(fold.moduleCard, isNull);
  });

  test('a lesson with no card records the completion alone', () {
    final fold = foldFirstCompletion(
      ClearedByReset.empty,
      lesson: opening,
      day: day,
      mastery: mastery,
      course: (modules: course.modules, cards: const []),
    );

    expect(fold.card, isNull);
    expect(fold.progress.ownedCollectibles, isEmpty);
  });

  test('the last lesson of a module closes it and hands its card over', () {
    final others = first.lessonIds.take(first.lessonIds.length - 1);
    final found = ClearedByReset(
      completedLessons: {for (final id in others) id: day},
    );

    final fold = foldFirstCompletion(
      found,
      lesson: closing,
      day: day,
      mastery: mastery,
      course: course,
    );

    expect(fold.closedModule?.id, first.id);
    expect(fold.moduleCard?.moduleId, first.id);
    expect(fold.progress.ownedCollectibles, contains(fold.moduleCard!.id));
  });

  test('a module part-finished hands nothing over', () {
    final fold = foldFirstCompletion(
      ClearedByReset.empty,
      lesson: closing,
      day: day,
      mastery: mastery,
      course: course,
    );

    expect(fold.closedModule, isNull);
    expect(fold.moduleCard, isNull);
  });

  test('a stage already stored is never lowered', () {
    final fold = foldFirstCompletion(
      const ClearedByReset(treeStage: treeStageCount),
      lesson: opening,
      day: day,
      mastery: mastery,
      course: course,
    );

    expect(fold.stageBefore, treeStageCount);
    expect(fold.progress.treeStage, treeStageCount);
  });
}
