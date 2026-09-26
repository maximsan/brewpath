import 'dart:async';

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/swipe/horizontal_swipe.dart';
import 'package:brew_path/core/swipe/swipe_hint_caption.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/domain/save_swipe_nudge.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_term_list.dart';
import 'package:brew_path/features/dictionary/presentation/term_row.dart';
import 'package:brew_path/features/dictionary/presentation/term_save_track.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/l10n/generated/app_localizations_en.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

const _category = DictionaryCategory(
  id: 'brewing',
  label: 'Brewing',
  glyph: 'brewing',
  summary: 'How coffee is made.',
);

DictionaryTerm _term(String id) => DictionaryTerm(
  id: id,
  term: id,
  categoryId: 'brewing',
  shortExplanation: 'What $id means.',
);

DictionaryView _view(List<DictionaryTerm> terms) => DictionaryView(
  terms: terms,
  categories: const [_category],
  completedLessonIds: const {},
  hasCourse: true,
);

void main() {
  setUp(useInMemoryDatabase);

  /// The shelf once the save has had a chance to land. The write runs through
  /// the entitlement and the shelf count, both of which read real content.
  Future<Set<String>> shelf(WidgetTester tester) async {
    var keys = const <String>{};
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      keys =
          (await SnapshotRepository().read()).clearedByReset.favourites.value;
      if (keys.isNotEmpty) break;
    }
    return keys;
  }

  Future<void> pump(
    WidgetTester tester,
    List<DictionaryTerm> terms, {
    Set<String> saved = const {},
    bool isBrowsing = true,
  }) => pumpWithProviders(
    tester,
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.darkRoast,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            DictionaryTermList(
              view: _view(terms),
              visible: terms,
              onOpen: (_) {},
              grouped: false,
              isBrowsing: isBrowsing,
            ),
          ],
        ),
      ),
    ),
    // At the root, not a nested scope: `isKeySavedProvider` declares no
    // dependencies, so it is hosted at the root and reads the root's set.
    container: ProviderContainer(
      overrides: [
        savedKeysProvider.overrideWith(
          (ref) async => {
            for (final id in saved) formatSavedKey(SavedKind.term, id),
          },
        ),
      ],
    ),
  );

  Finder row(String id) => find.ancestor(
    of: find.text(id),
    matching: find.byType(TermRow),
  );

  String label(WidgetTester tester) =>
      tester.widgetList<TermSaveTrack>(find.byType(TermSaveTrack)).first.isSaved
      ? AppLocalizationsEn().termAlreadySaved
      : AppLocalizationsEn().termSave;

  group('swiping a row right', () {
    testWidgets('saves an unsaved term', (tester) async {
      await pump(tester, [_term('crema')]);

      await tester.drag(row('crema'), const Offset(90, 0));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );

      expect(
        await shelf(tester),
        contains(formatSavedKey(SavedKind.term, 'crema')),
      );
    });

    testWidgets('short of the threshold saves nothing', (tester) async {
      await pump(tester, [_term('crema')]);

      await tester.drag(row('crema'), const Offset(40, 0));
      await tester.pumpAndSettle();

      expect(await shelf(tester), isEmpty);
    });

    testWidgets('a drag starting in the row padding still saves it', (
      tester,
    ) async {
      await pump(tester, [_term('crema')]);
      // The row's own vertical padding, which a target sized to the text
      // answered for neither the tap nor the drag.
      final box = tester.getRect(find.byType(HorizontalSwipe));

      await tester.dragFrom(
        Offset(box.left + 4, box.top + 4),
        const Offset(90, 0),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );

      expect(
        await shelf(tester),
        contains(formatSavedKey(SavedKind.term, 'crema')),
      );
    });

    testWidgets('a left swipe is refused and saves nothing', (tester) async {
      await pump(tester, [_term('crema')]);

      await tester.drag(row('crema'), const Offset(-160, 0));
      await tester.pumpAndSettle();

      expect(await shelf(tester), isEmpty);
    });
  });

  group('a row that is already saved', () {
    testWidgets('resists rather than going dead, and un-saves nothing', (
      tester,
    ) async {
      // Both rows in one list, under the same gesture: the damping is a
      // comparison rather than a number copied out of the geometry. The row's
      // own box never moves — the transform is inside it — so the word is
      // what says how far the drag got.
      await pump(
        tester,
        [_term('crema'), _term('body')],
        saved: const {'crema'},
      );

      Future<double> travelOf(String id) async {
        final swipe = find.descendant(
          of: row(id),
          matching: find.byType(HorizontalSwipe),
        );
        final before = tester.getTopLeft(find.text(id)).dx;
        final gesture = await tester.startGesture(tester.getCenter(swipe));
        await gesture.moveBy(const Offset(30, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();
        final moved = tester.getTopLeft(find.text(id)).dx - before;
        await gesture.up();
        await tester.pumpAndSettle();
        return moved;
      }

      final free = await travelOf('body');
      final resisted = await travelOf('crema');

      expect(resisted, greaterThan(0), reason: 'it resists, it is not frozen');
      expect(resisted, lessThan(free), reason: 'damped, so nothing that way');
      expect(
        tester
            .widget<HorizontalSwipe>(
              find.descendant(
                of: row('crema'),
                matching: find.byType(HorizontalSwipe),
              ),
            )
            .canBack,
        isFalse,
        reason: 'save-only: a stray drag must never empty a curated list',
      );
    });

    testWidgets('cannot be un-saved by a swipe landing before the shelf '
        'has resolved', (tester) async {
      // The shelf never answers, so the row builds with an unresolved read
      // for the whole test — the window a real device has for a frame or two.
      await pumpWithProviders(
        tester,
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.darkRoast,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                DictionaryTermList(
                  view: _view([_term('crema')]),
                  visible: [_term('crema')],
                  onOpen: (_) {},
                  grouped: false,
                ),
              ],
            ),
          ),
        ),
        container: ProviderContainer(
          overrides: [
            savedKeysProvider.overrideWith(
              (ref) => Completer<Set<String>>().future,
            ),
          ],
        ),
      );

      expect(
        tester.widget<HorizontalSwipe>(find.byType(HorizontalSwipe)).canBack,
        isFalse,
        reason: 'an unresolved read must not open the gesture',
      );

      await tester.drag(row('crema'), const Offset(120, 0));
      await tester.pumpAndSettle();

      expect(await shelf(tester), isEmpty);
    });

    testWidgets('says already saved rather than save', (tester) async {
      await pump(tester, [_term('crema')], saved: const {'crema'});

      expect(label(tester), AppLocalizationsEn().termAlreadySaved);
      expect(find.text('ALREADY SAVED'), findsOneWidget);
    });

    testWidgets('leads with the mark, which fits what the damping uncovers', (
      tester,
    ) async {
      await pump(tester, [_term('crema')], saved: const {'crema'});

      final swipe = find.byType(HorizontalSwipe);
      final atRest = tester.getTopLeft(find.text('crema')).dx;

      final gesture = await tester.startGesture(tester.getCenter(swipe));
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      // Far enough that a save would have committed twice over — what a
      // finger does when the row resists is push harder.
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();

      // The row is opaque, so the strip it has moved off is all that can be
      // read — how far the row travelled, not where its text sits. The words
      // never fit in that strip; the mark has to.
      final uncovered = tester.getTopLeft(find.text('crema')).dx - atRest;
      final mark = find.descendant(
        of: find.byType(TermSaveTrack),
        matching: find.byType(IconMark),
      );
      expect(mark, findsOneWidget);
      expect(
        tester.getTopRight(mark).dx - tester.getTopLeft(swipe).dx,
        lessThanOrEqualTo(uncovered),
        reason:
            'the mark must clear the row at a natural drag; only '
            '${uncovered.toStringAsFixed(1)}px is uncovered here',
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('an unsaved row says save', (tester) async {
      await pump(tester, [_term('crema')]);

      expect(label(tester), AppLocalizationsEn().termSave);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('carries the bookmark; an unsaved row carries none', (
      tester,
    ) async {
      await pump(
        tester,
        [
          _term('crema'),
          _term('body'),
        ],
        saved: const {'crema'},
      );

      expect(find.byTooltip('Remove crema from Saved'), findsOneWidget);
      expect(find.byTooltip('Save body'), findsNothing);
    });
  });

  group('the nudge', () {
    testWidgets('teaches on the first unsaved row above the fold', (
      tester,
    ) async {
      await pump(
        tester,
        [_term('a'), _term('b'), _term('c')],
        saved: const {'a'},
      );

      // The first nudge lands at 900ms; before that every row sits at 0.
      await tester.pump(const Duration(milliseconds: 950));

      expect(
        tester.widget<TermRow>(row('b')).nudge,
        greaterThan(0),
        reason: 'row a is saved, so it would demonstrate nothing',
      );
      expect(tester.widget<TermRow>(row('a')).nudge, 0);
      expect(tester.widget<TermRow>(row('c')).nudge, 0);
      await tester.pumpAndSettle();
    });

    testWidgets('renders nothing when every reachable row is saved', (
      tester,
    ) async {
      final terms = List.generate(
        dictionaryRowsAboveFold,
        (index) => _term('row$index'),
      );

      await pump(
        tester,
        terms,
        saved: {for (final term in terms) term.id},
      );

      expect(find.byType(SwipeHintCaption), findsNothing);
    });

    testWidgets('leaves a grouped run alone, where counting terms says '
        'nothing about the fold', (tester) async {
      await pumpWithProviders(
        tester,
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.darkRoast,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                DictionaryTermList(
                  view: _view([_term('crema')]),
                  visible: [_term('crema')],
                  onOpen: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      // Headers and category notes sit between the rows, so the fifth term is
      // not the fifth thing on screen.
      expect(find.byType(SwipeHintCaption), findsNothing);
      expect(tester.widget<TermRow>(row('crema')).nudge, 0);
    });

    testWidgets('leaves search results alone, which move as you type', (
      tester,
    ) async {
      await pump(tester, [_term('crema')], isBrowsing: false);

      expect(find.byType(SwipeHintCaption), findsNothing);
      expect(tester.widget<TermRow>(row('crema')).nudge, 0);
    });

    testWidgets('captions the browse list it is teaching on', (tester) async {
      await pump(tester, [_term('crema')]);
      await tester.pump();

      expect(find.byType(SwipeHintCaption), findsOneWidget);
      expect(
        find.text(AppLocalizationsEn().dictionarySwipeToSave.toUpperCase()),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });
  });
}
