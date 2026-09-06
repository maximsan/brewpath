import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:brew_path/core/constants/app_links.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_milestone_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/streak_ring.dart';
import 'package:brew_path/features/progress/presentation/streak_screen.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:brew_path/services/share/share_presenter.dart';
import 'package:brew_path/services/share/share_provider.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import '../support/widget_harness.dart';

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

/// Three days into the second week, with the freeze cadence still running —
/// the fixture the wrap is read off (#498).
const _secondWeek = StreakStatus(
  streak: 10,
  freezeHeld: false,
  daysToNextFreeze: 4,
  freezesSpent: 0,
  frozenDays: {},
);

/// The day after a closing day: the fill starts over at one seventh.
const _weekReopened = StreakStatus(
  streak: 8,
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
  bool milestoneDue = false,
  SharePresenter? presenter,
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
        streakMilestoneDueProvider.overrideWith((ref) async => milestoneDue),
        if (presenter != null)
          sharePresenterProvider.overrideWithValue(presenter),
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

/// A milestone-day fixture: seven in a row, the freeze just earned.
const _milestoneDay = StreakStatus(
  streak: 7,
  freezeHeld: true,
  daysToNextFreeze: null,
  freezesSpent: 0,
  frozenDays: {},
);

/// Bounded real-IO steps: the ack write and the companion's asset load are
/// real async under the test binding.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Records what the screen hands the share seam.
class _RecordingSharePresenter implements SharePresenter {
  Uint8List? bytes;
  String? fileName;
  String? link;

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    String? link,
  }) async {
    this.bytes = bytes;
    this.fileName = fileName;
    this.link = link;
  }
}

void main() {
  setUp(useInMemoryDatabase);

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

  testWidgets('the ring fills over the week, and says so nowhere else', (
    tester,
  ) async {
    // The fill measures the week; the caption that described a badge is gone
    // (#498). The freeze line stays — it is the screen's one number.
    await _pump(tester);

    expect(
      tester.widget<StreakRing>(find.byType(StreakRing)).fraction,
      5 / 7,
      reason: "the design's own example: 5 days on a 12-day streak",
    );
    expect(find.textContaining('badge'), findsNothing);
    expect(find.text('Next freeze in 3 days'), findsOneWidget);
  });

  testWidgets('only the fill wraps — the count and the cadence do not', (
    tester,
  ) async {
    // Day 10: the ring starts the second week over at 3/7 while the centre
    // still reads the whole streak and the freeze countdown keeps running.
    await _pump(tester, status: _secondWeek);

    expect(tester.widget<StreakRing>(find.byType(StreakRing)).fraction, 3 / 7);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('DAY STREAK'), findsOneWidget);
    expect(find.text('Next freeze in 4 days'), findsOneWidget);
  });

  testWidgets('the seventh day closes the ring', (tester) async {
    await _pump(tester, status: _milestoneDay);

    expect(tester.widget<StreakRing>(find.byType(StreakRing)).fraction, 1);
  });

  testWidgets('the eighth day starts the ring over', (tester) async {
    await _pump(tester, status: _weekReopened);

    expect(tester.widget<StreakRing>(find.byType(StreakRing)).fraction, 1 / 7);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('a milestone day opens on the beat', (tester) async {
    await _pump(tester, status: _milestoneDay, milestoneDue: true);
    await _settle(tester);

    expect(find.text('7 days in a row.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('DAY STREAK'), findsNothing);
  });

  testWidgets('presenting the beat writes the acknowledgement', (
    tester,
  ) async {
    await _pump(tester, status: _milestoneDay, milestoneDue: true);
    await _settle(tester);

    final stored = await SnapshotRepository().read();
    expect(stored.clearedByReset.acks, contains(milestoneAckKey));
  });

  testWidgets('Continue lands on the streak view', (tester) async {
    await _pump(tester, status: _milestoneDay, milestoneDue: true);
    await _settle(tester);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('DAY STREAK'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('reduced motion skips the beat and still acknowledges', (
    tester,
  ) async {
    await _pump(
      tester,
      status: _milestoneDay,
      milestoneDue: true,
      disableAnimations: true,
    );
    await _settle(tester);

    expect(find.text('DAY STREAK'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    final stored = await SnapshotRepository().read();
    expect(stored.clearedByReset.acks, contains(milestoneAckKey));
  });

  testWidgets('Share renders the fixed-size card into the presenter', (
    tester,
  ) async {
    final presenter = _RecordingSharePresenter();
    await _pump(tester, presenter: presenter);

    await tester.tap(find.text('Share your streak'));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      if (presenter.bytes != null) break;
    }

    expect(presenter.fileName, 'brewpath-streak.png');
    // A streak is a number about one person on one day, so the card carries
    // the site rather than an address of its own (#34).
    expect(presenter.link, AppLinks.site);
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(presenter.bytes!);
      return (await codec.getNextFrame()).image;
    });
    // The export lands at 1080 px wide regardless of the device the test
    // pretends to be — the whole point of off-screen composition (#26).
    expect(image!.width, 1080);
    expect(image.height, 1080);
  });

  testWidgets('loading carries a spoken label', (tester) async {
    final gate = Completer<StreakStatus>();
    await _pump(tester, load: () => gate.future);

    expect(find.bySemanticsLabel('Loading your streak'), findsOneWidget);
    gate.complete(_counting);
    await tester.pump();
  });
}
