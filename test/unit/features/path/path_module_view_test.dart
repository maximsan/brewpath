import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// Two modules of two lessons each — `m1l1 m1l2 m2l1 m2l2`, in course order.
List<ModuleWithProgress> _course({
  required int doneInFirst,
  required int doneInSecond,
  bool secondLocked = true,
}) => [
  ModuleWithProgress(
    module: testModule(),
    completedCount: doneInFirst,
    totalCount: 2,
    isLocked: false,
  ),
  ModuleWithProgress(
    module: testModule(id: 'm2', n: 2, lessonIds: const ['m2l1', 'm2l2']),
    completedCount: doneInSecond,
    totalCount: 2,
    isLocked: secondLocked,
  ),
];

Map<String, LessonModel> get _lessons => {
  for (final id in ['m1l1', 'm1l2', 'm2l1', 'm2l2'])
    id: testLesson(id: id, title: id),
};

void main() {
  group('buildPathModules', () {
    test('pairs every module with the density it draws at', () {
      final built = buildPathModules(
        modules: _course(doneInFirst: 1, doneInSecond: 0),
        lessonsById: _lessons,
        completedIds: const {'m1l1'},
        masteryById: const {},
      );

      expect(built.map((m) => m.density), [
        PathModuleDensity.active,
        PathModuleDensity.locked,
      ]);
    });

    test('lists each module its own lessons, in course order', () {
      final built = buildPathModules(
        modules: _course(doneInFirst: 0, doneInSecond: 0),
        lessonsById: _lessons,
        completedIds: const {},
        masteryById: const {},
      );

      expect(built[0].lessons.map((l) => l.lesson.id), ['m1l1', 'm1l2']);
      expect(built[1].lessons.map((l) => l.lesson.id), ['m2l1', 'm2l2']);
    });

    test('exactly one lesson in the whole course is current', () {
      final built = buildPathModules(
        modules: _course(doneInFirst: 2, doneInSecond: 0, secondLocked: false),
        lessonsById: _lessons,
        completedIds: const {'m1l1', 'm1l2'},
        masteryById: const {},
      );

      final current = [
        for (final module in built)
          for (final lesson in module.lessons)
            if (lesson.isCurrent) lesson.lesson.id,
      ];

      // Not "first unfinished in each module" — that would light up one per
      // module and tell the learner they are in four places at once.
      expect(current, ['m2l1']);
    });

    test('a finished course has no current lesson', () {
      final built = buildPathModules(
        modules: _course(doneInFirst: 2, doneInSecond: 2, secondLocked: false),
        lessonsById: _lessons,
        completedIds: const {'m1l1', 'm1l2', 'm2l1', 'm2l2'},
        masteryById: const {},
      );

      final anyCurrent = built
          .expand((module) => module.lessons)
          .any((lesson) => lesson.isCurrent);

      expect(anyCurrent, isFalse);
    });

    test('carries each lesson its completion and its stored mastery', () {
      final built = buildPathModules(
        modules: _course(doneInFirst: 1, doneInSecond: 0),
        lessonsById: _lessons,
        completedIds: const {'m1l1'},
        masteryById: const {'m1l1': MasteryResult(correct: 3, total: 4)},
      );

      final first = built[0].lessons[0];
      expect(first.isCompleted, isTrue);
      expect(first.mastery, const MasteryResult(correct: 3, total: 4));

      final second = built[0].lessons[1];
      expect(second.isCompleted, isFalse);
      expect(second.mastery, MasteryResult.unscored);
    });

    test(
      'a lesson the bank has no entry for is dropped, not rendered blank',
      () {
        final built = buildPathModules(
          modules: _course(doneInFirst: 0, doneInSecond: 0),
          lessonsById: {'m1l1': testLesson(title: 'm1l1')},
          completedIds: const {},
          masteryById: const {},
        );

        expect(built[0].lessons.map((l) => l.lesson.id), ['m1l1']);
        expect(built[1].lessons, isEmpty);
      },
    );

    test('the current lesson is found even when the bank is missing one', () {
      // `m1l1` is absent from the bank but still unfinished, so it is still
      // the course's next lesson — the tally must not skip to `m1l2` and mark
      // a later lesson current just because an earlier one failed to load.
      final built = buildPathModules(
        modules: _course(doneInFirst: 0, doneInSecond: 0),
        lessonsById: {'m1l2': testLesson(id: 'm1l2', title: 'm1l2')},
        completedIds: const {},
        masteryById: const {},
      );

      expect(built[0].lessons.single.isCurrent, isFalse);
    });
  });
}
