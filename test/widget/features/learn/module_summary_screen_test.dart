import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/learn/presentation/module_summary_screen.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

final _module = testModule(lessonIds: const ['m1l1']);
final _card = testCoffeeCard(title: 'First Card');

final _summary = ModuleSummary(
  module: _module,
  earnedCards: [_card],
  totalXp: 75,
);

Widget _app(Widget home) => MaterialApp(
  home: home,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
);

void main() {
  testWidgets('renders the companion, total XP and earned cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moduleSummaryProvider('module_beans').overrideWith((ref) => _summary),
          streakProvider.overrideWith((ref) => 0),
          companionLinesProvider.overrideWith(
            (ref) => CompanionLines.fromJson(const {
              'moduleComplete': ['Whole module brewed!'],
            }),
          ),
        ],
        child: _app(const ModuleSummaryScreen(moduleId: 'module_beans')),
      ),
    );
    await tester.pump();

    expect(find.text('Module complete!'), findsOneWidget);
    expect(find.text('Beans'), findsOneWidget);
    expect(find.text('+75 XP'), findsOneWidget);
    expect(find.byType(Companion), findsOneWidget);
    // The earned card surfaces as a badge with its title as the semantic label.
    expect(find.bySemanticsLabel('First Card'), findsOneWidget);
  });
}
