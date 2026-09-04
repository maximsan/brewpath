import 'dart:io';

import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design's ten-step ladder, transcribed from the `--t-*` block in
/// `prototype/index.html`. Nothing sits off it: a size that is not here cannot
/// be asked for, because no step carries it and the API takes no `fontSize`.
const _ladder = <String, double>{
  'hero': 56,
  'display': 30,
  'title': 26,
  'subtitle': 22,
  'heading': 19,
  'lead': 17,
  'body': 15,
  'support': 13,
  'label': 11,
  'micro': 9.5,
};

Map<String, TextStyle> _steps(MoodColors mood) => {
  'hero': AppText.hero(mood: mood),
  'display': AppText.display(mood: mood),
  'title': AppText.title(mood: mood),
  'subtitle': AppText.subtitle(mood: mood),
  'heading': AppText.heading(mood: mood),
  'lead': AppText.lead(mood: mood),
  'body': AppText.body(mood: mood),
  'support': AppText.support(mood: mood),
  'label': AppText.label(mood: mood),
  'micro': AppText.micro(mood: mood),
};

/// The step each of Material's slots lands on, and whether it takes the
/// full-strength ink or the muted role its step defaults to.
///
/// This is the expectation, written out independently; the reasoning that
/// produced it — role first, then the nearest Roboto size, ties downwards —
/// lives once, on `AppText.textTheme`. Restating it here would give it a
/// second home to drift from.
const _slotMap = <String, ({String step, bool ink})>{
  'displayLarge': (step: 'display', ink: true),
  'displayMedium': (step: 'display', ink: true),
  'displaySmall': (step: 'display', ink: true),
  'headlineLarge': (step: 'display', ink: true),
  'headlineMedium': (step: 'title', ink: true),
  'headlineSmall': (step: 'title', ink: true),
  'titleLarge': (step: 'heading', ink: true),
  'titleMedium': (step: 'body', ink: true),
  'titleSmall': (step: 'support', ink: true),
  'bodyLarge': (step: 'body', ink: true),
  'bodyMedium': (step: 'support', ink: false),
  'bodySmall': (step: 'support', ink: false),
  'labelLarge': (step: 'support', ink: false),
  'labelMedium': (step: 'label', ink: false),
  'labelSmall': (step: 'label', ink: false),
};

/// Material's slots grouped by family, largest first — the order the mapping
/// must not invert.
const _slotFamilies = <String, List<String>>{
  'display': ['displayLarge', 'displayMedium', 'displaySmall'],
  'headline': ['headlineLarge', 'headlineMedium', 'headlineSmall'],
  'title': ['titleLarge', 'titleMedium', 'titleSmall'],
  'body': ['bodyLarge', 'bodyMedium', 'bodySmall'],
  'label': ['labelLarge', 'labelMedium', 'labelSmall'],
};

Map<String, TextStyle?> _slots(TextTheme theme) => {
  'displayLarge': theme.displayLarge,
  'displayMedium': theme.displayMedium,
  'displaySmall': theme.displaySmall,
  'headlineLarge': theme.headlineLarge,
  'headlineMedium': theme.headlineMedium,
  'headlineSmall': theme.headlineSmall,
  'titleLarge': theme.titleLarge,
  'titleMedium': theme.titleMedium,
  'titleSmall': theme.titleSmall,
  'bodyLarge': theme.bodyLarge,
  'bodyMedium': theme.bodyMedium,
  'bodySmall': theme.bodySmall,
  'labelLarge': theme.labelLarge,
  'labelMedium': theme.labelMedium,
  'labelSmall': theme.labelSmall,
};

/// The slot names `TextTheme` declares, read off its own diagnostics rather
/// than transcribed here, so the tables above are checked against Flutter
/// rather than against a second copy of themselves.
///
/// `TextTheme.debugFillProperties` is hand-maintained upstream, so this catches
/// a slot Flutter adds only once Flutter's own authors list it there — a good
/// guard, not a guarantee.
Iterable<String> _declaredSlotNames() => const TextTheme()
    .toDiagnosticsNode()
    .getProperties()
    .map((property) => property.name)
    .whereType<String>();

void main() {
  group('the ladder', () {
    test("is ten steps at the design's sizes", () {
      final sizes = _steps(
        MoodColors.darkRoast,
      ).map((name, style) => MapEntry(name, style.fontSize));

      expect(sizes, _ladder);
    });

    test('still matches the design bundle', () {
      final css = File('prototype/index.html').readAsStringSync();
      final declared = <String, double>{};
      for (final match in RegExp(
        r'--t-([a-z]+):\s*([0-9.]+)px',
      ).allMatches(css)) {
        declared[match.group(1)!] = double.parse(match.group(2)!);
      }

      expect(
        declared,
        _ladder,
        reason:
            'the design bundle declares a different type ladder than this '
            'test transcribes — update the table, then the steps.',
      );
    });

    test('sizes descend, so the step names order the ladder', () {
      final sizes = _ladder.values.toList();
      for (var rung = 1; rung < sizes.length; rung++) {
        expect(sizes[rung], lessThan(sizes[rung - 1]));
      }
    });
  });

  group('the face axis', () {
    test('any step can be set in any face, at the same size', () {
      for (final face in AppFace.values) {
        expect(AppText.label(face: face).fontSize, _ladder['label']);
        expect(AppText.label(face: face).fontFamily, face.family);
      }
    });

    test('carries the weight the design pairs with the family', () {
      expect(AppFace.ui.family, AppFace.control.family);
      expect(AppFace.ui.weight, FontWeight.w400);
      expect(AppFace.control.weight, FontWeight.w500);
    });

    test('inherit asserts no face, so a slot keeps the surrounding one', () {
      final slot = AppText.body(face: AppFace.inherit);

      expect(slot.fontFamily, isNull);
      expect(slot.fontWeight, isNull);
      expect(
        slot.fontSize,
        _ladder['body'],
        reason: 'inheriting the face must not cost the step its size',
      );
    });

    testWidgets('an inherit slot renders in the ambient face', (tester) async {
      late TextStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTextStyle(
            style: AppText.display(mood: MoodColors.darkRoast),
            child: Builder(
              builder: (context) {
                resolved = DefaultTextStyle.of(
                  context,
                ).style.merge(AppText.body(face: AppFace.inherit));
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolved.fontFamily, AppFace.display.family);
      expect(resolved.fontSize, _ladder['body']);
    });
  });

  group('colour', () {
    test('takes the step’s role from the mood', () {
      expect(
        AppText.body(mood: MoodColors.cupping).color,
        MoodColors.cupping.ink,
      );
      expect(
        AppText.support(mood: MoodColors.cupping).color,
        MoodColors.cupping.inkMute,
        reason: 'support text is muted by role, not by call sites remembering',
      );
    });

    test('an explicit colour wins over the role', () {
      const chosen = Color(0xFF00FF00);

      expect(
        AppText.body(mood: MoodColors.darkRoast, color: chosen).color,
        chosen,
      );
    });

    test('with neither, it inherits rather than inventing one', () {
      expect(AppText.body().color, isNull);
    });
  });

  group("Material's slots", () {
    const mood = MoodColors.cupping;
    final theme = AppText.textTheme(mood);
    final steps = _steps(mood);

    test('the mapping covers every slot TextTheme declares', () {
      final declared = _declaredSlotNames().toSet();

      expect(
        _slotMap.keys.toSet(),
        declared,
        reason:
            'TextTheme declares a slot this mapping does not name — an unnamed '
            'slot is a Roboto hole, which is the fault this table closes',
      );
      // The tables below read slots through hand-written getter lists, which a
      // new slot would not join on its own. Lock them to the same set, or a
      // slot could be named once and go unchecked by every test after this.
      expect(_slots(theme).keys.toSet(), declared);
      expect(_slotFamilies.values.expand((slots) => slots).toSet(), declared);
    });

    test('every slot is filled, so none falls back to Roboto', () {
      final unmapped = _slots(theme).entries
          .where((slot) => slot.value == null)
          .map((slot) => slot.key)
          .toList();

      expect(
        unmapped,
        isEmpty,
        reason:
            'ThemeData merges a supplied TextTheme onto the default '
            'typography, so every slot left null keeps Roboto: '
            '${unmapped.join(', ')}',
      );
    });

    test('every slot lands on its step of the ladder', () {
      final resolved = _slots(theme).map(
        (name, style) => MapEntry(name, style!.fontSize),
      );
      final expected = _slotMap.map(
        (name, mapping) => MapEntry(name, _ladder[mapping.step]),
      );

      expect(resolved, expected);
    });

    test("every slot is set in one of the design's three faces", () {
      final families = {
        for (final face in AppFace.values)
          if (face.family != null) face.family,
      };

      for (final slot in _slots(theme).entries) {
        expect(
          slot.value!.fontFamily,
          isIn(families),
          reason: '${slot.key} is set outside the design’s faces',
        );
      }
    });

    test('every slot carries a weight the design has', () {
      for (final slot in _slots(theme).entries) {
        expect(
          slot.value!.fontWeight,
          anyOf(FontWeight.w400, FontWeight.w500),
          reason:
              'the design has exactly two weights — Plex Sans 400 body / 500 '
              'controls, Fraunces 400 — and ${slot.key} asks for a third',
        );
      }
    });

    test(
      'a slot matches its step exactly, tracking and line height included',
      () {
        for (final slot in _slots(theme).entries) {
          final step = steps[_slotMap[slot.key]!.step]!;

          expect(slot.value!.fontSize, step.fontSize);
          expect(
            slot.value!.letterSpacing,
            step.letterSpacing,
            reason:
                '${slot.key} would set its own tracking, which the step '
                'already carries',
          );
          expect(slot.value!.height, step.height);
        }
      },
    );

    test('a slot takes the ink its role calls for, not its step’s', () {
      for (final slot in _slots(theme).entries) {
        final takesInk = _slotMap[slot.key]!.ink;

        expect(
          slot.value!.color,
          takesInk ? mood.ink : mood.inkMute,
          reason: takesInk
              ? '${slot.key} names a title or the copy under one; muting it '
                    'would grey out text the reader is meant to read'
              : '${slot.key} is a support or label slot, and muted by role',
        );
      }
    });

    test("the mapping never inverts Material's own order", () {
      for (final family in _slotFamilies.entries) {
        final sizes = [
          for (final slot in family.value) _ladder[_slotMap[slot]!.step]!,
        ];

        for (var slot = 1; slot < sizes.length; slot++) {
          expect(
            sizes[slot],
            lessThanOrEqualTo(sizes[slot - 1]),
            reason:
                '${family.value[slot]} maps larger than '
                '${family.value[slot - 1]}, so the ${family.key} family reads '
                'upside down',
          );
        }
      }
    });
  });

  group('the ladder is the only place a size is chosen', () {
    test('no step accessor takes a size', () {
      final source = File('lib/shared/theme/app_text.dart').readAsStringSync();

      expect(
        RegExp(r'[({,]\s*(double|num)\??\s+fontSize').hasMatch(source),
        isFalse,
        reason:
            'a fontSize parameter puts the ladder back at the call sites it '
            'exists to remove',
      );
    });

    test('no widget in lib/ sets a literal font size', () {
      final offenders = <String>[];

      for (final file
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        // The ladder itself is where sizes live.
        if (file.path.endsWith('shared/theme/app_text.dart')) continue;

        final source = file.readAsStringSync();
        // A *literal* size is a hand-picked one, and off-ladder by definition.
        // A computed one — `fontSize: letter.size` in the mascot's drifting Zzz
        // — is animation geometry, sized to the drawing like the coordinates
        // beside it, and no more a type decision than an x-offset is.
        for (final match in RegExp(
          r'fontSize:\s*[0-9]',
        ).allMatches(source)) {
          offenders.add('${file.path}: ${match.group(0)}');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'these set a font size directly instead of naming a step on the '
            'ladder:\n${offenders.join('\n')}',
      );
    });
  });
}
