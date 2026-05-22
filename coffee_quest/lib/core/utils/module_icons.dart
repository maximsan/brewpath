import 'package:flutter/material.dart';

/// Maps a module's content-defined `iconName` to a Material icon so each
/// module reads with its own identity across the Learn and Path screens.
/// Falls back to a generic book icon for unknown names.
IconData moduleIcon(String iconName) {
  switch (iconName) {
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
