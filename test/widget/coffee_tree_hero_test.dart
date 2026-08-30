import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/progress/domain/color_matrix.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openProfile(WidgetTester tester) async {
    // Tall surface so the Profile slivers lay out fully inside the viewport.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
  }

  /// Profile draws two trees since #140 — the hero, and the thumbnail in the
  /// Studio door below it. Every finder here takes the first, which is the
  /// hero.
  Finder hero() => find.byType(CoffeeTree).first;

  String heroAssetName(WidgetTester tester) {
    final image = tester.widget<Image>(
      find.descendant(of: hero(), matching: find.byType(Image)).first,
    );
    return (image.image as AssetImage).assetName;
  }

  testWidgets('a fresh install shows the tree at seed', (tester) async {
    await openProfile(tester);

    expect(find.byType(CoffeeTree), findsWidgets);
    expect(heroAssetName(tester), 'assets/images/trees/1.png');
  });

  testWidgets('the hero renders the stage the snapshot holds', (tester) async {
    // Seed the singleton snapshot row before the app boots, the way a synced
    // device would have left it.
    await tester.runAsync(
      () => SnapshotRepository().write(
        const ProgressSnapshot(
          clearedByReset: ClearedByReset(treeStage: 7),
        ),
      ),
    );

    await openProfile(tester);

    expect(heroAssetName(tester), 'assets/images/trees/7.png');
  });

  testWidgets('a finished learner sees the tree at full growth', (
    tester,
  ) async {
    await tester.runAsync(
      () => SnapshotRepository().write(
        const ProgressSnapshot(clearedByReset: ClearedByReset(treeStage: 10)),
      ),
    );

    await openProfile(tester);

    // Loads the top frame through the real bundle, so an unbundled or
    // mis-copied 10.png fails here rather than shipping green.
    expect(heroAssetName(tester), 'assets/images/trees/10.png');
  });

  testWidgets('a stage above the shipped frames clamps to full growth', (
    tester,
  ) async {
    await tester.runAsync(
      () => SnapshotRepository().write(
        const ProgressSnapshot(clearedByReset: ClearedByReset(treeStage: 12)),
      ),
    );

    await openProfile(tester);

    expect(heroAssetName(tester), 'assets/images/trees/10.png');
  });

  testWidgets('the default grove paints the real art, unwrapped', (
    tester,
  ) async {
    await openProfile(tester);

    // Arabica in Daylight is the shipped illustration as drawn, so neither
    // wrapper should be in the tree at all.
    expect(
      find.descendant(
        of: hero(),
        matching: find.byType(ColorFiltered),
      ),
      findsNothing,
    );
  });

  testWidgets('a planted grove visibly changes the hero', (tester) async {
    await tester.runAsync(
      () => SnapshotRepository().write(
        const ProgressSnapshot(
          clearedByReset: ClearedByReset(treeStage: 7),
          clearedByDeleteOnly: ClearedByDeleteOnly(
            grove: Timestamped(
              value: Grove(variety: 'robusta', light: 'moonlit'),
              updatedAt: 1,
            ),
          ),
        ),
      ),
    );

    await openProfile(tester);

    // Same frame, wearing Robusta's silhouette under Moonlit.
    expect(heroAssetName(tester), 'assets/images/trees/7.png');

    // Robusta is wider than it is tall: scale(1.2, 0.9). Named rather than
    // found by position: the sway nests a second `Transform` around this one.
    final scaled = tester.widget<Transform>(
      find.byKey(CoffeeTree.silhouetteKey).first,
    );
    expect(scaled.transform.storage[0], closeTo(1.2, 1e-9));
    expect(scaled.transform.storage[5], closeTo(0.9, 1e-9));

    final tinted = tester.widget<ColorFiltered>(
      find.descendant(
        of: hero(),
        matching: find.byType(ColorFiltered),
      ),
    );
    expect(
      tinted.colorFilter,
      isNot(const ColorFilter.matrix(identityColorMatrix)),
    );
  });

  testWidgets('the hero announces its stage to screen readers', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.runAsync(
      () => SnapshotRepository().write(
        const ProgressSnapshot(
          clearedByReset: ClearedByReset(treeStage: 7),
        ),
      ),
    );

    await openProfile(tester);

    expect(
      find.bySemanticsLabel('Your coffee tree, stage 7 of 10'),
      findsOneWidget,
    );

    semantics.dispose();
  });
}
