/// Reading the app's own source as test input: which files are hand-written,
/// and what the string literals in one are. The comment scanner lives in
/// `tool/comment_blocks.dart`, shared with the pre-push and agent hooks.
library;

import 'dart:io';

export '../../tool/comment_blocks.dart';

/// Every hand-written Dart source under [root], relative to the package root.
/// Generated code mirrors identifiers rather than authoring them.
Iterable<File> dartSourcesUnder(String root) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .where((file) => !file.path.endsWith('.g.dart'))
    .where((file) => !file.path.endsWith('.freezed.dart'));

/// Single- and double-quoted string literals in [source].
///
/// Deliberately crude: it over-collects rather than under-collects, because a
/// literal this misses is a literal the rules stop protecting.
Iterable<String> stringLiteralsIn(String source) sync* {
  final pattern = RegExp("'([^'\\n]*)'|\"([^\"\\n]*)\"");
  for (final match in pattern.allMatches(source)) {
    yield match.group(1) ?? match.group(2) ?? '';
  }
}
