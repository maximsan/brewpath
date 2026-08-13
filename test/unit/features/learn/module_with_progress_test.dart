import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _module = ModuleModel(
  id: 'module_roast',
  title: 'Roasting',
  description: 'Desc',
  iconName: 'ic_roast',
  lessonIds: ['l1', 'l2'],
);

ModuleWithProgress _item({
  required int done,
  required bool locked,
  int total = 2,
}) => ModuleWithProgress(
  module: _module,
  completedCount: done,
  totalCount: total,
  isLocked: locked,
);

/// The derived state the progression indicators read. `isComplete` is the
/// interesting one: the design defines it as *finished and reachable*, so a
/// locked module never counts however its lesson tally reads.
void main() {
  group('isComplete', () {
    test('is true once every lesson of an unlocked module is done', () {
      expect(_item(done: 2, locked: false).isComplete, isTrue);
    });

    test('is false while lessons remain', () {
      expect(_item(done: 1, locked: false).isComplete, isFalse);
    });

    test('is false for a locked module, whatever its tally says', () {
      // A content update that adds a lesson to the prerequisite re-locks this
      // module without touching its own progress. The indicators signal
      // completion by going quiet, so a locked module that read as complete
      // would render with no lock, no status line and no chevron at all.
      expect(_item(done: 2, locked: true).isComplete, isFalse);
    });

    test('is false for an empty module rather than vacuously true', () {
      expect(_item(done: 0, locked: false, total: 0).isComplete, isFalse);
    });
  });

  group('progress', () {
    test('is the completed fraction', () {
      expect(_item(done: 1, locked: false).progress, 0.5);
    });

    test('is zero for an empty module rather than dividing by zero', () {
      expect(_item(done: 0, locked: false, total: 0).progress, 0);
    });
  });
}
