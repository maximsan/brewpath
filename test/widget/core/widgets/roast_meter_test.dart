import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/roast_bean.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.cupping,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

/// Keyed by the card it shows, so each pump mounts a fresh meter — except
/// where a test passes one key across two pumps to watch the same meter move.
Widget _meter(int position, {int total = 8, Key? key}) => RoastMeter(
  key: key ?? ValueKey(position),
  position: position,
  total: total,
  semanticsLabel: 'Card $position of $total',
);

/// The colour the bean is actually painted in, read off its painter.
Color _roast(WidgetTester tester) =>
    (tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(RoastBean),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as RoastBeanPainter)
        .roast;

void main() {
  group('the roast', () {
    testWidgets('starts green at the first card of a lesson', (tester) async {
      await tester.pumpWidget(_app(_meter(1), reduceMotion: true));

      expect(_roast(tester), ArtColors.raw);
    });

    testWidgets('reaches espresso on the last card', (tester) async {
      await tester.pumpWidget(_app(_meter(8), reduceMotion: true));

      expect(_roast(tester), ArtColors.roastDark);
    });

    testWidgets('moves on every card of an eight-card lesson', (tester) async {
      final shown = <Color>[];
      for (var position = 1; position <= 8; position++) {
        await tester.pumpWidget(_app(_meter(position), reduceMotion: true));
        shown.add(_roast(tester));
      }

      expect(
        shown.toSet(),
        hasLength(8),
        reason: 'a ramp that snapped between five stops would repeat itself',
      );
    });

    testWidgets('is the same colour in both moods', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.cupping,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: _meter(3)),
          ),
        ),
      );
      final cupping = _roast(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkRoast,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: _meter(3)),
          ),
        ),
      );

      expect(_roast(tester), cupping);
    });

    testWidgets('eases to the next card rather than snapping', (tester) async {
      const same = ValueKey('meter');
      await tester.pumpWidget(_app(_meter(1, key: same)));
      final first = _roast(tester);

      // Same key, so the meter is updated rather than remounted.
      await tester.pumpWidget(_app(_meter(2, key: same)));
      await tester.pump(const Duration(milliseconds: 40));

      final midFlight = _roast(tester);
      expect(midFlight, isNot(first));
      expect(midFlight, isNot(ArtColors.roastAt(1 / 7)));

      await tester.pumpAndSettle();
      expect(_roast(tester), ArtColors.roastAt(1 / 7));
    });

    testWidgets('drops the animator under reduced motion', (tester) async {
      await tester.pumpWidget(_app(_meter(1), reduceMotion: true));

      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      expect(_roast(tester), ArtColors.raw);
    });
  });

  group('the counter', () {
    testWidgets('is zero-padded', (tester) async {
      await tester.pumpWidget(_app(_meter(1), reduceMotion: true));

      expect(find.text('01 / 08'), findsOneWidget);
    });

    testWidgets('reports position only — never a score', (tester) async {
      await tester.pumpWidget(_app(_meter(4), reduceMotion: true));

      expect(find.textContaining('%'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('announces the position it was given', (tester) async {
      await tester.pumpWidget(_app(_meter(4), reduceMotion: true));

      expect(find.bySemanticsLabel('Card 4 of 8'), findsOneWidget);
    });
  });

  testWidgets('draws nothing when there is no run to report', (tester) async {
    await tester.pumpWidget(_app(_meter(0, total: 0), reduceMotion: true));

    expect(find.byType(RoastBean), findsNothing);
  });
}
