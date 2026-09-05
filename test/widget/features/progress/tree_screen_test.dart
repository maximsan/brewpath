import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/progress/presentation/tree_ladder.dart';
import 'package:brew_path/features/progress/presentation/tree_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// The Coffee Tree's own screen: what it says, how it is reached, and the one
/// motion it carries.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough for the whole of Profile, so the tree is not below the fold.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openProfile(WidgetTester tester) async {
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
    await tester.pumpAndSettle();
  }

  /// Settles a screen that never settles.
  ///
  /// The tree sways for as long as it is on screen, so `pumpAndSettle` spins
  /// forever here — the same reason the Tour's tests hand-roll their settle,
  /// and the reason the shared harness does around Roasty's idle loop. Long
  /// enough to cover the route transition.
  Future<void> settleSwaying(WidgetTester tester) async {
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Profile → tap the tree, which is the only way in.
  ///
  /// `.first` because Profile draws two trees since #140: the hero, and the
  /// thumbnail in the Studio door below it. The hero is the one above.
  Future<void> openTree(WidgetTester tester) async {
    await openProfile(tester);
    await tester.tap(find.byType(CoffeeTree).first);
    await settleSwaying(tester);
  }

  /// The rotation the tree is currently drawn at, read off the widget tree
  /// rather than off the controller — the sway is only real if it reaches the
  /// pixels.
  ///
  /// `.first` for the reason [openTree] gives: Profile draws the hero and the
  /// Studio door's thumbnail, and the hero is the one above.
  Matrix4 treeTransform(WidgetTester tester) =>
      tester.widget<Transform>(find.byKey(CoffeeTree.swayKey).first).transform;

  testWidgets('the Profile tree opens the screen', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openProfile(tester);
    expect(find.byType(TreeScreen), findsNothing);

    await tester.tap(find.byType(CoffeeTree).first);
    await settleSwaying(tester);

    expect(find.byType(TreeScreen), findsOneWidget);
  });

  testWidgets('it names the stage, counts the course and draws the ladder', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openTree(tester);

    // A fresh learner is at the seed with nothing finished. The screen's own
    // name is the bar's, and the bar is wordless until the page scrolls, so
    // what titles the page here is the stage the tree has reached (#513).
    expect(find.text('Seed'), findsOneWidget);
    expect(find.text('STAGE 1 OF $treeStageCount'), findsOneWidget);
    expect(find.text('CORE LESSONS COMPLETED'), findsOneWidget);
    expect(find.text('NEXT · SPROUT'), findsOneWidget);
    expect(find.byType(TreeLadder), findsOneWidget);
    expect(find.text('Back to profile'), findsOneWidget);
  });

  testWidgets('the counter reads off the real course, not a constant', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openTree(tester);

    // Asserted as a shape rather than as `0 / 32`: the course is authored
    // content and a lesson added to it must not fail this test.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(r'^0 / [1-9]\d*$').hasMatch(widget.data!),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Back to profile leaves the screen', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openTree(tester);

    await tester.tap(find.text('Back to profile'));
    await settleSwaying(tester);

    expect(find.byType(TreeScreen), findsNothing);
  });

  testWidgets('the tree sways here', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openTree(tester);

    final atRest = treeTransform(tester);
    // A quarter of the way through the sway's six seconds is its steepest
    // stretch, so any movement at all is visible by then.
    await tester.pump(const Duration(milliseconds: 1500));

    expect(treeTransform(tester), isNot(atRest));
  });

  testWidgets('reduced motion holds it upright and still', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openTree(tester);

    final held = treeTransform(tester);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(treeTransform(tester), held);
    // Upright, not frozen mid-lean: a held tilt reads as a rendering bug.
    expect(held, Matrix4.identity());
  });

  testWidgets('the Profile hero stays still even without reduced motion', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openProfile(tester);

    // The design freezes the hero, so the tab does not carry a permanent
    // animation behind everything else on it.
    final held = treeTransform(tester);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(treeTransform(tester), held);
    expect(held, Matrix4.identity());
  });
}
