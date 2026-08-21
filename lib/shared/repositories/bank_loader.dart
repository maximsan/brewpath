/// Reading a generated bank off the asset bundle.
///
/// Separated from the repository because this is not knowledge about the
/// course — it is the envelope the extractor writes and the ways that envelope
/// can be unusable. What a bank *means* lives next to the models; getting its
/// records out of the bundle lives here.
///
/// This half is only the IO: bytes, then JSON. Whether what came back is a
/// usable bank — including whether it was written against this build's schema
/// version — is decided by `bank_envelope.dart`, which is pure and therefore
/// testable without staging an asset.
library;

import 'dart:convert';

import 'package:brew_path/shared/repositories/bank_envelope.dart';
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:flutter/services.dart';

/// The raw records inside a generated bank's envelope.
///
/// A bank that is missing, malformed, empty, or written against a different
/// schema version throws. The banks are bundled with the app, so any of those
/// is a build defect — and an empty course that loads cleanly is the one
/// failure nobody notices until a learner opens a tab with nothing in it.
Future<List<Map<String, dynamic>>> loadBankRecords(String assetPath) async {
  final String raw;
  try {
    raw = await rootBundle.loadString(assetPath);
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

/// Reads a generated bank and parses each of its records.
Future<List<T>> loadBank<T>(
  String assetPath,
  T Function(Map<String, dynamic>) fromJson,
) async {
  final records = await loadBankRecords(assetPath);
  try {
    return [for (final record in records) fromJson(record)];
  } on Object catch (error) {
    throw ContentFormatException(
      '$assetPath holds an unreadable record: $error',
    );
  }
}
