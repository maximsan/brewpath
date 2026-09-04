import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_save_notice.dart';
import 'package:brew_path/features/progress/presentation/freeze_save_notice_card.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

/// The day the whole test runs on. Pinned, and handed to the card through
/// [currentDayProvider], so seeding and deriving agree on what "yesterday" is
/// even when the suite runs across midnight — which once made this test fail.
final DateTime _today = DateTime(2026, 9, 4);

/// Seeds a real seven-day run ending the day before yesterday, so the engine
/// derives an earned freeze spent on yesterday: the exact state the notice
/// exists for. Only the day is overridden — the card is exercised against the
/// same derivation chain the app ships.
Future<void> seedCoveredYesterday() async {
  final repo = SnapshotRepository();
  final today = epochDay(_today);
  final snapshot = await repo.read();
  var progress = snapshot.clearedByReset;
  const runLength = 7;
  for (var offset = 0; offset < runLength; offset++) {
    final day = today - 2 - offset;
    progress = progress.withActivity(day, 'lesson:seed$offset', marksDay: true);
  }
  await repo.write(snapshot.copyWith(clearedByReset: progress));
}

Future<void> pumpCard(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [currentDayProvider.overrideWithValue(_today)],
      child: const MaterialApp(
        home: Scaffold(body: FreezeSaveNoticeCard()),
      ),
    ),
  );
  // The card reads real IO (drift, the snapshot); bounded runAsync steps let
  // it land under the test binding.
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (find.text(freezeSaveNoticeTitle).evaluate().isNotEmpty) break;
  }
}

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('a freeze spent yesterday shows the notice', (tester) async {
    await seedCoveredYesterday();
    await pumpCard(tester);

    expect(find.text(freezeSaveNoticeTitle), findsOneWidget);
    expect(
      find.text(
        "Yesterday was covered by a freeze. You'll earn another in 7 days.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('dismissing writes the acknowledgement and clears the card', (
    tester,
  ) async {
    await seedCoveredYesterday();
    await pumpCard(tester);

    await tester.tap(find.byTooltip('Dismiss'));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      if (find.text(freezeSaveNoticeTitle).evaluate().isEmpty) break;
    }

    expect(find.text(freezeSaveNoticeTitle), findsNothing);
    final stored = await SnapshotRepository().read();
    expect(
      stored.clearedByReset.acks[freezeSaveAckKey],
      epochDay(_today) - 1,
    );
  });

  testWidgets('nothing due renders nothing', (tester) async {
    await pumpCard(tester);

    expect(find.text(freezeSaveNoticeTitle), findsNothing);
  });

  testWidgets('the notice carries one spoken phrase', (tester) async {
    await seedCoveredYesterday();
    await pumpCard(tester);

    expect(
      find.bySemanticsLabel(
        RegExp('Your streak is safe. Yesterday was covered'),
      ),
      findsOneWidget,
    );
  });
}
