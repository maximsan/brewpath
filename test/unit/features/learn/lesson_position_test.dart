import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/domain/lesson_position.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

void main() {
  final module = testModule(lessonIds: const ['m1l1', 'm1l2', 'm1l3']);

  group('lessonPositionIn', () {
    test('counts from one, over the module', () {
      expect(lessonPositionIn(module, 'm1l1'), (number: 1, total: 3));
      expect(lessonPositionIn(module, 'm1l3'), (number: 3, total: 3));
    });

    test('is null for a lesson the module does not list', () {
      expect(lessonPositionIn(module, 'm2l1'), isNull);
    });
  });

  group('the meta line', () {
    const position = (number: 2, total: 7);

    test('is the design’s one mono line', () {
      expect(todayMetaLine(position, minutes: 4), 'LESSON 2/7 · ~4 MIN');
    });

    test('is read as a sentence', () {
      expect(
        todayMetaSemantics(position, minutes: 4),
        'Lesson 2 of 7, about 4 minutes',
      );
    });
  });

  group('moduleOwning', () {
    final modules = [
      ModuleWithProgress(
        module: testModule(),
        completedCount: 0,
        totalCount: 2,
        isLocked: false,
      ),
      ModuleWithProgress(
        module: testModule(id: 'm2', n: 2, title: 'Processing'),
        completedCount: 0,
        totalCount: 2,
        isLocked: true,
      ),
    ];

    test('finds the module by id', () {
      expect(moduleOwning(modules, 'm2')?.title, 'Processing');
    });

    test('is null when no module carries the id', () {
      expect(moduleOwning(modules, 'm9'), isNull);
    });
  });
}
