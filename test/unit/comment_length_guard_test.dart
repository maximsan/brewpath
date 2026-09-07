import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';
import 'comment_length_baseline.dart';

void main() {
  const roots = ['lib', 'test', 'integration_test'];

  // Drift schema snapshots under test/generated are build output.
  bool isHandWritten(String path) => !path.startsWith('test/generated/');

  final overruns = <String, List<CommentBlock>>{};
  for (final root in roots) {
    for (final file in dartSourcesUnder(root)) {
      if (!isHandWritten(file.path)) continue;
      final long = commentBlocksIn(
        file.readAsStringSync(),
      ).where((block) => block.lines > maxCommentLines).toList();
      if (long.isNotEmpty) overruns[file.path] = long;
    }
  }

  test('no file has more over-long comment blocks than its baseline', () {
    final grown = <String>[
      for (final MapEntry(key: path, value: blocks) in overruns.entries)
        if (blocks.length > (commentLengthBaseline[path] ?? 0))
          for (final block in blocks)
            '$path:${block.line} runs ${block.lines} lines',
    ];

    expect(
      grown,
      isEmpty,
      reason:
          'a comment block may run $maxCommentLines lines: say what the '
          'member is, and one line of what is not obvious. The argument for '
          'a decision goes in the ADR or issue the code cites. '
          'Found ${grown.length}:\n${grown.join('\n')}',
    );
  });

  test('the baseline holds no file that has since been cleaned', () {
    final stale = <String>[
      for (final MapEntry(key: path, value: allowed)
          in commentLengthBaseline.entries)
        if ((overruns[path]?.length ?? 0) < allowed)
          "  '$path': ${overruns[path]?.length ?? 0},",
    ];

    expect(
      stale,
      isEmpty,
      reason:
          'the baseline only shrinks. Set these entries in '
          'test/unit/comment_length_baseline.dart (drop the zeros):\n'
          '${stale.join('\n')}',
    );
  });
}
