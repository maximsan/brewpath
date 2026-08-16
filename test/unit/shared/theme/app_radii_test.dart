import 'dart:io';

import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the radius stops', () {
    test("are the design's two languages plus the pill", () {
      expect(AppRadii.editorial, 2);
      expect(AppRadii.chrome, 14);
      expect(AppRadii.pill, 999);
    });

    test('stay in their own languages: sharp, soft, then round', () {
      expect(AppRadii.editorial, lessThan(AppRadii.chrome));
      expect(AppRadii.chrome, lessThan(AppRadii.pill));
    });
  });

  test('--r is still 14px in the design bundle', () {
    final css = File('prototype/index.html').readAsStringSync();
    final declared = RegExp(r'--r:\s*(\d+)px').firstMatch(css)?.group(1);

    expect(
      declared,
      isNotNull,
      reason: 'the design bundle no longer declares --r',
    );
    expect(double.parse(declared!), AppRadii.chrome);
  });
}
