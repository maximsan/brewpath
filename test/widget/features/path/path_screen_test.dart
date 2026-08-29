import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/domain/path_providers.dart';
import 'package:brew_path/features/path/presentation/path_lesson_row.dart';
import 'package:brew_path/features/path/presentation/path_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// A course of three modules, one at each density: module 1 finished, module 2
/// under way, module 3 not yet reached.
List<PathModule> _course() {
  PathModule build({
    required int position,
    required int done,
    required bool locked,
  }) {
    final lessonIds = ['m${position}l1', 'm${position}l2'];
    final item = ModuleWithProgress(
      module: testModule(
        id: 'm$position',
        n: position,
        title: 'Module $position',
        lessonIds: lessonIds,
      ),
      completedCount: done,
      totalCount: lessonIds.length,
      isLocked: locked,
    );

    return PathModule(
      item: item,
      density: pathModuleDensity(item),
      lessons: [
        for (var i = 0; i < lessonIds.length; i++)
          PathLesson(
            lesson: testLesson(
              id: lessonIds[i],
              title: 'Lesson $position.${i + 1}',
            ),
            isCompleted: i < done,
            isCurrent: position == 2 && i == done,
            mastery: MasteryResult.unscored,
          ),
      ],
    );
  }

  return [
    build(position: 1, done: 2, locked: false),
    build(position: 2, done: 1, locked: false),
    build(position: 3, done: 0, locked: true),
  ];
}

Future<void> _pumpPath(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [pathModulesProvider.overrideWith((ref) async => _course())],
      child: const MaterialApp(home: PathScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('every module is on the screen, at its own density', (
    tester,
  ) async {
    await _pumpPath(tester);

    for (final title in ['Module 1', 'Module 2', 'Module 3']) {
      expect(find.text(title), findsOneWidget, reason: '$title is missing');
    }
  });

  testWidgets('the active module lists its lessons without being asked', (
    tester,
  ) async {
    await _pumpPath(tester);

    expect(find.text('Lesson 2.1'), findsOneWidget);
    expect(find.text('Lesson 2.2'), findsOneWidget);
  });

  testWidgets('a finished module starts collapsed and opens on tap', (
    tester,
  ) async {
    await _pumpPath(tester);

    expect(find.text('Lesson 1.1'), findsNothing);

    await tester.tap(find.text('Module 1'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson 1.1'), findsOneWidget);
    expect(find.text('Lesson 1.2'), findsOneWidget);
  });

  testWidgets('and shuts again on a second tap', (tester) async {
    await _pumpPath(tester);

    await tester.tap(find.text('Module 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Module 1'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson 1.1'), findsNothing);
  });

  testWidgets('a locked module lists nothing and does not respond', (
    tester,
  ) async {
    await _pumpPath(tester);

    expect(find.text('Lesson 3.1'), findsNothing);

    await tester.tap(find.text('Module 3'));
    await tester.pumpAndSettle();

    // Still nothing: there is no lesson to open and no sheet to raise.
    expect(find.text('Lesson 3.1'), findsNothing);
  });

  testWidgets('the active module cannot be collapsed away', (tester) async {
    await _pumpPath(tester);

    await tester.tap(find.text('Module 2'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson 2.1'), findsOneWidget);
  });

  testWidgets('the header counts lessons and draws no progress bar', (
    tester,
  ) async {
    await _pumpPath(tester);

    // Two modules reachable, two lessons each; three of those four are done.
    expect(find.text('3 OF 4 LESSONS COMPLETE'), findsOneWidget);
    expect(find.text('Your journey'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('opening a finished module leaves the others as they were', (
    tester,
  ) async {
    await _pumpPath(tester);

    await tester.tap(find.text('Module 1'));
    await tester.pumpAndSettle();

    // The one open module plus the always-open active one — a locked module
    // never contributes rows.
    expect(find.byType(PathLessonRow), findsNWidgets(4));
  });
}
