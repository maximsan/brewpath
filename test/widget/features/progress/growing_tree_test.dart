import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/progress/presentation/growing_tree.dart';
import 'package:brew_path/features/progress/presentation/tree_growth_animation.dart';
import 'package:brew_path/features/progress/presentation/tree_growth_painters.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

Widget _host({
  required int fromStage,
  required int toStage,
  VoidCallback? onDone,
  bool reducedMotion = false,
}) => MaterialApp(
  theme: ThemeData(extensions: [MoodColors.cupping]),
  home: Scaffold(
    body: Center(
      child: GrowingTree(
        fromStage: fromStage,
        toStage: toStage,
        onDone: onDone,
      ),
    ),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
    child: child!,
  ),
);

/// Long enough for the whole beat, whatever it drew.
final _wholeBeat = treeGrowthTotal + const Duration(milliseconds: 100);

void main() {
  setUp(useInMemoryDatabase);

  group('a run that grew the tree', () {
    testWidgets('shows both frames while it crosses between them', (
      tester,
    ) async {
      await tester.pumpWidget(_host(fromStage: 3, toStage: 4));
      await tester.pump(treeGrowthDelay + treeCrossfadeDuration ~/ 2);

      final stages = tester
          .widgetList<CoffeeTree>(find.byType(CoffeeTree))
          .map((tree) => tree.stage)
          .toSet();
      expect(stages, {3, 4});

      await tester.pump(_wholeBeat);
    });

    testWidgets('hands over once the beat is done', (tester) async {
      var done = 0;
      await tester.pumpWidget(
        _host(fromStage: 3, toStage: 4, onDone: () => done++),
      );
      await tester.pump();
      expect(done, 0);

      await tester.pump(_wholeBeat);

      expect(done, 1);
    });

    testWidgets('rings and throws leaves', (tester) async {
      await tester.pumpWidget(_host(fromStage: 3, toStage: 4));
      // Just past the landing, where the glow is opening and the first leaves
      // are on their way.
      await tester.pump(
        treeGrowthDelay +
            treeCrossfadeDuration +
            const Duration(
              milliseconds: 200,
            ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is TreeGlowPainter,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is TreeLeafPainter,
        ),
        findsOneWidget,
      );

      await tester.pump(_wholeBeat);
    });
  });

  group('a run that did not', () {
    testWidgets('holds one frame and still hands over', (tester) async {
      var done = 0;
      await tester.pumpWidget(
        _host(fromStage: 4, toStage: 4, onDone: () => done++),
      );
      // The hand-over is scheduled in initState and arrives on the next tick,
      // not inside the first build.
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.byType(CoffeeTree), findsOneWidget);
      expect(done, 1);
    });

    testWidgets('draws no ring and no leaves', (tester) async {
      await tester.pumpWidget(_host(fromStage: 4, toStage: 4));
      await tester.pump(_wholeBeat);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is TreeGlowPainter,
        ),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is TreeLeafPainter,
        ),
        findsNothing,
      );
    });
  });

  // ADR-0011's ruling: the cross-fade survives stillness because a hard cut
  // loses the fact that the tree grew, which is the whole payoff. Everything
  // that moves is dropped — and ⚠️ the callback must still arrive.
  group('reduced motion', () {
    testWidgets('still cross-fades between the two frames', (tester) async {
      await tester.pumpWidget(
        _host(fromStage: 3, toStage: 4, reducedMotion: true),
      );
      await tester.pump(treeGrowthDelay + treeCrossfadeDuration ~/ 2);

      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((widget) => widget.opacity)
          .where((opacity) => opacity > 0 && opacity < 1);
      expect(opacities, isNotEmpty);

      await tester.pump(_wholeBeat);
    });

    testWidgets('drops the ring and the leaves', (tester) async {
      await tester.pumpWidget(
        _host(fromStage: 3, toStage: 4, reducedMotion: true),
      );
      await tester.pump(
        treeGrowthDelay +
            treeCrossfadeDuration +
            const Duration(
              milliseconds: 200,
            ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is TreeGlowPainter,
        ),
        findsNothing,
      );

      await tester.pump(_wholeBeat);
    });

    testWidgets('still hands over', (tester) async {
      var done = 0;
      await tester.pumpWidget(
        _host(
          fromStage: 3,
          toStage: 4,
          reducedMotion: true,
          onDone: () => done++,
        ),
      );
      await tester.pump(_wholeBeat);

      expect(done, 1);
    });
  });

  testWidgets('the ground is drawn whether or not the tree moved', (
    tester,
  ) async {
    await tester.pumpWidget(_host(fromStage: 4, toStage: 4));
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is TreeGroundPainter,
      ),
      findsOneWidget,
    );
  });

  testWidgets('a tree disposed mid-beat never calls back', (tester) async {
    var done = 0;
    await tester.pumpWidget(
      _host(fromStage: 3, toStage: 4, onDone: () => done++),
    );
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(_wholeBeat);

    expect(done, 0);
  });
}
