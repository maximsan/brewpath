import 'package:flutter/material.dart';

/// Maps a module's glyph name to a Material icon so each module — and each
/// collectible card derived from one — reads with its own identity across the
/// Learn, Path and Cards screens. Accepts both the bare form (`beans`) and the
/// prefixed one (`ic_beans`); falls back to a generic book icon for names the
/// course does not use.
IconData moduleIcon(String iconName) {
  final key = iconName.startsWith('ic_') ? iconName.substring(3) : iconName;
  switch (key) {
    case 'beans':
      return Icons.eco;
    case 'processing':
      return Icons.water_drop;
    case 'roasting':
      return Icons.local_fire_department;
    case 'grind':
      return Icons.grain;
    case 'brewing':
      return Icons.coffee_maker;
    default:
      return Icons.menu_book;
  }
}
