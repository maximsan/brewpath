// Self-describing tokens / DTOs / storage infra; no per-member docs.
// ignore_for_file: public_member_api_docs

abstract class XpValues {
  static const int perStep = 10;
  static const int moduleCompletionBonus = 25;

  /// Small XP granted for reviewing a completed lesson, capped to once per
  /// lesson per calendar day.
  static const int practiceXp = 2;

  static int forLesson(int stepCount) => stepCount * perStep;
}
