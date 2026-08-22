import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/learn/presentation/module_summary_screen.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

final ModuleModel _module = testModule(lessonIds: const ['m1l1']);
final CoffeeCardModel _card = testCoffeeCard(title: 'First Card');
// The title is the one the bundled bank actually ships. The card's *words*
// are authored content, which this rename does not reach — see #228.
final CoffeeCardModel _moduleReward = testCoffeeCard(
  id: 'cM1',
  title: 'Beans Field Guide',
  lessonId: null,
  moduleId: 'm1',
);

final _summary = ModuleSummary(
  module: _module,
  earnedCards: [_card],
  moduleReward: _moduleReward,
);

Widget _app(Widget home) => MaterialApp(
  home: home,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
);

void main() {
  Widget harness(ModuleSummary summary) => ProviderScope(
    overrides: [
      moduleSummaryProvider('module_beans').overrideWith((ref) => summary),
      streakProvider.overrideWith((ref) => 0),
      companionLinesProvider.overrideWith(
        (ref) => CompanionLines.fromJson(const {
          'moduleComplete': ['Whole module brewed!'],
        }),
      ),
    ],
    child: _app(const ModuleSummaryScreen(moduleId: 'module_beans')),
  );

  testWidgets('renders the companion, Module Reward and earned cards', (
    tester,
  ) async {
    await tester.pumpWidget(harness(_summary));
    await tester.pump();

    expect(find.text('Module complete!'), findsOneWidget);
    expect(find.text('Beans'), findsOneWidget);
    expect(find.byType(Companion), findsOneWidget);
    expect(find.text('Beans Field Guide'), findsOneWidget);
    expect(find.text('Reward unlocked'), findsOneWidget);
    // The earned card surfaces as a badge with its title as the semantic label.
    expect(find.bySemanticsLabel('First Card'), findsOneWidget);
  });

  testWidgets('shows no points line — the module pays nothing', (
    tester,
  ) async {
    await tester.pumpWidget(harness(_summary));
    await tester.pump();

    // The recap used to lead with the module's summed lesson points plus a
    // bonus of twenty-five. The module pays nothing (§5.1, #16).
    expect(find.textContaining('PTS'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
  });

  testWidgets('omits the Module Reward when it has not been collected', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(ModuleSummary(module: _module, earnedCards: [_card])),
    );
    await tester.pump();

    expect(find.text('Reward unlocked'), findsNothing);
    expect(find.text('Module complete!'), findsOneWidget);
  });
}
