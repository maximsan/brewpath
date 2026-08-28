import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds one of the design's own marks, the way `find.byIcon` finds a stock
/// glyph.
///
/// A mark is an SVG rather than a glyph in a font, so `find.byIcon` cannot see
/// it — which is why swapping a stock icon for a mark makes any test that
/// located it by `Icons.…` fail rather than quietly pass on nothing.
Finder findMark(AppIcon icon, {bool? active}) => find.byWidgetPredicate(
  (widget) =>
      widget is IconMark &&
      widget.icon == icon &&
      (active == null || widget.active == active),
  description: 'IconMark(${icon.name})',
);
