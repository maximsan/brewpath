import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design sets `font-optical-sizing: auto` on every display element, which
/// is a browser setting the `opsz` axis to the rendered size, and Fraunces is
/// drawn for that. A static cut gets a compromise at both ends of a 9.5–56px
/// ladder, so these pin the axis to the rung. Only Fraunces has it — the Plex
/// faces are static and must not be handed variations they cannot answer.
double? _opszOf(TextStyle style) {
  final variations = style.fontVariations;
  if (variations == null) return null;
  for (final variation in variations) {
    if (variation.axis == 'opsz') return variation.value;
  }
  return null;
}

void main() {
  const mood = MoodColors.darkRoast;

  group('the display face', () {
    test('carries an optical size at every step of the ladder', () {
      final steps = <String, (TextStyle, double)>{
        'display': (AppText.display(mood: mood), 30),
        'title': (AppText.title(mood: mood), 26),
        'heading': (AppText.heading(mood: mood), 19),
      };

      steps.forEach((name, pair) {
        expect(
          _opszOf(pair.$1),
          pair.$2,
          reason: 'AppText.$name should set opsz to its own rung size',
        );
      });
    });

    test('asks the axis for a size it actually has', () {
      // The axis runs 9..144. `micro` sits at 9.5 and `hero` at 56, so every
      // rung is inside it — but a rung added outside would clamp rather than
      // ask for a coordinate the font cannot answer.
      for (final style in <TextStyle>[
        AppText.micro(mood: mood, face: AppFace.display),
        AppText.hero(mood: mood, face: AppFace.display),
      ]) {
        final opsz = _opszOf(style)!;
        expect(opsz, greaterThanOrEqualTo(9));
        expect(opsz, lessThanOrEqualTo(144));
      }
    });

    test('the italic step carries it too', () {
      expect(_opszOf(AppText.headingItalic(mood: mood)), 19);
    });
  });

  group('the static faces', () {
    test('are handed no variations at all', () {
      for (final face in <AppFace>[AppFace.ui, AppFace.control, AppFace.mono]) {
        expect(
          AppText.body(mood: mood, face: face).fontVariations,
          isNull,
          reason:
              'AppFace.${face.name} is a static cut — a variation it cannot '
              'answer is noise on every span it sets',
        );
      }
    });

    test('the inherited face asks for nothing either', () {
      expect(
        AppText.body(mood: mood, face: AppFace.inherit).fontVariations,
        isNull,
      );
    });
  });

  test('every textTheme slot in the display face carries its rung size', () {
    final theme = AppText.textTheme(mood);

    // The four Fraunces slots, and the rung each lands on.
    expect(_opszOf(theme.displayLarge!), 30);
    expect(_opszOf(theme.headlineMedium!), 26);
    expect(_opszOf(theme.titleLarge!), 19);

    // A control-face slot stays static.
    expect(theme.titleMedium!.fontVariations, isNull);
  });
}
