import 'dart:io';

import 'comment_blocks.dart';

/// The directories and root files a test can only be reading because it is
/// asserting something about this repository.
const repoPaths = [
  'lib/',
  'tool/',
  'docs/',
  'prototype/',
  'assets/',
  'integration_test/',
  'pubspec.yaml',
  'analysis_options.yaml',
];

/// The one class of repo reader that is not a guard: a content test, which
/// checks the authored course rather than how the code is written.
const contentRoot = 'assets/';

/// A `File('…')` or `Directory('…')` on a name written out in full. A path
/// built by interpolation is a temporary directory, never the repo.
final _repoRead = RegExp(r"(?:File|Directory)\(\s*'([^'$\n]+)'");

/// The shared reader every guard is meant to go through.
const _sharedReader = 'support/dart_sources.dart';

/// Every repo path [source] reads by a literal name.
Iterable<String> repoPathsRead(String source) => _repoRead
    .allMatches(withoutComments(source))
    .map((match) => match.group(1)!)
    .where((path) => repoPaths.any(path.startsWith));

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
  if (file.path.endsWith('_guard_test.dart')) return true;
  final source = file.readAsStringSync();
  if (source.contains(_sharedReader)) return true;
  final read = repoPathsRead(source);
  return read.isNotEmpty && !read.every((path) => path.startsWith(contentRoot));
}

/// Every guard test, in a stable order.
List<String> guardTestPaths() => [
  for (final file in testFiles())
    if (isGuard(file)) file.path,
]..sort();

/// Writes them one per line, for the pre-push hook to hand to `flutter test`.
void main() => guardTestPaths().forEach(stdout.writeln);
