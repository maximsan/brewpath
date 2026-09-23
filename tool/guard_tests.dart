import 'dart:io';

import 'comment_blocks.dart';

/// Read one of these and a test is asserting a rule about how the app is
/// built, over files it does not own. Icons are among them because a mark is
/// drawn from the design, not authored the way the course is.
const guardRoots = [
  'lib/',
  'docs/',
  'prototype/',
  'assets/icons',
  'pubspec.yaml',
  'analysis_options.yaml',
];

/// A test that drives one of the extractor scripts, and the authored course.
const toolRoot = 'tool/';
const contentRoot = 'assets/';

/// Every root a test could name for a reason worth classifying.
const List<String> repoPaths = [...guardRoots, toolRoot, contentRoot];

/// Tests that name a repo path and are still not guards, each with the reason.
///
/// Listed rather than pattern-matched: every pattern that excluded these also
/// excluded a real guard. A list fails closed — a new test is swept until
/// someone puts it here on purpose, which is the opposite of the filename
/// convention this replaces.
const notGuards = <String, String>{
  'test/unit/content_rules_test.dart': 'validates the authored course',
  'test/unit/tool/extract_content_test.dart':
      'tests the extractor, and is slow',
  'test/unit/tool/extract_card_art_test.dart': 'tests the extractor',
  'test/unit/tool/translatable_fields_test.dart': 'tests the extractor',
  'test/unit/tool/word_search_test.dart': 'tests the extractor',
  'test/unit/tool/language_folders_complete_test.dart': 'tests the drafter',
};

/// The shared reader every guard is meant to go through.
const _sharedReader = 'support/dart_sources.dart';

/// Every repo root [source] names in a string, wherever it writes it: inside
/// the call, in a `const` beside it, in a list of them.
///
/// Looking only inside `File(…)` is what missed three of these — they keep
/// their paths in a constant — so this asks the cruder question instead.
Iterable<String> repoRootsNamed(String source) {
  final plain = withoutComments(source);
  return repoPaths.where(
    (root) => plain.contains("'$root") || plain.contains('"$root'),
  );
}

/// Every test file under `test/`.
Iterable<File> testFiles() => Directory('test')
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('_test.dart'));

/// Whether [file] reads the repo's own source to assert a rule about it.
///
/// Matched by what it reads, not by what it is called: a filename convention
/// stops guarding the moment someone names a file plainly, which is how
/// thirteen of these went unswept until #662.
bool isGuard(File file) {
  if (notGuards.containsKey(file.path)) return false;
  if (file.path.endsWith('_guard_test.dart')) return true;
  final source = file.readAsStringSync();
  if (source.contains(_sharedReader)) return true;
  return repoRootsNamed(source).any(guardRoots.contains);
}

/// Every guard test, in a stable order.
List<String> guardTestPaths() => [
  for (final file in testFiles())
    if (isGuard(file)) file.path,
]..sort();

/// Writes them one per line, for the pre-push hook to hand to `flutter test`.
void main() => guardTestPaths().forEach(stdout.writeln);
