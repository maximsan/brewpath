import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/swipe/horizontal_swipe.dart';
import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _cardWidth = 300;
const double _cardHeight = 200;
const Key _cardKey = Key('card');

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.darkRoast,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

/// A surface whose card reports the drag it was handed, so a test can read the
/// damped offset and the undamped travel apart.
class _Surface extends StatelessWidget {
  const _Surface({
    this.onAdvance,
    this.onBack,
    this.canAdvance = true,
    this.canBack = true,
    this.motion = const SwipeMotion(),
    this.onTap,
  });

  final VoidCallback? onAdvance;
  final VoidCallback? onBack;
  final bool canAdvance;
  final bool canBack;
  final SwipeMotion motion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => HorizontalSwipe(
    onAdvance: onAdvance,
    onBack: onBack,
    canAdvance: canAdvance,
    canBack: canBack,
    motion: motion,
    builder: (context, drag) => GestureDetector(
      onTap: onTap,
      child: _DragReport(key: _cardKey, drag: drag),
    ),
  );
}

class _DragReport extends StatelessWidget {
  const _DragReport({required this.drag, super.key});

  final SwipeDrag drag;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: swipeCaptionOpacity(drag.travel),
    child: const SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: ColoredBox(color: Color(0xFF123456)),
    ),
  );
}

SwipeDrag _dragOf(WidgetTester tester) =>
    tester.widget<_DragReport>(find.byKey(_cardKey)).drag;

double _cardLeft(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(_cardKey)).dx;

void main() {
  group('the direction contract', () {
    testWidgets('a left swipe past the threshold advances', (tester) async {
      var advanced = 0;
      await tester.pumpWidget(_app(_Surface(onAdvance: () => advanced++)));

      await tester.drag(find.byKey(_cardKey), const Offset(-90, 0));
      await tester.pumpAndSettle();

      expect(advanced, 1);
    });

    testWidgets('a right swipe past the threshold goes back', (tester) async {
      var back = 0;
      await tester.pumpWidget(_app(_Surface(onBack: () => back++)));

      await tester.drag(find.byKey(_cardKey), const Offset(90, 0));
      await tester.pumpAndSettle();

      expect(back, 1);
    });

    testWidgets('short of the threshold nothing fires, and the card '
        'returns to centre', (tester) async {
      var fired = 0;
      final centre = <double>[];
      await tester.pumpWidget(
        _app(_Surface(onAdvance: () => fired++, onBack: () => fired++)),
      );
      centre.add(_cardLeft(tester));

      await tester.drag(find.byKey(_cardKey), const Offset(-40, 0));
      await tester.pumpAndSettle();

      expect(fired, 0);
      expect(_cardLeft(tester), centre.single);
    });
  });

  group('a blocked direction', () {
    testWidgets('damps to 22% instead of going dead', (tester) async {
      await tester.pumpWidget(_app(const _Surface(canAdvance: false)));
      final centre = _cardLeft(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(_cardKey)),
      );
      await gesture.moveBy(const Offset(-60, 0));
      await tester.pump();

      expect(_dragOf(tester).offset, closeTo(-13.2, 0.01));
      expect(_cardLeft(tester), closeTo(centre - 13.2, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('never commits, however far it is dragged', (tester) async {
      var advanced = 0;
      await tester.pumpWidget(
        _app(_Surface(canAdvance: false, onAdvance: () => advanced++)),
      );

      await tester.drag(find.byKey(_cardKey), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(advanced, 0);
    });

    testWidgets('the same holds the other way round', (tester) async {
      var back = 0;
      await tester.pumpWidget(
        _app(_Surface(canBack: false, onBack: () => back++)),
      );

      await tester.drag(find.byKey(_cardKey), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(back, 0);
    });

    testWidgets('reaches full caption opacity on a 60px swipe', (tester) async {
      await tester.pumpWidget(_app(const _Surface(canAdvance: false)));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(_cardKey)),
      );
      await gesture.moveBy(const Offset(-60, 0));
      await tester.pump();

      expect(_dragOf(tester).travel, -60);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('a row, which has no flight', () {
    testWidgets('commits at once and springs home behind the change', (
      tester,
    ) async {
      var back = 0;
      await tester.pumpWidget(_app(_Surface(onBack: () => back++)));
      final centre = _cardLeft(tester);

      await tester.drag(find.byKey(_cardKey), const Offset(90, 0));
      await tester.pump();

      expect(back, 1);
      expect(
        _cardLeft(tester),
        greaterThan(centre),
        reason: 'still on its way home, not teleported',
      );

      await tester.pumpAndSettle();
      expect(_cardLeft(tester), centre);
    });

    testWidgets('reduced motion keeps the spring — it drops the flight, '
        'not the return', (tester) async {
      await tester.pumpWidget(_app(const _Surface(), reduceMotion: true));
      final centre = _cardLeft(tester);

      await tester.drag(find.byKey(_cardKey), const Offset(40, 0));
      await tester.pump();

      expect(_cardLeft(tester), greaterThan(centre));
      await tester.pumpAndSettle();
      expect(_cardLeft(tester), centre);
    });
  });

  group('the fly-off', () {
    const flight = SwipeMotion(exitDistance: 340, tiltDegreesPer100px: 7);

    testWidgets('the card leaves before the content changes', (tester) async {
      var advanced = 0;
      await tester.pumpWidget(
        _app(_Surface(motion: flight, onAdvance: () => advanced++)),
      );
      final centre = _cardLeft(tester);

      await tester.drag(find.byKey(_cardKey), const Offset(-90, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 180));

      expect(advanced, 0, reason: 'still in flight');
      expect(_cardLeft(tester), lessThan(centre - 90));

      await tester.pumpAndSettle();
      expect(advanced, 1);
      expect(_cardLeft(tester), centre, reason: 'landed at centre');
    });

    testWidgets('reduced motion drops the flight and fires at once', (
      tester,
    ) async {
      var advanced = 0;
      await tester.pumpWidget(
        _app(
          _Surface(motion: flight, onAdvance: () => advanced++),
          reduceMotion: true,
        ),
      );

      await tester.drag(find.byKey(_cardKey), const Offset(-90, 0));
      await tester.pump();

      expect(advanced, 1);
      expect(_dragOf(tester).phase, SwipePhase.rest);
      await tester.pumpAndSettle();
    });

    testWidgets('a finger landing mid-flight does not lose the commit', (
      tester,
    ) async {
      var advanced = 0;
      await tester.pumpWidget(
        _app(_Surface(motion: flight, onAdvance: () => advanced++)),
      );
      final centre = _cardLeft(tester);

      await tester.drag(find.byKey(_cardKey), const Offset(-90, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(advanced, 0, reason: 'still in flight');

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HorizontalSwipe)),
      );
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(advanced, 1, reason: 'the flight is presentation only');
      expect(_cardLeft(tester), centre);
    });
  });

  group('the whole element is the target', () {
    testWidgets('a drag starting in the padding still swipes', (tester) async {
      var advanced = 0;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 340,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Surface(onAdvance: () => advanced++),
            ),
          ),
        ),
      );

      final box = tester.getRect(find.byType(HorizontalSwipe));
      await tester.dragFrom(
        Offset(box.right - 2, box.center.dy),
        const Offset(-90, 0),
      );
      await tester.pumpAndSettle();

      expect(advanced, 1);
    });

    testWidgets('a drag does not also fire the element’s tap', (tester) async {
      var tapped = 0;
      var advanced = 0;
      await tester.pumpWidget(
        _app(_Surface(onAdvance: () => advanced++, onTap: () => tapped++)),
      );

      await tester.drag(find.byKey(_cardKey), const Offset(-90, 0));
      await tester.pumpAndSettle();

      expect(advanced, 1);
      expect(tapped, 0);
    });

    testWidgets('a tap still reaches the element', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_app(_Surface(onTap: () => tapped++)));

      await tester.tap(find.byKey(_cardKey));
      await tester.pumpAndSettle();

      expect(tapped, 1);
    });
  });
}
