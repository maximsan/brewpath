import 'dart:io';

import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/contrast.dart';

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

    test('holds exactly two trackings, and they are the two rung-breakers', () {
      // Tracking is the ladder's job since #410 — `AppTracking` carries the
      // design's values, and only a spacing too wide to be a rung is an
      // exception. Read off the source rather than the list, because the
      // register types every entry as `double` and cannot tell a tracking
      // from a padding.
      final declared = RegExp(r'OffToken<double> (\w*Tracking) =')
          .allMatches(
            File('lib/shared/theme/off_token.dart').readAsStringSync(),
          )
          .map((match) => match.group(1))
          .toList();

      expect(
        declared,
        containsAllInOrder(<String>['tabLabelTracking', 'tapCueTracking']),
      );
      expect(
        declared,
        hasLength(2),
        reason:
            'a third tracking here means the register is growing into a '
            'second type system beside AppTracking, which is the thing #410 '
            'ruled against. If the design assigns it to an app component, it '
            'belongs on the ladder: $declared',
      );
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
        contrastRatio(MoodColors.cupping.accent, canvas),
        lessThan(contrastRatio(MoodColors.darkRoast.accent, canvas)),
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
