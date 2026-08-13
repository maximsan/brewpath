import 'dart:io';

import 'package:brew_path/shared/theme/app_typography.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter resolves a font by the family **string**. A name that does not match
/// a `fonts:` entry in `pubspec.yaml` does not throw — it silently falls
/// back to the platform font, so the app renders in the wrong typeface with
/// no signal at all.
///
/// These tests close that gap by comparing what `AppTypography` asks for
/// against what the pubspec actually declares, in both directions.
void main() {
  final declaredFamilies = _familiesDeclaredInPubspec();

  /// One representative style per family is not enough — a typo in any single
  /// getter would slip through — so every style `AppTypography` exposes is
  /// checked.
  Map<String, TextStyle> stylesFor(MoodColors mood) => {
    'displayXL': AppTypography.displayXL(mood),
    'displayLG': AppTypography.displayLG(mood),
    'displayMD': AppTypography.displayMD(mood),
    'captionItalic': AppTypography.captionItalic(mood),
    'body': AppTypography.body(mood),
    'bodySm': AppTypography.bodySm(mood),
    'button': AppTypography.button(mood),
    'pickTitle': AppTypography.pickTitle(mood),
    'smallcaps': AppTypography.smallcaps(mood),
    'mono': AppTypography.mono(mood),
  };

  test('pubspec declares the three families the design stack uses', () {
    expect(
      declaredFamilies,
      containsAll(<String>['Fraunces', 'IBM Plex Sans', 'IBM Plex Mono']),
    );
  });

  for (final mood in <(String, MoodColors)>[
    ('cupping', MoodColors.cupping),
    ('darkRoast', MoodColors.darkRoast),
  ]) {
    test('every ${mood.$1} text style names a declared font family', () {
      stylesFor(mood.$2).forEach((name, style) {
        expect(
          style.fontFamily,
          isNotNull,
          reason: 'AppTypography.$name left fontFamily unset',
        );
        expect(
          declaredFamilies,
          contains(style.fontFamily),
          reason:
              'AppTypography.$name asks for "${style.fontFamily}", which '
              'no `fonts:` entry in pubspec.yaml declares — it would render '
              'in the platform fallback font instead of failing.',
        );
      });
    });
  }

  test('textTheme entries name declared font families', () {
    final theme = AppTypography.textTheme(MoodColors.darkRoast);
    for (final style in <TextStyle?>[
      theme.displayLarge,
      theme.displayMedium,
      theme.displaySmall,
      theme.headlineSmall,
      theme.bodyLarge,
      theme.bodyMedium,
      theme.labelLarge,
      theme.labelSmall,
    ]) {
      expect(declaredFamilies, contains(style?.fontFamily));
    }
  });

  test('every declared family is backed by a font file that exists', () {
    final assets = RegExp(
      r'-\s*asset:\s*(\S+)',
    ).allMatches(File('pubspec.yaml').readAsStringSync());
    expect(assets, isNotEmpty, reason: 'no font assets found in pubspec.yaml');
    for (final match in assets) {
      final path = match.group(1)!;
      expect(
        File(path).existsSync(),
        isTrue,
        reason: '$path is declared in pubspec.yaml but is not on disk',
      );
    }
  });
}

/// Reads the `family:` names out of the `fonts:` block. Parsed with a regex
/// rather than a YAML package because the project has no direct `yaml`
/// dependency, and pulling one in for a guard test is not worth it.
Set<String> _familiesDeclaredInPubspec() => RegExp(r'-\s*family:\s*(.+)')
    .allMatches(File('pubspec.yaml').readAsStringSync())
    .map((match) => match.group(1)!.trim())
    .toSet();
