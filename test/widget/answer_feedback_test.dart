import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The verdict block that closes every graded surface (#390).
///
/// The five copies it replaced had already drifted on type step and on
/// wrong-state colour, which is the failure one component exists to make
/// impossible — so these assert the things that drifted, not only that it
/// renders.
Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.cupping,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: child),
  ),
);

/// The mood the host paints in, so a test can name the colours it expects.
const MoodColors _mood = MoodColors.cupping;

/// Whether [verdict] is spoken when it appears, rather than only drawn.
bool _announces(WidgetTester tester, String verdict) => tester
    .widgetList<Semantics>(find.byType(Semantics))
    .where((node) => node.properties.label == verdict)
    .any((node) => node.properties.liveRegion ?? false);

Color? _verdictColour(WidgetTester tester, String rendered) =>
    tester.widget<Text>(find.text(rendered)).style?.color;

void main() {
  group('a right verdict', () {
    testWidgets('leads in sage, with the mascot taking the good news', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const AnswerFeedback(
            verdict: 'ALL CORRECT',
            outcome: Verdict.right,
            explanation: 'Grind, temperature and time are the three.',
          ),
        ),
      );

      expect(_verdictColour(tester, 'ALL CORRECT'), _mood.sage);
      expect(
        tester.widget<Roasty>(find.byType(Roasty)).state,
        RoastyState.correct,
      );
      expect(
        find.text('Grind, temperature and time are the three.'),
        findsOneWidget,
      );
    });
  });

  group('a wrong verdict', () {
    testWidgets('leads in berry, with the mascot taking the bad news', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const AnswerFeedback(
            verdict: 'NOT QUITE',
            outcome: Verdict.wrong,
            explanation: 'Puckering with no weight behind it is thin.',
          ),
        ),
      );

      expect(_verdictColour(tester, 'NOT QUITE'), _mood.berry);
      expect(
        tester.widget<Roasty>(find.byType(Roasty)).state,
        RoastyState.wrong,
      );
    });

    testWidgets('tones to accent on a term entry, not to the lesson berry', (
      tester,
    ) async {
      // A look-up that answers back in the colour the lesson player spends on
      // a wrong answer reads as a worse failure than missing a self-check is.
      await tester.pumpWidget(
        _host(
          const AnswerFeedback.reference(
            verdict: 'NOT QUITE',
            outcome: Verdict.wrong,
            explanation: 'Burrs crush; blades chop.',
          ),
        ),
      );

      expect(_verdictColour(tester, 'NOT QUITE'), _mood.accent);
      expect(_verdictColour(tester, 'NOT QUITE'), isNot(_mood.berry));
    });
  });

  testWidgets('the verdict is announced, not only drawn', (tester) async {
    // It arrives on commit with no focus change to bring a reader to it, so
    // without a live region a learner using one hears every option's mark and
    // never the outcome.
    await tester.pumpWidget(
      _host(
        const AnswerFeedback(verdict: 'CLEAN BOARD', outcome: Verdict.right),
      ),
    );

    expect(_announces(tester, 'CLEAN BOARD'), isTrue);
  });

  testWidgets('renders uppercase but is announced as written', (tester) async {
    // The case is the design's treatment of the line rather than part of what
    // it says, so assistive technology is given the string as authored.
    await tester.pumpWidget(
      _host(
        const AnswerFeedback(verdict: 'Good call', outcome: Verdict.right),
      ),
    );

    expect(find.text('GOOD CALL'), findsOneWidget);
    expect(_announces(tester, 'Good call'), isTrue);
  });

  testWidgets('carries what a surface adds under the explanation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AnswerFeedback(
          verdict: 'IN ORDER',
          outcome: Verdict.right,
          explanation: 'Nailed the sequence.',
          extra: Text('Rinse → Bloom → Pour'),
        ),
      ),
    );

    expect(find.text('Rinse → Bloom → Pour'), findsOneWidget);
  });

  testWidgets('holds a single frame under reduced motion', (tester) async {
    await tester.pumpWidget(
      _host(
        const AnswerFeedback(verdict: 'NOT QUITE', outcome: Verdict.wrong),
        reduceMotion: true,
      ),
    );

    // No pumpAndSettle: a mascot still animating would never settle, and that
    // is the whole of what reduced motion has to prevent here.
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.byType(Roasty), findsOneWidget);
  });
}
