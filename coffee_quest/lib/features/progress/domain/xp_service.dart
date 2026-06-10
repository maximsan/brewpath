import 'package:coffee_quest/core/constants/xp_values.dart';

/// Domain entry point for XP math. Thin wrapper over the [XpValues] constants —
/// kept as a class so it can be injected and stubbed in tests.
class XpService {
  /// Creates an [XpService].
  const XpService();

  /// XP awarded for completing a lesson with [stepCount] steps.
  int calculateLessonXp(int stepCount) => XpValues.forLesson(stepCount);

  /// Bonus XP awarded for completing a module.
  int get moduleCompletionBonus => XpValues.moduleCompletionBonus;

  /// XP awarded for a single practice run.
  int get practiceXp => XpValues.practiceXp;
}
