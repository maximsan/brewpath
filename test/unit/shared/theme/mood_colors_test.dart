import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/contrast.dart';

/// Hexes transcribed from the design bundle CSS
/// (`prototype/index.html` — `:root` for Cupping, `[data-mood="dark-roast"]`
/// for Dark Roast). Any drift between these and [MoodColors] is a bug in the
/// app, never in the table.
const _cuppingSpec = <String, Color>{
  'bg': Color(0xFFF4EFE6),
  'surface': Color(0xFFFBF7EE),
  'surface2': Color(0xFFEFE8DA),
  'ink': Color(0xFF1B1614),
  'inkMute': Color(0xFF6B5F54),
  'rule': Color(0xFFD8CFBF),
  'accent': Color(0xFFB8533A),
  'accentInk': Color(0xFFFBF7EE),
  'accentText': Color(0xFF783C2C),
  'sage': Color(0xFF5F6E55),
  'warn': Color(0xFF9A5F1C),
  'berry': Color(0xFFA8362A),
  'water': Color(0xFF5C93B8),
  'waterHi': Color(0xFFA9CFE3),
};

const _darkRoastSpec = <String, Color>{
  'bg': Color(0xFF1A130E),
  'surface': Color(0xFF251B14),
  'surface2': Color(0xFF30231A),
  'ink': Color(0xFFF3E7D2),
  'inkMute': Color(0xFFB59E84),
  'rule': Color(0xFF44321E),
  'accent': Color(0xFFE07A4F),
  'accentInk': Color(0xFF1A130E),
  'accentText': Color(0xFFEAA482),
  'sage': Color(0xFF97A285),
  'warn': Color(0xFFE6A35C),
  'berry': Color(0xFFC75450),
  'water': Color(0xFF7FB4D6),
  'waterHi': Color(0xFFC2E0EF),
};

Map<String, Color> _flatTokens(MoodColors mood) => {
  'bg': mood.bg,
  'surface': mood.surface,
  'surface2': mood.surface2,
  'ink': mood.ink,
  'inkMute': mood.inkMute,
  'rule': mood.rule,
  'accent': mood.accent,
  'accentInk': mood.accentInk,
  'accentText': mood.accentText,
  'sage': mood.sage,
  'warn': mood.warn,
  'berry': mood.berry,
  'water': mood.water,
  'waterHi': mood.waterHi,
};

void main() {
  group('MoodColors instances', () {
    test('Cupping matches the design bundle 1:1', () {
      expect(_flatTokens(MoodColors.cupping), _cuppingSpec);
    });

    test('Dark Roast matches the design bundle 1:1', () {
      expect(_flatTokens(MoodColors.darkRoast), _darkRoastSpec);
    });

    test('the two moods share no flat token value', () {
      final cupping = _flatTokens(MoodColors.cupping);
      final darkRoast = _flatTokens(MoodColors.darkRoast);
      for (final name in cupping.keys) {
        expect(
          cupping[name],
          isNot(darkRoast[name]),
          reason: '$name should flip between moods',
        );
      }
    });

    test('instances are equal to themselves and different across moods', () {
      expect(MoodColors.cupping, equals(MoodColors.cupping));
      expect(MoodColors.cupping, isNot(equals(MoodColors.darkRoast)));
      expect(
        MoodColors.cupping.hashCode,
        equals(MoodColors.cupping.hashCode),
      );
    });
  });

  group('accentText', () {
    test('clears AA as small text on every surface it is set on', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        for (final ground in [mood.bg, mood.surface, mood.surface2]) {
          expect(
            contrastRatio(mood.accentText, ground),
            greaterThanOrEqualTo(contrastMinimumSmallText),
          );
        }
      }
    });

    test('exists because raw accent does not clear it', () {
      // The finding the token answers: cupping accent is 4.23 on `bg`.
      expect(
        contrastRatio(MoodColors.cupping.accent, MoodColors.cupping.bg),
        lessThan(contrastMinimumSmallText),
      );
    });

    test('reads as the accent rather than as ink', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(mood.accentText, isNot(mood.ink));
        expect(mood.accentText, isNot(mood.accent));
        expect(
          contrastRatio(mood.accentText, mood.accent),
          lessThan(contrastMinimumSmallText),
          reason: 'a mix of accent and ink stays close to the accent',
        );
      }
    });
  });

  group('background-derived tokens', () {
    test('veil is the mood background at veil opacity', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(
          mood.veil.color,
          mood.bg.withValues(alpha: MoodColors.veilOpacity),
        );
        expect(
          mood.veilStrong.color,
          mood.bg.withValues(alpha: MoodColors.veilStrongOpacity),
        );
      }
    });

    test('veils follow the background rather than being fixed literals', () {
      expect(
        MoodColors.cupping.veil,
        isNot(MoodColors.darkRoast.veil),
      );
      expect(
        MoodColors.cupping.veilStrong,
        isNot(MoodColors.darkRoast.veilStrong),
      );
    });

    test('veilStrong is more opaque than veil', () {
      expect(
        MoodColors.darkRoast.veilStrong.color.a,
        greaterThan(MoodColors.darkRoast.veil.color.a),
      );
    });
  });

  group('lerp', () {
    test('returns the endpoints at t = 0 and t = 1', () {
      final atStart = MoodColors.cupping.lerp(MoodColors.darkRoast, 0);
      final atEnd = MoodColors.cupping.lerp(MoodColors.darkRoast, 1);

      expect(_flatTokens(atStart), _cuppingSpec);
      expect(_flatTokens(atEnd), _darkRoastSpec);
    });

    test('interpolates every flat token halfway', () {
      final halfway = MoodColors.cupping.lerp(MoodColors.darkRoast, 0.5);
      final actual = _flatTokens(halfway);

      for (final name in _cuppingSpec.keys) {
        expect(
          actual[name],
          Color.lerp(_cuppingSpec[name], _darkRoastSpec[name], 0.5),
          reason: '$name should interpolate',
        );
      }
    });

    test('derived veils follow the interpolated background', () {
      final halfway = MoodColors.cupping.lerp(MoodColors.darkRoast, 0.5);

      expect(
        halfway.veil.color,
        halfway.bg.withValues(alpha: MoodColors.veilOpacity),
      );
    });

    test('falls back to this instance for a non-MoodColors other', () {
      final other = MoodColors.cupping.lerp(null, 0.5);
      expect(_flatTokens(other), _cuppingSpec);
    });
  });

  group('copyWith', () {
    test('overrides only the named token', () {
      const replacement = Color(0xFF123456);
      final tweaked = MoodColors.darkRoast.copyWith(accent: replacement);

      expect(tweaked.accent, replacement);
      expect(
        _flatTokens(tweaked)..remove('accent'),
        _darkRoastSpec.entries
            .where((entry) => entry.key != 'accent')
            .fold<Map<String, Color>>({}, (map, entry) {
              return map..[entry.key] = entry.value;
            }),
      );
    });

    test('returns an equal instance when given no overrides', () {
      expect(MoodColors.darkRoast.copyWith(), equals(MoodColors.darkRoast));
    });

    test('re-derives the veils from an overridden background', () {
      const replacement = Color(0xFF102030);
      final tweaked = MoodColors.darkRoast.copyWith(bg: replacement);

      expect(
        tweaked.veil.color,
        replacement.withValues(alpha: MoodColors.veilOpacity),
      );
    });
  });

  group('theme lookup', () {
    testWidgets('BuildContext.mood reads the extension off the theme', (
      tester,
    ) async {
      late MoodColors seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [MoodColors.cupping]),
          home: Builder(
            builder: (context) {
              seen = context.mood;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(seen, MoodColors.cupping);
    });

    testWidgets('BuildContext.mood defaults to Dark Roast when unthemed', (
      tester,
    ) async {
      late MoodColors seen;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              seen = context.mood;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(seen, MoodColors.darkRoast);
    });
  });
}
