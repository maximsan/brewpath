import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The contract the smoke walk depends on: **an enabled button can be found
/// by what it says.**
///
/// `integration_test/smoke_test.dart` drives onboarding by waiting for an
/// enabled button carrying a label. It used to find one by reading the
/// button's direct child as a `Text`; when the button grew an optional
/// trailing mark and wrapped its label in a `Row`, every wait timed out
/// against a button that was on screen, and main's smoke gate stayed red
/// across five merges.
///
/// **The smoke job only runs on main**, so no pull request could catch that.
/// This runs on every one. It asserts the relationship, not the layout: how
/// the button arranges its label is the button's business, and this is free to
/// keep passing while that changes.
void main() {
  /// The button that says [label], enabled — the shape the smoke walk uses.
  Finder liveButton(String label) => find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (widget) => widget is FilledButton && widget.onPressed != null,
    ),
  );

  Future<void> pump(WidgetTester tester, Widget button) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.cupping,
      home: Scaffold(body: Center(child: button)),
    ),
  );

  testWidgets('an enabled button is found by its label', (tester) async {
    await pump(
      tester,
      PrimaryButton(label: 'Start learning', onPressed: () {}),
    );

    expect(liveButton('Start learning'), findsOneWidget);
  });

  testWidgets('a label beside a trailing mark is still found', (tester) async {
    // The case that broke it: the mark is what put a `Row` between the button
    // and its words.
    await pump(
      tester,
      PrimaryButton(
        label: 'Turn it over',
        onPressed: () {},
        trailingMark: AppIcon.chevron,
      ),
    );

    expect(liveButton('Turn it over'), findsOneWidget);
  });

  testWidgets('a disabled button is not live', (tester) async {
    // The distinction the walk exists to make: tapping a disabled button
    // succeeds and does nothing, so waiting for one must not resolve.
    await pump(
      tester,
      const PrimaryButton(label: 'Continue', onPressed: null),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(liveButton('Continue'), findsNothing);
  });
}
