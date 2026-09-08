import 'package:brew_path/core/utils/object_position.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the centre is the centre', () {
    expect(alignmentFromObjectPosition('50% 50%'), Alignment.center);
  });

  test('reads both axes from the top-left corner', () {
    final alignment = alignmentFromObjectPosition('50% 42%');
    expect(alignment.x, closeTo(0, 1e-9));
    expect(alignment.y, closeTo(-0.16, 1e-9));
    expect(alignmentFromObjectPosition('0% 100%'), Alignment.bottomLeft);
  });

  test('centres anything it cannot read', () {
    for (final position in const [
      null,
      '',
      'center',
      '50%',
      '50 42',
      'a% b%',
    ]) {
      expect(alignmentFromObjectPosition(position), Alignment.center);
    }
  });
}
