import 'package:brew_path/features/progress/domain/xp_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const xp = XpService();

  group('XpService', () {
    test('calculateLessonXp is 10 per step', () {
      expect(xp.calculateLessonXp(0), 0);
      expect(xp.calculateLessonXp(1), 10);
      expect(xp.calculateLessonXp(2), 20);
    });

    test('moduleCompletionBonus is 25', () {
      expect(xp.moduleCompletionBonus, 25);
    });
  });
}
