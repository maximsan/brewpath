import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/practice_shelf.dart';
import '../support/progress_seed.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough to build every section — a `ListView` only builds what fits,
  /// and the lower sections sit well below a phone's viewport.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('the Learn screen shows its four sections in order', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    // Learn is the initial tab — no nav needed.

    // Every section header is smallcaps — `SectionHeader` uppercases, the way
    // the design sets them. A practice group is a collapsible row under the
    // section, named in sentence case, and the course is Path's now — so
    // there is no MODULES header to find here (#394).
    for (final section in const ['CONTINUE LEARNING', 'PRACTICE', 'Games']) {
      expect(find.text(section), findsOneWidget, reason: section);
    }
    for (final gone in const [
      'PRACTICE A FINISHED LESSON',
      'MINI-GAMES',
      'MODULES',
      'LESSONS',
      'GAMES',
    ]) {
      expect(find.text(gone), findsNothing, reason: gone);
    }
  });

  testWidgets('the practice section lists only finished lessons', (
    tester,
  ) async {
    // The design has always said so — the prototype titles this section
    // "Completed work to revisit" and builds it from the completed set. The
    // app used to list all 32, putting a locked module one tap from playable.
    useTallViewport(tester);
    await seedCompletedLesson(SnapshotRepository(), 'm1l1');

    await pumpWithProviders(tester, const BrewPathApp());
    await openPracticeGroup(tester, AppLabels.practiceLessonsGroup);

    expect(find.text('What coffee actually is'), findsWidgets);
    // Deliberately the *third* lesson: the second becomes today's lesson once
    // the first is done, so it would show in the Today card either way.
    expect(
      find.text('What origin means'),
      findsNothing,
      reason: 'unfinished lessons are not practice material',
    );
  });

  testWidgets('a learner who has finished nothing sees no Lessons group', (
    tester,
  ) async {
    // The design lists the group only once there is something finished to
    // revisit; an empty group with a placeholder in it was the app's own.
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());

    expect(find.text('PRACTICE'), findsOneWidget);
    expect(find.text(AppLabels.practiceLessonsGroup), findsNothing);
    expect(find.text('No lessons available yet.'), findsNothing);
    expect(find.text(AppLabels.practiceGamesGroup), findsOneWidget);
  });

  testWidgets('no section offers practice by game type', (tester) async {
    // The cross-lesson drill is gone (#113): a screen the design never had,
    // assembled from whatever the learner happened to finish, recording
    // nothing. The seven authored mini-games cover the same ground.
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());

    expect(find.text('Practice by game type'), findsNothing);
  });
}
