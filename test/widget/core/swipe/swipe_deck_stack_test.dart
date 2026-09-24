import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/swipe/swipe_deck_stack.dart';
import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _radius = 20;

Widget _app({
  SwipeDrag drag = const SwipeDrag(),
  bool canAdvance = false,
  bool canBack = false,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: AppTheme.darkRoast,
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 300,
        height: 200,
        child: SwipeDeckStack(
          drag: drag,
          radius: _radius,
          canAdvance: canAdvance,
          canBack: canBack,
        ),
      ),
    ),
  ),
);

Finder get _slivers => find.byType(DecoratedBox);

Rect _sliverRect(WidgetTester tester, int at) =>
    tester.getRect(_slivers.at(at));

void main() {
  testWidgets('one sliver per side that has a card', (tester) async {
    await tester.pumpWidget(_app(canAdvance: true, canBack: true));
    expect(_slivers, findsNWidgets(2));
  });

  testWidgets('no sliver where there is nothing that way', (tester) async {
    await tester.pumpWidget(_app(canAdvance: true));
    expect(_slivers, findsOneWidget);
  });

  testWidgets('an empty deck draws nothing at all', (tester) async {
    await tester.pumpWidget(_app());
    expect(_slivers, findsNothing);
  });

  testWidgets('a sliver rests to the side of the card', (tester) async {
    await tester.pumpWidget(_app(canAdvance: true));
    final box = tester.getRect(find.byType(SwipeDeckStack));

    expect(_sliverRect(tester, 0).right, greaterThan(box.right));
  });

  testWidgets('it comes home as the drag goes its way', (tester) async {
    await tester.pumpWidget(
      _app(
        canAdvance: true,
        drag: const SwipeDrag(offset: -104, phase: SwipePhase.dragging),
      ),
    );
    final box = tester.getRect(find.byType(SwipeDeckStack));

    expect(_sliverRect(tester, 0), box);
  });

  testWidgets('it is drawn at the caller’s radius, in accent, not dimmed', (
    tester,
  ) async {
    await tester.pumpWidget(_app(canAdvance: true));
    final context = tester.element(find.byType(SwipeDeckStack));
    final mood = context.mood;
    final decoration =
        tester.widget<DecoratedBox>(_slivers.first).decoration as BoxDecoration;

    expect(decoration.borderRadius, BorderRadius.circular(_radius));
    expect(decoration.color!.a, 1, reason: 'full opacity, never a dim copy');
    expect(decoration.color, isNot(mood.surface));
    expect(decoration.border!.top.color, isNot(mood.rule));
  });
}
