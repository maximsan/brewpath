/// Reading the app's own source as test input: which files are hand-written,
/// and how to split one into comments and code so a guard about prose never
/// reads a string literal, and a guard about literals never reads prose.
library;

import 'dart:io';

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

/// Every comment in [source], line and block alike, one entry per comment.
/// A `//` inside a string literal is not a comment.
Iterable<String> commentsIn(String source) =>
    _runs(source).where((run) => run.isComment).map((run) => run.text);

/// [source] with its comments removed and its string literals kept.
String withoutComments(String source) =>
    _runs(source).where((run) => !run.isComment).map((run) => run.text).join();

typedef _Run = ({bool isComment, String text});

/// [source] cut into comments and the code between them, in order and whole.
Iterable<_Run> _runs(String source) sync* {
  var codeStart = 0;
  var index = 0;
  while (index < source.length) {
    if (source.startsWith('//', index)) {
      yield (isComment: false, text: source.substring(codeStart, index));
      final end = _lineEnd(source, index);
      yield (isComment: true, text: source.substring(index, end));
      index = codeStart = end;
    } else if (source.startsWith('/*', index)) {
      yield (isComment: false, text: source.substring(codeStart, index));
      final end = _blockCommentEnd(source, index);
      yield (isComment: true, text: source.substring(index, end));
      index = codeStart = end;
    } else if (_opensString(source, index)) {
      index = _stringEnd(source, index);
    } else {
      index++;
    }
  }
  yield (isComment: false, text: source.substring(codeStart));
}

int _lineEnd(String source, int from) {
  final newline = source.indexOf('\n', from);
  return newline == -1 ? source.length : newline;
}

/// Block comments nest in Dart, so `/* a /* b */ c */` is one comment.
int _blockCommentEnd(String source, int from) {
  var depth = 1;
  var index = from + 2;
  while (index < source.length) {
    if (source.startsWith('/*', index)) {
      depth++;
      index += 2;
    } else if (source.startsWith('*/', index)) {
      depth--;
      index += 2;
      if (depth == 0) return index;
    } else {
      index++;
    }
  }
  return source.length;
}

bool _isQuote(String char) => char == "'" || char == '"';

bool _opensString(String source, int at) {
  final char = source[at];
  if (_isQuote(char)) return true;
  return char == 'r' && at + 1 < source.length && _isQuote(source[at + 1]);
}

/// The index just past the string literal opening at [from]: raw or not,
/// single- or triple-quoted, escapes and `${…}` interpolations included.
int _stringEnd(String source, int from) {
  final raw = source[from] == 'r';
  final quoteAt = raw ? from + 1 : from;
  final quote = source[quoteAt];
  final triple = source.startsWith(quote * 3, quoteAt);
  final closer = triple ? quote * 3 : quote;
  var index = quoteAt + closer.length;
  while (index < source.length) {
    final char = source[index];
    if (!raw && char == r'\') {
      index += 2;
    } else if (!raw && char == r'$' && source.startsWith('{', index + 1)) {
      index = _interpolationEnd(source, index + 2);
    } else if (source.startsWith(closer, index)) {
      return index + closer.length;
    } else if (!triple && char == '\n') {
      return index;
    } else {
      index++;
    }
  }
  return source.length;
}

/// The index just past the `}` closing an interpolation whose body starts at
/// [from]. Strings inside it are skipped whole, so their braces do not count.
int _interpolationEnd(String source, int from) {
  var depth = 1;
  var index = from;
  while (index < source.length) {
    if (_opensString(source, index)) {
      index = _stringEnd(source, index);
    } else {
      final char = source[index];
      if (char == '{') depth++;
      if (char == '}') depth--;
      index++;
      if (depth == 0) return index;
    }
  }
  return source.length;
}
