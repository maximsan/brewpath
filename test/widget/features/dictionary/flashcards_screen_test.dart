import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/drill_results_view.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_view.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_empty_view.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_screen.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// Two terms the real bank carries, saved so they can be dealt.
const _arabica = 't:arabica';
const _robusta = 't:robusta';

/// A term no free lesson can reach: `cupping` carries no `lesson` at all, and
/// `accessibleTerms` drops a lessonless term for a free learner whatever
/// mentions it (ADR-0014). Saving it is the state #468 is about.
const _cupping = 't:cupping';

/// Saves [keys] the way the app does, before the drill is pumped.
Future<void> _seed(List<String> keys) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  for (final key in keys) {
    await toggleSaved(
      container.read(snapshotRepositoryProvider),
      key: key,
      now: DateTime(2026, 8, 31),
      isPlus: true,
      visible: 0,
    );
  }
}

/// Pumps the drill for a learner who owns the course, so the deck is every
/// term they saved rather than only the ones they have been taught.
///
/// Returns the container, so a test can read back what the review wrote.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool hasCourse = true,
}) async {
  final container = ProviderContainer(
    overrides: [
      courseEntitlementProvider.overrideWith((ref) async => hasCourse),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.cupping,
        home: const FlashcardsScreen(),
      ),
    ),
  );
  await settleLoaders(tester);
  return container;
}

/// Bounded pumps rather than `pumpAndSettle`: the results screen's companion
/// animates indefinitely, so settling would never return.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Lets the review's write actually reach the database, which the screen fires
/// and does not await.
Future<void> _settleWrite(WidgetTester tester) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

/// Today's activity entries, read straight off the record the drill writes to.
Future<Set<String>> _activityToday(ProviderContainer container) async {
  final snapshot = await container.read(snapshotRepositoryProvider).read();
  return snapshot.clearedByReset.dailyActivity.values
      .expand((entries) => entries)
      .toSet();
}

/// How many finished reviews the record holds.
int _reviews(Set<String> entries) => entries
    .where((entry) => parseActivityEntry(entry).type == ActivityType.flashcards)
    .length;

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('nothing saved opens the teaching state, not a dead end', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(FlashcardsEmptyView), findsOneWidget);
    expect(find.text(FlashcardsCopy.emptyBody), findsOneWidget);
    expect(find.text(FlashcardsCopy.browse), findsOneWidget);
    expect(
      find.byType(RoastMeter),
      findsNothing,
      reason: 'there is no position to be in when there are no cards',
    );
  });

  testWidgets('nothing saved reads the same whichever tier you are on', (
    tester,
  ) async {
    // The design's copy is for *nothing saved*, and that state is not about
    // tier at all — the second body must not leak into it.
    await _pump(tester, hasCourse: false);

    expect(find.text(FlashcardsCopy.emptyBody), findsOneWidget);
    expect(find.text(FlashcardsCopy.emptyOutOfReachBody), findsNothing);
  });

  testWidgets('saved, but none of it in reach, says so instead', (
    tester,
  ) async {
    // They did bookmark, and it did not become a deck. The design's copy is
    // written for *nothing saved* and is untrue here (#468).
    await _seed([_cupping]);
    await _pump(tester, hasCourse: false);

    expect(find.byType(FlashcardsEmptyView), findsOneWidget);
    expect(find.text(FlashcardsCopy.emptyOutOfReachBody), findsOneWidget);
    expect(
      find.text(FlashcardsCopy.emptyBody),
      findsNothing,
      reason: 'telling them to bookmark terms is the lie this fixes',
    );
  });

  testWidgets('a saved term is dealt, term-side up', (tester) async {
    await _seed([_arabica]);
    await _pump(tester);

    expect(find.byType(FlashcardView), findsOneWidget);
    expect(find.text('Arabica'), findsOneWidget);
    expect(
      find.text(FlashcardsCopy.tapToReveal.toUpperCase()),
      findsOneWidget,
      reason: 'a card that opened revealed would test nothing',
    );
  });

  testWidgets('tapping the card reveals the definition', (tester) async {
    await _seed([_arabica]);
    await _pump(tester);

    await tester.tap(find.byType(FlashcardView));
    await tester.pumpAndSettle();

    expect(
      find.text(FlashcardsCopy.tapToSeeTerm.toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(FlashcardsCopy.viewEntry),
      findsOneWidget,
      reason: "the entry link is the revealed card's continuation",
    );
  });

  testWidgets('the entry link is unreachable before the reveal', (
    tester,
  ) async {
    await _seed([_arabica]);
    await _pump(tester);

    expect(
      find.text(FlashcardsCopy.viewEntry),
      findsNothing,
      reason: 'a link to "more" before the reveal undercuts the recall',
    );
  });

  testWidgets('the counter says where in the deck the learner is', (
    tester,
  ) async {
    await _seed([_arabica, _robusta]);
    await _pump(tester);

    expect(find.byType(RoastMeter), findsOneWidget);
    expect(find.text('01 / 02'), findsOneWidget);

    await tester.tap(find.text(FlashcardsCopy.next));
    await tester.pumpAndSettle();

    expect(find.text('02 / 02'), findsOneWidget);
  });

  testWidgets('the last card finishes rather than offering another', (
    tester,
  ) async {
    await _seed([_arabica]);
    await _pump(tester);

    expect(find.text(FlashcardsCopy.finish), findsOneWidget);
    expect(find.text(FlashcardsCopy.next), findsNothing);
  });

  testWidgets('Prev is dead on the first card and live after it', (
    tester,
  ) async {
    await _seed([_arabica, _robusta]);
    await _pump(tester);

    OutlinedButton previous() => tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, FlashcardsCopy.previous),
    );

    expect(previous().onPressed, isNull);

    await tester.tap(find.text(FlashcardsCopy.next));
    await tester.pumpAndSettle();

    expect(previous().onPressed, isNotNull);
  });

  testWidgets('finishing counts the deck and offers another deal', (
    tester,
  ) async {
    await _seed([_arabica, _robusta]);
    await _pump(tester);

    await tester.tap(find.text(FlashcardsCopy.next));
    await tester.pumpAndSettle();
    await tester.tap(find.text(FlashcardsCopy.finish));
    await _settle(tester);

    expect(find.byType(DrillResultsView), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      find.text(FlashcardsCopy.reviewedNote(2).toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(FlashcardsCopy.goAgain), findsOneWidget);
    expect(
      find.text('02 / 02'),
      findsOneWidget,
      reason: 'the design leaves the counter full on the finished state',
    );
  });

  testWidgets('a finished review is recorded once, and only once', (
    tester,
  ) async {
    await _seed([_arabica]);
    final container = await _pump(tester);

    await tester.tap(find.text(FlashcardsCopy.finish));
    await _settle(tester);
    await _settleWrite(tester);

    expect(_reviews(await _activityToday(container)), 1);

    // A rebuild of the results must not write a second entry: the allowance
    // counts entries, so one review that recorded twice would cost the
    // learner two of their day.
    await _settle(tester);
    await _settleWrite(tester);

    expect(_reviews(await _activityToday(container)), 1);
  });

  testWidgets('an abandoned review records nothing', (tester) async {
    await _seed([_arabica, _robusta]);
    final container = await _pump(tester);

    // One card in, then away — the finish is never reached.
    await tester.tap(find.text(FlashcardsCopy.next));
    await tester.pumpAndSettle();
    await _settleWrite(tester);

    expect(_reviews(await _activityToday(container)), 0);
  });

  testWidgets('going again is a second review, and records as one', (
    tester,
  ) async {
    await _seed([_arabica]);
    final container = await _pump(tester);

    await tester.tap(find.text(FlashcardsCopy.finish));
    await _settle(tester);
    await _settleWrite(tester);

    await tester.tap(find.text(FlashcardsCopy.goAgain));
    await tester.pumpAndSettle();
    await tester.tap(find.text(FlashcardsCopy.finish));
    await _settle(tester);
    await _settleWrite(tester);

    expect(_reviews(await _activityToday(container)), 2);
  });

  testWidgets('one card is not worth a shuffle', (tester) async {
    await _seed([_arabica]);
    await _pump(tester);

    expect(
      find.byTooltip(FlashcardsCopy.shuffle),
      findsNothing,
      reason: 'a one-card deck has only one order to be in',
    );
  });

  testWidgets('two cards are', (tester) async {
    await _seed([_arabica, _robusta]);
    await _pump(tester);

    expect(find.byTooltip(FlashcardsCopy.shuffle), findsOneWidget);
  });

  testWidgets('the deck line counts what will actually be dealt', (
    tester,
  ) async {
    await _seed([_arabica, _robusta]);
    await _pump(tester);

    expect(find.text(FlashcardsCopy.deckLine(2).toUpperCase()), findsOneWidget);
  });
}
