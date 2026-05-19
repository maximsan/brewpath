import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/app/app.dart';
import 'package:coffee_quest/app/app_router.dart';

Future<ProviderContainer> _pumpApp(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const CoffeeQuestApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('starts on the Learn tab', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Learn — coming soon'), findsOneWidget);
  });

  testWidgets('each destination switches tabs', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.route_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Path — coming soon'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Cards — coming soon'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Profile — coming soon'), findsOneWidget);
  });

  testWidgets('branch navigator stack is preserved across tab switches', (
    tester,
  ) async {
    final container = await _pumpApp(tester);

    // Drill into a Learn sub-route.
    container.read(appRouterProvider).go('/learn/module/module_beans');
    await tester.pumpAndSettle();
    expect(find.text('Module: module_beans'), findsOneWidget);

    // Switch away to Path, then back to Learn.
    await tester.tap(find.byIcon(Icons.route_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Path — coming soon'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();

    // Learn branch retained its stack — still on the module sub-route.
    expect(find.text('Module: module_beans'), findsOneWidget);
  });
}
