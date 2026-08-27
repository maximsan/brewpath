import 'package:brew_path/app/tab_bar_theme.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _selected = <WidgetState>{WidgetState.selected};
const _unselected = <WidgetState>{};

Color? _iconInk(MoodColors mood, Set<WidgetState> states) =>
    tabBarTheme(mood).iconTheme?.resolve(states)?.color;

Color? _labelInk(MoodColors mood, Set<WidgetState> states) =>
    tabBarTheme(mood).labelTextStyle?.resolve(states)?.color;

void main() {
  group('the tab bar theme', () {
    test('draws no indicator, so sage can never fill one', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(
          tabBarTheme(mood).indicatorColor,
          Colors.transparent,
          reason:
              'undeclared, the indicator resolves to secondaryContainer → '
              'secondary = sage, the token documented "never an action" — and '
              'the design draws no pill at all',
        );
      }
    });

    test('the active tab is the accent, in mark and in label', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(_iconInk(mood, _selected), mood.accent);
        expect(_labelInk(mood, _selected), mood.accent);
      }
    });

    test('an inactive tab is muted ink', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(_iconInk(mood, _unselected), mood.inkMute);
        expect(_labelInk(mood, _unselected), mood.inkMute);
      }
    });

    test('neither state is the page background', () {
      const mood = MoodColors.darkRoast;
      expect(_iconInk(mood, _selected), isNot(mood.bg));
      expect(_labelInk(mood, _selected), isNot(mood.ink));
    });

    test('the bar takes the mood surface rather than a Material container', () {
      expect(
        tabBarTheme(MoodColors.cupping).backgroundColor,
        MoodColors.cupping.surface,
      );
      expect(
        tabBarTheme(MoodColors.darkRoast).backgroundColor,
        MoodColors.darkRoast.surface,
      );
    });

    test('the theme follows the mood it was built from', () {
      expect(
        _labelInk(MoodColors.cupping, _selected),
        isNot(_labelInk(MoodColors.darkRoast, _selected)),
      );
    });
  });

  group('the tab label', () {
    test('is the control face, not Roboto and not mono', () {
      final style = tabLabelStyle(MoodColors.darkRoast);

      expect(style.fontFamily, AppFace.control.family);
      expect(style.fontWeight, AppFace.control.weight);
    });

    test('sits on the ladder rung the design letters it at', () {
      final style = tabLabelStyle(MoodColors.darkRoast);
      final micro = AppText.micro(mood: MoodColors.darkRoast);

      expect(style.fontSize, micro.fontSize);
    });

    test('is lettered at the design tracking, not the rung it borrows', () {
      final style = tabLabelStyle(MoodColors.darkRoast);
      final micro = AppText.micro(mood: MoodColors.darkRoast);
      final size = micro.fontSize!;

      expect(style.letterSpacing, OffTokens.tabLabelTracking.value * size);
      expect(
        style.letterSpacing,
        isNot(micro.letterSpacing),
        reason:
            'the whole reason the tracking is an off-token is that the '
            'rung does not carry it',
      );
    });
  });
}
