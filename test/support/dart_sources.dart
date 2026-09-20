/// Reading the app's own source as test input: which files are hand-written,
/// and what the string literals in one are. The comment scanner lives in
/// `tool/comment_blocks.dart`, shared with the pre-push and agent hooks.
library;

import 'dart:io';

import '../../tool/comment_blocks.dart';

export '../../tool/comment_blocks.dart';

/// Every hand-written Dart source under [root], relative to the package root.
/// Generated code mirrors identifiers rather than authoring them.
Iterable<File> dartSourcesUnder(String root) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .where((file) => !file.path.endsWith('.g.dart'))
    .where((file) => !file.path.endsWith('.freezed.dart'));

/// A `Semantics(…)` call: the line it opens on, and the named arguments
/// written directly on it rather than on anything nested inside it.
typedef SemanticsCall = ({int line, Map<String, String> arguments});

/// Every `Semantics(…)` call in [source]. `MergeSemantics` and the other names
/// ending in `Semantics` are not matched; a nested call is its own entry.
///
/// Every name is found, which is what a rule about flags reads. A value is
/// verbatim unless it holds a string, which blanks, or a generic's comma,
/// which cuts it short — angle brackets are not counted.
Iterable<SemanticsCall> semanticsCallsIn(String source) sync* {
  final plain = withoutStringLiterals(withoutComments(source));
  for (final match in _semanticsCall.allMatches(plain)) {
    yield (
      line: '\n'.allMatches(plain.substring(0, match.start)).length + 1,
      arguments: _argumentsFrom(plain, match.end - 1),
    );
  }
}

final _semanticsCall = RegExp(r'(?<![A-Za-z0-9_$])Semantics\s*\(');
final _named = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([\s\S]*)$');

/// The named arguments at the top level of the argument list opening at
/// [open], as a map of name to the source text of its value.
Map<String, String> _argumentsFrom(String source, int open) {
  final arguments = <String, String>{};
  var start = open + 1;
  var depth = 0;
  void take(int end) {
    final match = _named.firstMatch(source.substring(start, end).trim());
    if (match != null) arguments[match.group(1)!] = match.group(2)!.trim();
  }

  for (var index = open; index < source.length; index++) {
    final char = source[index];
    if ('([{'.contains(char)) depth++;
    if (')]}'.contains(char)) {
      if (--depth == 0) {
        take(index);
        break;
      }
    }
    if (char == ',' && depth == 1) {
      take(index);
      start = index + 1;
    }
  }
  return arguments;
}

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
