import 'package:flutter_test/flutter_test.dart';

import '../../../support/dart_sources.dart';

/// Weight is not a number a call site passes.
///
/// `AppFace` pairs each family with the one weight the bundle carries for it —
/// Fraunces 400, Plex Sans 400/500, Plex Mono 500. A `copyWith(fontWeight: …)`
/// keeps the family and changes the number, which is the one combination that
/// fails silently: Flutter synthesises the missing cut by smearing the
/// letterforms instead of throwing. 53 sites once asked for w600/w700/w800
/// across three families that ship none of them, and one asked Plex Mono for a
/// 400 it has never had.
///
/// Whether each face's own weight is actually bundled is the sibling question,
/// and `font_families_test.dart` asks it against `pubspec.yaml`. This one only
/// asks who is allowed to name a weight at all.
void main() {
  /// The one file allowed to name a weight: the face table itself.
  const faceTable = 'app_text.dart';

  /// What counts as naming a weight.
  ///
  /// The constructor and the variable axis are here because the enum is not
  /// the only door: `FontWeight(600)` and
  /// `fontVariations: [FontVariation('wght', 600)]` reach the same synthesis
  /// by another spelling. `FontWeight.lerp` is exempt — it interpolates two
  /// weights it was handed rather than choosing one.
  const spellings = <String, String>{
    r'FontWeight\.(?!lerp\b)\w+': 'the FontWeight enum',
    r'FontWeight\(': 'the FontWeight constructor',
    "'wght'": 'the wght variable axis',
  };

  test('no call site in lib/ names a font weight', () {
    final offenders = <String>[];

    for (final file in dartSourcesUnder('lib')) {
      if (file.uri.pathSegments.last == faceTable) continue;
      final source = withoutComments(file.readAsStringSync());
      spellings.forEach((pattern, what) {
        for (final match in RegExp(pattern).allMatches(source)) {
          offenders.add('${file.path} reaches for $what: ${match.group(0)}');
        }
      });
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'weight belongs to AppFace, which pairs it with the family that '
          'ships it. Ask for emphasis by taking the slot that carries the '
          "control face — `titleMedium` is `bodyLarge`'s rung at 500, "
          "`labelLarge` is `bodyMedium`'s — never by naming a "
          'number:\n${offenders.join('\n')}',
    );
  });

  test('the guard would catch a weight reintroduced by any spelling', () {
    // A guard nobody has seen fail is a guard nobody knows is wired up.
    const reintroduced = '''
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontVariations: [FontVariation('wght', 700)],
      ),
      const heavier = FontWeight(800);
    ''';

    final caught = [
      for (final pattern in spellings.keys)
        ...RegExp(pattern).allMatches(reintroduced).map((m) => m.group(0)!),
    ];

    expect(caught, containsAll(<String>['FontWeight.w700', "'wght'"]));
    expect(caught, contains('FontWeight('));
  });

  test('interpolating two weights it was handed is not naming one', () {
    // `FontWeight.lerp` chooses nothing — exempting it keeps the guard from
    // crying wolf at an animation, which is how a guard gets disabled.
    final named = RegExp(
      spellings.keys.first,
    ).allMatches('FontWeight.lerp(a, b, t)');

    expect(named, isEmpty);
  });
}
