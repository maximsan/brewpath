/// Laying a language folder's records over the English master.
///
/// Pure on purpose, like `bank_envelope.dart` next door: the rules a
/// translation obeys are testable without staging an asset. ADR-0008 makes
/// English the master and the fallback; ADR-0026 keeps the fallback for
/// *missing* text only.
library;

import 'package:brew_path/shared/repositories/content_assembly.dart';

/// Which English text a translated entry was made from, field by field.
///
/// A fingerprint per piece of text, not per entry, so a typo fixed in one
/// paragraph leaves its neighbours alone (ADR-0025).
const String translatedFromField = 'translatedFrom';

/// Which of a translated entry's fields a native speaker has read.
///
/// A language ships on its draft and review follows, so "live" and "read" are
/// different facts and need different marks (ADR-0025).
const String nativeReviewedField = 'nativeReviewed';

/// The translation tool's bookkeeping, stripped before a model sees a record.
///
/// It travels in the folder because the folder is both what the owner reviews
/// and what the app ships; nothing on a device may read it.
const Set<String> bookkeepingFields = {
  translatedFromField,
  nativeReviewedField,
};

/// [master]'s records with [translated]'s text laid over them, by id.
///
/// Per entry and per field: a translated field wins, anything omitted stays
/// English, and ADR-0026 leaves staleness invisible. An id the master lacks
/// throws the way ADR-0018 refuses broken content, while a *missing* id is the
/// fallback ADR-0008 asks for — so only one direction is fatal.
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
  final merged = {...master, ...translation};
  return merged..removeWhere((field, _) => bookkeepingFields.contains(field));
}
