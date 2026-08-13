import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/bean_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _color = Color(0xFFE07A4F);
const _muted = Color(0xFFB59E84);
const _ink = Color(0xFFF3E7D2);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.darkRoast,
  home: Scaffold(body: Center(child: child)),
);

BeanGauge _gauge(double fill, {double? size}) => BeanGauge(
  fill: fill,
  color: _color,
  muted: _muted,
  ink: _ink,
  size: size ?? 20,
);

void main() {
  testWidgets('takes the size it is given', (tester) async {
    await tester.pumpWidget(_app(_gauge(0.5, size: 32)));

    expect(tester.getSize(find.byType(BeanGauge)), const Size(32, 32));
  });

  testWidgets('paints without error across the whole fill range', (
    tester,
  ) async {
    for (final fill in const [0.0, 0.12, 0.45, 0.6, 0.8, 1.0]) {
      await tester.pumpWidget(_app(_gauge(fill)));
      await tester.pump();

      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('clamps a fill outside 0..1 rather than overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_gauge(1.8)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_app(_gauge(-0.5)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not repaint when nothing changed', (tester) async {
    await tester.pumpWidget(_app(_gauge(0.5)));
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(BeanGauge),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter!;

    await tester.pumpWidget(_app(_gauge(0.5)));
    final same = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(BeanGauge),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter!;

    expect(same.shouldRepaint(painter), isFalse);
  });

  testWidgets('a full bean and an empty bean paint differently', (
    tester,
  ) async {
    // Guards the silhouette rule: at full the outline and crease flip to ink
    // so a solid fill does not dissolve the bean into one flat blob.
    await tester.pumpWidget(_app(_gauge(0)));
    final empty = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(BeanGauge),
        matching: find.byType(CustomPaint),
      ),
    );

    await tester.pumpWidget(_app(_gauge(1)));
    final full = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(BeanGauge),
        matching: find.byType(CustomPaint),
      ),
    );

    expect(full.painter!.shouldRepaint(empty.painter!), isTrue);
  });
}
