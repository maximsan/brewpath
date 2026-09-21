import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:flutter_test/flutter_test.dart';

/// The settings row called [label].
///
/// By the label it was given rather than by the text it draws, so a finder
/// does not have to know how the row renders it.
Finder settingsRow(String label) => find.byWidgetPredicate(
  (widget) => widget is SettingsNavRow && widget.label == label,
);

/// The section heading called [label], which renders uppercase.
Finder settingsSection(String label) => find.byWidgetPredicate(
  (widget) => widget is SmallcapsLabel && widget.text == label,
);
