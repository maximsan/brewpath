import 'dart:io';

import 'comment_blocks.dart';

/// Reports every comment block over the cap in the Dart files given, and in a
/// test file every doc comment on `main` or a test body. With `--changed`
/// and an optional base ref (default `origin/main`) it reads the files changed
/// against that base. Every file it sees must be clean; exit 1 on any offender.
/// Runs with plain `dart`, so it needs no package resolution.
void main(List<String> arguments) {
  final files = arguments.isNotEmpty && arguments.first == '--changed'
      ? _changedDartFiles(arguments.length > 1 ? arguments[1] : 'origin/main')
      : arguments;

  final overruns = <String>[];
  final testDocs = <String>[];
  for (final path in files.where(_isHandWritten)) {
    final source = File(path).readAsStringSync();
    for (final block in commentBlocksIn(source)) {
      if (block.lines > maxCommentLines) {
        overruns.add('$path:${block.line} runs ${block.lines} lines');
      }
    }
    if (_isTestFile(path)) {
      for (final line in testDocCommentsIn(source)) {
        testDocs.add('$path:$line');
      }
    }
  }
  if (overruns.isEmpty && testDocs.isEmpty) return;

  if (overruns.isNotEmpty) {
    stderr
      ..writeln(
        'A comment block runs $maxCommentLines lines at most: say what the '
        'member is, and one line of what is not obvious (CLAUDE.md, '
        'Comments).',
      )
      ..writeln(overruns.join('\n'));
  }
  if (testDocs.isNotEmpty) {
    stderr
      ..writeln(
        'A test file carries no doc comment on main or on a test body: the '
        'test name is the documentation (CLAUDE.md, Comments).',
      )
      ..writeln(testDocs.join('\n'));
  }
  exitCode = 1;
}

bool _isHandWritten(String path) =>
    path.endsWith('.dart') &&
    !path.endsWith('.g.dart') &&
    !path.endsWith('.freezed.dart') &&
    !path.contains('test/generated/') &&
    File(path).existsSync();

bool _isTestFile(String path) =>
    path.endsWith('_test.dart') &&
    (path.contains('test/') || path.contains('integration_test/'));

List<String> _changedDartFiles(String base) {
  final diff = Process.runSync('git', [
    'diff',
    '--name-only',
    '--diff-filter=ACMR',
    '$base...HEAD',
    '--',
    '*.dart',
  ]);
  if (diff.exitCode != 0) {
    stderr.write(diff.stderr);
    exit(2);
  }
  return (diff.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .toList();
}
