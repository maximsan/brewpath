/// Reading the app's own source as test input.
///
/// Two guards scan it for strings the product rules forbid — the glossary's
/// ruled-out terms and the companion's no-payout rule — and both need the same
/// two things: which files count as hand-written source, and what the string
/// literals in one are. Kept here because the second copy is what shows which
/// parts are shared.
library;

import 'dart:io';

/// Every hand-written Dart source under [root], relative to the package root.
///
/// Generated code is excluded: it mirrors identifiers rather than authoring
/// them, so a rule about what the app *says* has nothing to police there.
Iterable<File> dartSourcesUnder(String root) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .where((file) => !file.path.endsWith('.g.dart'))
    .where((file) => !file.path.endsWith('.freezed.dart'));

/// Single- and double-quoted string literals in [source].
///
/// Deliberately crude: it over-collects rather than under-collects, because a
/// literal this misses is a literal the rules stop protecting. It reads only
/// literals, so a comment *describing* a forbidden string — including the ones
/// these guards' own docs quote — is not mistaken for the app saying it.
Iterable<String> stringLiteralsIn(String source) sync* {
  final pattern = RegExp("'([^'\\n]*)'|\"([^\"\\n]*)\"");
  for (final match in pattern.allMatches(source)) {
    yield match.group(1) ?? match.group(2) ?? '';
  }
}

/// The comment text in [source], line and block alike, one entry per comment.
///
/// The inverse of [withoutComments], and crude in the same way and for the same
/// reason: a rule about what the code *says about itself* wants prose, and
/// over-collecting is the safe direction.
///
/// ⚠️ **A `//` inside a string literal reads as a comment start here**, so
/// everything after a URL on the same line is collected as prose. Nothing in
/// the repo trips it today; a caller adding a rule about paths should check
/// that first, because a URL sitting above one is exactly the shape that would
/// make this cry wolf.
Iterable<String> commentsIn(String source) sync* {
  // `dotAll` is for the block form only, which spans lines. The line form has
  // to stay `[^\n]*`: with `dotAll` its `.` matches newlines too, so the first
  // `//` in a file swallows everything after it — string literals included,
  // which is how a rule about prose starts reading code.
  final pattern = RegExp(r'/\*.*?\*/|//[^\n]*', dotAll: true);
  for (final match in pattern.allMatches(source)) {
    yield match.group(0)!;
  }
}

/// [source] with its comments removed.
///
/// A sweep that reads prose finds the thing it forbids in the sentence
/// explaining why it is forbidden — which is how a guard earns a reputation
/// for crying wolf, and then gets disabled. Line comments and block comments
/// both go; string literals are left alone, since a rule about literals wants
/// to see them.
String withoutComments(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp('//.*'), '');
