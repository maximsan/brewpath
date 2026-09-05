import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _miniGames = KeepSharpRecommendation(
  type: PracticeType.miniGames,
  destination: miniGameRun('g-quiz'),
);

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
            path: AppRoutes.miniGameIntro.path,
            name: AppRoutes.miniGameIntro.name,
            builder: (_, state) =>
                Text('game ${state.pathParameters['gameId']}'),
          ),
          GoRoute(
            path: AppRoutes.lesson.path,
            name: AppRoutes.lesson.name,
            builder: (_, state) =>
                Text('replay ${state.pathParameters['lessonId']}'),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [companionLinesProvider.overrideWith((ref) async => _lines)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  // Fixed pumps rather than pumpAndSettle: the acknowledged state's Roasty
  // animates indefinitely.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
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

  testWidgets('the CTA navigates to the recommended surface by name', (
    tester,
  ) async {
    await _pump(tester, keepSharp: _miniGames);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('game g-quiz'), findsOneWidget);
  });

  testWidgets('a replay recommendation shows its rule and routes to a replay', (
    tester,
  ) async {
    final replay = KeepSharpRecommendation(
      type: PracticeType.lessonReplay,
      destination: lessonRun('lesson_where_coffee'),
    );
    await _pump(tester, keepSharp: replay);

    expect(
      find.text("Finish a replay of any lesson you've completed."),
      findsOneWidget,
    );

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('replay lesson_where_coffee'), findsOneWidget);
  });

  testWidgets('reduced motion renders the card without animating', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(
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
            home: Scaffold(
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
    final replay = KeepSharpRecommendation(
      type: PracticeType.lessonReplay,
      destination: lessonRun('lesson_where_coffee'),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          textScaler: TextScaler.linear(_largeTextScale),
        ),
        child: MaterialApp(
          home: Scaffold(
            // Scrolls like the Learn screen does, so only a sideways
            // overflow can fail this.
            body: SingleChildScrollView(
              child: SizedBox(
                width: _narrowPhoneWidth,
                child: TodayCardWidget(today: null, keepSharp: replay),
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
