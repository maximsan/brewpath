/// What the lesson-completion footer offers, decided away from the widget.
library;

import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter/foundation.dart';

/// The design's CTA when another lesson is queued behind this one.
const String nextLessonLabel = 'Next lesson';

/// The design's CTA when nothing is queued — and the quiet link beside
/// [nextLessonLabel] when something is.
const String backToPathLabel = 'Back to Path';

/// The invitation a weak run gets, in the action colour rather than a
/// failure red.
const String practiceAgainLabel = 'Practice this lesson again';

/// The quiet link under the action, or null when the footer offers none.
@immutable
class CompletionLink {
  /// Creates a [CompletionLink].
  const CompletionLink({required this.label, required this.destination});

  /// What the link reads.
  final String label;

  /// Where it goes.
  final RouteDestination destination;
}

/// One primary action and at most one quiet link — the shape the shared
/// sticky action bar takes, resolved before any widget is built.
@immutable
class CompletionActions {
  /// Creates a [CompletionActions].
  const CompletionActions({
    required this.label,
    required this.destination,
    this.link,
  });

  /// What the primary action reads.
  final String label;

  /// Where the primary action goes.
  final RouteDestination destination;

  /// The quiet link under it, if this run earns one.
  final CompletionLink? link;
}

/// What the footer offers after finishing [lessonId].
///
/// Pure, so every branch is asserted without pumping a widget — which matters
/// because the branches are copy the learner reads, not styling.
///
/// **Three rules, in this order.**
///
/// **Two rules, and no module case.** A run that closes its module never
/// reaches this screen — the design branches to the module ending instead of
/// chaining through here (#458) — so there is no third branch and no label to
/// invent for a moment the design gives the lesson ending no word for.
///
/// 1. The action is the next lesson when one is playable, and
///    [backToPathLabel] when the course has nothing left queued.
/// 2. The quiet link is the weak run's practice invitation where there is one,
///    and [backToPathLabel] otherwise — never both. The design pairs the
///    invitation with the mastery chip and drops the plain return beside it
///    (`rewards.jsx:154-175`), so a weak run is asked to practise rather than
///    offered two ways out.
CompletionActions completionActions({
  required String lessonId,
  MasteryBand? band,
  String? nextLessonId,
}) {
  final practice = (band?.invitesPractice ?? false)
      ? CompletionLink(
          label: practiceAgainLabel,
          destination: lessonRun(lessonId),
        )
      : null;

  if (nextLessonId == null) {
    return CompletionActions(
      label: backToPathLabel,
      destination: pathTab,
      link: practice,
    );
  }

  return CompletionActions(
    label: nextLessonLabel,
    destination: lessonRun(nextLessonId),
    link:
        practice ??
        CompletionLink(label: backToPathLabel, destination: pathTab),
  );
}
