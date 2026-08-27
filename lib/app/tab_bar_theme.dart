import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The nav family is drawn on a 24×24 grid. The marks themselves are stock
/// Material until #378 ports the design's own; the box they sit in is not.
const double _markBox = 24;

/// The tab bar's theme, so none of it resolves through Material's fallbacks.
///
/// Left undeclared, `NavigationBar` reaches `ColorScheme.secondaryContainer`
/// for its indicator, and that slot is unset — so it falls through a second
/// time to `secondary`, which is [MoodColors.sage]: the token documented
/// "never an action", filling a pill behind the one tab that *is* an action.
/// The design draws no pill at all. An active tab is [MoodColors.accent] ink
/// on the same surface as an inactive one, and that is the whole rule.
NavigationBarThemeData tabBarTheme(MoodColors mood) => NavigationBarThemeData(
  backgroundColor: mood.surface,
  indicatorColor: Colors.transparent,
  iconTheme: WidgetStateProperty.resolveWith(
    (states) => IconThemeData(size: _markBox, color: _tabInk(mood, states)),
  ),
  labelTextStyle: WidgetStateProperty.resolveWith(
    (states) => tabLabelStyle(mood).copyWith(color: _tabInk(mood, states)),
  ),
);

Color _tabInk(MoodColors mood, Set<WidgetState> states) =>
    states.contains(WidgetState.selected) ? mood.accent : mood.inkMute;

/// The tab label: the ladder's micro step in the control face, lettered at the
/// design's own [OffTokens.tabLabelTracking] rather than the rung's.
///
/// Tracking is written in em and multiplied by the size on the way out, the
/// way `AppText` does it — so the size is read back off the style rather than
/// restated here, where it could drift from the rung.
TextStyle tabLabelStyle(MoodColors mood) {
  final base = AppText.micro(mood: mood, face: AppFace.control);
  // Never null: every `AppText` style takes its size from the ladder.
  final size = base.fontSize!;

  return base.copyWith(
    letterSpacing: OffTokens.tabLabelTracking.value * size,
  );
}
