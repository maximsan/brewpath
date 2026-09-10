import 'package:brew_path/core/config/support_contact_provider.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/monetization/domain/foundations_faq_tail.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/profile/presentation/settings/help_faq_row.dart';
import 'package:brew_path/features/profile/presentation/settings/help_support_screen.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:brew_path/services/links/link_opener.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// Section headings render uppercase, so they are found by what they were
/// given rather than by what they draw.
Finder _section(String label) => find.byWidgetPredicate(
  (widget) => widget is SmallcapsLabel && widget.text == label,
);

/// Records what a row asked the platform to open.
class _RecordingOpener implements LinkOpener {
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri target) async {
    opened.add(target);
    return true;
  }
}

const _pitch = PlusPitch(
  remainingLessons: 29,
  lockedGames: 4,
  referenceTerms: 8,
  savedFreeCap: 5,
);

void main() {
  setUp(useInMemoryDatabase);

  late _RecordingOpener opener;

  setUp(() => opener = _RecordingOpener());

  Future<void> pump(WidgetTester tester, {String? mailbox}) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plusPitchProvider.overrideWith((ref) async => _pitch),
          miniGameFormatsProvider.overrideWith((ref) async => []),
          foundationsFaqTailProvider.overrideWith(
            (ref) async => 'Nothing renews.',
          ),
          supportMailboxProvider.overrideWithValue(mailbox),
          linkOpenerProvider.overrideWithValue(opener),
        ],
        child: const MaterialApp(home: HelpSupportScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpPending(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HelpSupportScreen())),
    );
    await tester.pump();
  }

  testWidgets('files the App Guide, which is the row it already had', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text(AppGuideCopy.title), findsOneWidget);
    expect(_section(SettingsCopy.learnTheAppSection), findsOneWidget);
  });

  testWidgets('asks the design four questions', (tester) async {
    await pump(tester);

    expect(find.byType(HelpFaqRow), findsNWidgets(4));
  });

  testWidgets('opens an answer on the row that was tapped', (tester) async {
    await pump(tester);

    final first = tester.widget<HelpFaqRow>(find.byType(HelpFaqRow).first);
    expect(find.text(first.entry.answer!), findsNothing);

    await tester.tap(find.text(first.entry.question));
    await tester.pumpAndSettle();

    expect(find.text(first.entry.answer!), findsOneWidget);
  });

  testWidgets('holds one answer open at a time', (tester) async {
    await pump(tester);

    final rows = tester
        .widgetList<HelpFaqRow>(find.byType(HelpFaqRow))
        .toList();

    await tester.tap(find.text(rows[0].entry.question));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rows[1].entry.question));
    await tester.pumpAndSettle();

    expect(find.text(rows[0].entry.answer!), findsNothing);
    expect(find.text(rows[1].entry.answer!), findsOneWidget);
  });

  testWidgets('a second tap closes the row it opened', (tester) async {
    await pump(tester);

    final first = tester.widget<HelpFaqRow>(find.byType(HelpFaqRow).first);

    await tester.tap(find.text(first.entry.question));
    await tester.pumpAndSettle();
    await tester.tap(find.text(first.entry.question));
    await tester.pumpAndSettle();

    expect(find.text(first.entry.answer!), findsNothing);
  });

  testWidgets('every row announces itself as an expander', (tester) async {
    await pump(tester);

    final semantics = tester.getSemantics(find.byType(HelpFaqRow).first);

    expect(semantics.flagsCollection.isButton, isTrue);
    expect(
      semantics.flagsCollection.isExpanded.toBoolOrNull(),
      isFalse,
      reason: 'a closed row still announces that it can open',
    );
  });

  testWidgets('promises no reply time, because nobody can', (tester) async {
    await pump(tester);

    expect(find.textContaining('within a day'), findsNothing);
    expect(find.textContaining('usually faster'), findsNothing);
  });

  testWidgets('draws no contact row while there is no mailbox', (tester) async {
    // A row that looks live and does nothing is the failure #531 rules
    // against, so the section is absent rather than inert.
    await pump(tester);

    expect(_section(SettingsCopy.getInTouchSection), findsNothing);
    expect(find.text(SettingsCopy.emailSupportRow), findsNothing);
    expect(find.text(SettingsCopy.reportProblemRow), findsNothing);
  });

  testWidgets('no row on the screen is drawn live and inert', (tester) async {
    await pump(tester);

    for (final row in tester.widgetList<SettingsNavRow>(
      find.byType(SettingsNavRow),
    )) {
      expect(row.onTap, isNotNull, reason: row.label);
    }
  });

  group('once the mailbox exists', () {
    testWidgets('both rows are drawn, and the address is shown', (
      tester,
    ) async {
      await pump(tester, mailbox: 'hi@brewpath.app');

      expect(_section(SettingsCopy.getInTouchSection), findsOneWidget);
      expect(find.text('hi@brewpath.app'), findsOneWidget);
      expect(find.text(SettingsCopy.reportProblemRow), findsOneWidget);
    });

    testWidgets('Email support opens a composer to it', (tester) async {
      await pump(tester, mailbox: 'hi@brewpath.app');

      await tester.tap(find.text(SettingsCopy.emailSupportRow));
      await tester.pumpAndSettle();

      expect(opener.opened.single.scheme, 'mailto');
      expect(opener.opened.single.path, 'hi@brewpath.app');
    });

    testWidgets('Report a problem carries the build in its subject', (
      tester,
    ) async {
      await pump(tester, mailbox: 'hi@brewpath.app');

      await tester.tap(find.text(SettingsCopy.reportProblemRow));
      await tester.pumpAndSettle();

      expect(opener.opened.single.path, 'hi@brewpath.app');
      expect(
        opener.opened.single.queryParameters['subject'],
        isNotEmpty,
        reason: 'a report that cannot name its build cannot be matched to one',
      );
    });
  });

  testWidgets('draws the questions before their counts arrive', (tester) async {
    await pumpPending(tester);

    expect(
      find.byType(HelpFaqRow),
      findsNWidgets(4),
      reason: 'only one answer is counted; the questions never wait on it',
    );
  });

  testWidgets('the counted answer says so while it is being counted', (
    tester,
  ) async {
    await pumpPending(tester);

    final foundations = tester
        .widgetList<HelpFaqRow>(find.byType(HelpFaqRow))
        .firstWhere((row) => row.entry.question.contains('Foundations'));
    expect(foundations.entry.answer, isNull);

    await tester.tap(find.text(foundations.entry.question));
    await tester.pump();

    expect(find.text(SettingsCopy.faqCounting), findsOneWidget);
  });

  testWidgets('the answers carry the counts the banks gave', (tester) async {
    await pump(tester);

    final foundations = tester
        .widgetList<HelpFaqRow>(find.byType(HelpFaqRow))
        .firstWhere((row) => row.entry.question.contains('Foundations'));

    await tester.tap(find.text(foundations.entry.question));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('${_pitch.remainingLessons}'),
      findsOneWidget,
      reason: 'the count is read off the shipped banks, never typed',
    );
  });
}
