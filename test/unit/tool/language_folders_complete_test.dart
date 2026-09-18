// ADR-0026 lets the tool mark a language complete and asks for a test that
// re-checks the claim. This is that test: it re-runs the completeness check
// over every folder in the tree, so a folder that ships half-translated fails
// here rather than showing a reader English inside their own language.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const _folders = 'assets/content/l10n';

List<String> _shippedLanguages() {
  final root = Directory(_folders);
  if (!root.existsSync()) return const [];
  return root
      .listSync()
      .whereType<Directory>()
      .map((it) => p.basename(it.path))
      .toList()
    ..sort();
}

void main() {
  test('every language folder in the tree is complete', () {
    for (final code in _shippedLanguages()) {
      final result = Process.runSync('node', [
        'tool/draft_language.js',
        'check',
        code,
      ]);

      expect(
        result.exitCode,
        0,
        reason:
            'assets/content/l10n/$code is not complete, so the app must not '
            'offer it:\n${result.stderr}',
      );
    }
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
