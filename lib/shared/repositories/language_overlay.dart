/// Laying a language folder's records over the English master.
///
/// Pure on purpose, like `bank_envelope.dart` next door: the rules a
/// translation obeys are testable without staging an asset. ADR-0008 makes
/// English the master and the fallback; ADR-0027 keeps the fallback for
/// *missing* text only.
library;

import 'package:brew_path/shared/repositories/content_assembly.dart';

/// Which English text a translated entry was made from, field by field.
///
/// A fingerprint per piece of text, not per entry, so a typo fixed in one
/// paragraph leaves its neighbours alone (ADR-0026).
const String translatedFromField = 'translatedFrom';

/// Which of a translated entry's fields a native speaker has read.
///
/// A language ships on its draft and review follows, so "live" and "read" are
/// different facts and need different marks (ADR-0026).
const String nativeReviewedField = 'nativeReviewed';

/// Lists that are search keys, not prose, so a language sets its own length.
///
/// A term's aliases are its inflected forms — ten in Polish where English
/// needs three (ADR-0025) — and the length rule below exists to stop
/// *prose* being silently replaced, which these are not.
const Set<String> searchKeyFields = {'aliases'};

/// Fields a language owns outright, which never fall back to English.
///
/// Nobody is owed one, so an omission is an answer rather than a gap
/// (ADR-0025). Matched by bare name at every depth, and a match drops the
/// master's own value, so a name here must mean the same thing in every bank
/// that carries it.
const Set<String> fieldsThatNeverFallBack = {'pron'};

/// The translation tool's bookkeeping, stripped before a model sees a record.
///
/// It travels in the folder because the folder is both what the owner reviews
/// and what the app ships; nothing on a device may read it. Stripped at every
/// depth, because ADR-0026 marks a piece of text wherever it sits.
const Set<String> bookkeepingFields = {
  translatedFromField,
  nativeReviewedField,
};

/// [master]'s records with [translated]'s text laid over them, by id.
///
/// Per field at every depth: a translated field wins, anything omitted stays
/// English bar the fields a language owns outright, and a short list or an
/// unknown field is refused the way ADR-0018 refuses broken content.
List<Map<String, dynamic>> overlayTranslations({
  required List<Map<String, dynamic>> master,
  required List<Map<String, dynamic>> translated,
  required String assetPath,
}) {
  final byId = <Object?, Map<String, dynamic>>{};
  for (final record in translated) {
    final id = record['id'] as Object?;
    if (byId.containsKey(id)) {
      throw ContentFormatException(
        '$assetPath translates "$id" twice — one entry per id, so nothing but '
        'the file order decides which of the two a reader would get',
      );
    }
    byId[id] = record;
  }

  final records = [
    for (final record in master)
      _mergeRecord(record, byId.remove(record['id']), assetPath),
  ];
  if (byId.isNotEmpty) {
    throw ContentFormatException(
      '$assetPath translates "${byId.keys.first}", which the English bank '
      'no longer carries — redraft the folder against the current master',
    );
  }
  return records;
}

/// [master] with [translation] over it, or [master] where none was drafted.
Map<String, dynamic> _mergeRecord(
  Map<String, dynamic> master,
  Map<String, dynamic>? translation,
  String assetPath,
) => translation == null
    ? master
    : _mergeMap(master, translation, '$assetPath entry "${master['id']}"');

/// [master]'s fields with [translation]'s written over them, bookkeeping gone.
///
/// [where] names the entry and the field path under it, so a refusal says
/// which piece of text to redraft rather than which file.
Map<String, dynamic> _mergeMap(
  Map<String, dynamic> master,
  Map<String, dynamic> translation,
  String where,
) {
  final merged = <String, dynamic>{...master}
    ..removeWhere((field, _) => fieldsThatNeverFallBack.contains(field));
  for (final field in translation.entries) {
    if (bookkeepingFields.contains(field.key)) continue;
    if (!master.containsKey(field.key)) {
      throw ContentFormatException(
        '$where translates "${field.key}", which the master has no field for '
        '— check it against the English bank, because a misspelt key leaves '
        'the real one in English',
      );
    }
    if (field.value == null && fieldsThatNeverFallBack.contains(field.key)) {
      continue;
    }
    merged[field.key] = _mergeValue(
      master[field.key],
      field.value,
      '$where field "${field.key}"',
      setsItsOwnLength: searchKeyFields.contains(field.key),
    );
  }
  return merged..removeWhere((field, _) => bookkeepingFields.contains(field));
}

/// [translation] where it carries text, [master] where it does not.
///
/// Recurses so the fallback reaches a lesson's cards and a help entry's steps.
/// [setsItsOwnLength] drops the length rule for a search-key list, never the
/// shape check — a lone string must not land where the master holds a list.
Object? _mergeValue(
  Object? master,
  Object? translation,
  String where, {
  bool setsItsOwnLength = false,
}) {
  if (translation == null) return master;
  if (master is Map<String, dynamic> && translation is Map<String, dynamic>) {
    return _mergeMap(master, translation, where);
  }
  if (master is List && translation is List) {
    if (setsItsOwnLength) return List<Object?>.from(translation);
    if (master.length != translation.length) {
      throw ContentFormatException(
        '$where lists ${translation.length} where the master lists '
        '${master.length} — a list is translated whole or left out, because a '
        'short one replaces the English rather than falling back to it',
      );
    }
    return [
      for (var index = 0; index < master.length; index++)
        _mergeValue(
          master[index],
          translation[index],
          '$where item '
          '${index + 1}',
        ),
    ];
  }
  if (_isNested(master) || _isNested(translation)) {
    throw ContentFormatException(
      '$where is ${_shape(translation)} where the master has ${_shape(master)} '
      '— redraft the folder against the current master',
    );
  }
  return translation;
}

/// Whether [value] holds text under it rather than being text.
bool _isNested(Object? value) => value is Map || value is List;

/// What [value] is, in the words a refusal uses.
String _shape(Object? value) => switch (value) {
  Map() => 'a group of fields',
  List() => 'a list',
  null => 'nothing',
  _ => 'a single value',
};
