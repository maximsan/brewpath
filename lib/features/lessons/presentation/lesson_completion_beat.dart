/// The words the completion moment uses, and the rule that picks them.
///
/// Pure, so the copy a learner actually reads is asserted without pumping a
/// widget — these are four different sentences for four different runs, and
/// nothing else on the screen says which one happened.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';

/// The kicker over a first completion.
const String completeEyebrow = 'Lesson complete';

/// The kicker over a replay.
///
/// The design has one path here and the app has two: a replay pays nothing and
/// says so. Everything else about the two screens is the same.
const String reviewEyebrow = 'Review complete';

/// The opening beat's headline for a run in [band].
///
/// **A weak run is congratulated, not corrected.** `Good start.` is what the
/// design says to the run that needs practice — the invitation to replay is
/// carried by the chip and the link further down, and the beat's job is to
/// open warmly whatever the score was.
///
/// A run with no stored score falls to the neutral line, which is also what a
/// lesson finished before scores were recorded reads as.
String completionBeatTitle(MasteryBand? band) => switch (band) {
  MasteryBand.perfect => 'Perfect run!',
  MasteryBand.mastered => 'Mastered it.',
  MasteryBand.needsPractice => 'Good start.',
  null => 'Nice work.',
};

/// The kicker for a run, on the beat and on the content behind it alike.
String completionEyebrow({required bool isReplay}) =>
    isReplay ? reviewEyebrow : completeEyebrow;
