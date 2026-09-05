import 'dart:io';

import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/dart_sources.dart';

/// The mascot's palette, transcribed from the `/* Roasty palette */` block of
/// the mascot's design page (`prototype/Mascot - Roasty.html`). A bean is the
/// same brown under any theme, so these are identical in both moods. Any drift
/// between this table and [RoastyColors] is a bug in the app, never in the
/// table — and `design page` below proves the table itself has not drifted
/// from the source it was transcribed from.
const _spec = <String, Color>{
  '--bean-deep': Color(0xFF4A2B19),
  '--bean-body': Color(0xFF6B3E22),
  '--bean-warm': Color(0xFF8C5634),
  '--bean-shadow': Color(0xFF2F1A0E),
  '--leaf': Color(0xFF8A9D6B),
  '--leaf-deep': Color(0xFF5E7148),
  '--leaf-hilite': Color(0xFFB5C497),
  '--eye-white': Color(0xFFFBF7EE),
  '--mouth': Color(0xFF2A1B12),
  '--blush': Color(0xFFC47654),
};

/// The colours the drawings use that the palette block does not name. The
/// mascot component (`prototype/roasty.jsx`) writes each as a hex literal in
/// both moods, which is what makes them palette rather than theme.
const _unnamed = <String, Color>{
  'beanHighlight': Color(0xFFA26945),
  'cardGlow': Color(0xFFE6C68A),
  'confettiEmber': Color(0xFFB8533A),
  'confettiMoss': Color(0xFF7A8471),
  'confettiGold': Color(0xFFC8843A),
};

/// The palette as the app states it, by the design source's own token names.
Map<String, Color> get _tokens => RoastyColors.byTokenName;

void main() {
  group('the mascot palette', () {
    test('is the 10 tokens the design page names, valued 1:1', () {
      expect(_tokens, _spec);
    });

    test('shares no value with the marks the painters read off the mood', () {
      // roasty_painters_mood_test.dart asserts the *other* mood's warn, berry
      // and muted ink are absent from a painted frame. That only proves the
      // painter read the mood if no palette colour happens to equal one.
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        for (final colour in [..._spec.values, ..._unnamed.values]) {
          expect([
            mood.warn,
            mood.berry,
            mood.inkMute,
          ], isNot(contains(colour)));
        }
      }
    });

    test('carries the five colours the drawings use unnamed', () {
      expect({
        'beanHighlight': RoastyColors.beanHighlight,
        'cardGlow': RoastyColors.cardGlow,
        'confettiEmber': RoastyColors.confettiEmber,
        'confettiMoss': RoastyColors.confettiMoss,
        'confettiGold': RoastyColors.confettiGold,
      }, _unnamed);
    });
  });

  group('the gradients', () {
    test('the bean runs warm → body → deep, the design gradient order', () {
      expect(RoastyColors.beanGradient, [
        RoastyColors.beanWarm,
        RoastyColors.beanBody,
        RoastyColors.beanDeep,
      ]);
    });

    test('the leaf runs highlight → deep', () {
      expect(RoastyColors.leafGradient, [
        RoastyColors.leafHilite,
        RoastyColors.leafDeep,
      ]);
    });
  });

  group('the design page', () {
    test('still declares the palette block this test transcribes', () {
      final css = File('prototype/Mascot - Roasty.html').readAsStringSync();
      final block = RegExp(
        r'/\* Roasty palette \*/(.*?)\}',
        dotAll: true,
      ).firstMatch(css);
      expect(block, isNotNull, reason: 'the /* Roasty palette */ block moved');

      final declared = <String, Color>{};
      for (final match in RegExp(
        r'(--[a-z-]+)\s*:\s*#([0-9A-Fa-f]{6})',
      ).allMatches(block!.group(1)!)) {
        declared[match.group(1)!] = Color(
          0xFF000000 | int.parse(match.group(2)!, radix: 16),
        );
      }

      expect(
        declared,
        _spec,
        reason:
            'the design page declares a different mascot palette than this '
            'test transcribes — update the table, then the tokens.',
      );
    });

    test('the mascot component still draws the unnamed five where it did', () {
      // `contains('#B8533A')` anywhere in the file would pass on a hat that
      // happens to share the confetti's red, so each colour is read off the
      // drawing that uses it.
      expect(_fillsIn(_group('confetti')), {
        _hex(RoastyColors.confettiEmber),
        _hex(RoastyColors.confettiMoss),
        _hex(RoastyColors.confettiGold),
      });
      expect(_fillsIn(_group('sparkles')), {
        _hex(RoastyColors.confettiMoss),
        _hex(RoastyColors.confettiEmber),
      });

      final glow = RegExp(
        'gr-glow-.*?</radialGradient>',
        dotAll: true,
      ).firstMatch(_jsx);
      expect(glow, isNotNull, reason: 'the card glow gradient moved');
      expect(
        RegExp(
          'stopColor="(#[0-9A-Fa-f]{6})"',
        ).allMatches(glow!.group(0)!).map((match) => match.group(1)).toSet(),
        {_hex(RoastyColors.cardGlow)},
      );

      expect(
        _jsx,
        contains(
          RegExp(
            '<ellipse cx="78" cy="115"[^>]*fill="'
            '${_hex(RoastyColors.beanHighlight)}"',
          ),
        ),
        reason: 'the bean highlight has moved or been retoned',
      );
    });

    test('the mascot component still gives the mood marks to the theme', () {
      // The painters read these off the mood rather than the palette because
      // the component draws them with theme tokens. If the design ever pins
      // one of them, it belongs on RoastyColors and this says so.
      expect(_group('module-rays'), contains('stroke="var(--warn)"'));
      expect(
        'fill="var(--warn)"'.allMatches(_group('face-module')),
        hasLength(2),
      );
      expect('fill="var(--warn)"'.allMatches(_group('sparkles')), hasLength(2));
      expect('var(--berry)'.allMatches(_group('wrong-x')), hasLength(3));
      expect(_group('sleep-zzz'), contains('fill="var(--ink-mute)"'));
    });
  });

  test(
    'no Roasty painter spells a colour — it reads the palette or the mood',
    () {
      // The whole reason the palette exists: 37 literals across three painters
      // were correct only until the design retoned the bean, and nothing would
      // have said so. A colour is either on `RoastyColors` (fixed in both
      // moods) or read off the mood the host hands the painter — never spelled
      // inline.
      final offenders = <String>[];

      for (final file in dartSourcesUnder('lib/features/companion')) {
        for (final match in RegExp(
          r'Color\(0x[0-9A-Fa-f]+\)|Color\.from(ARGB|RGBO)\(|\bColors\.\w+',
        ).allMatches(withoutComments(file.readAsStringSync()))) {
          offenders.add('${file.path} spells ${match.group(0)}');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'put the colour on RoastyColors, or read it from the mood:\n'
            '${offenders.join('\n')}',
      );
    },
  );
}

/// The mascot component the app screens render, in both moods.
final String _jsx = File('prototype/roasty.jsx').readAsStringSync();

/// The markup of the `className="…"` group in [_jsx], up to the comment that
/// opens the next section.
String _group(String className) {
  final start = _jsx.indexOf('className="$className"');
  expect(start, isNot(-1), reason: 'roasty.jsx has no $className group');
  final end = _jsx.indexOf('{/*', start);
  return _jsx.substring(start, end == -1 ? _jsx.length : end);
}

/// Every hex fill in [markup].
Set<String> _fillsIn(String markup) => RegExp(
  'fill="(#[0-9A-Fa-f]{6})"',
).allMatches(markup).map((match) => match.group(1)!).toSet();

/// [colour] the way the component spells it.
String _hex(Color colour) =>
    '#${colour.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
