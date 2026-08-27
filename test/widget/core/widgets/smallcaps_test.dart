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
/// A hand-rolled smallcaps is not wrong in a way a screenshot shows loudly; it
/// lands a letter or two off and stays that way, which is the kind of drift a
/// test catches and review does not.
void main() {
  const mood = MoodColors.darkRoast;

  Future<Widget> pump(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(body: widget),
      ),
    );

    return widget;
  }

  TextStyle rendered(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text)).style!;

  group('SmallcapsLabel is the rule', () {
    testWidgets('it letters the ladder’s label step and uppercases the text', (
      tester,
    ) async {
      await pump(tester, const SmallcapsLabel('lower case'));

      expect(find.text('LOWER CASE'), findsOneWidget);
      expect(rendered(tester), AppText.label(mood: mood));
    });

    testWidgets('it is announced as written, not as it is lettered', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const SmallcapsLabel('Beans and Botany'));

      // Uppercase is the type rule, not what the label says. Announced as
      // rendered, a short one like `TDS` invites being spelled out.
      expect(find.bySemanticsLabel('Beans and Botany'), findsOneWidget);
      expect(find.bySemanticsLabel('BEANS AND BOTANY'), findsNothing);

      handle.dispose();
    });

    testWidgets('a caller may recolour it without restating the rest', (
      tester,
    ) async {
      await pump(tester, SmallcapsLabel('kicker', color: mood.accent));

      expect(rendered(tester), AppText.label(mood: mood, color: mood.accent));
    });
  });

  group('SectionHeader', () {
    testWidgets('sets its title in the one rule, uppercased', (tester) async {
      await pump(tester, const SectionHeader('Practice a finished lesson'));

      expect(
        find.text('PRACTICE A FINISHED LESSON'),
        findsOneWidget,
        reason:
            'the design sets every section header in smallcaps; this one was '
            'the only heading in the app that was not uppercase at all',
      );
      expect(rendered(tester), AppText.label(mood: mood));
    });

    testWidgets('it offers itself as a heading to assistive technology', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const SectionHeader('Modules'));

      expect(
        tester.getSemantics(find.byType(SectionHeader)),
        matchesSemantics(label: 'Modules', isHeader: true),
      );

      handle.dispose();
    });
  });
}
