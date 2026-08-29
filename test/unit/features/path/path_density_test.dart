import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

ModuleWithProgress _module({
  required int position,
  required int total,
  required int done,
  bool locked = false,
}) => ModuleWithProgress(
  module: testModule(
    id: 'm$position',
    n: position,
    lessonIds: [for (var i = 0; i < total; i++) 'm${position}l$i'],
  ),
  completedCount: done,
  totalCount: total,
  isLocked: locked,
);

void main() {
  group('pathModuleDensity', () {
    test('an unlocked, unfinished module is active', () {
      final density = pathModuleDensity(
        _module(position: 1, total: 4, done: 1),
      );
      expect(density, PathModuleDensity.active);
    });

    test('an untouched but reachable module is still active', () {
      final density = pathModuleDensity(
        _module(position: 1, total: 4, done: 0),
      );
      expect(density, PathModuleDensity.active);
    });

    test('every lesson done makes it complete', () {
      final density = pathModuleDensity(
        _module(position: 1, total: 4, done: 4),
      );
      expect(density, PathModuleDensity.complete);
    });

    test('a locked module is locked however its lessons tally', () {
      for (final done in [0, 2, 4]) {
        final density = pathModuleDensity(
          _module(position: 2, total: 4, done: done, locked: true),
        );
        expect(
          density,
          PathModuleDensity.locked,
          reason: 'locked wins at $done of 4 done',
        );
      }
    });

    test('only complete collapses; the other two are fixed open or shut', () {
      expect(PathModuleDensity.complete.canCollapse, isTrue);
      expect(PathModuleDensity.active.canCollapse, isFalse);
      expect(PathModuleDensity.locked.canCollapse, isFalse);
    });

    test('an active module is open and a locked one lists nothing', () {
      expect(PathModuleDensity.active.showsLessonsWhenCollapsed, isTrue);
      expect(PathModuleDensity.locked.showsLessonsWhenCollapsed, isFalse);
      expect(PathModuleDensity.complete.showsLessonsWhenCollapsed, isFalse);
    });
  });

  group('pathCourseSummary', () {
    test('counts lessons, not modules', () {
      final summary = pathCourseSummary([
        _module(position: 1, total: 6, done: 6),
        _module(position: 2, total: 8, done: 3),
      ]);

      expect(summary.done, 9);
      expect(summary.unlocked, 14);
    });

    test('a locked module contributes neither half of the count', () {
      // The design counts against what the learner can actually reach —
      // `MODULES.filter(m => !m.locked)` — so a locked module is not a
      // denominator the count can never close.
      final summary = pathCourseSummary([
        _module(position: 1, total: 6, done: 6),
        _module(position: 2, total: 8, done: 0, locked: true),
      ]);

      expect(summary.done, 6);
      expect(summary.unlocked, 6);
    });

    test('an empty course reads as zero of zero rather than throwing', () {
      final summary = pathCourseSummary(const []);

      expect(summary.done, 0);
      expect(summary.unlocked, 0);
      expect(summary.label, '0 of 0 lessons complete');
    });

    test('the label is the design line', () {
      final summary = pathCourseSummary([
        _module(position: 1, total: 6, done: 2),
      ]);

      expect(summary.label, '2 of 6 lessons complete');
    });

    test(
      'one remaining lesson is still spelled plurally, as the design does',
      () {
        final summary = pathCourseSummary([
          _module(position: 1, total: 1, done: 0),
        ]);

        expect(summary.label, '0 of 1 lessons complete');
      },
    );
  });
}
