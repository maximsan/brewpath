/// The contract between the extractor's output and this build.
///
/// Pure on purpose: everything here decides whether a *decoded* envelope is
/// usable, with no bundle, no file system and no Flutter. Reading the bytes
/// lives next door in `bank_loader.dart`, so every way a bank can be unusable
/// is testable without staging an asset.
///
/// Why the app refuses a mismatch rather than coping with one, and what would
/// end the arrangement, is ADR-0006.
library;

import 'package:brew_path/shared/repositories/content_assembly.dart';

/// The generated-bank schema version this build is written to read.
///
/// **This number exists twice** — here, and as `SCHEMA_VERSION` in
/// `tool/extract_content.js`, which stamps it. They cannot share a constant
/// across languages, so a test reads the committed banks and asserts they carry
/// this value: bumping one side alone fails the suite rather than surfacing as
/// a refusal on a learner's device.
///
/// When to bump is documented in the extractor's header, next to the code whose
/// change triggers it.
const int contentSchemaVersion = 1;

/// The records inside a decoded bank envelope, or a refusal naming the problem.
///
/// [decoded] is whatever `jsonDecode` returned; [assetPath] names the bank in
/// every error, because "a bank is malformed" is not actionable and "this bank
/// is malformed" is.
///
/// Every check throws rather than degrades. The banks ship inside the app, so
/// each of these is a build defect — and the one that matters is the quiet
/// one: a bank read past its contract yields nulls deep inside a lesson, at the
/// card that needed the field, in front of a learner.
List<Map<String, dynamic>> bankRecords(
  Object? decoded, {
  required String assetPath,
}) {
  if (decoded is! Map<String, dynamic>) {
    throw ContentFormatException('$assetPath is not a bank envelope');
  }

  _assertVersion(decoded['schemaVersion'], assetPath: assetPath);

  final items = decoded['items'];
  if (items is! List || items.isEmpty) {
    throw ContentFormatException('$assetPath carries no items');
  }
  return items.cast<Map<String, dynamic>>();
}

/// Refuses any bank not stamped at exactly [contentSchemaVersion].
///
/// Exact rather than a minimum, and absent counts as a mismatch: the banks
/// travel inside the binary, so the two sides always ship together and a
/// difference in either direction is a build defect. An unstamped bank is
/// precisely the output that shipped before this contract existed.
///
/// The `is int` is load-bearing. `1.0 == 1` is true of Dart's numbers, so a
/// version that arrived as a double would otherwise pass a check that rejects
/// the string `'1'`.
void _assertVersion(Object? found, {required String assetPath}) {
  if (found is int && found == contentSchemaVersion) return;
  final describedAs = found == null
      ? 'no schemaVersion'
      : 'schemaVersion $found';
  throw ContentFormatException(
    '$assetPath carries $describedAs, but this build reads '
    'schemaVersion $contentSchemaVersion — regenerate the banks with '
    'tool/extract_content.js',
  );
}
