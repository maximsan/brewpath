import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

SvgPicture _rendered(WidgetTester tester) =>
    tester.widget<SvgPicture>(find.byType(SvgPicture));

SvgAssetLoader _loaderOf(WidgetTester tester) =>
    _rendered(tester).bytesLoader as SvgAssetLoader;

String _assetOf(WidgetTester tester) => _loaderOf(tester).assetName;

/// What `currentColor` in the drawing resolves to — the mark's ink.
Color? _inkOf(WidgetTester tester) => _loaderOf(tester).theme?.currentColor;

Future<void> _pumpMark(
  WidgetTester tester,
  IconMark mark, {
  bool cupping = false,
}) => tester.pumpWidget(
  MaterialApp(
    theme: cupping ? AppTheme.cupping : AppTheme.darkRoast,
    home: Scaffold(body: Center(child: mark)),
  ),
);

void main() {
  testWidgets('draws the mark the design drew', (tester) async {
    await _pumpMark(tester, const IconMark(AppIcon.roasting));

    expect(_assetOf(tester), 'assets/icons/roasting.svg');
  });

  testWidgets('takes the muted ink until it is given another', (tester) async {
    await _pumpMark(tester, const IconMark(AppIcon.cup));

    expect(
      _inkOf(tester),
      MoodColors.darkRoast.inkMute,
      reason: 'the design draws every inactive glyph in ink-mute',
    );
  });

  testWidgets('takes the ink an IconButton gives it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              foregroundColor: MoodColors.darkRoast.accent,
            ),
            icon: const IconMark(AppIcon.bookmark, active: true),
          ),
        ),
      ),
    );

    expect(
      _inkOf(tester),
      MoodColors.darkRoast.accent,
      reason:
          'IconButton colours its glyph by merging an IconTheme, which '
          'flutter_svg does not read — so a saved bookmark filled in muted '
          'ink instead of the accent its own rule asks for',
    );
  });

  testWidgets('follows the mood it is drawn in', (tester) async {
    await _pumpMark(tester, const IconMark(AppIcon.cup));
    final dark = _inkOf(tester);

    await _pumpMark(tester, const IconMark(AppIcon.cup), cupping: true);
    // MaterialApp animates a theme change, so the first frame after the swap
    // still carries the old mood — the same settle mood_theme_test.dart makes.
    await tester.pumpAndSettle();

    expect(_inkOf(tester), isNot(dark));
    expect(_inkOf(tester), MoodColors.cupping.inkMute);
  });

  testWidgets('an active tab mark is a different drawing', (tester) async {
    await _pumpMark(tester, const IconMark(AppIcon.cup, active: true));

    expect(
      _assetOf(tester),
      'assets/icons/cup_active.svg',
      reason:
          'the design fills the shape and dims the steam when a tab is '
          'active, which is a second drawing rather than a recolour',
    );
  });

  testWidgets('a mark with no active state ignores the flag', (tester) async {
    await _pumpMark(tester, const IconMark(AppIcon.gear, active: true));

    expect(
      _assetOf(tester),
      'assets/icons/gear.svg',
      reason: 'so a call site can pass a selection flag without asking first',
    );
  });

  testWidgets('is unlabelled unless a label is asked for', (tester) async {
    await _pumpMark(tester, const IconMark(AppIcon.bean));
    expect(find.bySemanticsLabel('Points'), findsNothing);

    await _pumpMark(
      tester,
      const IconMark(AppIcon.bean, semanticLabel: 'Points'),
    );
    expect(find.bySemanticsLabel('Points'), findsOneWidget);
  });
}
