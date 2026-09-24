import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/dictionary/domain/vocab_destination.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/domain/practice_group.dart';
import 'package:brew_path/features/learn/domain/practice_group_providers.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/widget_harness.dart';

const _miniGames = KeepSharpRecommendation(
  type: PracticeType.miniGames,
  start: OpenPracticeGroup(PracticeGroupKind.games),
);

const _replay = KeepSharpRecommendation(
  type: PracticeType.lessonReplay,
  start: OpenPracticeGroup(PracticeGroupKind.lessons),
);

final _vocab = KeepSharpRecommendation(
  type: PracticeType.vocabGame,
  start: OpenSurface(vocabGame),
);

/// Which practice groups the Start above the list has opened.
Set<PracticeGroupKind> _openGroups(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    ).read(openPracticeGroupsProvider);

/// The design seats him at `size={84}` beside the title and rule.
const double _designRoastySize = 84;

/// Accessibility's largest common step, on a small phone: the rule wraps
/// to several lines and the mascot must not push the text off the card.
const double _largeTextScale = 2;
const double _narrowPhoneWidth = 320;

/// One deterministic acknowledgement phrase.
const _lines = CompanionLines({
  'keepSharpComplete': ['Done for today. Sharp as ever.'],
});

/// Pumps the card inside a real router so the CTA's named navigation can be
/// exercised, with marker screens standing in for the practice surfaces.
Future<void> _pump(
  WidgetTester tester, {
  KeepSharpRecommendation? keepSharp,
  bool acknowledged = false,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.learn.path,
    routes: [
      GoRoute(
        path: AppRoutes.learn.path,
        name: AppRoutes.learn.name,
        builder: (_, _) => Scaffold(
          body: TodayCardWidget(
            today: null,
            keepSharp: keepSharp,
            keepSharpDone: acknowledged,
          ),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.vocabGame.path,
            name: AppRoutes.vocabGame.name,
            builder: (_, _) => const Text('the vocab drill'),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [companionLinesProvider.overrideWith((ref) async => _lines)],
      child: MaterialApp.router(theme: AppTheme.cupping, routerConfig: router),
    ),
  );
  // Fixed pumps rather than pumpAndSettle: the acknowledged state's Roasty
  // animates indefinitely.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  // The CTA asks the free day's allowance before it navigates (#216), so the
  // recommendation's two routing tests read a real database.
  setUp(useInMemoryDatabase);

  testWidgets('the caught-up state recommends and states the rule', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _miniGames);

    expect(find.text('KEEP SHARP'), findsOneWidget);
    expect(find.text('Mini-games'), findsOneWidget);
    expect(find.text('Play two different games today.'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('the dead-end copy is gone', (tester) async {
    await _pump(tester, keepSharp: _miniGames);

    expect(find.text("You're all caught up!"), findsNothing);
    expect(find.text('No lessons left to study.'), findsNothing);
  });

  testWidgets("a drill's CTA navigates to its surface by name", (
    tester,
  ) async {
    await _pump(tester, keepSharp: _vocab);

    await tester.tap(find.text('Start'));
    await settleLoaders(tester);

    expect(find.text('the vocab drill'), findsOneWidget);
    expect(_openGroups(tester), isEmpty);
  });

  testWidgets('the mini-games CTA opens the Games group and goes nowhere', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _miniGames);

    await tester.tap(find.text('Start'));
    // One frame, not a settle: the resting Roasty on the card never settles.
    await tester.pump();

    expect(_openGroups(tester), {PracticeGroupKind.games});
    expect(find.text('Start'), findsOneWidget, reason: 'still on the tab');
  });

  testWidgets('a replay recommendation shows its rule and opens Lessons', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _replay);

    expect(
      find.text("Finish a replay of any lesson you've completed."),
      findsOneWidget,
    );

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(_openGroups(tester), {PracticeGroupKind.lessons});
    expect(find.text('Start'), findsOneWidget, reason: 'still on the tab');
  });

  testWidgets('reduced motion renders the card without animating', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: const Scaffold(
            body: TodayCardWidget(today: null, keepSharp: _miniGames),
          ),
        ),
      ),
    );
    // pump (not pumpAndSettle): a running animation would keep scheduling
    // frames and hang settle; a static card completes in one frame.
    await tester.pump();

    expect(find.text('Mini-games'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the quiet state carries a semantics label too', (tester) async {
    await _pump(tester);

    expect(
      find.bySemanticsLabel(RegExp('Keep Sharp.*no recommendation')),
      findsOneWidget,
    );
  });

  testWidgets('an empty pool degrades to a quiet state with no CTA', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('KEEP SHARP'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a met rule swaps the CTA for Roasty and a phrase', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _miniGames, acknowledged: true);

    expect(find.text('Done for today. Sharp as ever.'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(find.text('Play two different games today.'), findsNothing);
  });

  testWidgets('the acknowledged state carries a semantics label', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _miniGames, acknowledged: true);

    expect(
      find.bySemanticsLabel(RegExp('Keep Sharp complete for today')),
      findsOneWidget,
    );
  });

  testWidgets('acknowledged renders statically under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          companionLinesProvider.overrideWith((ref) async => _lines),
        ],
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: AppTheme.cupping,
            home: const Scaffold(
              body: TodayCardWidget(
                today: null,
                keepSharp: _miniGames,
                keepSharpDone: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Done for today. Sharp as ever.'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the recommendation carries a semantics label', (tester) async {
    await _pump(tester, keepSharp: _miniGames);

    expect(
      find.bySemanticsLabel(RegExp('Keep Sharp.*Mini-games')),
      findsOneWidget,
    );
  });

  testWidgets('the recommendation seats Roasty at rest on his plate', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _miniGames);

    final roasty = tester.widget<Roasty>(find.byType(Roasty));
    expect(roasty.state, RoastyState.idle);
    expect(roasty.plate, isTrue);
    expect(roasty.size, _designRoastySize);
  });

  testWidgets('the resting Roasty is decorative', (tester) async {
    await _pump(tester, keepSharp: _miniGames);

    expect(
      find.ancestor(
        of: find.byType(Roasty),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        "Keep Sharp: today's recommendation is Mini-games. "
        'Play two different games today.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the pick is read once, then the button names it', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, keepSharp: _miniGames);

    expect(find.bySemanticsLabel('KEEP SHARP'), findsNothing);
    expect(find.bySemanticsLabel('Mini-games'), findsNothing);
    expect(find.bySemanticsLabel('Start: Mini-games'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the layout holds when the rule wraps at a large text size', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          textScaler: TextScaler.linear(_largeTextScale),
        ),
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: const Scaffold(
            // Scrolls like the Learn screen does, so only a sideways
            // overflow can fail this.
            body: SingleChildScrollView(
              child: SizedBox(
                width: _narrowPhoneWidth,
                child: TodayCardWidget(today: null, keepSharp: _replay),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Start'), findsOneWidget);
    // The text column gives way; he keeps the design's size.
    expect(tester.getSize(find.byType(Roasty)).width, _designRoastySize);
  });

  testWidgets('the completed state is unchanged: one Roasty, no plate', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _miniGames, acknowledged: true);

    final roasty = tester.widget<Roasty>(find.byType(Roasty));
    expect(roasty.plate, isFalse);
  });
}
