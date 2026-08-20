// Self-describing tokens / DTOs / storage infra; no per-member docs.
// ignore_for_file: public_member_api_docs

abstract class XpValues {
  static const int perStep = 10;
  static const int moduleCompletionBonus = 25;

  /// Small XP granted for reviewing a completed lesson, capped to once per
  /// lesson per calendar day.
  static const int practiceXp = 2;

  /// Granted the first time a Coffee Challenge is logged. Replays pay nothing:
  /// points measure what a learner has covered, not how often they repeat it.
  static const int challengeCompletion = 5;

  static int forLesson(int stepCount) => stepCount * perStep;
}
