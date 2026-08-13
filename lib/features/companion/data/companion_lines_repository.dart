import 'dart:convert';

import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:flutter/services.dart';

/// Loads and caches the companion's speech lines from the bundled
/// `companion_lines.json` asset.
class CompanionLinesRepository {
  static const String _assetPath = 'assets/content/companion_lines.json';

  CompanionLines? _cache;

  /// Loads and caches the companion lines.
  Future<CompanionLines> getLines() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return _cache = CompanionLines.fromJson(json);
  }
}
