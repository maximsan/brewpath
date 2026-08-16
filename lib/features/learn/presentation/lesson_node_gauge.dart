/// Pure state → gauge mapping for a lesson node, extracted so every arm is
/// unit-testable without pumping a widget.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter/foundation.dart';

/// Which mood token paints a lesson node.
///
/// A tone rather than a `Color`, so this file stays free of `BuildContext` and
/// the mapping can be tested without a theme.
enum LessonNodeTone {
  /// `inkMute` — finished, but holding no score.
  muted,

  /// `accent` — the current lesson, or one that needs practice.
  accent,

  /// `sage` — "learned".
  sage,
}

/// How a lesson node is drawn: how full the bean is, and in which tone.
@immutable
class LessonNodeGauge {
  /// Creates a [LessonNodeGauge].
  const LessonNodeGauge({required this.fill, required this.tone});

  /// Bean fill, `0..1`.
  final double fill;

  /// The token the bean is painted in.
  final LessonNodeTone tone;

  /// Floor applied to a scored lesson's fill, so a hard-won result never draws
  /// as an empty bean — a learner who scored 0 of 5 still sees *something*.
  static const double scoredFloor = 0.12;

  /// Fill shown for the current lesson before it has ever been played. Not a
  /// score: a deliberate "you are here" nudge.
  static const double unplayedCurrentFill = 0.45;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonNodeGauge && other.fill == fill && other.tone == tone;

  @override
  int get hashCode => Object.hash(fill, tone);

  @override
  String toString() => 'LessonNodeGauge($fill, $tone)';
}

/// Maps a lesson's progression state onto its node gauge.
///
/// Ported from the design's lesson row (`prototype/screens.jsx`): the bean
/// *is* the gauge, so mastery reads as "how full" instead of a word in the
/// margin.
///
/// The one arm worth stating out loud: **complete but unscored stays
/// deliberately neutral** — a muted, empty bean, never a full sage one. Only a
/// lesson with a stored score can claim mastery, so a lesson finished before
/// scores were recorded does not get to borrow one.
LessonNodeGauge lessonNodeGauge({
  required bool isComplete,
  required bool isCurrent,
  MasteryResult mastery = MasteryResult.unscored,
}) {
  final scored = isComplete && mastery.isScored;
  final needsPractice = scored && mastery.band == MasteryBand.needsPractice;

  final fill = switch (null) {
    _ when scored =>
      mastery.ratio < LessonNodeGauge.scoredFloor
          ? LessonNodeGauge.scoredFloor
          : mastery.ratio,
    _ when isCurrent => LessonNodeGauge.unplayedCurrentFill,
    _ => 0.0,
  };

  final tone = switch (null) {
    _ when isComplete && !scored => LessonNodeTone.muted,
    _ when isCurrent || needsPractice => LessonNodeTone.accent,
    _ => LessonNodeTone.sage,
  };

  return LessonNodeGauge(fill: fill, tone: tone);
}
