import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_quick_chips.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_empty_view.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_screen.dart';
import 'package:brew_path/features/learn/presentation/practice_drills_widget.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/features/saved/presentation/saved_study_row.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// A term the free lessons mention, so a free learner reaches it from the
/// start (ADR-0014). No entitlement override anywhere below — these are the
/// paths a real free learner walks.
const _cherry = 't:cherry';

/// A term outside the free pool: no free lesson names it. Saving one puts a
/// row on the shelf that the deck cannot deal.
const _geisha = 't:geisha';

/// Saves [keys] the way the app does, before the shell is pumped.
Future<void> _seed(List<String> keys) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  for (final key in keys) {
    await toggleSaved(
      container.read(snapshotRepositoryProvider),
      key: key,
      now: DateTime(2026, 8, 31),
      isPlus: false,
      visible: 0,
    );
  }
}

/// A deck of one, for a free learner who has finished nothing: the term is
/// accessible because a free lesson mentions it, not because they learned it.
Future<void> _seedDeckOfOne() => _seed([_cherry]);

/// A tall surface, so a tab's lower sections lay out inside the viewport
/// instead of being virtualized out of the tree.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Boots the app on the Learn tab.
Future<void> _openApp(WidgetTester tester) async {
  _useTallViewport(tester);
  await pumpWithProviders(tester, const BrewPathApp());
}

/// Opens the dictionary.
///
/// Routed rather than tapped: the header's dictionary entry is a stock
/// Material glyph rather than one of the app's marks, so there is nothing for
/// `findMark` to find and a `byIcon` would be asserting the header's business
/// rather than this drill's.
Future<void> _openDictionary(WidgetTester tester) async {
  _useTallViewport(tester);
  final container = await pumpWithProviders(tester, const BrewPathApp());
  container.read(appRouterProvider).go('/learn/dictionary');
  await settleLoaders(tester);
}

/// The Flashcards chip on Dictionary home. Scoped, because the Learn tab
/// underneath this pushed route carries a practice row of the same name.
Finder _chip() => find.descendant(
  of: find.byType(DictionaryQuickChips),
  matching: find.text(FlashcardsCopy.title),
);

/// The Flashcards row in the Learn tab's practice card — scoped for the same
/// reason, since the card now holds the vocab drill's row beside it.
Finder _practiceRow() => find.descendant(
  of: find.byType(PracticeDrillsWidget),
  matching: find.text(FlashcardsCopy.title),
);

/// Opens the Saved shelf from the Learn tab's header.
Future<void> _openSaved(WidgetTester tester) async {
  await _openApp(tester);
  await tester.tap(findMark(AppIcon.bookmark));
  await settleLoaders(tester);
}

void main() {
  setUp(useInMemoryDatabase);

  group('the dictionary chip', () {
    testWidgets('is on the home screen, and opens the drill', (tester) async {
      await _openDictionary(tester);

      expect(find.byType(DictionaryHomeScreen), findsOneWidget);
      expect(_chip(), findsOneWidget);

      await tester.tap(_chip());
      await settleLoaders(tester);

      expect(find.byType(FlashcardsScreen), findsOneWidget);
    });

    testWidgets('is there with an empty deck, and teaches on arrival', (
      tester,
    ) async {
      await _openDictionary(tester);

      await tester.tap(_chip());
      await settleLoaders(tester);

      expect(
        find.byType(FlashcardsEmptyView),
        findsOneWidget,
        reason:
            'hiding the chip until something is saved would mean only the '
            'learners who already knew could ever find the drill',
      );
    });

    testWidgets('carries the deck count once there is a deck', (tester) async {
      await _seedDeckOfOne();
      await _openDictionary(tester);

      expect(find.text('1'), findsWidgets);
    });
  });

  group("the shelf's study row", () {
    testWidgets('offers the deck it can actually deal', (tester) async {
      await _seedDeckOfOne();
      await _openSaved(tester);

      expect(find.byType(SavedScreen), findsOneWidget);
      expect(find.text(FlashcardsCopy.studyRow(1)), findsOneWidget);

      await tester.tap(find.text(FlashcardsCopy.studyRow(1)));
      await settleLoaders(tester);

      expect(find.byType(FlashcardsScreen), findsOneWidget);
    });

    testWidgets('stays when the terms are saved but not yet reachable', (
      tester,
    ) async {
      // Saved, but no free lesson names it — so the shelf has a terms group
      // and the deck has nothing in it (ADR-0014). The row is the learner's
      // way to find out why, so it must not vanish; it drops the count rather
      // than offering to study none.
      await _seed([_geisha]);
      await _openSaved(tester);

      expect(find.byType(SavedStudyRow), findsOneWidget);
      expect(find.text(FlashcardsCopy.studyRow(0)), findsNothing);
      expect(find.text(FlashcardsCopy.title), findsOneWidget);

      await tester.tap(find.byType(SavedStudyRow));
      await settleLoaders(tester);

      expect(find.byType(FlashcardsEmptyView), findsOneWidget);
    });

    testWidgets('is absent when the shelf holds no terms at all', (
      tester,
    ) async {
      // A saved lesson puts rows on the shelf without putting a term under the
      // heading this row belongs to — and the design draws it inside that
      // group.
      await _seed(['l:m1l1']);
      await _openSaved(tester);

      expect(find.byType(SavedScreen), findsOneWidget);
      expect(find.byType(SavedStudyRow), findsNothing);
    });
  });

  group("the Learn tab's practice row", () {
    testWidgets('is always there, whatever is saved', (tester) async {
      await _openApp(tester);

      expect(_practiceRow(), findsOneWidget);
      expect(
        find.text(FlashcardsCopy.practiceRowEyebrow.toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('opens the drill', (tester) async {
      await _seedDeckOfOne();
      await _openApp(tester);

      await tester.tap(_practiceRow());
      await settleLoaders(tester);

      expect(find.byType(FlashcardsScreen), findsOneWidget);
    });

    testWidgets('lands on the same teaching state with nothing saved', (
      tester,
    ) async {
      await _openApp(tester);

      await tester.tap(_practiceRow());
      await settleLoaders(tester);

      expect(find.byType(FlashcardsEmptyView), findsOneWidget);
    });
  });

  testWidgets('closing the drill returns to where it was opened from', (
    tester,
  ) async {
    await _seedDeckOfOne();
    await _openSaved(tester);

    await tester.tap(find.text(FlashcardsCopy.studyRow(1)));
    await settleLoaders(tester);
    expect(find.byType(FlashcardsScreen), findsOneWidget);

    await tester.tap(findMark(AppIcon.close));
    await settleLoaders(tester);

    expect(
      find.byType(SavedScreen),
      findsOneWidget,
      reason: 'the shelf is where this learner came from, not the Learn tab',
    );
  });
}
