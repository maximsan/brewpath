import 'package:brew_path/features/companion/domain/companion_mood.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';

/// Pure mapping from the high-level companion model (a persistent [mood] plus
/// an optional transient [reaction]) to the low-level [RoastyState] the
/// renderer understands. A present [reaction] always wins; else [mood] decides.
///
/// NOTE: the current Roasty skin has no dedicated "happy" pose, so
/// [CompanionMood.happy] maps to [RoastyState.idle]. Add a distinct pose to the
/// skin and update this mapping when one exists.
RoastyState roastyStateFor({
  required CompanionMood mood,
  CompanionReaction? reaction,
}) {
  if (reaction != null) return _reactionState(reaction);
  return _moodState(mood);
}

RoastyState _reactionState(CompanionReaction reaction) {
  switch (reaction) {
    case CompanionReaction.lessonComplete:
      return RoastyState.lesson;
    case CompanionReaction.moduleComplete:
      return RoastyState.module;
    // The skin has no dedicated course pose; the module celebration is its
    // biggest, so the course moment borrows it. Add a pose and split when one
    // exists (same shape as the happy→idle note above).
    case CompanionReaction.courseComplete:
      return RoastyState.module;
    // A day's practice earns the lesson-sized celebration, one notch below
    // the module pose the course moments use.
    case CompanionReaction.keepSharpComplete:
      return RoastyState.lesson;
    // A brew logged is one day's real-world work — the same size of moment as
    // a lesson, and a notch below the module pose the course moments use.
    case CompanionReaction.challengeComplete:
      return RoastyState.lesson;
    // The streak beat keeps the design's pose for it — Roasty at
    // correct, a personal win rather than a course-sized one (#26).
    case CompanionReaction.streakMilestone:
      return RoastyState.correct;
  }
}

RoastyState _moodState(CompanionMood mood) {
  switch (mood) {
    case CompanionMood.idle:
    case CompanionMood.happy:
      return RoastyState.idle;
  }
}
