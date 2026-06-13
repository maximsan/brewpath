import 'package:flutter/material.dart';

/// Maps a content-defined `iconName` to a Material icon so each module —
/// and each collectible card derived from one — reads with its own identity
/// across the Learn, Path, and Cards screens. Accepts both the module form
/// (`beans`) and the card form (`ic_beans`); falls back to a generic book
/// icon for unknown names.
IconData moduleIcon(String iconName) {
  final key = iconName.startsWith('ic_') ? iconName.substring(3) : iconName;
  switch (key) {
    case 'beans':
      return Icons.eco;
    case 'processing':
      return Icons.water_drop;
    case 'roast':
      return Icons.local_fire_department;
    case 'brewing':
      return Icons.coffee_maker;
    case 'taste':
      return Icons.restaurant;
    default:
      return Icons.menu_book;
  }
}
