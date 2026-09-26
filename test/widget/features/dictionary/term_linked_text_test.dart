// Glossary terms in lesson copy, drawn as links to the peek sheet (#99).
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/term_linked_text.dart';
import 'package:brew_path/features/dictionary/presentation/term_peek_sheet.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/predict_card_view.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _brewing = DictionaryCategory(
  id: 'brewing',
  label: 'Brewing',
  glyph: 'dripper',
  summary: 'Water, grounds, time.',
);

const _bloom = DictionaryTerm(
  id: 'bloom',
  term: 'Bloom',
  categoryId: 'brewing',
  shortExplanation: 'The rise when water first wets fresh grounds.',
  lessonId: 'm1l1',
);

const _crema = DictionaryTerm(
  id: 'crema',
  term: 'Crema',
  categoryId: 'brewing',
  shortExplanation: 'The foam an espresso pulls with.',
  lessonId: 'm1l1',
);

const _concept = ConceptCard(
  label: 'CONCEPT',
  title: 'What fresh grounds do',
  fill: [
    FillLiteral('Fresh grounds give off '),
    FillBlank(answer: 'gas', options: ['gas', 'oil'], label: 'What escapes'),
    FillLiteral('.'),
  ],
  paragraphs: [
    'Wet the bed and it swells — a bloom you can watch.',
    'Stale grounds barely move, so the crema is thin too.',
  ],
  meta: [],
);

const _predict = PredictCard(
  label: 'LESSON 1',
  title: 'Does a fresh bag behave?',
  body: 'Pour on fresh grounds and the bed lifts into a bloom.',
  question: 'The rise is called the ___.',
  options: ['Bloom', 'Crema'],
  answer: 'Bloom',
  hold: 'Hold that thought about the crema.',
);

DictionaryView _view({List<DictionaryTerm> terms = const [_bloom, _crema]}) =>
    DictionaryView(
      terms: terms,
      categories: const [_brewing],
      completedLessonIds: const {},
      hasCourse: true,
    );

Widget _host(Widget child, {DictionaryView? view}) => ProviderScope(
  overrides: [
    dictionaryViewProvider.overrideWith((ref) async => view ?? _view()),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.cupping,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

/// Every span in the tree that is drawn as a link.
List<TextSpan> _links(WidgetTester tester) {
  final spans = <TextSpan>[];
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    text.textSpan?.visitChildren((span) {
      if (span is TextSpan && span.recognizer != null) spans.add(span);
      return true;
    });
  }
  return spans;
}

/// The words each link shows.
List<String?> _linked(WidgetTester tester) => [
  for (final span in _links(tester)) span.text,
];

void main() {
  group('a concept card', () {
    testWidgets('links a term in its prose and opens the peek sheet on it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(ConceptCardView(card: _concept, onContinue: () {})),
      );
      await tester.pumpAndSettle();

      expect(_linked(tester), ['bloom']);

      await tester.tapOnText(find.textRange.ofSubstring('bloom'));
      await tester.pumpAndSettle();

      expect(find.byType(TermPeekSheet), findsOneWidget);
      expect(
        find.text('The rise when water first wets fresh grounds.'),
        findsOneWidget,
      );
    });

    testWidgets('leaves the card’s own tap targets working', (
      tester,
    ) async {
      var continued = 0;
      await tester.pumpWidget(
        _host(ConceptCardView(card: _concept, onContinue: () => continued++)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('gas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));

      expect(continued, 1);
    });

    testWidgets('links the verdict block’s explanation once checked', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(ConceptCardView(card: _concept, onContinue: () {})),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('gas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();

      expect(_linked(tester), ['crema', 'bloom']);
    });

    testWidgets('links no term the learner’s own view does not hold', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ConceptCardView(card: _concept, onContinue: () {}),
          view: _view(terms: const [_crema]),
        ),
      );
      await tester.pumpAndSettle();

      expect(_linked(tester), isEmpty);
    });
  });

  group('a predict card', () {
    testWidgets('links a term in its body and nowhere else on the card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PredictCardView(
            card: _predict,
            options: _predict.options,
            onContinue: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_linked(tester), ['bloom']);
    });

    testWidgets('leaves the guess it holds plain — nothing is graded there', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PredictCardView(
            card: _predict,
            options: _predict.options,
            onContinue: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bloom'));
      // Not `pumpAndSettle`: the block brings Roasty, who idles forever.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(_predict.hold), findsOneWidget);
      expect(_linked(tester), ['bloom']);
    });
  });

  group('a link', () {
    testWidgets('wears the accent, weight 500 and a dotted rule', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const TermLinkedText(text: 'Watch the bloom rise.')),
      );
      await tester.pumpAndSettle();

      final style = _links(tester).single.style;

      expect(style?.color, MoodColors.cupping.accent);
      expect(style?.fontWeight, FontWeight.w500);
      expect(style?.decoration, TextDecoration.underline);
      expect(style?.decorationStyle, TextDecorationStyle.dotted);
      expect(
        style?.decorationColor,
        MoodColors.cupping.accent.withValues(alpha: 0.6),
      );
    });

    testWidgets('is announced as a link named by the words on the page', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const TermLinkedText(text: 'Watch the bloom rise.')),
      );
      await tester.pumpAndSettle();

      expect(
        find.semantics.byLabel('bloom'),
        isSemantics(label: 'bloom', isLink: true, hasTapAction: true),
      );
      handle.dispose();
    });
  });

  group('a term entry', () {
    testWidgets('does not link inside its own self-check', (tester) async {
      await tester.pumpWidget(
        _host(
          const AnswerFeedback(
            verdict: 'Not quite',
            outcome: Verdict.wrong,
            explanation: 'The bloom is the rise, not the crema.',
            placement: VerdictPlacement.reference,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_linked(tester), isEmpty);
    });
  });
}
