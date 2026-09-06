import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/shared/theme/app_text.dart';
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
            verdict: 'All correct',
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
            verdict: 'Not quite',
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
          const AnswerFeedback(
            verdict: 'Not quite',
            outcome: Verdict.wrong,
            explanation: 'Burrs crush; blades chop.',
            placement: VerdictPlacement.reference,
          ),
        ),
      );

      expect(_verdictColour(tester, 'NOT QUITE'), _mood.accent);
      expect(_verdictColour(tester, 'NOT QUITE'), isNot(_mood.berry));
    });
  });

  group('a held guess', () {
    testWidgets('leads in ink-mute — nothing has been graded yet', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const AnswerFeedback(
            verdict: 'Your guess · Seed',
            outcome: Verdict.held,
            explanation: 'Hold that thought.',
            placement: VerdictPlacement.heldGuess,
          ),
        ),
      );
      await tester.pump();

      expect(_verdictColour(tester, 'YOUR GUESS · SEED'), _mood.inkMute);
      expect(_verdictColour(tester, 'YOUR GUESS · SEED'), isNot(_mood.sage));
      expect(_verdictColour(tester, 'YOUR GUESS · SEED'), isNot(_mood.berry));
    });

    testWidgets('puts the mascot at the card face, holding it', (tester) async {
      await tester.pumpWidget(
        _host(
          const AnswerFeedback(
            verdict: 'Your guess · Seed',
            outcome: Verdict.held,
            placement: VerdictPlacement.heldGuess,
          ),
        ),
      );
      await tester.pump();

      final roasty = tester.widget<Roasty>(find.byType(Roasty));
      expect(roasty.state, RoastyState.card);
      // The design draws him smaller here than on a graded card.
      expect(roasty.size, lessThan(VerdictPlacement.card.mascot));
    });

    testWidgets('sets the hold at the body step, as the design does', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const AnswerFeedback(
            verdict: 'Your guess · Seed',
            outcome: Verdict.held,
            explanation: 'Hold that thought.',
            placement: VerdictPlacement.heldGuess,
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.widget<Text>(find.text('Hold that thought.')).style?.fontSize,
        AppText.body(mood: _mood).fontSize,
      );
    });
  });

  testWidgets('the explanation stays muted at either step', (tester) async {
    // The step says how much room the explanation takes, never how loudly it
    // speaks: the design colours this text ink-mute whichever size it is set
    // at, and `AppText.body` defaults to full ink.
    for (final placement in VerdictPlacement.values) {
      await tester.pumpWidget(
        _host(
          AnswerFeedback(
            verdict: 'Not quite',
            outcome: Verdict.wrong,
            explanation: 'Burrs crush; blades chop.',
            placement: placement,
          ),
        ),
      );
      await tester.pump();

      expect(
        tester
            .widget<Text>(find.text('Burrs crush; blades chop.'))
            .style
            ?.color,
        _mood.inkMute,
        reason: "$placement sets the explanation off the design's ink-mute",
      );
    }
  });

  testWidgets('the verdict is announced, not only drawn', (tester) async {
    // It arrives on commit with no focus change to bring a reader to it, so
    // without a live region a learner using one hears every option's mark and
    // never the outcome.
    await tester.pumpWidget(
      _host(
        const AnswerFeedback(verdict: 'Clean board', outcome: Verdict.right),
      ),
    );

    expect(_announces(tester, 'Clean board'), isTrue);
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
          verdict: 'In order',
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
        const AnswerFeedback(verdict: 'Not quite', outcome: Verdict.wrong),
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
