/// Reading a generated bank off the asset bundle, in the language that ships.
///
/// What a bank *means* lives next to the models; getting its records out of
/// the bundle lives here. This half is only the IO — whether what came back is
/// usable is decided by `bank_envelope.dart`, and how a language folder lands
/// on the master by `language_overlay.dart`, both pure.
library;

import 'dart:convert';

import 'package:brew_path/shared/content/content_language.dart';
import 'package:brew_path/shared/repositories/bank_envelope.dart';
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:brew_path/shared/repositories/language_overlay.dart';
import 'package:flutter/services.dart';

/// The raw records inside [bank]'s envelope, in [language].
///
/// A bank that is missing, malformed, empty, or written against a different
/// schema version throws — including a language's own copy, because ADR-0008
/// ships a language only once its folder is whole, so a gap in it is a build
/// defect rather than something to read around.
Future<List<Map<String, dynamic>>> loadBankRecords(
  String bank, {
  ContentLanguage language = activeContentLanguage,
  AssetBundle? bundle,
}) async {
  final masterPath = masterBankPath(bank);
  final master = await _readRecords(masterPath, bundle);

  final translatedPath = translatedBankPath(bank, language);
  if (translatedPath == null) return master;

  return overlayTranslations(
    master: master,
    translated: await _readRecords(translatedPath, bundle),
    assetPath: translatedPath,
  );
}

/// Reads a generated bank and parses each of its records.
///
/// A record that fails to parse names the folder it could have come from as
/// well as the master, because by here the two have already been merged.
Future<List<T>> loadBank<T>(
  String bank,
  T Function(Map<String, dynamic>) fromJson, {
  ContentLanguage language = activeContentLanguage,
  AssetBundle? bundle,
}) async {
  final records = await loadBankRecords(
    bank,
    language: language,
    bundle: bundle,
  );
  try {
    return [for (final record in records) fromJson(record)];
  } on Object catch (error) {
    final translatedPath = translatedBankPath(bank, language);
    final source = translatedPath == null
        ? masterBankPath(bank)
        : '${masterBankPath(bank)} overlaid by $translatedPath';
    throw ContentFormatException('$source holds an unreadable record: $error');
  }
}

/// The records in the bank at [assetPath], or a refusal naming the file.
Future<List<Map<String, dynamic>>> _readRecords(
  String assetPath,
  AssetBundle? bundle,
) async {
  final String raw;
  try {
    raw = await (bundle ?? rootBundle).loadString(assetPath);
  } on Object catch (error) {
    throw ContentFormatException('$assetPath could not be read: $error');
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException catch (error) {
    throw ContentFormatException('$assetPath is not valid JSON: $error');
  }

  return bankRecords(decoded, assetPath: assetPath);
}
