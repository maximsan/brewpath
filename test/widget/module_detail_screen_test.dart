import 'package:brew_path/features/learn/presentation/module_detail_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('uncompleted lessons show no Review action', (tester) async {
    await pumpWithProviders(
      tester,
      const MaterialApp(home: ModuleDetailScreen(moduleId: 'm1')),
    );

    // No lesson of m1 is completed, so nothing offers a Review.
    expect(find.text('Review'), findsNothing);
  });

  testWidgets('a completed lesson shows a Review action', (tester) async {
    // Mark one of m1's lessons as completed.
    await tester.runAsync(
      () => ProgressRepository().saveCompletion(
        lessonId: 'm1l1',
        xpEarned: 10,
        mastery: const MasteryResult(correct: 5, total: 5),
      ),
    );

    await pumpWithProviders(
      tester,
      const MaterialApp(home: ModuleDetailScreen(moduleId: 'm1')),
    );

    // Exactly the one completed lesson exposes a Review action.
    expect(find.text('Review'), findsOneWidget);
  });
}
