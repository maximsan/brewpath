/// Laying a language folder's records over the English master.
///
/// Pure on purpose, like `bank_envelope.dart` next door: the rules a
/// translation obeys are testable without staging an asset. ADR-0008 makes
/// English the master and the fallback; ADR-0026 keeps the fallback for
/// *missing* entries only.
library;

import 'package:brew_path/shared/repositories/content_assembly.dart';

/// The field a drafted entry carries its approval fingerprint in.
///
/// Written and read by the translation tool (ADR-0025) and stripped here, so
/// no model ever has to know the pipeline exists.
const String approvedAgainstField = 'approvedAgainst';

/// [master]'s records with [translated]'s text laid over them, by id.
///
/// Per entry and per field: a translated field wins, anything the folder omits
/// stays English. Staleness is deliberately invisible — ADR-0026 shows the old
/// translation until its replacement is approved, so there is nothing to check.
List<Map<String, dynamic>> overlayTranslations({
  required List<Map<String, dynamic>> master,
  required List<Map<String, dynamic>> translated,
  required String assetPath,
}) {
  final byId = {
    for (final record in translated) record['id'] as Object?: record,
  };
  final records = [
    for (final record in master) _merge(record, byId.remove(record['id'])),
  ];
  if (byId.isNotEmpty) {
    throw ContentFormatException(
      '$assetPath translates "${byId.keys.first}", which the English bank '
      'no longer carries — redraft the folder against the current master',
    );
  }
  return records;
}

/// [master] with [translation]'s fields written over it, bookkeeping removed.
Map<String, dynamic> _merge(
  Map<String, dynamic> master,
  Map<String, dynamic>? translation,
) {
  if (translation == null) return master;
  return {...master, ...translation}..remove(approvedAgainstField);
}
