import 'package:brew_path/features/lessons/presentation/lesson_completion_beat.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the beat opens on what the run did', () {
    test('a clean run', () {
      expect(completionBeatTitle(MasteryBand.perfect), 'Perfect run!');
    });

    test('one mistake', () {
      expect(completionBeatTitle(MasteryBand.mastered), 'Mastered it.');
    });

    // Congratulated, not corrected: the invitation to replay is carried by the
    // chip and the link further down.
    test('a weak run is still opened warmly', () {
      expect(completionBeatTitle(MasteryBand.needsPractice), 'Good start.');
    });

    test('a run with no stored score falls to the neutral line', () {
      expect(completionBeatTitle(null), 'Nice work.');
    });

    test('every band has a line of its own', () {
      final lines = {
        for (final band in MasteryBand.values) completionBeatTitle(band),
      };
      expect(lines, hasLength(MasteryBand.values.length));
      expect(lines, isNot(contains(completionBeatTitle(null))));
    });
  });

  group('the kicker', () {
    test('a first completion', () {
      expect(completionEyebrow(isReplay: false), completeEyebrow);
    });

    // The app keeps the two apart where the design has one path: a replay pays
    // nothing, and the kicker is the only thing that says so once the rail has
    // no rows to draw.
    test('a replay', () {
      expect(completionEyebrow(isReplay: true), reviewEyebrow);
    });
  });
}
