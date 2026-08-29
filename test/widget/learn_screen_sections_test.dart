import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
    // the design sets them. The lead card's eyebrow is not a section header,
    // so it keeps its sentence case.
    // Practice is one section with two groups under it, and the course is
    // Path's now — so there is no MODULES header to find here (#394).
    for (final section in const [
      "Today's lesson",
      'PRACTICE',
      'LESSONS',
      'GAMES',
    ]) {
      expect(find.text(section), findsOneWidget, reason: section);
    }
    for (final gone in const [
      'PRACTICE A FINISHED LESSON',
      'MINI-GAMES',
      'MODULES',
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
    await ProgressRepository().saveCompletion(
      lessonId: 'm1l1',
      xpEarned: 10,
      mastery: const MasteryResult(correct: 5, total: 5),
    );

    await pumpWithProviders(tester, const BrewPathApp());

    expect(find.text('What coffee actually is'), findsWidgets);
    // Deliberately the *third* lesson: the second becomes today's lesson once
    // the first is done, so it would show in the Today card either way.
    expect(
      find.text('What origin means'),
      findsNothing,
      reason: 'unfinished lessons are not practice material',
    );
  });

  testWidgets('a learner who has finished nothing sees an empty section', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());

    expect(find.text('PRACTICE'), findsOneWidget);
    expect(find.text('No lessons available yet.'), findsOneWidget);
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
