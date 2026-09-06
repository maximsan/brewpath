import 'package:brew_path/features/tour/domain/micro_tip_layout.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the card sits, on a phone with a home indicator and on one without.
void main() {
  test('clears the tab bar by a section gap where the bar shows', () {
    expect(
      microTipBottomInset(safeBottom: 34, tabBarHeight: 80, raised: true),
      34 + 80 + AppSpacing.lg,
    );
  });

  test('sits a hairline above the safe edge where the bar does not', () {
    expect(
      microTipBottomInset(safeBottom: 34, tabBarHeight: 80, raised: false),
      34 + AppSpacing.sm,
    );
  });

  test('a phone with no inset lands on the design’s own figures', () {
    // The design's 112 and 40 are measured over a frame that reserves 28 for
    // the home indicator, so the numbers a device without one gets are those
    // less 28: 84 above the bar, 12 above the edge.
    expect(
      microTipBottomInset(safeBottom: 0, tabBarHeight: 60, raised: true),
      60 + AppSpacing.lg,
    );
    expect(
      microTipBottomInset(safeBottom: 0, tabBarHeight: 60, raised: false),
      AppSpacing.sm,
    );
  });

  test('follows a bar that changes height', () {
    expect(
      microTipBottomInset(safeBottom: 0, tabBarHeight: 96, raised: true),
      greaterThan(
        microTipBottomInset(safeBottom: 0, tabBarHeight: 80, raised: true),
      ),
    );
  });
}
