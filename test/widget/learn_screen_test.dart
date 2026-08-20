import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/learn_screen.dart';
import 'package:brew_path/features/learn/presentation/module_card_widget.dart';
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

final _todayLesson = testLesson(title: 'Where coffee grows');

Future<void> _pumpLearn(WidgetTester tester) async {
  // Tall surface so the lazy `ListView` builds all 5 module cards at once —
  // the hero card and the practice sections above them leave no room in the
  // default 600px height.
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        modulesWithProgressProvider.overrideWith((ref) async => _modules),
        todayLessonProvider.overrideWith((ref) async => _todayLesson),
        keepSharpRecommendationProvider.overrideWith((ref) async => null),
        keepSharpAcknowledgedTodayProvider.overrideWith(
          (ref) async => false,
        ),
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
    expect(find.text(AppLabels.lockedModuleMessage), findsOneWidget);
  });
}
