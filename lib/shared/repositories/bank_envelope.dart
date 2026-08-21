/// The contract between the extractor's output and this build.
///
/// Pure on purpose: everything here decides whether a *decoded* envelope is
/// usable, with no bundle, no file system and no Flutter. Reading the bytes
/// lives next door in `bank_loader.dart`, so every way a bank can be
/// unusable is testable without staging an asset.
library;

import 'package:brew_path/shared/repositories/content_assembly.dart';

/// The generated-bank schema version this build is written to read.
///
/// **This number exists twice** — here, and in `tool/extract_content.js`, which
/// stamps it. They cannot share a constant across languages, so instead a test
/// reads the committed banks and asserts they carry this value. Bumping one
/// side alone fails that test rather than surfacing as a refusal on a learner's
/// device.
///
/// The bump rules are documented in the extractor's header, next to the code
/// whose change triggers them. In short: renaming or removing a field, or
/// changing what an existing card kind *means*, is breaking; adding an optional
/// field, a bank, or entries is not.
const int contentSchemaVersion = 1;

/// The records inside a decoded bank envelope, or a refusal naming the problem.
///
/// [decoded] is whatever `jsonDecode` returned; [assetPath] names the bank in
/// every error, because "a bank is malformed" is not actionable and "this bank
/// is malformed" is.
///
/// Every check here throws rather than degrades. The banks ship inside the app,
/// so each of these is a build defect — and the failure that matters is the
/// quiet one: a bank read past its contract yields nulls deep inside a lesson,
/// at the card that needed the field, in front of a learner.
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
/// **Exact, not a minimum.** The banks travel inside the binary, so the two
/// sides always ship together and any difference at all is a build defect —
/// in either direction. A range check would be machinery for a compatibility
/// window that cannot occur, and it would wave through the stale-bank case
/// this exists to catch.
///
/// **Absent is a mismatch, not a pass.** An unstamped bank is precisely the
/// output that shipped before this contract existed.
void _assertVersion(Object? found, {required String assetPath}) {
  if (found == contentSchemaVersion) return;
  final describedAs = found == null
      ? 'no schemaVersion'
      : 'schemaVersion $found';
  throw ContentFormatException(
    '$assetPath carries $describedAs, but this build reads '
    'schemaVersion $contentSchemaVersion — regenerate the banks with '
    'tool/extract_content.js',
  );
}
