import 'package:coffee_quest/features/onboarding/presentation/goal/goal_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalController', () {
    test('no selection initially → cannot submit', () {
      final controller = GoalController(onSubmit: (_) {});
      expect(controller.selectedIndex, isNull);
      expect(controller.canSubmit, isFalse);
      controller.dispose();
    });

    test('pick selects an option, notifies, and enables submit', () {
      var notifications = 0;
      final controller = GoalController(onSubmit: (_) {})
        ..addListener(() => notifications++);

      controller.pick(2);

      expect(controller.selectedIndex, 2);
      expect(controller.canSubmit, isTrue);
      expect(notifications, 1);
      controller.dispose();
    });

    test('submit forwards the selected index', () {
      int? submitted;
      final controller = GoalController(onSubmit: (index) => submitted = index)
        ..pick(1);

      controller.submit();

      expect(submitted, 1);
      controller.dispose();
    });

    test('submit is a no-op with no selection', () {
      var submitted = false;
      final controller = GoalController(onSubmit: (_) => submitted = true);

      controller.submit();

      expect(submitted, isFalse);
      controller.dispose();
    });

    test('pick swaps the selection', () {
      final controller = GoalController(onSubmit: (_) {})
        ..pick(0)
        ..pick(2);

      expect(controller.selectedIndex, 2);
      controller.dispose();
    });
  });
}
