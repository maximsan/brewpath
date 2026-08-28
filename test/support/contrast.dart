/// The WCAG contrast ratio, for the guards that check a token *reads* rather
/// than only that it is spelled the way the design spells it.
///
/// Two token tests need it — `mood_colors_test` proves `accentText` clears AA
/// where raw `accent` does not, and `off_token_test` checks the stated reason
/// the rewarded-ad ring is allowed off-token. Kept here because a third copy
/// of a formula is how the three quietly drift apart.
library;

import 'dart:ui';

/// AA's floor for text below the large-text threshold.
const double contrastMinimumSmallText = 4.5;

/// The WCAG 2.x ratio between [a] and [b], from 1 (identical) to 21.
double contrastRatio(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}
