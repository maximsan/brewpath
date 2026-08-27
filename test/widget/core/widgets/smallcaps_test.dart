import 'dart:io';

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design has **one** smallcaps rule — `.smallcaps`: IBM Plex Sans 500 at
/// the ladder's label step, 0.14em, uppercase. `SmallcapsLabel` carries it.
///
/// What this file pins is that nothing carries a second copy of it. A hand-
/// rolled smallcaps is not wrong in a way a screenshot shows loudly; it lands a
/// letter or two off and stays that way, which is exactly the kind of drift a
/// test catches and review does not.
void main() {
  const mood = MoodColors.darkRoast;

  Future<TextStyle> styleOf(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(body: widget),
      ),
    );

    return tester.widget<Text>(find.byType(Text)).style!;
  }

  group('SmallcapsLabel is the rule', () {
    testWidgets('it letters the design’s smallcaps, and uppercases the text', (
      tester,
    ) async {
      final style = await styleOf(tester, const SmallcapsLabel('lower case'));
      final rule = AppText.label(mood: mood);

      expect(find.text('LOWER CASE'), findsOneWidget);
      expect(style.fontFamily, AppFace.control.family);
      expect(style.fontWeight, AppFace.control.weight);
      expect(style.fontSize, rule.fontSize);
      expect(style.letterSpacing, rule.letterSpacing);
      expect(style.color, mood.inkMute);
    });

    testWidgets('a caller may recolour it without restating the rest', (
      tester,
    ) async {
      final style = await styleOf(
        tester,
        SmallcapsLabel('kicker', color: mood.accent),
      );

      expect(style.color, mood.accent);
      expect(style.letterSpacing, AppText.label(mood: mood).letterSpacing);
    });
  });

  group('SectionHeader', () {
    testWidgets('sets its title in the one rule, uppercased', (tester) async {
      final style = await styleOf(
        tester,
        const SectionHeader('Practice a finished lesson'),
      );
      final rule = AppText.label(mood: mood);

      expect(
        find.text('PRACTICE A FINISHED LESSON'),
        findsOneWidget,
        reason:
            'the design sets every section header in smallcaps; this one was '
            'the only heading in the app that was not uppercase at all',
      );
      expect(style.fontFamily, AppFace.control.family);
      expect(style.fontSize, rule.fontSize);
      expect(style.letterSpacing, rule.letterSpacing);
      expect(style.color, mood.inkMute);
    });

    testWidgets('it is the same style SmallcapsLabel gives, not a near miss', (
      tester,
    ) async {
      final header = await styleOf(tester, const SectionHeader('Modules'));
      final label = await styleOf(tester, const SmallcapsLabel('Modules'));

      expect(header, label);
    });
  });

  group('nothing hand-rolls a second copy of the rule', () {
    /// The three the register named (§7.1): the shared section header, the
    /// dictionary entry's block labels, and Settings' group labels.
    const rewritten = <String>[
      'lib/core/widgets/section_header.dart',
      'lib/features/dictionary/presentation/term_entry_body.dart',
      'lib/features/profile/presentation/settings_screen.dart',
    ];

    test('each of the three routes through SmallcapsLabel', () {
      for (final path in rewritten) {
        expect(
          File(path).readAsStringSync(),
          contains('SmallcapsLabel'),
          reason: '$path was one of the three hand-rolled smallcaps',
        );
      }
    });

    test('and none of them letters its own', () {
      final offenders = <String>[];

      for (final path in rewritten) {
        if (File(path).readAsStringSync().contains('letterSpacing:')) {
          offenders.add(path);
        }
      }

      // Tracking, not weight. Weight is a separate sweep (#380) and one of
      // these files still carries a `w600` on an unrelated tile, so asserting
      // on it here would couple this rule to a fault it does not own.
      expect(
        offenders,
        isEmpty,
        reason:
            'tracking belongs to the rule, not to a call site picking a number '
            'that looks about right:\n${offenders.join('\n')}',
      );
    });
  });
}
