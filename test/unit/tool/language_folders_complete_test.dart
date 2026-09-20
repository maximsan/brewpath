// ADR-0026 lets the tool mark a language complete and asks for a test that
// re-checks the claim. This is that test: it re-runs the completeness check
// over every folder pubspec.yaml bundles, so a folder that ships
// half-translated fails here rather than showing a reader English inside
// their own language. A folder in the tree that pubspec.yaml does not bundle
// is a draft Flutter never ships: nothing is offered, so it is left alone.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _folders = 'assets/content/l10n';

/// One `- assets/content/l10n/<code>/` line under `assets:`, capturing the code.
final RegExp _bundledFolder = RegExp(
  r'^\s*-\s*assets/content/l10n/([^/\s]+)/\s*$',
  multiLine: true,
);

/// The language codes whose folders [pubspec] bundles, in the order listed.
List<String> bundledLanguages(String pubspec) =>
    _bundledFolder.allMatches(pubspec).map((match) => match.group(1)!).toList();

void main() {
  test('every language folder pubspec.yaml bundles is complete', () {
    final codes = bundledLanguages(File('pubspec.yaml').readAsStringSync());
    for (final code in codes) {
      final result = Process.runSync('node', [
        'tool/draft_language.js',
        'check',
        code,
      ]);

      expect(
        result.exitCode,
        0,
        reason:
            '$_folders/$code is bundled but not complete, so the app must not '
            'ship it:\n${result.stderr}',
      );
    }
  });

  test('only the language folders are read off pubspec.yaml', () {
    const pubspec = '''
flutter:
  assets:
    - assets/content/
    - assets/content/generated/
    # - assets/content/l10n/be/   (a draft, not yet bundled)
    - assets/content/l10n/pl/
    - assets/icons/
''';

    expect(bundledLanguages(pubspec), ['pl']);
  });

  test('pubspec.yaml never bundles a folder the tree does not have', () {
    final onDisk = Directory(_folders).existsSync()
        ? Directory(_folders).listSync().whereType<Directory>().length
        : 0;
    final bundled = bundledLanguages(
      File('pubspec.yaml').readAsStringSync(),
    ).length;

    // A draft may sit in the tree unlisted while it is filled, so the tree can
    // hold more folders than pubspec lists — never fewer.
    expect(bundled, lessThanOrEqualTo(onDisk));
  });

  test('the check refuses a language whose folder is not there at all', () {
    final result = Process.runSync('node', [
      'tool/draft_language.js',
      'check',
      'zz',
    ]);

    expect(result.exitCode, isNot(0));
  });

  test('the master is not a folder, and the tool says so', () {
    final result = Process.runSync('node', [
      'tool/draft_language.js',
      'check',
      'en',
    ]);

    expect(result.exitCode, isNot(0));
    expect(result.stderr.toString(), contains('master'));
  });
}
