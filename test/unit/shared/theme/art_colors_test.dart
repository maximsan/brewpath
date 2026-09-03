import 'dart:io';

import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The illustration palette, transcribed from the design bundle CSS
/// (`prototype/index.html`, the `--art-*` / `--cream` block). Literal coffee:
/// identical in both moods, because a ripe cherry is the same colour under any
/// theme. Any drift between this table and [ArtColors] is a bug in the app,
/// never in the table — and `design bundle` below proves the table itself has
/// not drifted from the source it was transcribed from.
const _spec = <String, Color>{
  '--art-raw': Color(0xFF9FB088),
  '--art-roast-light': Color(0xFFC79A63),
  '--art-roast-mid': Color(0xFFA2703C),
  '--art-roast-deep': Color(0xFF7A4526),
  '--art-roast-dark': Color(0xFF54301C),
  '--art-cherry-skin': Color(0xFFA93227),
  '--art-cherry-pulp': Color(0xFFC9563A),
  '--art-cherry-gel': Color(0xFFD9A94C),
  '--art-cherry-parchment': Color(0xFFE3D2AE),
  '--art-cherry-silverskin': Color(0xFFF1E8D6),
  '--art-cherry-seed': Color(0xFF8FA184),
  '--art-seed-crease': Color(0xFF5C6B52),
  '--art-ripe': Color(0xFFC8843A),
  '--art-sour': Color(0xFFB79A3C),
  '--art-cream': Color(0xFFF0DCB8),
};

/// The palette as the app states it, by the design source's own token names.
///
/// Read from `lib` rather than restated here, so there is one such map and the
/// bagpick bean's colour resolution cannot drift from what this guard checks.
/// **The comparison keeps all of its force**: [_spec]'s hex values are still
/// transcribed independently, so a constant filed under the wrong token name
/// fails the first test below exactly as it did when both maps lived here.
Map<String, Color> get _tokens => ArtColors.byTokenName;

void main() {
  group('the illustration palette', () {
    test('is the 15 tokens the design ships, valued 1:1', () {
      expect(_tokens, _spec);
    });

    test('shares no value with either mood — art is never a theme token', () {
      final moodValues = {
        for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) ...[
          mood.bg,
          mood.surface,
          mood.surface2,
          mood.ink,
          mood.inkMute,
          mood.rule,
          mood.accent,
          mood.accentInk,
          mood.sage,
          mood.warn,
          mood.berry,
          mood.water,
          mood.waterHi,
        ],
      };

      _tokens.forEach((name, colour) {
        expect(
          moodValues,
          isNot(contains(colour)),
          reason:
              '$name has the value of a mood token; keeping cherry and bean '
              'colours out of the semantic tokens is what lets --warn mean '
              'exactly one thing.',
        );
      });
    });
  });

  group('the ramps', () {
    test('roast runs raw green → espresso, in stages', () {
      expect(ArtColors.roastRamp, [
        ArtColors.raw,
        ArtColors.roastLight,
        ArtColors.roastMid,
        ArtColors.roastDeep,
        ArtColors.roastDark,
      ]);
    });

    test('cherry runs outside in, skin → seed', () {
      expect(ArtColors.cherryRamp, [
        ArtColors.cherrySkin,
        ArtColors.cherryPulp,
        ArtColors.cherryGel,
        ArtColors.cherryParchment,
        ArtColors.cherrySilverskin,
        ArtColors.cherrySeed,
      ]);
    });

    test('roastAt lands on the ramp stops at their own positions', () {
      expect(ArtColors.roastAt(0), ArtColors.raw);
      expect(ArtColors.roastAt(0.25), ArtColors.roastLight);
      expect(ArtColors.roastAt(0.5), ArtColors.roastMid);
      expect(ArtColors.roastAt(0.75), ArtColors.roastDeep);
      expect(ArtColors.roastAt(1), ArtColors.roastDark);
    });

    test('roastAt blends between the two stops it sits between', () {
      expect(
        ArtColors.roastAt(0.125),
        Color.lerp(ArtColors.raw, ArtColors.roastLight, 0.5),
      );
    });

    test('roastAt clamps rather than running off either end', () {
      expect(ArtColors.roastAt(-1), ArtColors.raw);
      expect(ArtColors.roastAt(2), ArtColors.roastDark);
    });
  });

  group('resolving a design-source token name', () {
    test('returns the palette colour the design bundle names', () {
      expect(ArtColors.ofToken('--art-cherry-seed'), ArtColors.cherrySeed);
      expect(ArtColors.ofToken('--art-cherry-gel'), ArtColors.cherryGel);
      expect(ArtColors.ofToken('--art-cream'), ArtColors.cream);
    });

    test('resolves every token the palette carries', () {
      for (final entry in ArtColors.byTokenName.entries) {
        expect(ArtColors.ofToken(entry.key), entry.value);
      }
    });

    test('throws on an unknown token rather than defaulting', () {
      // The point of the whole function. Authored content refers to these by
      // name, and a fallback colour would draw something plausible and wrong
      // — in illustrations where the colour *is* the information.
      expect(
        () => ArtColors.ofToken('--art-not-a-colour'),
        throwsArgumentError,
      );
    });

    test('does not accept the CSS var() wrapper', () {
      // Unwrapping `var(...)` is the content layer's job, not the palette's:
      // the encoding belongs to whichever bank wrote it, and the palette knows
      // only about token names.
      expect(
        () => ArtColors.ofToken('var(--art-cherry-seed)'),
        throwsArgumentError,
      );
    });
  });

  test('the spec table still matches the design bundle', () {
    final css = File('prototype/index.html').readAsStringSync();
    final declared = <String, Color>{};
    for (final match in RegExp(
      r'(--(?:art-[a-z-]+|cream))\s*:\s*#([0-9A-Fa-f]{6})',
    ).allMatches(css)) {
      declared[match.group(1)!] = Color(
        0xFF000000 | int.parse(match.group(2)!, radix: 16),
      );
    }

    expect(
      declared,
      _spec,
      reason:
          'the design bundle declares a different illustration palette than '
          'this test transcribes — update the table, then the tokens.',
    );
  });
}
