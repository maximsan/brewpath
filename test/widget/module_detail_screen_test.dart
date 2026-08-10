import 'package:brew_path/features/learn/presentation/module_detail_screen.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('uncompleted lessons show no Review action', (tester) async {
    await pumpWithProviders(
      tester,
      const MaterialApp(home: ModuleDetailScreen(moduleId: 'module_beans')),
    );

    // module_beans has 3 lessons, none completed — so no Review actions.
    expect(find.text('Review'), findsNothing);
  });

  testWidgets('a completed lesson shows a Review action', (tester) async {
    // Mark one of module_beans' three lessons as completed.
    await tester.runAsync(
      () => ProgressRepository().saveCompletion(
        lessonId: 'lesson_where_coffee',
        xpEarned: 10,
        score: 100,
      ),
    );

    await pumpWithProviders(
      tester,
      const MaterialApp(home: ModuleDetailScreen(moduleId: 'module_beans')),
    );

    // Exactly the one completed lesson exposes a Review action.
    expect(find.text('Review'), findsOneWidget);
  });
}
