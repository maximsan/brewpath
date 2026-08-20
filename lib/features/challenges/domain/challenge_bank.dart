/// Lookups over the Coffee Challenge bank, and the one string it splits.
library;

import 'package:brew_path/shared/models/content/brew_challenge.dart';

/// The separator the design uses inside an effort string.
const String _effortSeparator = '·';

/// The challenge with [id], or null.
BrewChallenge? challengeById(List<BrewChallenge> bank, String id) =>
    bank.where((challenge) => challenge.id == id).firstOrNull;

/// The challenge [lessonId] carries, or null.
///
/// **Twenty of the thirty-two lessons carry none**, and that is the designed
/// common case rather than a gap: one lesson was given no challenge because it
/// would ask for a machine the learner does not own.
BrewChallenge? challengeForLesson(List<BrewChallenge> bank, String lessonId) =>
    bank
        .where(
          (challenge) =>
              challenge.scope == ChallengeScope.lesson &&
              challenge.lessonId == lessonId,
        )
        .firstOrNull;

/// The capstone challenge for [moduleId], or null.
BrewChallenge? challengeForModule(List<BrewChallenge> bank, String moduleId) =>
    bank
        .where(
          (challenge) =>
              challenge.scope == ChallengeScope.module &&
              challenge.moduleId == moduleId,
        )
        .firstOrNull;

/// The challenge stamped onto [cardId], or null.
BrewChallenge? challengeForCard(List<BrewChallenge> bank, String cardId) =>
    bank.where((challenge) => challenge.cardId == cardId).firstOrNull;

/// The two halves of an effort string, for surfaces that stack them.
typedef ChallengeEffort = ({String? trigger, String? duration});

/// Splits `'Next brews · 5 min'` into when and how long.
///
/// A view helper, not a model field: the model mirrors the bank, and splitting
/// on the way in would bake a presentation decision into content and produce a
/// wrong field the day a record authors only one half. A record with no
/// separator yields its whole text as the trigger and a null duration, rather
/// than guessing which half it meant.
ChallengeEffort effortParts(String effort) {
  final separator = effort.indexOf(_effortSeparator);
  if (separator < 0) {
    final whole = effort.trim();
    return (trigger: whole.isEmpty ? null : whole, duration: null);
  }

  final trigger = effort.substring(0, separator).trim();
  final duration = effort.substring(separator + 1).trim();
  return (
    trigger: trigger.isEmpty ? null : trigger,
    duration: duration.isEmpty ? null : duration,
  );
}
