import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/freeze_mark.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monday-first fixture week: done Mon–Tue, Wednesday covered by a freeze,
/// done Thursday, today Friday still open, weekend ahead.
const int _monday = 20650;
const List<StreakDay> _week = [
  StreakDay(day: _monday, mark: StreakDayMark.done, isToday: false),
  StreakDay(day: _monday + 1, mark: StreakDayMark.done, isToday: false),
  StreakDay(day: _monday + 2, mark: StreakDayMark.frozen, isToday: false),
  StreakDay(day: _monday + 3, mark: StreakDayMark.done, isToday: false),
  StreakDay(day: _monday + 4, mark: StreakDayMark.empty, isToday: true),
  StreakDay(day: _monday + 5, mark: StreakDayMark.empty, isToday: false),
  StreakDay(day: _monday + 6, mark: StreakDayMark.empty, isToday: false),
];

Future<void> _pump(
  WidgetTester tester, {
  WeekStripSize size = WeekStripSize.large,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: WeekStrip(days: _week, size: size),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('each day speaks its weekday and state', (tester) async {
    await _pump(tester);

    expect(find.bySemanticsLabel('Monday, done'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Wednesday, covered by a freeze'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Saturday, empty'), findsOneWidget);
  });

  testWidgets('today reads as still open, not as empty', (tester) async {
    await _pump(tester);

    expect(find.bySemanticsLabel('Friday, still open'), findsOneWidget);
    expect(find.bySemanticsLabel('Friday, empty'), findsNothing);
  });

  testWidgets('only the covered day carries the freeze mark', (tester) async {
    await _pump(tester);

    expect(find.byType(FreezeMark), findsOneWidget);
  });

  testWidgets('the small variant renders the same seven cells', (
    tester,
  ) async {
    await _pump(tester, size: WeekStripSize.small);

    expect(find.bySemanticsLabel('Monday, done'), findsOneWidget);
    expect(find.byType(FreezeMark), findsOneWidget);
  });

  testWidgets('the strip is static under reduced motion', (tester) async {
    await _pump(tester, disableAnimations: true);

    expect(tester.hasRunningAnimations, isFalse);
  });
}
