/// The words the completion moment uses, and the rule that picks them.
///
/// Pure, so the copy a learner actually reads is asserted without pumping a
/// widget — these are four different sentences for four different runs, and
/// nothing else on the screen says which one happened.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';

/// The opening beat's headline for a run in [band].
///
/// A weak run is congratulated, not corrected: the invitation to replay is
/// carried further down, and the beat opens warmly whatever the score was. A
/// run with no stored score falls to the neutral line.
String completionBeatTitle(AppLocalizations strings, MasteryBand? band) =>
    switch (band) {
      MasteryBand.perfect => strings.completionBeatPerfect,
      MasteryBand.mastered => strings.completionBeatMastered,
      MasteryBand.needsPractice => strings.completionBeatNeedsPractice,
      null => strings.completionBeatNeutral,
    };

/// The kicker for a run, on the beat and on the content behind it alike.
///
/// A replay pays nothing and says so; the design has one path here and the
/// app has two.
String completionEyebrow(AppLocalizations strings, {required bool isReplay}) =>
    isReplay
    ? strings.completionEyebrowReview
    : strings.completionEyebrowComplete;
