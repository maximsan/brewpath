import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The glossary rules **points** and lists *XP* and *score* under _Avoid_
/// (`CONTEXT.md`), and §5.1 is explicit that the currency is points "throughout
/// — code, copy and mascot state".
///
/// A sweep is a one-off; this is the guard that keeps it swept. Twelve
/// user-facing strings said XP when #160 opened, spread across the profile
/// stat, two lesson previews, both result screens, the reset and settings copy,
/// and a label painted into the mascot's reward burst — a set large enough that
/// a rename pass reliably misses one.
///
/// **Scoped to strings a learner can read**, not to identifiers. The storage
/// layer still carries `totalXp` and `xpEarned` column names, which cannot be
/// renamed without a migration the destructive rebuild (#79) owns; renaming
/// them is not what this rule is protecting.
void main() {
  /// Every Dart source file under `lib/`.
  Iterable<File> libSources() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      // Generated code mirrors identifiers, which this rule does not police.
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'));

  /// Single- and double-quoted string literals in [source].
  ///
  /// Deliberately crude: it over-collects rather than under-collects, because a
  /// literal this misses is a literal the rule stops protecting.
  Iterable<String> stringLiterals(String source) sync* {
    final pattern = RegExp("'([^'\\n]*)'|\"([^\"\\n]*)\"");
    for (final match in pattern.allMatches(source)) {
      yield match.group(1) ?? match.group(2) ?? '';
    }
  }

  test('no user-facing string says XP', () {
    final offenders = <String>[];
    for (final file in libSources()) {
      final source = file.readAsStringSync();
      for (final literal in stringLiterals(source)) {
        if (RegExp(r'\bXP\b').hasMatch(literal)) {
          offenders.add('${file.path}: "$literal"');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'the currency is points, not XP (CONTEXT.md, §5.1) — '
          'found:\n${offenders.join('\n')}',
    );
  });
}
