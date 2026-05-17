import 'package:coffee_quest/core/constants/xp_values.dart';

/// Domain entry point for XP math. Thin wrapper over the [XpValues] constants —
/// kept as a class so it can be injected and stubbed in tests.
class XpService {
  const XpService();

  int calculateLessonXp(int stepCount) => XpValues.forLesson(stepCount);

  int get moduleCompletionBonus => XpValues.moduleCompletionBonus;
}
