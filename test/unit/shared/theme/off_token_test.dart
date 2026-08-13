import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast ratio, used to check the *reason* the rewarded-ad ring is
/// allowed off-token — not just that it is spelled the way the design does.
double _contrast(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}

void main() {
  group('OffToken', () {
    test('carries its value and the reason it is off-token', () {
      const escape = OffToken(
        Color(0xFF123456),
        reason: 'because the spec says so',
      );

      expect(escape.value, const Color(0xFF123456));
      expect(escape.reason, 'because the spec says so');
    });
  });

  group('the register', () {
    test('every entry states a reason', () {
      expect(OffTokens.register, isNotEmpty);
      for (final entry in OffTokens.register) {
        expect(
          entry.reason.trim(),
          isNotEmpty,
          reason:
              'an off-token value with no stated reason is just a magic '
              'literal that passed review once',
        );
      }
    });

    test('holds the rewarded-ad ring and the canvas it sits on', () {
      expect(
        OffTokens.register,
        containsAll(<OffToken<Object>>[
          OffTokens.rewardedAdCanvas,
          OffTokens.rewardedAdProgressRing,
        ]),
      );
    });
  });

  group('the rewarded-ad exception', () {
    test('the ad canvas is darker than either mood canvas', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(
          OffTokens.rewardedAdCanvas.value.computeLuminance(),
          lessThan(mood.bg.computeLuminance()),
          reason:
              'the exception only holds because the ad canvas is fixed '
              'near-black in both moods',
        );
      }
    });

    test('the themed accent really would go too dark on that canvas', () {
      final canvas = OffTokens.rewardedAdCanvas.value;

      expect(
        _contrast(MoodColors.cupping.accent, canvas),
        lessThan(_contrast(MoodColors.darkRoast.accent, canvas)),
        reason:
            'if the Cupping accent read as well as the Dark Roast one on the '
            'ad canvas, this exception would have no reason to exist',
      );
    });

    test('the ring keeps the Dark Roast accent rather than the mood one', () {
      expect(
        OffTokens.rewardedAdProgressRing.value,
        MoodColors.darkRoast.accent,
      );
      expect(
        OffTokens.rewardedAdProgressRing.value,
        isNot(MoodColors.cupping.accent),
      );
    });
  });
}
