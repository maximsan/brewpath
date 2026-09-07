import 'dart:io';

import 'comment_blocks.dart';

/// Reports every comment block over the cap in the Dart files given, or with
/// `--changed [base]` in the files changed against a base ref (default
/// `origin/main`). No baseline: a file this sees must be clean. Exit 1 on any.
/// Runs with plain `dart`, so it needs no package resolution.
void main(List<String> arguments) {
  final files = arguments.isNotEmpty && arguments.first == '--changed'
      ? _changedDartFiles(arguments.length > 1 ? arguments[1] : 'origin/main')
      : arguments;

  final offenders = <String>[
    for (final path in files.where(_isHandWritten))
      for (final block in commentBlocksIn(File(path).readAsStringSync()))
        if (block.lines > maxCommentLines)
          '$path:${block.line} runs ${block.lines} lines',
  ];
  if (offenders.isEmpty) return;

  stderr
    ..writeln(
      'A comment block runs $maxCommentLines lines at most: say what the '
      'member is, and one line of what is not obvious (CLAUDE.md, Comments).',
    )
    ..writeln(offenders.join('\n'));
  exitCode = 1;
}

bool _isHandWritten(String path) =>
    path.endsWith('.dart') &&
    !path.endsWith('.g.dart') &&
    !path.endsWith('.freezed.dart') &&
    !path.contains('test/generated/') &&
    File(path).existsSync();

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
