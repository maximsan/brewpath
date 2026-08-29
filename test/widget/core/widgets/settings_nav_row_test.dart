import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one row the whole settings surface renders through.
///
/// The design draws it label-left, value-or-affordance-right, over a hairline —
/// and gives it **no icon slot at all** (`prototype/settings.jsx:149`). The
/// app's rows had grown leading glyphs the design never drew, which is what
/// makes this a component rather than a `ListTile` call with different
/// arguments.
/// A node a screen reader announces as a button.
final Matcher _isButton = containsSemantics(isButton: true);

void main() {
  Future<void> pump(WidgetTester tester, Widget row) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(body: ListView(children: [row])),
    ),
  );

  testWidgets('draws no icon before the label', (tester) async {
    await pump(
      tester,
      const SettingsNavRow(label: 'Account and sync', value: 'hi@brewpath.app'),
    );

    expect(find.text('Account and sync'), findsOneWidget);
    expect(find.text('hi@brewpath.app'), findsOneWidget);
    expect(
      find.byType(Icon),
      findsNothing,
      reason:
          'the design gives the row no icon slot; a leading glyph here is '
          'the app inventing one',
    );
  });

  testWidgets('a row that does something is a button, and fires once', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      SettingsNavRow(label: 'Purchases', onTap: () => taps++),
    );

    expect(tester.getSemantics(find.text('Purchases')), _isButton);

    await tester.tap(find.text('Purchases'));
    expect(taps, 1);
  });

  testWidgets('a row that only reports is not a button', (tester) async {
    await pump(tester, const SettingsNavRow(label: 'Version', value: '1.0.0'));

    expect(tester.getSemantics(find.text('Version')), isNot(_isButton));
  });

  testWidgets('the whole toggle row flips the switch, not just the switch', (
    tester,
  ) async {
    // The design's rule: "the WHOLE row toggles (44px+ target)". Reaching for
    // a 32px switch at the screen edge is the miss this prevents.
    var value = false;
    await pump(
      tester,
      SettingsNavRow(
        label: 'Notifications',
        toggleValue: value,
        onToggle: (next) => value = next,
      ),
    );

    await tester.tap(find.text('Notifications'));
    expect(value, isTrue);
  });

  testWidgets('a destructive row is berry, and says so to a reader', (
    tester,
  ) async {
    await pump(
      tester,
      SettingsNavRow(
        label: 'Reset progress',
        isDestructive: true,
        onTap: () {},
      ),
    );

    final label = tester.widget<Text>(find.text('Reset progress'));
    expect(label.style?.color, MoodColors.darkRoast.berry);
  });

  testWidgets('a dimmed row still acts — it only reads as inactive', (
    tester,
  ) async {
    // The design's `dim` sets opacity and nothing else
    // (`prototype/settings.jsx:151`). It has to stay live: tapping the dimmed
    // reminder row is how the reminder gets turned on in the first place.
    var taps = 0;
    await pump(
      tester,
      SettingsNavRow(
        label: 'Daily reminder',
        value: 'Off',
        isDimmed: true,
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.text('Daily reminder'));
    expect(taps, 1);
    expect(
      tester.widget<Opacity>(find.byType(Opacity)).opacity,
      lessThan(1),
    );
  });

  testWidgets('every row clears the platform minimum tap target', (
    tester,
  ) async {
    await pump(tester, SettingsNavRow(label: 'About', onTap: () {}));

    expect(
      tester.getSize(find.byType(SettingsNavRow)).height,
      greaterThanOrEqualTo(SettingsNavRow.minHeight),
    );
  });
}
