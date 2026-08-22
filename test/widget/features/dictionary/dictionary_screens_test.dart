import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/dictionary/presentation/term_detail_screen.dart';
import 'package:brew_path/features/dictionary/presentation/term_peek_sheet.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  pronunciation: 'uh-RAB-ih-kuh',
  deepExplanation: 'Roughly 60% of world coffee.',
  example: 'A bag saying 100% Arabica.',
  sources: [DictionarySource(label: 'The World Atlas of Coffee')],
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
  ],
  child: MaterialApp(theme: AppTheme.cupping, home: child),
);

void main() {
  group('dictionary home', () {
    testWidgets('renders each category with its terms', (tester) async {
      await tester.pumpWidget(_wrap(const DictionaryHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Beans and Botany'), findsOneWidget);
      expect(find.text('Coffee Trade'), findsOneWidget);
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
      expect(find.text('IN USE'), findsNothing);
      expect(find.text('CHECK YOURSELF'), findsNothing);
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
      expect(find.text('CHECK YOURSELF'), findsOneWidget);
      expect(find.text('SOURCES'), findsOneWidget);
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
