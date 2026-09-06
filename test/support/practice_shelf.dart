import 'package:brew_path/features/learn/presentation/practice/practice_group.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the practice group named [label] on the Learn tab.
///
/// Both groups arrive closed, as the design has them, so a test that reaches
/// for a row has to open its group first — the way a learner does.
Future<void> openPracticeGroup(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(PracticeGroup),
      matching: find.text(label),
    ),
  );
  await tester.pump();
  await tester.pump(PracticeGroup.turnDuration);
}
