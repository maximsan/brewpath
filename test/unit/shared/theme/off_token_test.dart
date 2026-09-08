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
    test('every reason is one line', () {
      expect(OffTokens.register, isNotEmpty);
      for (final entry in OffTokens.register) {
        expect(
          entry.reason.trim(),
          isNotEmpty,
          reason: 'an off-token value with no reason is a magic literal',
        );
        expect(
          entry.reason.length,
          lessThanOrEqualTo(OffToken.maxReasonLength),
          reason:
              'a reason names the design declaration, nothing more; the '
              'argument for it belongs in an ADR or issue: ${entry.reason}',
        );
      }
    });

    test('every reason quotes a design declaration the design still makes', () {
      final design = Directory('prototype')
          .listSync()
          .whereType<File>()
          .where((file) => RegExp(r'\.(jsx|html|js)$').hasMatch(file.path))
          .map((file) => file.readAsStringSync())
          .join('\n');
      final quoted = RegExp('`([^`]+)`');
      // Whole declarations only, so `marginTop: 2` does not pass on
      // `marginTop: 20`.
      RegExp wholeDeclaration(String declaration) =>
          RegExp('(?<![\\w.-])${RegExp.escape(declaration)}(?![\\w.-])');

      for (final entry in OffTokens.register) {
        final declarations = quoted
            .allMatches(entry.reason)
            .map((match) => match.group(1)!)
            .toList();
        expect(
          declarations,
          isNotEmpty,
          reason: 'a reason quotes the design in backticks: ${entry.reason}',
        );
        for (final declaration in declarations) {
          expect(
            wholeDeclaration(declaration).hasMatch(design),
            isTrue,
            reason:
                'the design no longer says `$declaration`; re-check the value '
                'and quote what it says now: ${entry.reason}',
          );
        }
      }
    });

    test('holds only trackings a single component owns', () {
      // A tracking two components share is vocabulary and belongs on
      // AppTracking (#410, #441). Read off the source: the register types
      // every entry as double and cannot tell a tracking from a padding.
      final declared = RegExp(r'OffToken<double> (\w*Tracking) =')
          .allMatches(
            File('lib/shared/theme/off_token.dart').readAsStringSync(),
          )
          .map((match) => match.group(1))
          .toList();

      expect(declared, <String>['tapCueTracking', 'microTipBodyTracking']);
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
