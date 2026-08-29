import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/learn_screen.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/content_fixtures.dart';

/// First module unlocked, the next four locked — mirrors a fresh user.
final _modules = <ModuleWithProgress>[
  for (var position = 1; position <= 5; position++)
    ModuleWithProgress(
      module: testModule(
        id: 'm$position',
        n: position,
        title: 'Title m$position',
      ),
      completedCount: 0,
      totalCount: 2,
      isLocked: position > 1,
    ),
];

final LessonModel _todayLesson = testLesson(title: 'Where coffee grows');

Future<void> _pumpLearn(WidgetTester tester, {LessonModel? today}) async {
  // Tall surface so the lazy `ListView` builds the whole tab at once.
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        modulesWithProgressProvider.overrideWith((ref) async => _modules),
        todayLessonProvider.overrideWith((ref) async => today),
        keepSharpRecommendationProvider.overrideWith((ref) async => null),
        keepSharpAcknowledgedTodayProvider.overrideWith((ref) async => false),
      ],
      child: const MaterialApp(home: LearnScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the day is here and the course is not', (tester) async {
    await _pumpLearn(tester, today: _todayLesson);

    expect(find.text("Today's lesson"), findsOneWidget);
    // The module list moved to Path (#394). A module glyph is what a module
    // row is drawn with, so its absence is the list's absence — and none of
    // the module titles is reachable from this tab either.
    expect(find.byType(ModuleGlyph), findsNothing);
    for (final module in _modules) {
      expect(find.text(module.module.title), findsNothing);
    }
  });

  testWidgets('the lead card is introduced by its eyebrow', (tester) async {
    await _pumpLearn(tester, today: _todayLesson);

    expect(find.text(AppLabels.continueLearning.toUpperCase()), findsOneWidget);
    expect(find.text(AppLabels.allCaughtUp.toUpperCase()), findsNothing);
  });

  testWidgets('a caught-up learner is told so, not offered a lesson', (
    tester,
  ) async {
    await _pumpLearn(tester);

    expect(find.text(AppLabels.allCaughtUp.toUpperCase()), findsOneWidget);
    expect(find.text(AppLabels.continueLearning.toUpperCase()), findsNothing);
  });

  testWidgets('practice is one section with two groups under it', (
    tester,
  ) async {
    await _pumpLearn(tester, today: _todayLesson);

    expect(find.text(AppLabels.practiceSection.toUpperCase()), findsOneWidget);
    expect(
      find.text(AppLabels.practiceLessonsGroup.toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(AppLabels.practiceGamesGroup.toUpperCase()),
      findsOneWidget,
    );
    // The two headers the design does not have.
    expect(find.text('PRACTICE A FINISHED LESSON'), findsNothing);
    expect(find.text('MINI-GAMES'), findsNothing);
  });
}
