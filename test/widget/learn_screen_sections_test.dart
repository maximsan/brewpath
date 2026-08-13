import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('Learn screen shows all four sections in spec order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());
    // Learn is the initial tab — no nav needed.

    expect(find.text("Today's lesson"), findsOneWidget);
    expect(find.text('Practice any lesson'), findsOneWidget);
    expect(find.text('Practice by game type'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
  });

  testWidgets(
    'Practice-by-game-type chips disabled when no lessons completed',
    (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpWithProviders(tester, const BrewPathApp());

      // ActionChip with onPressed: null reports `isEnabled == false`.
      final chips = tester.widgetList<ActionChip>(find.byType(ActionChip));
      expect(chips, isNotEmpty);
      expect(chips.every((c) => !c.isEnabled), isTrue);
    },
  );

  testWidgets(
    'Practice-by-game-type chips enable after a lesson is completed',
    (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Mark the first lesson as completed before mounting the app.
      await ProgressRepository().saveCompletion(
        lessonId: 'lesson_where_coffee',
        xpEarned: 10,
        mastery: const MasteryResult(correct: 5, total: 5),
      );

      await pumpWithProviders(tester, const BrewPathApp());

      final chips = tester.widgetList<ActionChip>(find.byType(ActionChip));
      expect(chips.any((c) => c.isEnabled), isTrue);
    },
  );
}
