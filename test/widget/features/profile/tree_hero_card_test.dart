import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/profile/presentation/widgets/tree_hero_card.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The hero's two derivations: which stage it names, and how it counts the
/// course. Both are the kind of thing that reads fine until the edges.
void main() {
  Future<void> pumpHero(
    WidgetTester tester, {
    required int stage,
    required int completed,
    required int total,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: TreeHeroCard(
            stage: stage,
            treatment: GroveTreatment.identity,
            completed: completed,
            total: total,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );
  }

  group('the count', () {
    testWidgets('reads nothing done at the start', (tester) async {
      await pumpHero(tester, stage: 1, completed: 0, total: 32);

      expect(find.text('0 / 32 CORE LESSONS'), findsOneWidget);
    });

    testWidgets('counts through the middle of the course', (tester) async {
      await pumpHero(tester, stage: 5, completed: 17, total: 32);

      expect(find.text('17 / 32 CORE LESSONS'), findsOneWidget);
    });

    testWidgets('says Fully grown rather than counting to itself', (
      tester,
    ) async {
      await pumpHero(tester, stage: 10, completed: 32, total: 32);

      expect(find.text('FULLY GROWN'), findsOneWidget);
      expect(find.textContaining('32 / 32'), findsNothing);
    });

    testWidgets('does not claim full growth before the course exists', (
      tester,
    ) async {
      // Banks still loading: nothing is known, so nothing is finished.
      await pumpHero(tester, stage: 0, completed: 0, total: 0);

      expect(
        find.text('FULLY GROWN'),
        findsNothing,
        reason: '0 of 0 is an empty course, not a finished one',
      );
    });
  });

  group('the stage line', () {
    testWidgets('shows the drawn stage, not the stored zero', (tester) async {
      // A fresh install stores 0; the art clamps to the seed, and the number
      // beside the name has to agree with it.
      await pumpHero(tester, stage: 0, completed: 0, total: 32);

      expect(find.text('Stage 1 · Seed'), findsOneWidget);
    });

    testWidgets('names the stage it has reached', (tester) async {
      await pumpHero(tester, stage: 7, completed: 20, total: 32);

      expect(find.text('Stage 7 · Turning'), findsOneWidget);
    });
  });

  testWidgets('the whole card is the way through to the tree', (tester) async {
    var opened = false;
    await pumpHero(
      tester,
      stage: 3,
      completed: 5,
      total: 32,
      onTap: () => opened = true,
    );

    await tester.tap(find.byType(TreeHeroCard));

    expect(opened, isTrue);
  });
}
