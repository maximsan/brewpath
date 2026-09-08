import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/category_index.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/dictionary/presentation/status_chip.dart';
import 'package:brew_path/features/dictionary/presentation/term_detail_screen.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_copy.dart';
import 'package:brew_path/features/dictionary/presentation/term_full_entry_gate.dart';
import 'package:brew_path/features/dictionary/presentation/term_peek_sheet.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';

const _beans = DictionaryCategory(
  id: 'beans',
  label: 'Beans and Botany',
  glyph: 'cherry',
  summary: 'The plant, the seed, where it grows.',
);
const _trade = DictionaryCategory(
  id: 'trade',
  label: 'Coffee Trade',
  glyph: 'scales',
  summary: 'From farm to roaster.',
);

/// A term with every optional block filled, so a test can assert one is gone.
const _full = DictionaryTerm(
  id: 'arabica',
  term: 'Arabica',
  categoryId: 'beans',
  shortExplanation: 'The species behind most specialty coffee.',
  lessonId: 'm1l2',
  aliases: ['Coffea arabica'],
  relatedIds: ['tds'],
  pronunciation: 'uh-RAB-ih-kuh',
  deepExplanation: 'Roughly 60% of world coffee.',
  example: 'A bag saying 100% Arabica.',
  sources: [
    DictionarySource(label: 'The World Atlas of Coffee'),
    DictionarySource(label: 'SCA', url: 'https://sca.coffee/research'),
  ],
  check: DictionaryCheck(
    question: 'Arabica usually has…',
    choices: [
      Choice(text: 'More caffeine'),
      Choice(text: 'More sweetness', isCorrect: true),
    ],
    explanation: 'Arabica is prized for sweetness.',
  ),
);

/// A term carrying only the short explanation — a quarter of the real bank.
const _stub = DictionaryTerm(
  id: 'tds',
  term: 'TDS',
  categoryId: 'trade',
  shortExplanation: 'Total dissolved solids.',
);

/// The view as the provider would build it for a learner of the given tier:
/// with the course, the whole bank; without it, the lesson terms only, which
/// is what `visibleTerms` leaves. The view is handed in already narrowed
/// because that is what every screen receives — none of them re-derive it.
DictionaryView _view({
  Set<String> completed = const {},
  bool hasCourse = true,
}) => DictionaryView(
  terms: visibleTerms(terms: const [_full, _stub], hasCourse: hasCourse),
  categories: const [_beans, _trade],
  completedLessonIds: completed,
  hasCourse: hasCourse,
);

/// A counted pitch, so the gate's assertions do not wait on the banks.
const _pitch = PlusPitch(
  remainingLessons: 29,
  lockedGames: 4,
  referenceTerms: 8,
  savedFreeCap: 5,
);

Widget _wrap(Widget child, {DictionaryView? view}) => ProviderScope(
  overrides: [
    dictionaryViewProvider.overrideWith((ref) async => view ?? _view()),
    lessonTitleProvider(
      'm1l2',
    ).overrideWith((ref) async => 'Arabica vs Robusta'),
    plusPitchProvider.overrideWith((ref) async => _pitch),
  ],
  child: MaterialApp(theme: AppTheme.cupping, home: child),
);

void main() {
  group('dictionary home', () {
    testWidgets('leads with the kicker and the name, not a bar title', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Coffee Dictionary'), findsOneWidget);
      expect(find.text('REFERENCE · 2 TERMS'), findsOneWidget);
      // The shelf is about one subject, and says so — it read `Dictionary`.
      expect(find.text('Dictionary'), findsNothing);
      expect(find.widgetWithText(AppBar, 'Coffee Dictionary'), findsNothing);
    });

    testWidgets('the filter is one control, not three loose chips', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<DictionaryFilter>), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('each category wears its own mark', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      // Beans and Trade are different topics, so they are different marks —
      // every category drew one generic cup before #378's icons had a
      // consumer.
      expect(findMark(AppIcon.beans), findsOneWidget);
      expect(findMark(AppIcon.trade), findsOneWidget);
      expect(findMark(AppIcon.cup), findsNothing);
    });

    testWidgets('opens on the category index, not a wall of terms', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      // A learner arrives wanting a subject. The index names each category,
      // says what it covers, and counts what is behind it.
      expect(find.byType(CategoryIndex), findsOneWidget);
      expect(find.text('Beans and Botany'), findsOneWidget);
      expect(find.text('Coffee Trade'), findsOneWidget);
      expect(find.text('The plant, the seed, where it grows.'), findsOneWidget);
      // Not the terms — those are one tap in.
      expect(find.text('Arabica'), findsNothing);
    });

    testWidgets('a category opens its terms and names itself', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beans and Botany'));
      await tester.pumpAndSettle();

      expect(find.text('Arabica'), findsOneWidget);
      // The other category's term is behind its own row.
      expect(find.text('TDS'), findsNothing);
      // The heading follows the learner, and offers the way back.
      expect(find.text('All categories'), findsOneWidget);
    });

    testWidgets('a row says how the word sounds, beside the word', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beans and Botany'));
      await tester.pumpAndSettle();

      // The respelling belongs on the row, not only in the entry:
      // scanning a list is where you meet a word you
      // cannot pronounce.
      expect(find.text('uh-RAB-ih-kuh'), findsOneWidget);
    });

    testWidgets('leaving a category returns to the index', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beans and Botany'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All categories'));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryIndex), findsOneWidget);
    });

    testWidgets('narrows to the terms a query matches', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'arab');
      await tester.pumpAndSettle();

      expect(find.text('Arabica'), findsOneWidget);
      expect(find.text('TDS'), findsNothing);
    });

    testWidgets('says so when a query matches nothing', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('No terms match that search.'), findsOneWidget);
    });

    testWidgets('counts to-learn without the reference term', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      // Two terms, one reference-only: All 2, Learned 0, To learn 1.
      expect(find.text('All 2'), findsOneWidget);
      expect(find.text('To learn 1'), findsOneWidget);
    });
  });

  group('term detail', () {
    testWidgets('the term is a page heading with its status beside it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'arabica')),
      );
      await tester.pumpAndSettle();

      // A heading in the page, not a title in the bar — which is what lets it
      // set at display size and take a chip.
      expect(find.widgetWithText(AppBar, 'Arabica'), findsNothing);
      expect(find.text('Arabica'), findsOneWidget);
      expect(find.byType(StatusChip), findsOneWidget);
    });

    testWidgets('the status is a mark and a word, never one alone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'arabica')),
      );
      await tester.pumpAndSettle();

      // The three states differ by hue, and hue is the one thing a screen
      // reader cannot report — so the word travels with the mark.
      expect(
        tester.getSemantics(find.byType(StatusChip)).label,
        isNotEmpty,
      );
    });

    testWidgets('the blocks carry the design labels', (tester) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'arabica')),
      );
      await tester.pumpAndSettle();

      expect(find.text('IN PRACTICE'), findsOneWidget);
      expect(find.text('KNOWLEDGE CHECK'), findsOneWidget);
      expect(find.text('RELATED TERMS'), findsOneWidget);
      // The words they replaced.
      expect(find.text('IN USE'), findsNothing);
      expect(find.text('CHECK YOURSELF'), findsNothing);
      expect(find.text('RELATED'), findsNothing);
    });

    testWidgets('tells a reference term that no lesson covers it', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'tds')));
      await tester.pumpAndSettle();

      expect(find.textContaining('No lesson covers this one'), findsOneWidget);
      expect(find.text('Not on the path'.toUpperCase()), findsOneWidget);
    });

    testWidgets('a stub renders its short explanation and nothing else', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'tds')));
      await tester.pumpAndSettle();

      expect(find.text('Total dissolved solids.'), findsOneWidget);
      expect(find.text('IN PRACTICE'), findsNothing);
      expect(find.text('KNOWLEDGE CHECK'), findsNothing);
      expect(find.text('SOURCES'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a learned term points back at the lesson', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TermDetailScreen(termId: 'arabica'),
          view: _view(completed: const {'m1l2'}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Where you learned it'.toUpperCase()), findsOneWidget);
      expect(find.text('KNOWLEDGE CHECK'), findsOneWidget);
      expect(find.text('SOURCES'), findsOneWidget);
      expect(
        find.text('Arabica vs Robusta'),
        findsOneWidget,
        reason: 'the lesson is named by title; an id is not an answer',
      );
      expect(find.text('m1l2'), findsNothing);
    });

    testWidgets('a related term is shown by name, not by id', (tester) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'arabica')));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ActionChip, 'TDS'), findsOneWidget);
      expect(
        find.widgetWithText(ActionChip, 'tds'),
        findsNothing,
        reason: 'a learner should never be shown a raw content id',
      );
    });

    testWidgets('a related term peeks instead of burying the entry', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'arabica')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ActionChip, 'TDS'));
      await tester.pumpAndSettle();

      // The peek is over the entry, and the entry is still behind it.
      expect(find.text('Total dissolved solids.'), findsOneWidget);
      expect(find.text('Read the full entry'), findsOneWidget);
      expect(find.text('Arabica'), findsWidgets);
    });

    testWidgets('a source with an address shows it', (tester) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'arabica')));
      await tester.pumpAndSettle();

      expect(find.text('https://sca.coffee/research'), findsOneWidget);
    });

    testWidgets('an unlearned term promises the lesson instead', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'arabica')));
      await tester.pumpAndSettle();

      expect(find.text("Where you'll learn it".toUpperCase()), findsOneWidget);
    });

    testWidgets('the self-check explains only after an answer', (tester) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'arabica')));
      await tester.pumpAndSettle();

      expect(find.text('Arabica is prized for sweetness.'), findsNothing);
      await tester.tap(find.text('More caffeine'));
      await tester.pumpAndSettle();
      expect(find.text('Arabica is prized for sweetness.'), findsOneWidget);
    });
  });

  group('term peek sheet', () {
    testWidgets('opens over the screen and dismisses', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showTermPeekSheet(context, 'tds'),
                child: const Text('peek'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('peek'));
      await tester.pumpAndSettle();
      expect(find.text('Total dissolved solids.'), findsOneWidget);
      expect(find.text('Read the full entry'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Total dissolved solids.'), findsNothing);
    });
  });

  group('without the course', () {
    final free = _view(hasCourse: false);

    testWidgets('the shelf holds the lesson terms and nothing else', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen(), view: free));
      await tester.pumpAndSettle();

      // One reference term in the fixture, and it is gone from the kicker,
      // the filter counts and the category index alike — absent, not locked.
      expect(find.text('REFERENCE · 1 TERMS'), findsOneWidget);
      expect(find.text('All 1'), findsOneWidget);
      expect(find.text('Beans and Botany'), findsOneWidget);
      expect(find.text('Coffee Trade'), findsNothing);
    });

    testWidgets('no search finds a reference term', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen(), view: free));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'tds');
      await tester.pumpAndSettle();

      expect(find.text('TDS'), findsNothing);
      expect(find.text('No terms match that search.'), findsOneWidget);
    });

    testWidgets('a link to a reference term lands on nothing', (tester) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'tds'), view: free),
      );
      await tester.pumpAndSettle();

      expect(find.text('That term is not in the dictionary.'), findsOneWidget);
      expect(find.text('Total dissolved solids.'), findsNothing);
    });

    testWidgets('an entry stops at its short explanation', (tester) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'arabica'), view: free),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('The species behind most specialty coffee.'),
        findsOneWidget,
      );
      expect(find.byType(TermFullEntryGate), findsOneWidget);
      expect(
        find.text(TermEntryCopy.fullExplanation.toUpperCase()),
        findsOneWidget,
      );
      // None of the course's content is built, so none of it can be found.
      expect(find.text('Roughly 60% of world coffee.'), findsNothing);
      expect(find.text('IN PRACTICE'), findsNothing);
      expect(find.text('KNOWLEDGE CHECK'), findsNothing);
      expect(find.text('SOURCES'), findsNothing);
      expect(find.text('More caffeine'), findsNothing);
      expect(find.text('https://sca.coffee/research'), findsNothing);
      // What is not course content stays: how to say it, and where it sits.
      expect(find.text('uh-RAB-ih-kuh'), findsOneWidget);
      expect(find.text("Where you'll learn it".toUpperCase()), findsOneWidget);
    });

    testWidgets('a short-only term offers nothing to unlock', (tester) async {
      // Every shipped term carries a full entry today; the model still allows
      // one that does not, and a gate in front of nothing is a lie.
      const brief = DictionaryTerm(
        id: 'bloom',
        term: 'Bloom',
        categoryId: 'beans',
        shortExplanation: 'The puff of gas when water first hits the grounds.',
        lessonId: 'm1l2',
      );
      await tester.pumpWidget(
        _wrap(
          const TermDetailScreen(termId: 'bloom'),
          view: const DictionaryView(
            terms: [brief],
            categories: [_beans],
            completedLessonIds: {},
            hasCourse: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(brief.shortExplanation), findsOneWidget);
      expect(find.byType(TermFullEntryGate), findsNothing);
      expect(find.text(TermEntryCopy.readFullEntry), findsNothing);
    });

    testWidgets('a related reference term is not offered', (tester) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'arabica'), view: free),
      );
      await tester.pumpAndSettle();

      // Arabica relates to TDS; for a free learner that chip would open a
      // term they cannot have, so the block has nothing to draw.
      expect(find.widgetWithText(ActionChip, 'TDS'), findsNothing);
      expect(find.text('RELATED TERMS'), findsNothing);
    });

    testWidgets('reading the full entry raises the gate, not the entry', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'arabica'), view: free),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(TermEntryCopy.readFullEntry));
      await tester.pumpAndSettle();

      expect(find.text(PlusCopy.title), findsOneWidget);
      expect(
        find.text(const LockedFullEntry(term: 'Arabica').header),
        findsOneWidget,
        reason: 'the sheet names the word that was tapped',
      );
      expect(find.text('Roughly 60% of world coffee.'), findsNothing);
    });

    testWidgets('the gated row is one button a screen reader can press', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TermDetailScreen(termId: 'arabica'), view: free),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(TermFullEntryGate));
      expect(semantics.label, TermEntryCopy.gateSemantics);
      expect(semantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('the peek offers the entry without promising it whole', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showTermPeekSheet(context, 'arabica'),
                child: const Text('peek'),
              ),
            ),
          ),
          view: free,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('peek'));
      await tester.pumpAndSettle();

      // The gated row carries the *full entry* promise; the way through to
      // the page says what it is.
      expect(find.byType(TermFullEntryGate), findsOneWidget);
      expect(find.text(TermEntryCopy.openEntry), findsOneWidget);
      expect(find.text(TermEntryCopy.readFullEntry), findsOneWidget);
      expect(find.text('Roughly 60% of world coffee.'), findsNothing);
    });
  });

  group('with the course', () {
    testWidgets('an entry is whole, with nothing to sell', (tester) async {
      await tester.pumpWidget(_wrap(const TermDetailScreen(termId: 'arabica')));
      await tester.pumpAndSettle();

      expect(find.text('Roughly 60% of world coffee.'), findsOneWidget);
      expect(find.text('IN PRACTICE'), findsOneWidget);
      expect(find.text('KNOWLEDGE CHECK'), findsOneWidget);
      expect(find.text('SOURCES'), findsOneWidget);
      expect(find.byType(TermFullEntryGate), findsNothing);
      expect(find.text(TermEntryCopy.readFullEntry), findsNothing);
    });
  });
}
