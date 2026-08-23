import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/path/domain/visual_guide_providers.dart';
import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_empty_view.dart';
import 'package:brew_path/features/saved/presentation/saved_group_section.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// Headings and subtitles are drawn by the smallcaps label, which uppercases.
/// The assertions below use what the learner actually reads.
const _terms = 'DICTIONARY TERMS';
const _lessons = 'LESSONS';
const _guides = 'VISUAL GUIDES';

/// The shelf against the **real** content banks, so a row's title and subtitle
/// are the ones a learner would actually see rather than a fixture's.
Widget _wrap() => ProviderScope(
  child: MaterialApp(theme: AppTheme.cupping, home: const SavedScreen()),
);

/// Pumps the shelf with exactly [earned] guides unlocked.
///
/// The container carries the override rather than a nested `ProviderScope`:
/// the shelf provider resolves against the container the screen is mounted
/// under, so an inner scope added below it changes nothing.
Future<void> _pumpWithGuides(
  WidgetTester tester,
  List<VisualGuide> earned,
) async {
  final container = ProviderContainer(
    overrides: [
      visualGuideShelfForProvider.overrideWith(
        (ref) async =>
            VisualGuideShelf(earned: earned, remaining: 8 - earned.length),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.cupping, home: const SavedScreen()),
    ),
  );
  await settleLoaders(tester);
}

/// A guide, with the id/subject split that `g:` has to get right.
VisualGuide _guide(String subject, String title) => VisualGuide(
  id: 'g-$subject',
  subject: subject,
  unlock: const VisualGuideUnlock(lesson: 'm3l1'),
  label: 'VISUAL GUIDE',
  title: title,
  summary: 'What $subject is.',
  fact: 'Worth repeating about $subject.',
);

/// Saves [keys] the way the app does, before the screen is pumped.
Future<void> _seed(WidgetTester tester, List<String> keys) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  for (final key in keys) {
    await toggleSaved(
      container.read(snapshotRepositoryProvider),
      key: key,
      now: DateTime(2026, 8, 23),
    );
  }
}

void main() {
  setUp(useInMemoryDatabase);

  testWidgets(
    'an empty shelf teaches the bookmark rather than showing nothing',
    (
      tester,
    ) async {
      await pumpWithProviders(tester, _wrap());

      expect(find.byType(SavedEmptyView), findsOneWidget);
      expect(find.text(SavedEmptyView.message), findsOneWidget);
    },
  );

  testWidgets('a saved term appears under its group, with its category', (
    tester,
  ) async {
    await _seed(tester, ['t:arabica']);
    await pumpWithProviders(tester, _wrap());

    expect(find.text(_terms), findsOneWidget);
    expect(find.text('Arabica'), findsOneWidget);
  });

  testWidgets('a saved lesson shows the module it belongs to', (tester) async {
    await _seed(tester, ['l:m1l1']);
    await pumpWithProviders(tester, _wrap());

    expect(find.text(_lessons), findsOneWidget);
    expect(find.text('What coffee actually is'), findsOneWidget);
    expect(find.text('MODULE 1 · BEANS'), findsOneWidget);
  });

  testWidgets('lessons read in course order, not the order they were saved', (
    tester,
  ) async {
    // m2l1 saved first; m1l1 teaches earlier and must lead.
    await _seed(tester, ['l:m2l1', 'l:m1l1']);
    await pumpWithProviders(tester, _wrap());

    final first = tester.getTopLeft(find.text('What coffee actually is')).dy;
    final second = tester.getTopLeft(find.text('Washed, natural, honey')).dy;
    expect(first, lessThan(second));
  });

  testWidgets('a kind with nothing saved renders no heading', (tester) async {
    await _seed(tester, ['t:arabica']);
    await pumpWithProviders(tester, _wrap());

    expect(find.text(_lessons), findsNothing);
    expect(
      find.text(_guides),
      findsNothing,
      reason: 'no guide is saved, and none is earned either',
    );
  });

  testWidgets('groups are ordered terms, then lessons', (tester) async {
    await _seed(tester, ['l:m1l1', 't:arabica']);
    await pumpWithProviders(tester, _wrap());

    final terms = tester.getTopLeft(find.text(_terms)).dy;
    final lessons = tester.getTopLeft(find.text(_lessons)).dy;
    expect(
      terms,
      lessThan(lessons),
      reason: 'the design fixes the order; saving order must not change it',
    );
  });

  testWidgets('unsaving the last row of a group removes its heading', (
    tester,
  ) async {
    await _seed(tester, ['t:arabica']);
    await pumpWithProviders(tester, _wrap());
    expect(find.text(_terms), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark));
    await settleLoaders(tester);

    expect(find.text(_terms), findsNothing);
    expect(find.byType(SavedEmptyView), findsOneWidget);
  });

  testWidgets('a saved key nothing resolves is skipped, not shown broken', (
    tester,
  ) async {
    await _seed(tester, ['t:arabica', 't:no-such-term', 'l:no-such-lesson']);
    await pumpWithProviders(tester, _wrap());

    expect(find.text('Arabica'), findsOneWidget);
    expect(find.text(_lessons), findsNothing);
    expect(find.textContaining('no-such'), findsNothing);
  });

  testWidgets('a term row shows its category', (tester) async {
    await _seed(tester, ['t:arabica']);
    await pumpWithProviders(tester, _wrap());

    expect(
      find.text('BEANS AND BOTANY'),
      findsOneWidget,
      reason: 'two similar-sounding terms are told apart by their category',
    );
  });

  testWidgets('each group says how many it holds', (tester) async {
    await _seed(tester, ['t:arabica', 't:robusta']);
    await pumpWithProviders(tester, _wrap());

    expect(
      find.descendant(
        of: find.byType(SavedGroupSection),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
  });

  group('visual guides', () {
    final roast = _guide('roast', 'Roast Levels');
    final grind = _guide('grind', 'Grind Size');

    testWidgets('a saved guide appears under its own group', (tester) async {
      await _seed(tester, ['g:roast']);
      await _pumpWithGuides(tester, [roast]);

      expect(find.text(_guides), findsOneWidget);
      expect(find.text('Roast Levels'), findsOneWidget);
    });

    testWidgets('a guide the learner has not earned never reaches the shelf', (
      tester,
    ) async {
      // Saved while earned, then Reset locked it again. The shelf must not
      // become a way back into content the course has re-locked.
      await _seed(tester, ['g:roast']);
      await _pumpWithGuides(tester, const []);

      expect(find.text(_guides), findsNothing);
      expect(find.text('Roast Levels'), findsNothing);
      expect(find.byType(SavedEmptyView), findsOneWidget);
    });

    testWidgets('a guide row opens that guide', (tester) async {
      await _seed(tester, ['g:roast']);
      await _pumpWithGuides(tester, [roast]);

      await tester.tap(find.text('Roast Levels'));
      await tester.pumpAndSettle();

      // A sheet, not a route: a reference opens over what you were reading.
      expect(find.byType(VisualGuideSheetBody), findsOneWidget);
    });

    testWidgets('guides read in bank order, not save order', (tester) async {
      await _seed(tester, ['g:grind', 'g:roast']);
      await _pumpWithGuides(tester, [roast, grind]);

      expect(
        tester.getTopLeft(find.text('Roast Levels')).dy,
        lessThan(tester.getTopLeft(find.text('Grind Size')).dy),
      );
    });

    testWidgets('guides come last, after terms and lessons', (tester) async {
      await _seed(tester, ['g:roast', 't:arabica', 'l:m1l1']);
      await _pumpWithGuides(tester, [roast]);

      final terms = tester.getTopLeft(find.text(_terms)).dy;
      final lessons = tester.getTopLeft(find.text(_lessons)).dy;
      final guides = tester.getTopLeft(find.text(_guides)).dy;
      expect(terms, lessThan(lessons));
      expect(lessons, lessThan(guides));
    });
  });

  testWidgets('the count line counts what is shown', (tester) async {
    await _seed(tester, ['t:arabica', 't:robusta', 't:no-such-term']);
    await pumpWithProviders(tester, _wrap());

    expect(find.text('2 items to revisit'), findsOneWidget);
  });

  testWidgets('one saved item reads in the singular', (tester) async {
    await _seed(tester, ['t:arabica']);
    await pumpWithProviders(tester, _wrap());

    expect(find.text('1 item to revisit'), findsOneWidget);
  });

  testWidgets('the shelf says so when it cannot load', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedShelfProvider.overrideWith(
            (ref) async => throw StateError('the bank is unreachable'),
          ),
        ],
        child: _wrap(),
      ),
    );
    await settleLoaders(tester);

    // An empty-looking shelf would be a lie about the learner's data.
    expect(find.byType(SavedEmptyView), findsNothing);
    expect(find.textContaining('unreachable'), findsOneWidget);
  });
}
