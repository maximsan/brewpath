import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/pick_card.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  home: Scaffold(body: Center(child: child)),
);

Color _buttonFill(WidgetTester tester) {
  final button = tester.widget<FilledButton>(find.byType(FilledButton));
  return button.style!.backgroundColor!.resolve({})!;
}

void main() {
  testWidgets('a shared widget paints the accent of the ambient mood', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AppTheme.darkRoast,
        PrimaryButton(label: 'Plant your seed', onPressed: () {}),
      ),
    );
    expect(_buttonFill(tester), MoodColors.darkRoast.accent);

    await tester.pumpWidget(
      _app(
        AppTheme.cupping,
        PrimaryButton(label: 'Plant your seed', onPressed: () {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(_buttonFill(tester), MoodColors.cupping.accent);
  });

  testWidgets('surfaces and hairlines flip with the mood too', (tester) async {
    Widget card(ThemeData theme) => _app(
      theme,
      PickCard(
        title: 'Pour over',
        description: 'V60, Chemex, Kalita',
        selected: false,
        onTap: () {},
      ),
    );

    await tester.pumpWidget(card(AppTheme.darkRoast));
    expect(
      tester.widget<Material>(find.byType(Material).last).color,
      MoodColors.darkRoast.surface,
    );

    await tester.pumpWidget(card(AppTheme.cupping));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Material>(find.byType(Material).last).color,
      MoodColors.cupping.surface,
    );
  });

  testWidgets('the extension lerps while the theme animates between moods', (
    tester,
  ) async {
    late MoodColors observed;
    Widget probe(ThemeData theme) => _app(
      theme,
      Builder(
        builder: (context) {
          observed = context.mood;
          return const SizedBox.shrink();
        },
      ),
    );

    await tester.pumpWidget(probe(AppTheme.darkRoast));
    expect(observed.bg, MoodColors.darkRoast.bg);

    await tester.pumpWidget(probe(AppTheme.cupping));
    await tester.pump(kThemeAnimationDuration ~/ 2);

    // Mid-transition the mood is a blend, which is only possible because
    // MoodColors.lerp is wired up — a non-lerping extension would snap.
    expect(observed.bg, isNot(MoodColors.darkRoast.bg));
    expect(observed.bg, isNot(MoodColors.cupping.bg));

    await tester.pumpAndSettle();
    expect(observed.bg, MoodColors.cupping.bg);
  });

  testWidgets('an unthemed subtree still renders in the default mood', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Continue', onPressed: () {}),
        ),
      ),
    );

    expect(_buttonFill(tester), MoodColors.darkRoast.accent);
  });
}
