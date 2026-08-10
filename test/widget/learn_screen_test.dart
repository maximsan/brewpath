import 'package:brew_path/core/constants/app_strings.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/learn_screen.dart';
import 'package:brew_path/features/learn/presentation/module_card_widget.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ModuleModel _module(String id, {String? unlock}) => ModuleModel(
  id: id,
  title: 'Title $id',
  description: 'Desc $id',
  iconName: 'ic_beans',
  lessonIds: const ['l1', 'l2'],
  unlockRequirement: unlock,
);

/// First module unlocked, the next four locked — mirrors a fresh user.
final _modules = <ModuleWithProgress>[
  ModuleWithProgress(
    module: _module('module_beans'),
    completedCount: 0,
    totalCount: 2,
    isLocked: false,
  ),
  for (final id in const [
    'module_processing',
    'module_roast',
    'module_brewing',
    'module_taste',
  ])
    ModuleWithProgress(
      module: _module(id, unlock: 'prev'),
      completedCount: 0,
      totalCount: 2,
      isLocked: true,
    ),
];

const _todayLesson = LessonModel(
  id: 'lesson_where_coffee',
  moduleId: 'module_beans',
  title: 'Where coffee grows',
  summary: 'Intro',
  xpReward: 10,
  cardId: 'card_where_coffee',
  steps: [
    LessonStepModel.multipleChoice(
      question: 'Q',
      options: ['a', 'b'],
      correctIndex: 0,
      explanation: 'E',
    ),
  ],
);

Future<void> _pumpLearn(WidgetTester tester) async {
  // Tall surface so the lazy `ListView` builds all 5 module cards at once —
  // the hero card no longer leaves room for them in the default 600px height.
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        modulesWithProgressProvider.overrideWith((ref) async => _modules),
        todayLessonProvider.overrideWith((ref) async => _todayLesson),
      ],
      child: const MaterialApp(home: LearnScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders today card and all 5 module cards', (tester) async {
    await _pumpLearn(tester);

    expect(find.text("Today's lesson"), findsOneWidget);
    expect(find.byType(ModuleCardWidget), findsNWidgets(5));
  });

  testWidgets('locked modules show a lock icon', (tester) async {
    await _pumpLearn(tester);

    expect(find.byIcon(Icons.lock_outline), findsNWidgets(4));
  });

  testWidgets('tapping a locked module surfaces the unlock hint', (
    tester,
  ) async {
    await _pumpLearn(tester);

    await tester.tap(find.byIcon(Icons.lock_outline).first);
    await tester.pump(); // let the SnackBar appear
    expect(find.text(AppStrings.lockedModuleMessage), findsOneWidget);
  });
}
