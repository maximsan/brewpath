import 'dart:ui';

import 'package:brew_path/features/studio/domain/grove_swatch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("reads the bank's authored swatches", () {
    // The four the bank ships, so a change to their format fails here rather
    // than showing a learner four blank dots.
    expect(swatchColor('#6B7F5A'), const Color(0xFF6B7F5A));
    expect(swatchColor('#C98A3C'), const Color(0xFFC98A3C));
    expect(swatchColor('#7E93A8'), const Color(0xFF7E93A8));
    expect(swatchColor('#D9DEE0'), const Color(0xFFD9DEE0));
  });

  test('a missing hash still reads', () {
    expect(swatchColor('6B7F5A'), const Color(0xFF6B7F5A));
  });

  test('anything it cannot read is null, never a wrong colour', () {
    // Null costs the pill its dot. A fallback colour would show a swatch that
    // is confidently wrong about what the light does.
    expect(swatchColor(''), isNull);
    expect(swatchColor('#FFF'), isNull);
    expect(swatchColor('#GGGGGG'), isNull);
    expect(swatchColor('#6B7F5A00'), isNull);
  });
}
