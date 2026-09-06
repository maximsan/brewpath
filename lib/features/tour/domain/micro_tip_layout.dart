import 'package:brew_path/shared/theme/app_spacing.dart';

/// How far above the foot of the screen a micro-tip card sits.
///
/// The design places it 112 from the bottom where the tab bar shows and 40
/// where it does not, over a frame that reserves 28 for the home indicator and
/// draws an 88-tall bar. Here [safeBottom] stands in for that 28 and
/// [tabBarHeight] for the 88, and what is left is the clearance the design
/// draws: a section gap over the bar, a hairline gap over the screen edge.
///
/// Pure, and a function rather than a method, so the arithmetic can be checked
/// without pumping the whole app around it.
double microTipBottomInset({
  required double safeBottom,
  required double tabBarHeight,
  required bool raised,
}) => raised
    ? safeBottom + tabBarHeight + AppSpacing.lg
    : safeBottom + AppSpacing.sm;
