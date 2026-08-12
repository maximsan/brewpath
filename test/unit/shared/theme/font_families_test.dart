import 'dart:io';

import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter resolves a font by the family **string**. A name that does not match
/// a `fonts:` entry in `pubspec.yaml` does not throw — it silently falls
/// back to the platform font, so the app renders in the wrong typeface with
/// no signal at all.
///
/// These tests close that gap by comparing what `AppText` asks for
/// against what the pubspec actually declares, in both directions.
void main() {
  final declaredFamilies = _familiesDeclaredInPubspec();

  /// One representative style per family is not enough — a typo in any single
  /// getter would slip through — so every step `AppText` exposes is checked, in
  /// every face that names a family.
  Map<String, TextStyle> stylesFor(MoodColors mood) => {
    for (final face in AppFace.values.where((face) => face.family != null)) ...{
      'hero.${face.name}': AppText.hero(mood: mood, face: face),
      'display.${face.name}': AppText.display(mood: mood, face: face),
      'title.${face.name}': AppText.title(mood: mood, face: face),
      'heading.${face.name}': AppText.heading(mood: mood, face: face),
      'lead.${face.name}': AppText.lead(mood: mood, face: face),
      'body.${face.name}': AppText.body(mood: mood, face: face),
      'support.${face.name}': AppText.support(mood: mood, face: face),
      'label.${face.name}': AppText.label(mood: mood, face: face),
      'micro.${face.name}': AppText.micro(mood: mood, face: face),
    },
    'headingItalic': AppText.headingItalic(mood: mood),
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
          reason: 'AppText.$name left fontFamily unset',
        );
        expect(
          declaredFamilies,
          contains(style.fontFamily),
          reason:
              'AppText.$name asks for "${style.fontFamily}", which '
              'no `fonts:` entry in pubspec.yaml declares — it would render '
              'in the platform fallback font instead of failing.',
        );
      });
    });
  }

  test('textTheme entries name declared font families', () {
    final theme = AppText.textTheme(MoodColors.darkRoast);
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

  test('every font family named anywhere in lib/ is declared', () {
    // `AppText` is not the only place a family can be asked for: a
    // `CustomPainter` builds its own `TextStyle` to hand to a `TextPainter`,
    // and those were outside this guard until a painter shipped
    // 'IBMPlexMono' — no such family, so the label had been drawing in the
    // platform fallback with nothing to signal it.
    final offenders = <String>[];

    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))) {
      for (final match in RegExp(
        '''fontFamily:\\s*'([^']+)\'''',
      ).allMatches(file.readAsStringSync())) {
        final family = match.group(1)!;
        if (!declaredFamilies.contains(family)) {
          offenders.add('${file.path} asks for "$family"');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'no `fonts:` entry declares these, so they render in the platform '
          'fallback instead of failing:\n${offenders.join('\n')}',
    );
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
