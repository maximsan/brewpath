import 'dart:async';

import 'package:flutter/semantics.dart';

import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/monetization/domain/foundations_faq_tail.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/profile/domain/help_faq.dart';
import 'package:brew_path/features/profile/domain/help_faq_provider.dart';
import 'package:brew_path/features/profile/presentation/settings/help_faq_row.dart';
import 'package:brew_path/features/profile/presentation/settings/help_support_screen.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// Section headings render uppercase, so they are found by what they were
/// given rather than by what they draw.
Finder _section(String label) => find.byWidgetPredicate(
  (widget) => widget is SmallcapsLabel && widget.text == label,
);

const _pitch = PlusPitch(
  remainingLessons: 29,
  lockedGames: 4,
  referenceTerms: 8,
  savedFreeCap: 5,
);

void main() {
  setUp(useInMemoryDatabase);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plusPitchProvider.overrideWith((ref) async => _pitch),
          foundationsFaqTailProvider.overrideWith(
            (ref) async => 'Nothing renews.',
          ),
        ],
        child: const MaterialApp(home: HelpSupportScreen()),
      ),
    );
    await tester.pumpAndSettle();
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
    expect(find.text(first.entry.answer), findsNothing);

    await tester.tap(find.text(first.entry.question));
    await tester.pumpAndSettle();

    expect(find.text(first.entry.answer), findsOneWidget);
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

    expect(find.text(rows[0].entry.answer), findsNothing);
    expect(find.text(rows[1].entry.answer), findsOneWidget);
  });

  testWidgets('a second tap closes the row it opened', (tester) async {
    await pump(tester);

    final first = tester.widget<HelpFaqRow>(find.byType(HelpFaqRow).first);

    await tester.tap(find.text(first.entry.question));
    await tester.pumpAndSettle();
    await tester.tap(find.text(first.entry.question));
    await tester.pumpAndSettle();

    expect(find.text(first.entry.answer), findsNothing);
  });

  testWidgets('every row announces itself as an expander', (tester) async {
    await pump(tester);

    final semantics = tester.getSemantics(find.byType(HelpFaqRow).first);

    expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(semantics.hasFlag(SemanticsFlag.hasExpandedState), isTrue);
  });

  testWidgets('promises no reply time, because nobody can', (tester) async {
    await pump(tester);

    expect(find.textContaining('within a day'), findsNothing);
    expect(find.textContaining('usually faster'), findsNothing);
  });

  testWidgets('draws no contact row while there is no mailbox', (tester) async {
    // `supportEmail` is null until the owner creates it, and a row that looks
    // live and does nothing is the failure #531 rules against.
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

  testWidgets('shows the questions before their counts arrive', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plusPitchProvider.overrideWith(
            (ref) => Completer<PlusPitch>().future,
          ),
        ],
        child: const MaterialApp(home: HelpSupportScreen()),
      ),
    );
    await tester.pump();

    expect(_section(SettingsCopy.commonQuestionsSection), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
