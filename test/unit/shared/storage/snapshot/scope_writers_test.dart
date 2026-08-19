import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/snapshot_generators.dart';

/// Every writer on the progress scope, against a fully-populated scope.
///
/// These writers copy the scope field by field, so the failure mode is a
/// field silently left behind — progress a learner earned, dropped by the
/// write that recorded something else. The compiler catches a *renamed*
/// field (it did, loudly, when two branches renamed and added one in the same
/// release), but it cannot catch a forgotten one, which is what this covers.
void main() {
  final populated = SnapshotGen(11).progress();

  test('withAck changes the acks and nothing else', () {
    final after = populated.withAck('courseComplete', 20300);

    expect(after.acks['courseComplete'], 20300);
    expect(after.withAck('courseComplete', 20300), after);
    expect(
      after.toJson()..remove('acks'),
      populated.toJson()..remove('acks'),
    );
  });

  test('withTreeStageAtLeast changes the stage and nothing else', () {
    final after = populated.withTreeStageAtLeast(treeStageCount);

    expect(after.treeStage, treeStageCount);
    expect(
      after.toJson()..remove('treeStage'),
      populated.toJson()..remove('treeStage'),
    );
  });

  test('withTreeStageAtLeast never lowers a stage already reached', () {
    final grown = populated.withTreeStageAtLeast(treeStageCount);

    expect(grown.withTreeStageAtLeast(1).treeStage, treeStageCount);
  });
}
