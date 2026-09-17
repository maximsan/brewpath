import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/shared/content/content_language.dart';
import 'package:brew_path/shared/models/content/companion_line.dart';
import 'package:brew_path/shared/repositories/bank_loader.dart';
import 'package:flutter/services.dart';

/// Loads and caches the companion's speech lines from the `companion_lines`
/// bank, so a language folder reaches them like any other content (#604).
class CompanionLinesRepository {
  CompanionLines? _cache;

  /// Loads and caches the companion lines.
  ///
  /// [language] and [bundle] exist for tests staging a folder English does not
  /// ship yet; production reads the active language off the real bundle.
  Future<CompanionLines> getLines({
    ContentLanguage language = activeContentLanguage,
    AssetBundle? bundle,
  }) async => _cache ??= CompanionLines.fromRecords(
    await loadBank(
      'companion_lines',
      CompanionLine.fromJson,
      language: language,
      bundle: bundle,
    ),
  );
}
