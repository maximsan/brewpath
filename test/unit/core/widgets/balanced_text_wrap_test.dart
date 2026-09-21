import 'package:brew_path/core/widgets/balanced_text_wrap.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _style = TextStyle(fontSize: 10, height: 1);

/// The Path tab's own title, and a heading long enough that a greedy wrap
/// leaves its last word alone on a line.
const _title = 'Beginner Foundations';
const _orphaning = 'Why two Ethiopias taste different';

List<double> _lineWidthsAt(String text, double box) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: _style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: box);
  final widths = [for (final line in painter.computeLineMetrics()) line.width];
  painter.dispose();
  return widths;
}

double _longestLineAt(String text, double box) =>
    _lineWidthsAt(text, box).reduce((a, b) => a > b ? a : b);

double _shortestLineAt(String text, double box) =>
    _lineWidthsAt(text, box).reduce((a, b) => a < b ? a : b);

double _balanced(String text, double box) => balancedWrapWidth(
  text: text,
  style: _style,
  maxWidth: box,
  textDirection: TextDirection.ltr,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('balancedWrapWidth', () {
    test('leaves a heading that fits on one line the whole box', () {
      expect(_balanced(_title, 1000), 1000);
    });

    test('narrows a heading that wraps', () {
      expect(_balanced(_title, 150), lessThan(150));
    });

    test('keeps the line count it found at the full width', () {
      for (final box in <double>[150, 200, 250, 300]) {
        expect(
          _lineWidthsAt(_orphaning, _balanced(_orphaning, box)).length,
          _lineWidthsAt(_orphaning, box).length,
          reason: 'balancing may even the lines, never add one',
        );
      }
    });

    test('pulls a word down off a long line to sit with the orphan', () {
      const box = 250.0;
      final balanced = _balanced(_orphaning, box);

      expect(_lineWidthsAt(_orphaning, box).length, 2);
      expect(
        _longestLineAt(_orphaning, balanced),
        lessThan(_longestLineAt(_orphaning, box)),
      );
      expect(
        _shortestLineAt(_orphaning, balanced),
        greaterThan(_shortestLineAt(_orphaning, box)),
      );
    });

    test('never returns a width the text would overflow', () {
      for (final box in <double>[150, 200, 250, 300]) {
        final balanced = _balanced(_orphaning, box);
        expect(
          _longestLineAt(_orphaning, balanced),
          lessThanOrEqualTo(balanced),
        );
      }
    });

    test('hands an unbounded or empty box straight back', () {
      expect(_balanced(_title, double.infinity), double.infinity);
      expect(_balanced(_title, 0), 0);
    });

    test('a word wider than the box is left to overflow, not squeezed', () {
      expect(_balanced('Unbreakable', 20), 20);
    });
  });
}
