import 'dart:io';

import 'package:brew_path/features/companion/presentation/roasty_body.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The plate is the one mascot colour the design names as a token
/// (`--roasty-plate`), because it is a decision rather than a drawing: paper
/// pinned to one value so the bean stays readable on a Dark Roast ground.
/// This guard keeps the app's value at the design's.
void main() {
  test('the plate is the paper the design pins', () {
    final source = File('prototype/roasty.jsx').readAsStringSync();
    final declared = RegExp(
      r'--roasty-plate:\s*#([0-9A-Fa-f]{6})',
    ).firstMatch(source);

    expect(declared, isNotNull, reason: 'the design no longer pins a plate');
    expect(
      roastyPlate,
      Color(0xFF000000 | int.parse(declared!.group(1)!, radix: 16)),
    );
  });

  test('the plate does not follow the mood into Dark Roast', () {
    // The point of pinning it: on the dark surface the bean would otherwise
    // sit on a plate the same colour as the ground behind it.
    expect(roastyPlate, isNot(MoodColors.darkRoast.surface));
    expect(roastyPlate, isNot(MoodColors.darkRoast.accent));
  });
}
