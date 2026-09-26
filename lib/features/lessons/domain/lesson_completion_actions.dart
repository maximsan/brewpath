/// What the lesson-completion footer offers, decided away from the widget.
library;

import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';

/// A labelled way off the screen that is not the primary action.
@immutable
class CompletionLink {
  /// Creates a [CompletionLink].
  const CompletionLink({required this.label, required this.destination});

  /// What it reads.
  final String label;

  /// Where it goes.
  final RouteDestination destination;
}

/// One primary action, and at most the practice invitation under it — the
/// shape the shared sticky action bar takes, resolved before any widget is
/// built.
@immutable
class CompletionActions {
  /// Creates a [CompletionActions].
  const CompletionActions({
    required this.label,
    required this.destination,
    this.practice,
  });

  /// What the primary action reads.
  final String label;

  /// Where the primary action goes.
  final RouteDestination destination;

  /// The bordered invitation under it, on a run that earned one.
  final CompletionLink? practice;
}

/// What the footer offers after finishing [lessonId].
///
/// The next lesson when one is playable, Back to Path when nothing is queued,
/// and a weak run invited to practise under it. No module case: a run that
/// closes its module goes to the module ending instead (#458). No second way
/// out either — the screen's own close already goes there.
CompletionActions completionActions({
  required AppLocalizations strings,
  required String lessonId,
  MasteryBand? band,
  String? nextLessonId,
}) {
  final practice = (band?.invitesPractice ?? false)
      ? CompletionLink(
          label: strings.completionPracticeAgain,
          destination: lessonRun(lessonId),
        )
      : null;

  if (nextLessonId == null) {
    return CompletionActions(
      label: strings.completionBackToPath,
      destination: pathTab,
      practice: practice,
    );
  }

  return CompletionActions(
    label: strings.completionNextLesson,
    destination: lessonRun(nextLessonId),
    practice: practice,
  );
}
