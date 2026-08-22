import 'dart:async';

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/streak_screen.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _counting = StreakStatus(
  streak: 12,
  freezeHeld: false,
  daysToNextFreeze: 3,
  freezesSpent: 0,
  frozenDays: {},
);

const _holding = StreakStatus(
  streak: 9,
  freezeHeld: true,
  daysToNextFreeze: null,
  freezesSpent: 0,
  frozenDays: {},
);

Future<void> _pump(
  WidgetTester tester, {
  Future<StreakStatus> Function()? load,
  StreakStatus status = _counting,
  List<StreakDay> weekDays = const [],
  bool disableAnimations = false,
}) async {
  final router = GoRouter(
    initialLocation: '/streak',
    routes: [
      GoRoute(path: '/streak', builder: (_, _) => const StreakScreen()),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        streakStatusProvider.overrideWith(
          (ref) => load != null ? load() : Future.value(status),
        ),
        weekStripDaysProvider.overrideWith((ref) async => weekDays),
      ],
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('renders the hero count and the countdown line', (tester) async {
    await _pump(tester);

    expect(find.text('12'), findsOneWidget);
    expect(find.text('DAY STREAK'), findsOneWidget);
    expect(find.text('Next freeze in 3 days'), findsOneWidget);
  });

  testWidgets('a held freeze reads singular with no countdown', (tester) async {
    await _pump(tester, status: _holding);

    expect(find.text('1 freeze held · covers a missed day'), findsOneWidget);
    expect(find.textContaining('Next freeze'), findsNothing);
  });

  testWidgets('a covered day this week is named on the status line', (
    tester,
  ) async {
    // Today's own day index is always inside the current week, whatever
    // weekday the suite happens to run on.
    final now = DateTime.now();
    final covered = StreakStatus(
      streak: 5,
      freezeHeld: false,
      daysToNextFreeze: 7,
      freezesSpent: 1,
      frozenDays: {epochDay(now)},
    );
    await _pump(tester, status: covered);

    expect(
      find.text(
        '${weekdayNames[now.weekday - DateTime.monday]} '
        'was covered by a freeze',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the week strip renders when its days resolve', (tester) async {
    const monday = 20650;
    await _pump(
      tester,
      weekDays: const [
        StreakDay(day: monday, mark: StreakDayMark.done, isToday: false),
        StreakDay(day: monday + 1, mark: StreakDayMark.frozen, isToday: false),
        StreakDay(day: monday + 2, mark: StreakDayMark.empty, isToday: true),
      ],
    );

    expect(find.byType(WeekStrip), findsOneWidget);
    expect(
      find.bySemanticsLabel('Tuesday, covered by a freeze'),
      findsOneWidget,
    );
  });

  testWidgets('the count carries one spoken phrase', (tester) async {
    await _pump(tester);

    expect(find.bySemanticsLabel('12 day streak'), findsOneWidget);
  });

  testWidgets('reduced motion renders statically', (tester) async {
    await _pump(tester, disableAnimations: true);

    expect(find.text('12'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('loading carries a spoken label', (tester) async {
    final gate = Completer<StreakStatus>();
    await _pump(tester, load: () => gate.future);

    expect(find.bySemanticsLabel('Loading your streak'), findsOneWidget);
    gate.complete(_counting);
    await tester.pump();
  });
}
