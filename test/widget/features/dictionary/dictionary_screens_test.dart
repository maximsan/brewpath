import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/dictionary/presentation/status_chip.dart';
import 'package:brew_path/features/dictionary/presentation/term_detail_screen.dart';
import 'package:brew_path/features/dictionary/presentation/term_peek_sheet.dart';
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

DictionaryView _view({Set<String> completed = const {}}) => DictionaryView(
  terms: const [_full, _stub],
  categories: const [_beans, _trade],
  completedLessonIds: completed,
);

Widget _wrap(Widget child, {DictionaryView? view}) => ProviderScope(
  overrides: [
    dictionaryViewProvider.overrideWith((ref) async => view ?? _view()),
    lessonTitleProvider(
      'm1l2',
    ).overrideWith((ref) async => 'Arabica vs Robusta'),
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
      expect(find.text('REFERENCE'), findsOneWidget);
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

    testWidgets('renders each category with its terms', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      // The category names head sections, so they are smallcaps; the terms
      // under them are not.
      expect(find.text('BEANS AND BOTANY'), findsOneWidget);
      expect(find.text('COFFEE TRADE'), findsOneWidget);
      expect(find.text('Arabica'), findsOneWidget);
      expect(find.text('TDS'), findsOneWidget);
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
}
